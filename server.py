from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import sqlite3, hashlib, jwt, os, json, datetime, secrets, string, smtplib, random, requests as req_lib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import anthropic

app = Flask(__name__, static_folder='.')
CORS(app)

# ── CONFIG ──
SECRET_KEY        = os.environ.get('JWT_SECRET', 'stud-secret-key-change-in-prod')
ANTHROPIC_API_KEY = os.environ.get('ANTHROPIC_API_KEY', '')
DB_PATH           = os.environ.get('DB_PATH', 'stud.db')
SMTP_HOST         = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
SMTP_PORT         = int(os.environ.get('SMTP_PORT', '587'))
SMTP_USER         = os.environ.get('SMTP_USER', '')
SMTP_PASS         = os.environ.get('SMTP_PASS', '')
RESEND_API_KEY    = os.environ.get('RESEND_API_KEY', '')
GOOGLE_CLIENT_ID  = os.environ.get('GOOGLE_CLIENT_ID', '')
FROM_EMAIL        = os.environ.get('FROM_EMAIL', 'noreply@coraic.com')
FROM_NAME         = os.environ.get('FROM_NAME', 'Coraic')

# ── DATABASE ──
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    c = conn.cursor()

    c.execute('''CREATE TABLE IF NOT EXISTS users (
        id                   INTEGER PRIMARY KEY AUTOINCREMENT,
        username             TEXT UNIQUE NOT NULL,
        email                TEXT UNIQUE NOT NULL,
        password_hash        TEXT,
        email_verified       INTEGER DEFAULT 0,
        verify_code          TEXT,
        verify_code_expires  TEXT,
        google_id            TEXT,
        created_at           TEXT DEFAULT CURRENT_TIMESTAMP
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

    c.execute('''CREATE TABLE IF NOT EXISTS ai_settings (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id    INTEGER UNIQUE NOT NULL,
        provider   TEXT DEFAULT 'anthropic',
        api_key    TEXT DEFAULT '',
        model      TEXT DEFAULT 'claude-sonnet-4-6',
        style      TEXT DEFAULT 'friendly',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    )''')

    c.execute('''CREATE TABLE IF NOT EXISTS game_memory (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id      INTEGER,
        summary      TEXT DEFAULT '',
        context      TEXT DEFAULT '',
        approved     INTEGER DEFAULT 0,
        updated_at   TEXT DEFAULT CURRENT_TIMESTAMP
    )''')

    # Migrations for existing DBs
    for migration in [
        "ALTER TABLE ai_settings ADD COLUMN style TEXT DEFAULT 'friendly'",
        "ALTER TABLE plugin_keys ADD COLUMN session_expires TEXT",
        "ALTER TABLE users ADD COLUMN email_verified INTEGER DEFAULT 0",
        "ALTER TABLE users ADD COLUMN verify_code TEXT",
        "ALTER TABLE users ADD COLUMN verify_code_expires TEXT",
        "ALTER TABLE users ADD COLUMN google_id TEXT",
    ]:
        try:
            c.execute(migration)
            conn.commit()
        except Exception:
            pass

    # Mark existing users as verified so they don't get locked out
    c.execute("UPDATE users SET email_verified=1 WHERE email_verified IS NULL OR email_verified=0 AND verify_code IS NULL")
    conn.commit()
    conn.close()

init_db()

# ── HELPERS ──
def hash_password(pw):
    return hashlib.sha256(pw.encode()).hexdigest()

def make_token(user_id, username, email):
    payload = {
        'user_id':  user_id,
        'username': username,
        'email':    email,
        'exp':      datetime.datetime.utcnow() + datetime.timedelta(days=30)
    }
    return jwt.encode(payload, SECRET_KEY, algorithm='HS256')

def decode_token(token):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
    except:
        return None

def get_current_user():
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    return decode_token(token)

def generate_plugin_key():
    chars = string.ascii_uppercase + string.digits
    p1 = ''.join(random.choices(chars, k=5))
    p2 = ''.join(random.choices(chars, k=5))
    return f'SC-{p1}-{p2}'

def generate_code():
    return str(random.randint(100000, 999999))

# ── EMAIL VIA RESEND (primary) ──────────────────────────────────
def send_email(to_email, subject, html_body):
    # Try Resend first (recommended)
    if RESEND_API_KEY:
        try:
            r = req_lib.post(
                'https://api.resend.com/emails',
                headers={
                    'Authorization': f'Bearer {RESEND_API_KEY}',
                    'Content-Type': 'application/json'
                },
                json={
                    'from': f'{FROM_NAME} <{FROM_EMAIL}>',
                    'to': [to_email],
                    'subject': subject,
                    'html': html_body
                },
                timeout=10
            )
            if r.status_code in (200, 201):
                print(f'[EMAIL ✓ Resend] To: {to_email}')
                return True
            else:
                print(f'[EMAIL Resend error] {r.status_code}: {r.text}')
        except Exception as e:
            print(f'[EMAIL Resend exception] {e}')

    # Fall back to SMTP
    if SMTP_USER and SMTP_PASS:
        try:
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From']    = f'{FROM_NAME} <{SMTP_USER}>'
            msg['To']      = to_email
            msg.attach(MIMEText(html_body, 'html'))
            s = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
            s.starttls()
            s.login(SMTP_USER, SMTP_PASS)
            s.sendmail(SMTP_USER, to_email, msg.as_string())
            s.quit()
            print(f'[EMAIL ✓ SMTP] To: {to_email}')
            return True
        except Exception as e:
            print(f'[EMAIL SMTP error] {e}')

    # Dev mode — log code to console
    print(f'[EMAIL DEV MODE] No email service configured. To: {to_email} | Subject: {subject}')
    return False

def email_html_base(title, body_html):
    return f"""
    <div style="font-family:'Segoe UI',Arial,sans-serif;background:#09090f;color:#f0f0ff;padding:40px;max-width:480px;margin:0 auto;border-radius:16px;border:1px solid #1e2030;">
      <div style="margin-bottom:28px;display:flex;align-items:center;gap:10px;">
        <div style="width:36px;height:36px;background:linear-gradient(135deg,#ff7a2e,#ff9555);border-radius:9px;display:inline-flex;align-items:center;justify-content:center;">
          <span style="color:#fff;font-weight:900;font-size:14px;">⚡</span>
        </div>
        <span style="font-size:18px;font-weight:800;letter-spacing:-0.3px;">Coraic</span>
      </div>
      {body_html}
      <p style="font-size:11px;color:#3a3a5c;margin-top:28px;line-height:1.6;">Didn't request this? You can safely ignore this email.</p>
    </div>"""

def code_email_html(username, code, purpose='plugin'):
    purpose_text = 'Roblox Studio plugin' if purpose == 'plugin' else 'account'
    return email_html_base('Verification Code', f"""
      <p style="color:#7a8fa8;font-size:13px;margin-bottom:6px;">Hey {username},</p>
      <p style="font-size:15px;margin-bottom:24px;line-height:1.6;">Your {purpose_text} verification code:</p>
      <div style="background:#0d1520;border:1px solid rgba(255,122,46,0.25);border-radius:14px;padding:32px;text-align:center;margin-bottom:24px;">
        <div style="font-size:52px;font-weight:900;letter-spacing:16px;color:#ff7a2e;font-family:monospace;">{code}</div>
        <div style="font-size:11px;color:#4a5a72;margin-top:12px;">Expires in 10 minutes</div>
      </div>
      <p style="font-size:12px;color:#4a5a72;line-height:1.6;">Enter this code to verify your {purpose_text}. Once verified, you'll have permanent access.</p>""")

# ── LEVEL SYSTEM ──
LEVELS = [
    ('Beginner',  0,    100),  ('Learner',   100,  250),
    ('Builder',   250,  500),  ('Developer', 500,  900),
    ('Pro',       900,  1400), ('Expert',    1400, 2000),
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
    text = text.strip()
    if '```' in text:
        parts = text.split('```')
        text = parts[1] if len(parts) > 1 else text
        if text.startswith('json'):
            text = text[4:]
    return text.strip()

def ai_complete(user_id=None, system=None, messages=None, max_tokens=1000):
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
            resp = client.chat.completions.create(model=model or 'gpt-4o', messages=oai_messages, max_tokens=max_tokens)
            return resp.choices[0].message.content
        else:
            client = anthropic.Anthropic(api_key=api_key)
            kwargs = {'model': model or 'claude-sonnet-4-6', 'max_tokens': max_tokens, 'messages': messages}
            if system:
                kwargs['system'] = system
            resp = client.messages.create(**kwargs)
            return resp.content[0].text
    except Exception as e:
        print(f'[AI ERROR] {e}')
        raise

# ── STATIC FILES ──
@app.route('/')
def index():
    return send_from_directory('.', 'landing.html')

@app.route('/<path:filename>')
def static_files(filename):
    return send_from_directory('.', filename)

@app.route('/health')
def health():
    return jsonify({'status': 'ok', 'version': '9.0', 'email_service': 'resend' if RESEND_API_KEY else ('smtp' if SMTP_USER else 'dev_mode')})

@app.route('/admin/delete-all-users', methods=['POST'])
def admin_delete_all_users():
    data = request.json or {}
    if data.get('secret') != 'stud-admin-2024':
        return jsonify({'error': 'Unauthorized'})
    conn = get_db()
    c = conn.cursor()
    c.execute('DELETE FROM plugin_keys')
    c.execute('DELETE FROM profiles')
    c.execute('DELETE FROM users')
    conn.commit()
    conn.close()
    return jsonify({'success': True})

@app.route('/admin/delete-user', methods=['POST'])
def admin_delete_user():
    data = request.json or {}
    email = data.get('email', '').strip().lower()
    if data.get('secret') != 'stud-admin-2024':
        return jsonify({'error': 'Unauthorized'})
    if not email:
        return jsonify({'error': 'Email required'})
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT id FROM users WHERE email=?', (email,))
    user = c.fetchone()
    if not user:
        conn.close()
        return jsonify({'error': 'User not found'})
    uid = user['id']
    c.execute('DELETE FROM plugin_keys WHERE user_id=?', (uid,))
    c.execute('DELETE FROM profiles WHERE user_id=?', (uid,))
    c.execute('DELETE FROM users WHERE id=?', (uid,))
    conn.commit()
    conn.close()
    return jsonify({'success': True, 'deleted': email})

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
        return jsonify({'error': 'All fields are required.'})
    if len(username) < 3:
        return jsonify({'error': 'Username must be at least 3 characters.'})
    if len(password) < 8:
        return jsonify({'error': 'Password must be at least 8 characters.'})
    if '@' not in email:
        return jsonify({'error': 'Enter a valid email address.'})

    verify_code    = generate_code()
    verify_expires = (datetime.datetime.utcnow() + datetime.timedelta(minutes=10)).isoformat()

    conn = get_db()
    try:
        c = conn.cursor()
        c.execute(
            'INSERT INTO users (username, email, password_hash, email_verified, verify_code, verify_code_expires) VALUES (?,?,?,0,?,?)',
            (username, email, hash_password(password), verify_code, verify_expires)
        )
        user_id = c.lastrowid
        c.execute('INSERT INTO profiles (user_id) VALUES (?)', (user_id,))
        conn.commit()
    except sqlite3.IntegrityError as e:
        conn.close()
        if 'username' in str(e).lower():
            return jsonify({'error': 'That username is already taken.'})
        return jsonify({'error': 'That email is already registered.', 'suggest_login': True})
    finally:
        conn.close()

    # Send verification email
    email_sent = send_email(
        email,
        'Verify your Coraic account',
        code_email_html(username, verify_code, purpose='account')
    )

    return jsonify({
        'needs_verification': True,
        'email_preview': email[:3] + '***@' + email.split('@')[1],
        'dev_code': verify_code if not email_sent else None,
        'user_id': user_id
    })

@app.route('/auth/verify-email', methods=['POST'])
def verify_email():
    data    = request.json or {}
    email   = data.get('email',    '').strip().lower()
    code    = data.get('code',     '').strip()
    user_id = data.get('user_id')

    conn = get_db()
    c = conn.cursor()

    if user_id:
        c.execute('SELECT * FROM users WHERE id=?', (user_id,))
    else:
        c.execute('SELECT * FROM users WHERE email=?', (email,))
    user = c.fetchone()

    if not user:
        conn.close()
        return jsonify({'error': 'User not found.'}), 404

    if user['email_verified']:
        # Already verified — just log them in
        token = make_token(user['id'], user['username'], user['email'])
        conn.close()
        return jsonify({'token': token, 'user': {'id': user['id'], 'username': user['username'], 'email': user['email']}})

    if not user['verify_code']:
        conn.close()
        return jsonify({'error': 'No verification pending. Please request a new code.'}), 400

    try:
        expires = datetime.datetime.fromisoformat(user['verify_code_expires'])
        if datetime.datetime.utcnow() > expires:
            conn.close()
            return jsonify({'error': 'Code expired. Request a new one.'}), 400
    except:
        pass

    if user['verify_code'] != code:
        conn.close()
        return jsonify({'error': 'Wrong code. Check your email and try again.'}), 400

    # Mark verified
    c.execute('UPDATE users SET email_verified=1, verify_code=NULL, verify_code_expires=NULL WHERE id=?', (user['id'],))
    conn.commit()

    token = make_token(user['id'], user['username'], user['email'])
    conn.close()
    print(f'[AUTH] ✓ Email verified: {user["email"]}')
    return jsonify({'token': token, 'user': {'id': user['id'], 'username': user['username'], 'email': user['email']}})

@app.route('/auth/resend-verification', methods=['POST'])
def resend_verification():
    data  = request.json or {}
    email = data.get('email', '').strip().lower()
    user_id = data.get('user_id')

    conn = get_db()
    c = conn.cursor()
    if user_id:
        c.execute('SELECT * FROM users WHERE id=?', (user_id,))
    else:
        c.execute('SELECT * FROM users WHERE email=?', (email,))
    user = c.fetchone()

    if not user:
        conn.close()
        return jsonify({'error': 'User not found.'}), 404

    if user['email_verified']:
        conn.close()
        return jsonify({'error': 'Email already verified.'}), 400

    new_code    = generate_code()
    new_expires = (datetime.datetime.utcnow() + datetime.timedelta(minutes=10)).isoformat()
    c.execute('UPDATE users SET verify_code=?, verify_code_expires=? WHERE id=?', (new_code, new_expires, user['id']))
    conn.commit()
    conn.close()

    email_sent = send_email(
        user['email'],
        'Your new Coraic verification code',
        code_email_html(user['username'], new_code, purpose='account')
    )

    return jsonify({
        'success': True,
        'dev_code': new_code if not email_sent else None
    })

@app.route('/auth/login', methods=['POST'])
def login():
    data     = request.json or {}
    email    = data.get('email',    '').strip().lower()
    password = data.get('password', '')

    if not email or not password:
        return jsonify({'error': 'Email and password are required.'})

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT * FROM users WHERE email=? AND password_hash=?', (email, hash_password(password)))
    user = c.fetchone()

    if not user:
        conn.close()
        return jsonify({'error': 'Invalid email or password.'})

    # Check email verified
    if not user['email_verified']:
        # Resend code automatically
        new_code    = generate_code()
        new_expires = (datetime.datetime.utcnow() + datetime.timedelta(minutes=10)).isoformat()
        c.execute('UPDATE users SET verify_code=?, verify_code_expires=? WHERE id=?', (new_code, new_expires, user['id']))
        conn.commit()
        email_sent = send_email(user['email'], 'Verify your Coraic account', code_email_html(user['username'], new_code, purpose='account'))
        conn.close()
        return jsonify({
            'needs_verification': True,
            'user_id': user['id'],
            'email_preview': email[:3] + '***@' + email.split('@')[1],
            'dev_code': new_code if not email_sent else None,
            'error': 'Please verify your email first. We sent a new code.'
        })

    conn.close()
    token = make_token(user['id'], user['username'], user['email'])
    return jsonify({'token': token, 'user': {'id': user['id'], 'username': user['username'], 'email': user['email']}})

# ── GOOGLE OAUTH ──────────────────────────────────────────────
@app.route('/auth/google', methods=['POST'])
def google_auth():
    data     = request.json or {}
    id_token = data.get('credential', '')

    if not id_token:
        return jsonify({'error': 'No Google credential provided.'}), 400

    # Verify with Google
    try:
        r = req_lib.get(f'https://oauth2.googleapis.com/tokeninfo?id_token={id_token}', timeout=10)
        info = r.json()
        if 'error' in info:
            return jsonify({'error': 'Invalid Google token.'}), 401
        if GOOGLE_CLIENT_ID and info.get('aud') != GOOGLE_CLIENT_ID:
            return jsonify({'error': 'Token audience mismatch.'}), 401
    except Exception as e:
        return jsonify({'error': f'Could not verify Google token: {e}'}), 500

    google_id = info.get('sub')
    email     = info.get('email', '').lower()
    name      = info.get('name', email.split('@')[0])
    username  = name.replace(' ', '').lower()[:20]

    if not email or not google_id:
        return jsonify({'error': 'Could not get email from Google.'}), 400

    conn = get_db()
    c = conn.cursor()

    # Find existing user
    c.execute('SELECT * FROM users WHERE email=? OR google_id=?', (email, google_id))
    user = c.fetchone()

    if user:
        # Update google_id and mark verified if not already
        c.execute('UPDATE users SET google_id=?, email_verified=1 WHERE id=?', (google_id, user['id']))
        conn.commit()
        user_id  = user['id']
        username = user['username']
    else:
        # Create new account (Google accounts are auto-verified)
        # Ensure unique username
        base = username
        suffix = 0
        while True:
            try:
                c.execute(
                    'INSERT INTO users (username, email, password_hash, email_verified, google_id) VALUES (?,?,?,1,?)',
                    (username, email, '', google_id)
                )
                break
            except sqlite3.IntegrityError:
                suffix += 1
                username = f'{base}{suffix}'

        user_id = c.lastrowid
        c.execute('INSERT INTO profiles (user_id) VALUES (?)', (user_id,))
        conn.commit()

    conn.close()
    token = make_token(user_id, username, email)
    return jsonify({'token': token, 'user': {'id': user_id, 'username': username, 'email': email}, 'new_user': not bool(user)})

# ── CHECK USERNAME AVAILABILITY ───────────────────
@app.route('/auth/check-username', methods=['GET'])
def check_username():
    username = request.args.get('username', '').strip().lower()
    if not username or len(username) < 3:
        return jsonify({'available': False, 'reason': 'Too short'})
    if len(username) > 20:
        return jsonify({'available': False, 'reason': 'Too long'})
    import re
    if not re.match(r'^[a-z0-9_]+$', username):
        return jsonify({'available': False, 'reason': 'Only letters, numbers and underscores'})
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT id FROM users WHERE LOWER(username)=?', (username,))
    exists = c.fetchone()
    conn.close()
    return jsonify({'available': not bool(exists)})

# ── SET USERNAME (after Google signup) ───────────────────────
@app.route('/auth/set-username', methods=['POST'])
def set_username():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401
    data     = request.json or {}
    username = data.get('username', '').strip().lower()
    if not username or len(username) < 3:
        return jsonify({'error': 'Username must be at least 3 characters.'})
    if len(username) > 20:
        return jsonify({'error': 'Username must be 20 characters or less.'})
    import re
    if not re.match(r'^[a-z0-9_]+$', username):
        return jsonify({'error': 'Only lowercase letters, numbers and underscores allowed.'})
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT id FROM users WHERE LOWER(username)=? AND id!=?', (username, user['user_id']))
    if c.fetchone():
        conn.close()
        return jsonify({'error': 'That username is already taken. Pick another one.'})
    c.execute('UPDATE users SET username=? WHERE id=?', (username, user['user_id']))
    conn.commit()
    # Return fresh token with updated username
    c.execute('SELECT email FROM users WHERE id=?', (user['user_id'],))
    row = c.fetchone()
    conn.close()
    new_token = make_token(user['user_id'], username, row['email'] if row else user['email'])
    return jsonify({'success': True, 'token': new_token, 'username': username})

# ════════════════════════════════════════
# PROFILE
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
    c.execute('SELECT username, email FROM users WHERE id=?', (user_id,))
    u = c.fetchone()
    if u:
        result['username'] = u['username']
        result['email']    = u['email']

    c.execute('SELECT plugin_key, session_token FROM plugin_keys WHERE user_id=?', (user_id,))
    pk = c.fetchone()
    result['plugin_key']       = pk['plugin_key']    if pk else None
    result['plugin_connected'] = bool(pk and pk['session_token'])

    c.execute('SELECT provider, model, api_key, style FROM ai_settings WHERE user_id=?', (user_id,))
    ai = c.fetchone()
    result['ai_provider'] = ai['provider'] if ai else None
    result['ai_model']    = ai['model']    if ai else None
    result['ai_style']    = ai['style']    if ai else 'friendly'
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
    c.execute('SELECT plugin_key FROM plugin_keys WHERE user_id=?', (user_id,))
    existing = c.fetchone()
    if existing:
        conn.close()
        return jsonify({'plugin_key': existing['plugin_key']})

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
        conn.close()
        return jsonify({'error': 'Invalid plugin key. Get yours from the Coraic dashboard.'})

    code    = generate_code()
    expires = (datetime.datetime.utcnow() + datetime.timedelta(minutes=10)).isoformat()
    c.execute('UPDATE plugin_keys SET email_code=?, email_code_expires=? WHERE plugin_key=?', (code, expires, plugin_key))
    conn.commit()
    conn.close()

    email_sent = send_email(
        row['email'],
        f'Coraic Plugin Code: {code}',
        code_email_html(row['username'], code, purpose='plugin')
    )

    email_preview = row['email'][:3] + '***@' + row['email'].split('@')[1]
    return jsonify({
        'success':       True,
        'email_preview': email_preview,
        'dev_code':      code if not email_sent else None
    })

@app.route('/plugin/confirm', methods=['POST'])
def plugin_confirm():
    data       = request.json or {}
    plugin_key = data.get('plugin_key',  '').strip().upper()
    email_code = data.get('email_code',  '').strip()

    if not plugin_key or not email_code:
        return jsonify({'error': 'Missing data.'}), 400

    conn = get_db()
    c = conn.cursor()
    c.execute('''SELECT pk.*, u.username FROM plugin_keys pk JOIN users u ON pk.user_id=u.id
                 WHERE pk.plugin_key=?''', (plugin_key,))
    row = c.fetchone()

    if not row:
        conn.close()
        return jsonify({'error': 'Invalid plugin key.'})
    if not row['email_code']:
        conn.close()
        return jsonify({'error': 'No code pending. Click Connect again.'}), 400

    try:
        expires = datetime.datetime.fromisoformat(row['email_code_expires'])
        if datetime.datetime.utcnow() > expires:
            conn.close()
            return jsonify({'error': 'Code expired. Click Connect again.'}), 400
    except:
        pass

    if row['email_code'] != email_code:
        conn.close()
        return jsonify({'error': 'Wrong code. Check your email.'}), 400

    # Permanent session (100 years)
    session_token   = secrets.token_hex(32)
    session_expires = (datetime.datetime.utcnow() + datetime.timedelta(days=36500)).isoformat()
    c.execute('''UPDATE plugin_keys SET session_token=?, session_expires=?, email_code=NULL, email_code_expires=NULL
                 WHERE plugin_key=?''', (session_token, session_expires, plugin_key))
    conn.commit()
    conn.close()

    print(f'[AUTH] ✓ {row["username"]} permanently connected via plugin key')
    return jsonify({'success': True, 'session_token': session_token, 'username': row['username']})

@app.route('/plugin/session', methods=['POST'])
def plugin_session():
    data          = request.json or {}
    session_token = data.get('session_token', '').strip()
    if not session_token:
        return jsonify({'valid': False})

    conn = get_db()
    c = conn.cursor()
    c.execute('''SELECT pk.session_expires, u.username FROM plugin_keys pk JOIN users u ON pk.user_id=u.id
                 WHERE pk.session_token=?''', (session_token,))
    row = c.fetchone()
    conn.close()

    if not row:
        return jsonify({'valid': False})
    try:
        expires = datetime.datetime.fromisoformat(row['session_expires'])
        if datetime.datetime.utcnow() > expires:
            return jsonify({'valid': False, 'reason': 'expired'})
    except:
        return jsonify({'valid': False})

    return jsonify({'valid': True, 'username': row['username']})

# ════════════════════════════════════════
# AI SETTINGS
# ════════════════════════════════════════

@app.route('/ai/settings', methods=['GET'])
def get_ai_settings():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401
    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT provider, model, api_key, style FROM ai_settings WHERE user_id=?', (user['user_id'],))
    row = c.fetchone()
    conn.close()
    if not row:
        return jsonify({'provider': 'anthropic', 'model': 'claude-sonnet-4-6', 'style': 'friendly', 'has_key': False, 'key_preview': None})
    key = row['api_key'] or ''
    masked = (key[:8] + '...' + key[-4:]) if len(key) > 12 else ('••••••••' if key else None)
    return jsonify({'provider': row['provider'], 'model': row['model'], 'style': row['style'] or 'friendly', 'has_key': bool(key), 'key_preview': masked})

@app.route('/ai/settings', methods=['POST'])
def save_ai_settings():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401
    data     = request.json or {}
    provider = data.get('provider', 'anthropic')
    api_key  = data.get('api_key',  '').strip()
    model    = data.get('model',    'claude-sonnet-4-6')
    style    = data.get('style',    'friendly')
    if not model:
        model = 'claude-sonnet-4-6' if provider == 'anthropic' else 'gpt-4o'
    conn = get_db()
    c = conn.cursor()
    if api_key:
        c.execute('''INSERT INTO ai_settings (user_id, provider, api_key, model, style) VALUES (?,?,?,?,?)
                     ON CONFLICT(user_id) DO UPDATE SET provider=excluded.provider,
                     api_key=excluded.api_key, model=excluded.model, style=excluded.style''',
                  (user['user_id'], provider, api_key, model, style))
    else:
        c.execute('''INSERT INTO ai_settings (user_id, provider, model, style) VALUES (?,?,?,?)
                     ON CONFLICT(user_id) DO UPDATE SET provider=excluded.provider,
                     model=excluded.model, style=excluded.style''',
                  (user['user_id'], provider, model, style))
    conn.commit()
    conn.close()
    return jsonify({'success': True})

@app.route('/ai/test', methods=['POST'])
def test_ai():
    user = get_current_user()
    if not user:
        return jsonify({'error': 'Not authenticated'}), 401
    try:
        output = ai_complete(user_id=user['user_id'], messages=[{'role': 'user', 'content': 'Say "Coraic AI is online!" and nothing else.'}], max_tokens=60)
        return jsonify({'success': True, 'reply': output.strip()})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

# ════════════════════════════════════════
# TUTOR ROUTES
# ════════════════════════════════════════

@app.route('/tutor-chat', methods=['POST'])
def tutor_chat():
    user    = get_current_user()
    user_id = user['user_id'] if user else None
    data    = request.json or {}
    message = data.get('message', '')
    history = data.get('history', [])

    if user_id:
        p  = get_or_create_profile(user_id)
        pd = profile_to_dict(p)
    else:
        pd = {'level': 'Beginner', 'xp': 0, 'topics_struggling': []}

    system = f"""You are Coraic AI, an expert Roblox Lua tutor. Student level: {pd['level']} (XP: {pd['xp']}).
Adapt explanations to their level. Use real Lua code examples. Be encouraging but concise.
Use code blocks for code. Reference Roblox-specific APIs (game:GetService, RemoteEvents, etc).
Struggling topics: {pd['topics_struggling']}."""

    messages = history[-10:] + [{'role': 'user', 'content': message}]
    reply = ai_complete(user_id=user_id, system=system, messages=messages, max_tokens=800)

    if user_id:
        conn = get_db()
        c = conn.cursor()
        c.execute('UPDATE profiles SET xp=xp+5 WHERE user_id=?', (user_id,))
        conn.commit()
        conn.close()
        p2 = get_or_create_profile(user_id)
        return jsonify({'reply': reply, 'profile': profile_to_dict(p2)})

    return jsonify({'reply': reply})

@app.route('/tutor-lesson', methods=['POST'])
def tutor_lesson():
    user    = get_current_user()
    user_id = user['user_id'] if user else None
    data    = request.json or {}
    topic   = data.get('topic', '')

    if user_id:
        p  = get_or_create_profile(user_id)
        pd = profile_to_dict(p)
    else:
        pd = {'level': 'Beginner'}

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'''Create a detailed Roblox Lua lesson on "{topic}" for a {pd["level"]} student.
Use this structure:

# {topic}

## What Is It?
[2-3 sentence overview]

## Core Concept
[Explain clearly]

## Code Example
```lua
[working Lua code]
```

## How It Works
[Line-by-line explanation]

## Practice Exercise
[One hands-on exercise]

## Pro Tip
[One advanced tip]

Write clearly. Use real Roblox APIs.'''}],
        max_tokens=1200)

    if user_id:
        conn = get_db()
        c = conn.cursor()
        c.execute('SELECT lessons_completed FROM profiles WHERE user_id=?', (user_id,))
        row = c.fetchone()
        completed = json.loads(row[0] or '[]')
        if topic not in completed:
            completed.append(topic)
        c.execute('UPDATE profiles SET lessons_completed=?, xp=xp+15 WHERE user_id=?', (json.dumps(completed), user_id))
        conn.commit()
        conn.close()
        p2 = get_or_create_profile(user_id)
        return jsonify({'content': text, 'profile': profile_to_dict(p2)})

    return jsonify({'content': text})

@app.route('/tutor-quiz', methods=['POST'])
def tutor_quiz():
    user    = get_current_user()
    user_id = user['user_id'] if user else None
    data    = request.json or {}
    topic   = data.get('topic', '')

    if user_id:
        p  = get_or_create_profile(user_id)
        pd = profile_to_dict(p)
    else:
        pd = {'level': 'Beginner'}

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'Generate exactly 20 UNIQUE multiple choice Roblox Lua quiz questions for a {pd["level"]} student'
        f'{f" specifically about {topic}" if topic else ", covering a wide variety of topics"}.\n'
        'Rules: Never repeat questions. Each tests a DIFFERENT concept. Vary difficulty.\n'
        'Return ONLY valid JSON array of 20 objects, no markdown:\n'
        '[{"topic":"subtopic","question":"question","code":"lua code or empty string",'
        '"options":["A","B","C","D"],"correct_index":0,"explanation":"why correct"}]'}],
        max_tokens=6000)
    try:
        questions = json.loads(clean_json_response(text))
        if not isinstance(questions, list):
            raise ValueError('not a list')
        for q in questions:
            if 'correct_index' not in q and 'correct' in q:
                letter = str(q['correct']).strip().upper()
                q['correct_index'] = ord(letter[0]) - ord('A') if letter else 0
    except:
        questions = [{'topic': topic or 'Lua', 'question': 'Error generating questions. Please try again.',
                      'code': '', 'options': ['Try again']*4, 'correct_index': 0, 'explanation': 'Please retry.'}]

    return jsonify({'questions': questions})

# ════════════════════════════════════════
# FEEDBACK
# ════════════════════════════════════════

@app.route('/feedback', methods=['POST'])
def feedback():
    data = request.json or {}
    print(f'[FEEDBACK] {data.get("text", data.get("message", ""))[:200]}')
    return jsonify({'success': True})

# ════════════════════════════════════════
# PLUGIN SCRIPT ENDPOINTS
# ════════════════════════════════════════

def get_user_id_from_session(data):
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
    try:
        expires = datetime.datetime.fromisoformat(row['session_expires'])
        if datetime.datetime.utcnow() > expires:
            return None
    except:
        return None
    return row['user_id']

@app.route('/fix-script', methods=['POST'])
def fix_script():
    data              = request.json or {}
    script            = data.get('script', data.get('scriptContent', ''))
    issue             = data.get('issue',  data.get('errorMessage',  ''))
    workspace_context = data.get('workspace_context', data.get('gameContext', ''))
    errors            = data.get('errors', '')
    attempt           = data.get('attempt', 1)
    user_id           = get_user_id_from_session(data)

    prompt = f"""You are an expert Roblox Lua developer. Fix this script.

Attempt: {attempt}/4 | Issue: {issue} | Previous errors: {errors or 'none'}
Game context: {workspace_context[:800] if workspace_context else 'none'}

Script:
{script}

Return ONLY valid JSON:
{{"fixed_script": "complete fixed lua code", "explanation": "what was wrong and what you fixed"}}"""

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content': prompt}], max_tokens=2000)
    try:
        result = json.loads(clean_json_response(text))
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
    data              = request.json or {}
    script_name       = data.get('script_name', data.get('scriptName', 'NewScript'))
    service           = data.get('service', 'ServerScriptService')
    description       = data.get('description', '')
    workspace_context = data.get('workspace_context', '')
    errors            = data.get('errors', '')
    attempt           = data.get('attempt', 1)
    user_id           = get_user_id_from_session(data)

    is_local    = service in ['StarterPlayerScripts', 'StarterGui', 'StarterCharacterScripts']
    script_type = 'LocalScript' if is_local else 'Script'

    prompt = f"""Write a complete Roblox {script_type} for {service}.
Name: {script_name} | Description: {description} | Attempt: {attempt}/4
Previous errors: {errors or 'none'} | Game context: {workspace_context[:800] if workspace_context else 'none'}
Rules: use task.wait(), game:GetService(), proper client/server boundaries, pcall for safety.
Return ONLY valid JSON: {{"script": "complete lua code here"}}"""

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content': prompt}], max_tokens=2000)
    try:
        result = json.loads(clean_json_response(text))
        if 'script' not in result:
            result = {'script': text}
    except:
        result = {'script': text}

    return jsonify(result)

@app.route('/review', methods=['POST'])
def review():
    data         = request.json or {}
    fixed_script = data.get('fixed_script', '')
    issue        = data.get('issue', '')
    user_id      = get_user_id_from_session(data)

    text = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'Review this Roblox Lua code. Issue: {issue}\n\n{fixed_script[:2000]}\n\n'
        'Return ONLY valid JSON:\n{"score": 8, "passed": true, "errors": "none or list issues"}\n'
        'Score 1-10. passed=true if score >= 8.'}], max_tokens=200)
    try:
        result = json.loads(clean_json_response(text))
    except:
        result = {'score': 7, 'passed': False, 'errors': 'Parse error'}

    return jsonify(result)

# ════════════════════════════════════════
# GAME MEMORY
# ════════════════════════════════════════

def get_memory_user_id(data=None):
    if data:
        uid = get_user_id_from_session(data)
        if uid:
            return uid
    return None

@app.route('/scan', methods=['POST'])
def scan():
    data              = request.json or {}
    workspace_context = data.get('workspace_context', '')
    user_id           = get_memory_user_id(data)

    summary = ai_complete(user_id=user_id, messages=[{'role': 'user', 'content':
        f'Analyze this Roblox game workspace. Summarize: game type, main systems, script architecture. Under 150 words.\n\n{workspace_context[:3000]}'}],
        max_tokens=400)

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT id FROM game_memory WHERE user_id IS ?', (user_id,))
    existing = c.fetchone()
    if existing:
        c.execute('UPDATE game_memory SET summary=?, context=?, approved=0, updated_at=CURRENT_TIMESTAMP WHERE user_id IS ?',
                  (summary.strip(), workspace_context[:5000], user_id))
    else:
        c.execute('INSERT INTO game_memory (user_id, summary, context, approved) VALUES (?,?,?,0)',
                  (user_id, summary.strip(), workspace_context[:5000]))
    conn.commit()
    conn.close()
    return jsonify({'summary': summary.strip()})

@app.route('/get-memory', methods=['GET'])
def get_memory():
    session_token = request.args.get('session_token') or request.headers.get('X-Session-Token', '')
    user_id = None
    if session_token:
        conn = get_db()
        c = conn.cursor()
        c.execute('SELECT user_id FROM plugin_keys WHERE session_token=?', (session_token,))
        row = c.fetchone()
        conn.close()
        if row:
            user_id = row['user_id']

    conn = get_db()
    c = conn.cursor()
    c.execute('SELECT summary, approved FROM game_memory WHERE user_id IS ? ORDER BY id DESC LIMIT 1', (user_id,))
    row = c.fetchone()
    conn.close()
    if row:
        return jsonify({'game_summary': row['summary'], 'approved': bool(row['approved'])})
    return jsonify({'game_summary': '', 'approved': False})

@app.route('/approve', methods=['POST'])
def approve():
    data    = request.json or {}
    user_id = get_memory_user_id(data)
    conn = get_db()
    c = conn.cursor()
    c.execute('UPDATE game_memory SET approved=1 WHERE user_id IS ?', (user_id,))
    if c.rowcount == 0:
        conn.close()
        return jsonify({'error': 'No memory to approve'}), 400
    conn.commit()
    conn.close()
    return jsonify({'success': True})

@app.route('/reset-memory', methods=['POST'])
def reset_memory():
    data    = request.json or {}
    user_id = get_memory_user_id(data)
    conn = get_db()
    c = conn.cursor()
    c.execute('DELETE FROM game_memory WHERE user_id IS ?', (user_id,))
    conn.commit()
    conn.close()
    return jsonify({'success': True})

# ════════════════════════════════════════
# MAIN
# ════════════════════════════════════════

if __name__ == '__main__':
    port  = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    print(f'Coraic server v9.0 — port {port}')
    app.run(host='0.0.0.0', port=port, debug=debug)