from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import sqlite3, hashlib, jwt, os, json, datetime, secrets, string, smtplib, random
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import anthropic

app = Flask(__name__, static_folder='.')
CORS(app, origins=["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:5500", "https://nolagjr.github.io"])

# ── CONFIG ──
SECRET_KEY      = os.environ.get('JWT_SECRET', 'stud-secret-key-change-in-prod')
ANTHROPIC_API_KEY = os.environ.get('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', '')
DB_PATH         = 'stud.db'
SMTP_HOST       = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
SMTP_PORT       = int(os.environ.get('SMTP_PORT', '587'))
SMTP_USER       = os.environ.get('SMTP_USER', '')
SMTP_PASS       = os.environ.get('SMTP_PASS', '')

# ── DATABASE ──
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS users (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        username     TEXT UNIQUE NOT NULL,
        email        TEXT UNIQUE NOT NULL,
        password_hash TEXT,
        created_at   TEXT DEFAULT CURRENT_TIMESTAMP
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS profiles (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id           INTEGER UNIQUE NOT NULL,
        xp                INTEGER DEFAULT 0,
        total_fixes       INTEGER DEFAULT 0,
        quiz_correct      INTEGER DEFAULT 0,
        quiz_total        INTEGER DEFAULT 0,
        mistakes          TEXT DEFAULT '[]',
        topics_mastered   TEXT DEFAULT '[]',
        topics_struggling TEXT DEFAULT '[]',
        lessons_completed TEXT DEFAULT '[]',
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    # Plugin keys: SC-XXXXX-XXXXX → email code → session token
    c.execute('''CREATE TABLE IF NOT EXISTS plugin_keys (
        id                  INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id             INTEGER NOT NULL,
        plugin_key          TEXT UNIQUE NOT NULL,
        email_code          TEXT,
        email_code_expires  TEXT,
        session_token       TEXT,
        session_expires     TEXT,
        created_at          TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    # User-supplied AI API keys
    c.execute('''CREATE TABLE IF NOT EXISTS ai_settings (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER UNIQUE NOT NULL,
        provider   TEXT DEFAULT 'anthropic',
        api_key    TEXT DEFAULT '',
        model      TEXT DEFAULT 'claude-opus-4-5',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    conn.commit()
    conn.close()

# ── HELPERS ──
def hash_password(pw):
    return hashlib.sha256(pw.encode()).hexdigest()

def make_token(user_id, username, email):
    payload = {
        'user_id': user_id,
        'username': username,
        'email': email,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=30)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def decode_token(token):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
    except:
        return None

def get_current_user():
    """Extract user from JWT in Authorization header."""
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    return decode_token(token)

def generate_plugin_key():
    chars = string.ascii_uppercase + string.digits
    p1 = ''.join(random.choices(chars, k=5))
    p2 = ''.join(random.choices(chars, k=5))
    return f'SC-{p1}-{p2}'

def generate_email_code():
    return str(random.randint(100000, 999999))

def ai_complete(user_id=None, system=None, messages=None, max_tokens=1000):
    """Universal AI completion — uses user's own key/provider if set, else server Anthropic key."""
    if messages is None:
        messages = []

    provider = 'anthropic'
    api_key  = ANTHROPIC_API_KEY
    model    = None

    if user_id:
        conn = get_db()
        c = conn.cursor()
        c.execute('SELECT provider, api_key, model FROM ai_settings WHERE user_id=?', (user_id,))
        row = c.fetchone()
        conn.close()
        if row and row['api_key']:
            provider = row['provider'] or 'anthropic'
            api_key  = row['api_key']
            model    = row['model']

    try:
        if provider == 'openai':
            try:
                import openai as oai
            except ImportError:
                raise Exception('openai package not installed')
            client = oai.OpenAI(api_key=api_key)
            oai_messages = []
            if system:
                oai_messages.append({'role': 'system', 'content': system})
            oai_messages.extend(messages)
            resp = client.chat.completions.create(
                model=model or 'gpt-4o',
                messages=oai_messages,
                max_tokens=max_tokens
            )
            return resp.choices[0].message.content
        else:
            client = anthropic.Anthropic(api_key=api_key)
            kwargs = {
                'model':      model or 'claude-opus-4-5',
                'max_tokens': max_tokens,
                'messages':   messages
            }
            if system:
                kwargs['system'] = system
            resp = client.messages.create(**kwargs)
            return resp.content[0].text
    except Exception as e:
        print(f'[AI ERROR] {e}')
        raise

# Keep for backwards compat (review/scan use this directly)
def get_ai_client(user_id=None):
    api_key = ANTHROPIC_API_KEY
    if user_id:
        conn = get_db()
        c = conn.cursor()
        c.execute('SELECT api_key, provider FROM ai_settings WHERE user_id=?', (user_id,))
        row = c.fetchone()
        conn.close()
        if row and row['api_key'] and row['provider'] == 'anthropic':
            api_key = row['api_key']
    return anthropic.Anthropic(api_key=api_key)

def send_email(to_email, subject, html_body):
    if not SMTP_USER or not SMTP_PASS:
        print(f'[EMAIL SKIPPED] To: {to_email} | Subject: {subject}')
        return True
    try:
        msg = MIMEMultipart('alternative')
        msg['Subject'] = subject
        msg['From']    = f'Stud AI <{SMTP_USER}>'
        msg['To']      = to_email
        msg.attach(MIMEText(html_body, 'html'))
        s = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
        s.starttls()
        s.login(SMTP_USER, SMTP_PASS)
        s.sendmail(SMTP_USER, to_email, msg.as_string())
        s.quit()
        return True
    except Exception as e:
        print(f'[EMAIL ERROR] {e}')
        return False

def plugin_key_email_html(username, code):
    return f"""
    <div style="font-family:'Courier New',monospace;background:#060b11;color:#ddeeff;padding:40px;border-radius:12px;max-width:480px;margin:0 auto;border:1px solid #162336;">
      <div style="margin-bottom:24px;">
        <div style="width:36px;height:36px;background:linear-gradient(135deg,#2e7fff,#0af0ff);border-radius:8px;display:inline-block;text-align:center;line-height:36px;font-size:16px;font-weight:900;color:white;">S</div>
        <span style="font-size:18px;font-weight:800;margin-left:10px;">Stud<span style="color:#0af0ff;">.</span></span>
      </div>
      <p style="color:#7a8fa8;font-size:13px;margin-bottom:8px;">Hey {username},</p>
      <p style="font-size:15px;margin-bottom:24px;">Your Roblox Studio plugin verification code:</p>
      <div style="background:#0d1520;border:1px solid rgba(46,127,255,0.25);border-radius:10px;padding:28px;text-align:center;margin-bottom:24px;">
        <div style="font-size:42px;font-weight:900;letter-spacing:12px;color:#2e7fff;">{code}</div>
        <div style="font-size:11px;color:#4a5a72;margin-top:10px;">Expires in 10 minutes</div>
      </div>
      <p style="font-size:12px;color:#4a5a72;line-height:1.6;">Enter this in the Stud plugin inside Roblox Studio to finish connecting.</p>
      <p style="font-size:11px;color:#2a3a52;margin-top:16px;">Didn't request this? Ignore this email.</p>
    </div>"""

# ── LEVEL SYSTEM ──
LEVELS = [
    ('Beginner',  0,    100),
    ('Learner',   100,  250),
    ('Builder',   250,  500),
    ('Developer', 500,  900),
    ('Pro',       900,  1400),
    ('Expert',    1400, 2000),
    ('Master',    2000, 999999),
]

def get_level_info(xp):
    for name, low, high in LEVELS:
        if xp < high:
            return name, xp - low, high - low
    return 'Master', xp, 999999

def get_or_create_profile(user_id):
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT * FROM profiles WHERE user_id=?', (user_id,))
    row = c.fetchone()
    if not row:
        c.execute('INSERT INTO profiles (user_id) VALUES (?)', (user_id,))
        conn.commit()
        c.execute('SELECT * FROM profiles WHERE user_id=?', (user_id,))
        row = c.fetchone()
    conn.close()
    return dict(row)

def profile_to_dict(p):
    level, xp_in, xp_next = get_level_info(p['xp'])
    return {
        'level':              level,
        'xp':                 p['xp'],
        'xp_in_level':        xp_in,
        'xp_to_next':         xp_next,
        'total_fixes':        p['total_fixes'],
        'quiz_correct':       p['quiz_correct'],
        'quiz_total':         p['quiz_total'],
        'mistakes':           json.loads(p['mistakes']           or '[]'),
        'topics_mastered':    json.loads(p['topics_mastered']    or '[]'),
        'topics_struggling':  json.loads(p['topics_struggling']  or '[]'),
        'lessons_completed':  json.loads(p['lessons_completed']  or '[]'),
    }

def clean_json_response(text):
    """Strip markdown fences from AI JSON responses."""
    text = text.strip()
    if '```' in text:
        parts = text.split('```')
        text = parts[1] if len(parts) > 1 else text
        if text.startswith('json'):
            text = text[4:]
    return text.strip()

# ── STATIC FILES ──
@app.route('/')
def index():
    return send_from_directory('.', 'landing.html')

@app.route('/<path:filename>')
def static_files(filename):
    return send_from_directory('.', filename)

@app.route('/health')
def health():
    return jsonify({'status': 'ok', 'version': '6.1'})

# ════════════════════════════════════════
# AUTH ROUTES
# ════════════════════════════════════════

@app.route('/auth/signup', methods=['POST'])
def signup():
    data     = request.json or {}
    username = data.get('username', '').strip()
    email    = data.get('email',    '').strip().lower()
    password = data.get('password', '')

    if not username or not email or not password:
        return jsonify({'error': 'All fields are required.'}), 400
    if len(username) < 3:
        return jsonify({'error': 'Username must be at least 3 characters.'}), 400
    if len(password) < 8:
        return jsonify({'error': 'Password must be at least 8 characters.'}), 400
    if '@' not in email:
        return jsonify({'error': 'Enter a valid email address.'}), 400

    conn = get_db()
    try:
        c = conn.cursor()
        c.execute(
            'INSERT INTO users (username, email, password_hash) VALUES (?,?,?)',
            (username, email, hash_password(password))
        )
        user_id = c.lastrowid
        c.execute('INSERT INTO profiles (user_id) VALUES (?)', (user_id,))
        conn.commit()
        token = make_token(user_id, username, email)
        return jsonify({
            'token': token,
            'user':  {'id': user_id, 'username': username, 'email': email}
        })
    except sqlite3.IntegrityError as e:
        if 'username' in str(e):
            return jsonify({'error': 'Username already taken.'}), 409
        return jsonify({'error': 'Email already registered.'}), 409
    finally:
        conn.close()

@app.route('/auth/login', methods=['POST'])
def login():
    data     = request.json or {}
    email    = data.get('email',    '').strip().lower()
    password = data.get('password', '')

    if not email or not password:
        return jsonify({'error': 'Email and password are required.'}), 400

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT * FROM users WHERE email=? AND password_hash=?',
              (email, hash_password(password)))
    user = c.fetchone()
    conn.close()

    if not user:
        return jsonify({'error': 'Invalid email or password.'}), 401

    token = make_token(user['id'], user['username'], user['email'])
    return jsonify({
        'token': token,
        'user':  {'id': user['id'], 'username': user['username'], 'email': user['email']}
    })

# ════════════════════════════════════════
# PROFILE  (uses JWT — no more hardcoded user_id=1)
# ════════════════════════════════════════

@app.route('/get-profile')
def get_profile():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401

    user_id = user['user_id']
    p = get_or_create_profile(user_id)
    result = profile_to_dict(p)

    conn = get_db()
    c = conn.cursor()

    # Attach user info
    c.execute('SELECT username, email FROM users WHERE id=?', (user_id,))
    u = c.fetchone()
    if u:
        result['username'] = u['username']
        result['email']    = u['email']

    # Attach plugin key info
    c.execute('SELECT plugin_key, session_token FROM plugin_keys WHERE user_id=?', (user_id,))
    pk = c.fetchone()
    result['plugin_key']       = pk['plugin_key']    if pk else None
    result['plugin_connected'] = bool(pk and pk['session_token'])

    # Attach AI settings
    c.execute('SELECT provider, model, api_key FROM ai_settings WHERE user_id=?', (user_id,))
    ai = c.fetchone()
    result['ai_provider'] = ai['provider'] if ai else None
    result['ai_model']    = ai['model']    if ai else None
    result['has_ai_key']  = bool(ai and ai['api_key'])

    conn.close()
    return jsonify(result)

# ════════════════════════════════════════
# PLUGIN KEY SYSTEM
# ════════════════════════════════════════

@app.route('/plugin/generate-key', methods=['POST'])
def plugin_generate_key():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401

    user_id = user['user_id']
    conn = get_db()
    c = conn.cursor()

    # Return existing key if they have one
    c.execute('SELECT plugin_key FROM plugin_keys WHERE user_id=?', (user_id,))
    existing = c.fetchone()
    if existing:
        conn.close()
        return jsonify({'plugin_key': existing['plugin_key']})

    # Generate a unique key
    while True:
        key = generate_plugin_key()
        c.execute('SELECT id FROM plugin_keys WHERE plugin_key=?', (key,))
        if not c.fetchone():
            break

    c.execute('INSERT INTO plugin_keys (user_id, plugin_key) VALUES (?,?)', (user_id, key))
    conn.commit()
    conn.close()
    return jsonify({'plugin_key': key})

@app.route('/plugin/get-key', methods=['GET'])
def plugin_get_key():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT plugin_key, session_token FROM plugin_keys WHERE user_id=?', (user['user_id'],))
    row = c.fetchone()
    conn.close()

    if not row:
        return jsonify({'plugin_key': None, 'connected': False})
    return jsonify({'plugin_key': row['plugin_key'], 'connected': bool(row['session_token'])})

@app.route('/plugin/connect', methods=['POST'])
def plugin_connect():
    """Step 1 — plugin sends SC key → server sends 6-digit email code."""
    data       = request.json or {}
    plugin_key = data.get('plugin_key', '').strip().upper()

    if not plugin_key:
        return jsonify({'error': 'No plugin key provided.'}), 400

    conn = get_db()
    c = conn.cursor()
    c.execute('''SELECT pk.*, u.email, u.username
                 FROM plugin_keys pk JOIN users u ON pk.user_id=u.id
                 WHERE pk.plugin_key=?''', (plugin_key,))
    row = c.fetchone()

    if not row:
        return jsonify({'error': 'Invalid plugin key. Get yours from the Stud dashboard.'}), 404

    code    = generate_email_code()
    expires = (datetime.datetime.utcnow() + datetime.timedelta(minutes=10)).isoformat()

    c.execute('UPDATE plugin_keys SET email_code=?, email_code_expires=? WHERE plugin_key=?',
              (code, expires, plugin_key))
    conn.commit()
    conn.close()

    send_email(row['email'],
               f'Stud Plugin Code: {code}',
               plugin_key_email_html(row['username'], code))

    email_preview = row['email'][:3] + '***@' + row['email'].split('@')[1]
    return jsonify({
        'success':       True,
        'email_preview': email_preview,
        'dev_code':      code if not (SMTP_USER and SMTP_PASS) else None
    })

@app.route('/plugin/confirm', methods=['POST'])
def plugin_confirm():
    """Step 2 — plugin sends 6-digit code → server returns session token."""
    data       = request.json or {}
    plugin_key = data.get('plugin_key',  '').strip().upper()
    email_code = data.get('email_code',  '').strip()

    if not plugin_key or not email_code:
        return jsonify({'error': 'Missing data.'}), 400

    conn = get_db()
    c = conn.cursor()
    c.execute('''SELECT pk.*, u.username
                 FROM plugin_keys pk JOIN users u ON pk.user_id=u.id
                 WHERE pk.plugin_key=?''', (plugin_key,))
    row = c.fetchone()

    if not row:
        return jsonify({'error': 'Invalid plugin key.'}), 404
    if not row['email_code']:
        return jsonify({'error': 'No code pending. Start again.'}), 400

    expires = datetime.datetime.fromisoformat(row['email_code_expires'])
    if datetime.datetime.utcnow() > expires:
        conn.close()
        return jsonify({'error': 'Code expired. Click Connect again.'}), 400

    if row['email_code'] != email_code:
        conn.close()
        return jsonify({'error': 'Wrong code. Check your email.'}), 400

    session_token   = secrets.token_hex(32)
    session_expires = (datetime.datetime.utcnow() + datetime.timedelta(days=30)).isoformat()

    c.execute('''UPDATE plugin_keys
                 SET session_token=?, session_expires=?, email_code=NULL
                 WHERE plugin_key=?''', (session_token, session_expires, plugin_key))
    conn.commit()
    conn.close()

    return jsonify({'success': True, 'session_token': session_token, 'username': row['username']})

@app.route('/plugin/session', methods=['POST'])
def plugin_session():
    """Called on Studio startup to check if saved token is still valid."""
    data          = request.json or {}
    session_token = data.get('session_token', '').strip()

    if not session_token:
        return jsonify({'valid': False})

    conn = get_db()
    c = conn.cursor()
    c.execute('''SELECT pk.session_expires, u.username
                 FROM plugin_keys pk JOIN users u ON pk.user_id=u.id
                 WHERE pk.session_token=?''', (session_token,))
    row = c.fetchone()
    conn.close()

    if not row:
        return jsonify({'valid': False})

    expires = datetime.datetime.fromisoformat(row['session_expires'])
    if datetime.datetime.utcnow() > expires:
        return jsonify({'valid': False, 'reason': 'expired'})

    return jsonify({'valid': True, 'username': row['username']})

# ════════════════════════════════════════
# AI SETTINGS  (bring your own API key)
# ════════════════════════════════════════

@app.route('/ai/settings', methods=['GET'])
def get_ai_settings():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT provider, model, api_key FROM ai_settings WHERE user_id=?', (user['user_id'],))
    row = c.fetchone()
    conn.close()

    if not row:
        return jsonify({'provider': None, 'model': None, 'has_key': False, 'key_preview': None})

    key = row['api_key'] or ''
    masked = (key[:8] + '...' + key[-4:]) if len(key) > 12 else ('••••••••' if key else None)
    return jsonify({'provider': row['provider'], 'model': row['model'],
                    'has_key': bool(key), 'key_preview': masked})

@app.route('/ai/settings', methods=['POST'])
def save_ai_settings():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401

    data     = request.json or {}
    provider = data.get('provider', 'anthropic')
    api_key  = data.get('api_key',  '').strip()
    model    = data.get('model',    '')

    if not api_key:
        return jsonify({'error': 'API key is required.'}), 400

    if not model:
        model = 'claude-opus-4-5' if provider == 'anthropic' else 'gpt-4o'

    conn = get_db()
    c = conn.cursor()
    c.execute('''INSERT INTO ai_settings (user_id, provider, api_key, model) VALUES (?,?,?,?)
                 ON CONFLICT(user_id) DO UPDATE SET provider=excluded.provider,
                 api_key=excluded.api_key, model=excluded.model''',
              (user['user_id'], provider, api_key, model))
    conn.commit()
    conn.close()
    return jsonify({'success': True})

@app.route('/ai/test', methods=['POST'])
def test_ai():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401
    try:
        output = ai_complete(
            user_id=user['user_id'],
            messages=[{'role': 'user', 'content': 'Write one line of Roblox Lua that prints Hello World. Code only.'}],
            max_tokens=60
        )
        return jsonify({'success': True, 'output': output.strip()})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

# ════════════════════════════════════════
# TUTOR ROUTES  (all use JWT now)
# ════════════════════════════════════════

@app.route('/tutor-chat', methods=['POST'])
def tutor_chat():
    user    = get_current_user()
    user_id = user['user_id'] if user else 1

    data    = request.json or {}
    message = data.get('message', '')
    history = data.get('history', [])

    p  = get_or_create_profile(user_id)
    pd = profile_to_dict(p)

    system = f"""You are Stud, an expert Roblox Lua tutor. Student level: {pd['level']} (XP: {pd['xp']}).
Adapt explanations to their level. Use real Lua code examples. Be encouraging but concise.
Use code blocks for code. Reference Roblox-specific APIs (game:GetService, RemoteEvents, etc).
Struggling topics: {pd['topics_struggling']}."""

    messages = history[-10:] + [{'role': 'user', 'content': message}]
    reply = ai_complete(user_id=user_id, system=system, messages=messages, max_tokens=800)

    conn = get_db()
    c = conn.cursor()
    c.execute('UPDATE profiles SET xp=xp+5 WHERE user_id=?', (user_id,))
    conn.commit()
    conn.close()

    p2 = get_or_create_profile(user_id)
    return jsonify({'reply': reply, 'profile': profile_to_dict(p2)})

@app.route('/tutor-lesson', methods=['POST'])
def tutor_lesson():
    user    = get_current_user()
    user_id = user['user_id'] if user else 1

    data  = request.json or {}
    topic = data.get('topic', '')

    p  = get_or_create_profile(user_id)
    pd = profile_to_dict(p)

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
            f'Create a Roblox Lua lesson on "{topic}" for a {pd["level"]} student.\n'
            'Return ONLY valid JSON (no markdown):\n'
            '{"title":"...","summary":"one sentence","concept":"2-3 sentences",'
            '"example":"lua code only","explanation":"what the code does",'
            '"practice":"one exercise","tip":"one pro tip"}'}], max_tokens=1000)
    try:
        lesson = json.loads(text)
    except:
        lesson = {'title': topic, 'concept': text, 'summary': f'Learn about {topic}'}

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT lessons_completed FROM profiles WHERE user_id=?', (user_id,))
    row = c.fetchone()
    completed = json.loads(row[0] or '[]')
    if topic not in completed:
        completed.append(topic)
    c.execute('UPDATE profiles SET lessons_completed=?, xp=xp+15 WHERE user_id=?',
              (json.dumps(completed), user_id))
    conn.commit()
    conn.close()

    p2 = get_or_create_profile(user_id)
    return jsonify({'lesson': lesson, 'profile': profile_to_dict(p2)})

@app.route('/tutor-quiz', methods=['POST'])
def tutor_quiz():
    user    = get_current_user()
    user_id = user['user_id'] if user else 1

    data  = request.json or {}
    topic = data.get('topic', '')

    p  = get_or_create_profile(user_id)
    pd = profile_to_dict(p)

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
            f'Create a multiple choice Roblox Lua quiz question for a {pd["level"]} student'
            f'{f" about {topic}" if topic else ""}.\n'
            'Return ONLY valid JSON:\n'
            '{"topic":"topic","question":"the question","code":"optional lua or empty",'
            '"options":["A. ...","B. ...","C. ...","D. ..."],"correct":"A","explanation":"why"}'}],
        max_tokens=600)
    try:
        quiz = json.loads(text)
    except:
        quiz = {'topic': 'Lua Basics', 'question': 'Error generating question.',
                'code': '', 'options': ['A. Try again'], 'correct': 'A', 'explanation': ''}

    return jsonify({'quiz': quiz})

@app.route('/tutor-answer', methods=['POST'])
def tutor_answer():
    user    = get_current_user()
    user_id = user['user_id'] if user else 1

    data    = request.json or {}
    answer  = data.get('answer',  '')
    correct = data.get('correct', '')
    topic   = data.get('topic',   '')

    is_correct = bool(answer and correct and answer[0].upper() == correct.upper())

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT * FROM profiles WHERE user_id=?', (user_id,))
    p = dict(c.fetchone())

    xp_gained = 0
    if is_correct:
        xp_gained = 20
        mastered = json.loads(p['topics_mastered'] or '[]')
        if topic and topic not in mastered:
            mastered.append(topic)
        c.execute('UPDATE profiles SET quiz_correct=quiz_correct+1, quiz_total=quiz_total+1, xp=xp+?, topics_mastered=? WHERE user_id=?',
                  (xp_gained, json.dumps(mastered), user_id))
    else:
        struggling = json.loads(p['topics_struggling'] or '[]')
        if topic and topic not in struggling:
            struggling.append(topic)
        mistakes = json.loads(p['mistakes'] or '[]')
        found = next((m for m in mistakes if m['topic'] == topic), None)
        if found:
            found['count'] += 1
        else:
            mistakes.append({'topic': topic, 'count': 1})
        c.execute('UPDATE profiles SET quiz_total=quiz_total+1, topics_struggling=?, mistakes=? WHERE user_id=?',
                  (json.dumps(struggling), json.dumps(mistakes), user_id))

    old_level = get_level_info(p['xp'])[0]
    conn.commit()
    p2 = get_or_create_profile(user_id)
    new_level = get_level_info(p2['xp'])[0]
    conn.close()

    return jsonify({
        'correct':    is_correct,
        'xp_gained':  xp_gained,
        'leveled_up': old_level != new_level,
        'profile':    profile_to_dict(p2)
    })

# ════════════════════════════════════════
# PLUGIN SCRIPT ENDPOINTS
# ════════════════════════════════════════

def get_user_id_from_session(data):
    """Get user_id from plugin session token if provided."""
    session_token = data.get('session_token', '')
    if not session_token:
        return None
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT user_id, session_expires FROM plugin_keys WHERE session_token=?', (session_token,))
    row = c.fetchone()
    conn.close()
    if not row:
        return None
    expires = datetime.datetime.fromisoformat(row['session_expires'])
    if datetime.datetime.utcnow() > expires:
        return None
    return row['user_id']

@app.route('/fix-script', methods=['POST'])
def fix_script():
    data = request.json or {}
    script            = data.get('script', data.get('scriptContent', ''))
    issue             = data.get('issue',  data.get('errorMessage',  ''))
    workspace_context = data.get('workspace_context', data.get('gameContext', ''))
    errors            = data.get('errors', '')
    attempt           = data.get('attempt', 1)

    user_id = get_user_id_from_session(data)

    prompt = f"""You are an expert Roblox Lua developer. Fix this script.

Attempt: {attempt}/4
Issue: {issue}
Previous errors: {errors or 'none'}
Game context: {workspace_context[:800] if workspace_context else 'none'}

Script:
{script}

Return ONLY valid JSON:
{{"fixed_script": "complete fixed lua code", "explanation": "what was wrong and what you fixed"}}"""

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content': prompt}], max_tokens=2000)
    try:
        result = json.loads(text)
        if 'fixed_script' not in result:
            result = {'fixed_script': text, 'explanation': ''}
    except:
        result = {'fixed_script': text, 'explanation': ''}

    if user_id:
        conn = get_db()
        c = conn.cursor()
        c.execute('UPDATE profiles SET total_fixes=total_fixes+1, xp=xp+10 WHERE user_id=?', (user_id,))
        conn.commit()
        conn.close()

    return jsonify(result)

@app.route('/write-script', methods=['POST'])
def write_script():
    data = request.json or {}
    script_name       = data.get('script_name', data.get('scriptName', 'NewScript'))
    service           = data.get('service', 'ServerScriptService')
    description       = data.get('description', '')
    workspace_context = data.get('workspace_context', '')
    errors            = data.get('errors', '')
    attempt           = data.get('attempt', 1)

    user_id = get_user_id_from_session(data)

    is_local    = service in ['StarterPlayerScripts', 'StarterGui', 'StarterCharacterScripts']
    script_type = 'LocalScript' if is_local else 'Script'

    prompt = f"""Write a complete Roblox {script_type} for {service}.

Name: {script_name}
Description: {description}
Attempt: {attempt}/4
Previous errors: {errors or 'none'}
Game context: {workspace_context[:800] if workspace_context else 'none'}

Rules: use task.wait(), game:GetService(), proper client/server boundaries, pcall for safety.

Return ONLY valid JSON:
{{"script": "complete lua code here"}}"""

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content': prompt}], max_tokens=2000)
    text = clean_json_response(text)
    try:
        result = json.loads(text)
        if 'script' not in result:
            result = {'script': text}
    except:
        result = {'script': text}

    return jsonify(result)

@app.route('/review', methods=['POST'])
def review():
    data = request.json or {}
    fixed_script      = data.get('fixed_script', '')
    issue             = data.get('issue', '')
    workspace_context = data.get('workspace_context', '')
    user_id           = get_user_id_from_session(data)

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'Review this Roblox Lua code. Issue it solved: {issue}\n\n'
        f'{fixed_script[:2000]}\n\n'
        'Return ONLY valid JSON:\n'
        '{"score": 8, "passed": true, "errors": "none or list issues"}\n'
        'Score 1-10. passed=true if score >= 8.'}], max_tokens=200)
    try:
        result = json.loads(text)
    except:
        result = {'score': 7, 'passed': False, 'errors': 'Parse error'}

    return jsonify(result)

@app.route('/scan', methods=['POST'])
def scan():
    data              = request.json or {}
    workspace_context = data.get('workspace_context', '')
    user_id           = get_user_id_from_session(data)

    summary = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'Analyze this Roblox game workspace. Summarize: game type, main systems, '
        f'script architecture. Under 150 words. Be specific.\n\n{workspace_context[:3000]}'}],
        max_tokens=400)
    summary = summary.strip()

    with open('game_memory.json', 'w') as f:
        json.dump({'summary': summary, 'context': workspace_context, 'approved': False}, f)

    return jsonify({'summary': summary})

@app.route('/get-memory', methods=['GET'])
def get_memory():
    try:
        with open('game_memory.json', 'r') as f:
            data = json.load(f)
        return jsonify({'game_summary': data.get('summary', ''), 'approved': data.get('approved', False)})
    except:
        return jsonify({'game_summary': '', 'approved': False})

@app.route('/approve', methods=['POST'])
def approve():
    try:
        with open('game_memory.json', 'r') as f:
            data = json.load(f)
        data['approved'] = True
        with open('game_memory.json', 'w') as f:
            json.dump(data, f)
        return jsonify({'success': True})
    except:
        return jsonify({'error': 'No memory to approve'}), 400

@app.route('/reset-memory', methods=['POST'])
def reset_memory():
    try:
        with open('game_memory.json', 'w') as f:
            json.dump({'summary': '', 'context': '', 'approved': False}, f)
    except:
        pass
    return jsonify({'success': True})

if __name__ == '__main__':
    init_db()
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    print(f'Stud server v7.0 — port {port}')
    app.run(host='0.0.0.0', port=port, debug=debug)