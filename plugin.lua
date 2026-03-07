-- StudCoding Plugin v15 - SC Plugin Key Auth + Public Launch
local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local ScriptContext = game:GetService("ScriptContext")
local TweenService = game:GetService("TweenService")

local toolbar = plugin:CreateToolbar("StudCoding")
local button = toolbar:CreateButton("StudCoding", "Open StudCoding AI", "rbxassetid://4458901886")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, true, false, 340, 700, 300, 400)
local widget = plugin:CreateDockWidgetPluginGui("StudCoding", widgetInfo)
widget.Title = "StudCoding AI"

-- ═══════════════════════════════
-- SOUND
-- ═══════════════════════════════
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://5152885585"
clickSound.Volume = 0.5
clickSound.Parent = widget

local function playClick()
	clickSound:Stop()
	clickSound:Play()
end

-- ═══════════════════════════════
-- THEMES
-- ═══════════════════════════════
local themes = {
	dark = {
		bg       = Color3.fromRGB(8,   13,  20),
		surface  = Color3.fromRGB(11,  18,  28),
		surface2 = Color3.fromRGB(15,  25,  40),
		border   = Color3.fromRGB(22,  38,  60),
		accent   = Color3.fromRGB(46,  127, 255),
		cyan     = Color3.fromRGB(10,  240, 255),
		success  = Color3.fromRGB(0,   229, 160),
		danger   = Color3.fromRGB(255, 69,  103),
		warning  = Color3.fromRGB(255, 184, 48),
		text     = Color3.fromRGB(220, 232, 255),
		muted    = Color3.fromRGB(80,  110, 150),
		white    = Color3.fromRGB(255, 255, 255),
		grid     = Color3.fromRGB(16,  28,  46),
		purple   = Color3.fromRGB(140, 80,  255),
		green    = Color3.fromRGB(0,   180, 100),
		gold     = Color3.fromRGB(255, 200, 50),
	},
	light = {
		bg       = Color3.fromRGB(240, 244, 252),
		surface  = Color3.fromRGB(255, 255, 255),
		surface2 = Color3.fromRGB(230, 236, 248),
		border   = Color3.fromRGB(200, 212, 232),
		accent   = Color3.fromRGB(46,  127, 255),
		cyan     = Color3.fromRGB(0,   180, 220),
		success  = Color3.fromRGB(0,   180, 120),
		danger   = Color3.fromRGB(220, 50,  80),
		warning  = Color3.fromRGB(200, 140, 0),
		text     = Color3.fromRGB(20,  30,  50),
		muted    = Color3.fromRGB(120, 140, 170),
		white    = Color3.fromRGB(20,  30,  50),
		grid     = Color3.fromRGB(220, 228, 244),
		purple   = Color3.fromRGB(120, 60,  220),
		green    = Color3.fromRGB(0,   160, 90),
		gold     = Color3.fromRGB(180, 130, 0),
	}
}

local isDark = true
local C = themes.dark

-- ═══════════════════════════════
-- ROOT
-- ═══════════════════════════════
local root = Instance.new("Frame")
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3 = C.bg
root.BorderSizePixel = 0
root.ClipsDescendants = true
root.Parent = widget

-- ═══════════════════════════════
-- AUTH SCREEN
-- ═══════════════════════════════
-- CHANGE 1: New constants for SC-key auth system
local SESSION_KEY = "stud_session_v3"
local PLUGKEY_KEY = "stud_plugin_key_v3"
local BASE_URL    = "https://studcoding-production.up.railway.app"

local savedSession   = plugin:GetSetting(SESSION_KEY)  or ""
local savedPluginKey = plugin:GetSetting(PLUGKEY_KEY)  or ""

local authScreen = Instance.new("Frame")
authScreen.Size = UDim2.new(1, 0, 1, 0)
authScreen.BackgroundColor3 = C.bg
authScreen.BorderSizePixel = 0
authScreen.ZIndex = 100
authScreen.Visible = true
authScreen.Parent = root

local authLogoMark = Instance.new("Frame")
authLogoMark.Size = UDim2.new(0, 36, 0, 36)
authLogoMark.Position = UDim2.new(0.5, -18, 0, 32)
authLogoMark.BackgroundColor3 = C.accent
authLogoMark.BorderSizePixel = 0
authLogoMark.ZIndex = 101
authLogoMark.Parent = authScreen
local authLogoCorner = Instance.new("UICorner")
authLogoCorner.CornerRadius = UDim.new(0, 8)
authLogoCorner.Parent = authLogoMark

local authLogoTxt = Instance.new("TextLabel")
authLogoTxt.Size = UDim2.new(1, 0, 1, 0)
authLogoTxt.BackgroundTransparency = 1
authLogoTxt.Text = "S."
authLogoTxt.TextColor3 = Color3.new(1, 1, 1)
authLogoTxt.TextSize = 15
authLogoTxt.Font = Enum.Font.GothamBold
authLogoTxt.ZIndex = 102
authLogoTxt.Parent = authLogoMark

local authCard = Instance.new("Frame")
authCard.Size = UDim2.new(1, -32, 0, 0)
authCard.AutomaticSize = Enum.AutomaticSize.Y
authCard.Position = UDim2.new(0, 16, 0, 84)
authCard.BackgroundTransparency = 1
authCard.ZIndex = 101
authCard.Parent = authScreen

local authCardLayout = Instance.new("UIListLayout")
authCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
authCardLayout.Padding = UDim.new(0, 10)
authCardLayout.Parent = authCard

-- ── SCREEN 1: SC Plugin Key ──
-- CHANGE 2: Replaced activation code screen with SC plugin key screen
local screen1 = Instance.new("Frame")
screen1.Size = UDim2.new(1, 0, 0, 0)
screen1.AutomaticSize = Enum.AutomaticSize.Y
screen1.BackgroundTransparency = 1
screen1.LayoutOrder = 1
screen1.Parent = authCard

local s1Layout = Instance.new("UIListLayout")
s1Layout.SortOrder = Enum.SortOrder.LayoutOrder
s1Layout.Padding = UDim.new(0, 8)
s1Layout.Parent = screen1

local authTitle1 = Instance.new("TextLabel")
authTitle1.Size = UDim2.new(1, 0, 0, 22)
authTitle1.BackgroundTransparency = 1
authTitle1.Text = "Connect to Stud"
authTitle1.TextColor3 = C.text
authTitle1.TextSize = 15
authTitle1.Font = Enum.Font.GothamBold
authTitle1.TextXAlignment = Enum.TextXAlignment.Left
authTitle1.LayoutOrder = 1
authTitle1.ZIndex = 102
authTitle1.Parent = screen1

local authSub1 = Instance.new("TextLabel")
authSub1.Size = UDim2.new(1, 0, 0, 36)
authSub1.BackgroundTransparency = 1
authSub1.Text = "Paste your plugin key from the Stud dashboard."
authSub1.TextColor3 = C.muted
authSub1.TextSize = 11
authSub1.Font = Enum.Font.Gotham
authSub1.TextXAlignment = Enum.TextXAlignment.Left
authSub1.TextWrapped = true
authSub1.LayoutOrder = 2
authSub1.ZIndex = 102
authSub1.Parent = screen1

local actWrap = Instance.new("Frame")
actWrap.Size = UDim2.new(1, 0, 0, 36)
actWrap.BackgroundColor3 = C.surface
actWrap.BorderSizePixel = 0
actWrap.LayoutOrder = 3
actWrap.ZIndex = 102
actWrap.Parent = screen1
local actCorner = Instance.new("UICorner")
actCorner.CornerRadius = UDim.new(0, 6)
actCorner.Parent = actWrap
local actStroke = Instance.new("UIStroke")
actStroke.Color = C.border
actStroke.Thickness = 1
actStroke.Parent = actWrap

local actCodeInput = Instance.new("TextBox")
actCodeInput.Size = UDim2.new(1, -16, 1, -8)
actCodeInput.Position = UDim2.new(0, 8, 0, 4)
actCodeInput.BackgroundTransparency = 1
actCodeInput.PlaceholderText = "SC-XXXXX-XXXXX"
actCodeInput.PlaceholderColor3 = C.muted
actCodeInput.Text = savedPluginKey
actCodeInput.TextColor3 = C.text
actCodeInput.TextSize = 12
actCodeInput.Font = Enum.Font.Code
actCodeInput.TextXAlignment = Enum.TextXAlignment.Left
actCodeInput.ClearTextOnFocus = false
actCodeInput.ZIndex = 103
actCodeInput.Parent = actWrap

actCodeInput.Focused:Connect(function()
	TweenService:Create(actStroke, TweenInfo.new(0.15), {Color = C.accent}):Play()
end)
actCodeInput.FocusLost:Connect(function()
	TweenService:Create(actStroke, TweenInfo.new(0.15), {Color = C.border}):Play()
end)

local authError1 = Instance.new("TextLabel")
authError1.Size = UDim2.new(1, 0, 0, 0)
authError1.AutomaticSize = Enum.AutomaticSize.Y
authError1.BackgroundTransparency = 1
authError1.Text = ""
authError1.TextColor3 = C.danger
authError1.TextSize = 11
authError1.Font = Enum.Font.Gotham
authError1.TextXAlignment = Enum.TextXAlignment.Left
authError1.TextWrapped = true
authError1.Visible = false
authError1.LayoutOrder = 4
authError1.ZIndex = 102
authError1.Parent = screen1

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1, 0, 0, 38)
verifyBtn.BackgroundColor3 = C.accent
verifyBtn.TextColor3 = Color3.new(1, 1, 1)
verifyBtn.Text = "Connect →"
verifyBtn.TextSize = 13
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.BorderSizePixel = 0
verifyBtn.AutoButtonColor = false
verifyBtn.LayoutOrder = 5
verifyBtn.ZIndex = 102
verifyBtn.Parent = screen1
local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 6)
verifyCorner.Parent = verifyBtn

verifyBtn.MouseEnter:Connect(function()
	TweenService:Create(verifyBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 145, 255)}):Play()
end)
verifyBtn.MouseLeave:Connect(function()
	TweenService:Create(verifyBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.accent}):Play()
end)
verifyBtn.MouseButton1Down:Connect(function() playClick() end)

local authNote1 = Instance.new("TextLabel")
authNote1.Size = UDim2.new(1, 0, 0, 28)
authNote1.BackgroundTransparency = 1
authNote1.Text = "Get your key: studai.com → Dashboard → Install Plugin"
authNote1.TextColor3 = C.muted
authNote1.TextSize = 10
authNote1.Font = Enum.Font.Gotham
authNote1.TextXAlignment = Enum.TextXAlignment.Center
authNote1.LayoutOrder = 6
authNote1.ZIndex = 102
authNote1.Parent = screen1

-- ── SCREEN 2: Email Code (unchanged from v14) ──
local screen2 = Instance.new("Frame")
screen2.Size = UDim2.new(1, 0, 0, 0)
screen2.AutomaticSize = Enum.AutomaticSize.Y
screen2.BackgroundTransparency = 1
screen2.LayoutOrder = 1
screen2.Visible = false
screen2.Parent = authCard

local s2Layout = Instance.new("UIListLayout")
s2Layout.SortOrder = Enum.SortOrder.LayoutOrder
s2Layout.Padding = UDim.new(0, 8)
s2Layout.Parent = screen2

local authTitle2 = Instance.new("TextLabel")
authTitle2.Size = UDim2.new(1, 0, 0, 22)
authTitle2.BackgroundTransparency = 1
authTitle2.Text = "Check Your Email"
authTitle2.TextColor3 = C.text
authTitle2.TextSize = 15
authTitle2.Font = Enum.Font.GothamBold
authTitle2.TextXAlignment = Enum.TextXAlignment.Left
authTitle2.LayoutOrder = 1
authTitle2.ZIndex = 102
authTitle2.Parent = screen2

local authSub2 = Instance.new("TextLabel")
authSub2.Size = UDim2.new(1, 0, 0, 36)
authSub2.BackgroundTransparency = 1
authSub2.Text = "A 6-digit code was sent to your email. Check spam too."
authSub2.TextColor3 = C.muted
authSub2.TextSize = 11
authSub2.Font = Enum.Font.Gotham
authSub2.TextXAlignment = Enum.TextXAlignment.Left
authSub2.TextWrapped = true
authSub2.LayoutOrder = 2
authSub2.ZIndex = 102
authSub2.Parent = screen2

-- Dev mode hint (shown when SMTP is not configured)
local devHint = Instance.new("TextLabel")
devHint.Size = UDim2.new(1, 0, 0, 0)
devHint.AutomaticSize = Enum.AutomaticSize.Y
devHint.BackgroundTransparency = 1
devHint.Text = ""
devHint.TextColor3 = C.warning
devHint.TextSize = 11
devHint.Font = Enum.Font.GothamBold
devHint.TextXAlignment = Enum.TextXAlignment.Left
devHint.TextWrapped = true
devHint.Visible = false
devHint.LayoutOrder = 3
devHint.ZIndex = 102
devHint.Parent = screen2

local emailWrap = Instance.new("Frame")
emailWrap.Size = UDim2.new(1, 0, 0, 36)
emailWrap.BackgroundColor3 = C.surface
emailWrap.BorderSizePixel = 0
emailWrap.LayoutOrder = 4
emailWrap.ZIndex = 102
emailWrap.Parent = screen2
local emailCorner = Instance.new("UICorner")
emailCorner.CornerRadius = UDim.new(0, 6)
emailCorner.Parent = emailWrap
local emailStroke = Instance.new("UIStroke")
emailStroke.Color = C.border
emailStroke.Thickness = 1
emailStroke.Parent = emailWrap

local emailCodeInput = Instance.new("TextBox")
emailCodeInput.Size = UDim2.new(1, -16, 1, -8)
emailCodeInput.Position = UDim2.new(0, 8, 0, 4)
emailCodeInput.BackgroundTransparency = 1
emailCodeInput.PlaceholderText = "6-digit code"
emailCodeInput.PlaceholderColor3 = C.muted
emailCodeInput.Text = ""
emailCodeInput.TextColor3 = C.text
emailCodeInput.TextSize = 18
emailCodeInput.Font = Enum.Font.GothamBold
emailCodeInput.TextXAlignment = Enum.TextXAlignment.Center
emailCodeInput.ClearTextOnFocus = false
emailCodeInput.ZIndex = 103
emailCodeInput.Parent = emailWrap

emailCodeInput.Focused:Connect(function()
	TweenService:Create(emailStroke, TweenInfo.new(0.15), {Color = C.success}):Play()
end)
emailCodeInput.FocusLost:Connect(function()
	TweenService:Create(emailStroke, TweenInfo.new(0.15), {Color = C.border}):Play()
end)

local authError2 = Instance.new("TextLabel")
authError2.Size = UDim2.new(1, 0, 0, 0)
authError2.AutomaticSize = Enum.AutomaticSize.Y
authError2.BackgroundTransparency = 1
authError2.Text = ""
authError2.TextColor3 = C.danger
authError2.TextSize = 11
authError2.Font = Enum.Font.Gotham
authError2.TextXAlignment = Enum.TextXAlignment.Left
authError2.TextWrapped = true
authError2.Visible = false
authError2.LayoutOrder = 5
authError2.ZIndex = 102
authError2.Parent = screen2

local unlockBtn = Instance.new("TextButton")
unlockBtn.Size = UDim2.new(1, 0, 0, 38)
unlockBtn.BackgroundColor3 = C.success
unlockBtn.TextColor3 = Color3.fromRGB(0, 30, 20)
unlockBtn.Text = "Unlock Plugin →"
unlockBtn.TextSize = 13
unlockBtn.Font = Enum.Font.GothamBold
unlockBtn.BorderSizePixel = 0
unlockBtn.AutoButtonColor = false
unlockBtn.LayoutOrder = 6
unlockBtn.ZIndex = 102
unlockBtn.Parent = screen2
local unlockCorner = Instance.new("UICorner")
unlockCorner.CornerRadius = UDim.new(0, 6)
unlockCorner.Parent = unlockBtn

unlockBtn.MouseEnter:Connect(function()
	TweenService:Create(unlockBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 210, 150)}):Play()
end)
unlockBtn.MouseLeave:Connect(function()
	TweenService:Create(unlockBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.success}):Play()
end)
unlockBtn.MouseButton1Down:Connect(function() playClick() end)

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(1, 0, 0, 28)
backBtn.BackgroundTransparency = 1
backBtn.TextColor3 = C.muted
backBtn.Text = "← Back"
backBtn.TextSize = 11
backBtn.Font = Enum.Font.GothamBold
backBtn.BorderSizePixel = 0
backBtn.AutoButtonColor = false
backBtn.LayoutOrder = 7
backBtn.ZIndex = 102
backBtn.Parent = screen2
backBtn.MouseButton1Down:Connect(function() playClick() end)

-- ── AUTH STATE ──
local pendingPluginKey = ""

local function showAuthScreen(n)
	screen1.Visible = (n == 1)
	screen2.Visible = (n == 2)
end

local function hideAuth()
	TweenService:Create(authScreen, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	task.delay(0.35, function()
		authScreen.Visible = false
	end)
end

local function showAuthError(screen, msg)
	if screen == 1 then
		authError1.Text = msg
		authError1.Visible = true
	else
		authError2.Text = msg
		authError2.Visible = true
	end
end

-- CHANGE 3: New auth flow - SC Plugin Key → /plugin/connect → email code → /plugin/confirm
verifyBtn.MouseButton1Click:Connect(function()
	local key = actCodeInput.Text:match("^%s*(.-)%s*$"):upper()
	if key == "" then
		showAuthError(1, "Paste your plugin key.")
		return
	end
	if not key:match("^SC%-%w+%-%w+$") then
		showAuthError(1, "Format should be SC-XXXXX-XXXXX")
		return
	end
	authError1.Visible = false
	verifyBtn.Text = "Connecting..."
	verifyBtn.BackgroundColor3 = C.surface2

	task.spawn(function()
		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/plugin/connect",
				HttpService:JSONEncode({plugin_key = key}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		verifyBtn.Text = "Connect →"
		TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()

		if not ok then
			showAuthError(1, "Can't connect. Is the server running?")
			return
		end

		local data = HttpService:JSONDecode(result)
		if data.error then
			showAuthError(1, data.error)
			return
		end

		pendingPluginKey = key
		plugin:SetSetting(PLUGKEY_KEY, key)

		if data.email_preview then
			authSub2.Text = "Code sent to " .. data.email_preview .. ". Check spam too."
		end

		-- Dev mode: show code directly if SMTP not configured
		if data.dev_code then
			devHint.Text = "⚡ Dev mode — code: " .. tostring(data.dev_code)
			devHint.Visible = true
		else
			devHint.Visible = false
		end

		emailCodeInput.Text = ""
		authError2.Visible = false
		showAuthScreen(2)
	end)
end)

-- Back button
backBtn.MouseButton1Click:Connect(function()
	showAuthScreen(1)
end)

-- Verify email code → /plugin/confirm → get session token
unlockBtn.MouseButton1Click:Connect(function()
	local code = emailCodeInput.Text:match("^%s*(.-)%s*$")
	if code == "" then
		showAuthError(2, "Enter the 6-digit code from your email.")
		return
	end
	authError2.Visible = false
	unlockBtn.Text = "Unlocking..."
	unlockBtn.BackgroundColor3 = C.surface2

	task.spawn(function()
		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/plugin/confirm",
				HttpService:JSONEncode({
					plugin_key = pendingPluginKey,
					email_code = code
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		unlockBtn.Text = "Unlock Plugin →"
		TweenService:Create(unlockBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.success}):Play()

		if not ok then
			showAuthError(2, "Can't connect. Is the server running?")
			return
		end

		local data = HttpService:JSONDecode(result)
		if data.error then
			showAuthError(2, data.error)
			return
		end

		plugin:SetSetting(SESSION_KEY, data.session_token)
		savedSession = data.session_token
		hideAuth()
	end)
end)

-- Check saved session on open → /plugin/session
local function checkSavedSession()
	if savedSession == "" then
		showAuthScreen(1)
		authScreen.Visible = true
		return
	end

	task.spawn(function()
		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/plugin/session",
				HttpService:JSONEncode({session_token = savedSession}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if ok then
			local data = HttpService:JSONDecode(result)
			if data.valid then
				hideAuth()
				return
			end
		end

		plugin:SetSetting(SESSION_KEY, "")
		savedSession = ""
		showAuthScreen(1)
		authScreen.Visible = true
	end)
end

-- ═══════════════════════════════
-- GRID LINES
-- ═══════════════════════════════
local gridLines = {}
local gridSize = 24
for i = 0, 60 do
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1, 0, 0, 1)
	h.Position = UDim2.new(0, 0, 0, i * gridSize)
	h.BackgroundColor3 = C.grid
	h.BorderSizePixel = 0
	h.ZIndex = 1
	h.Parent = root
	table.insert(gridLines, h)

	local v = Instance.new("Frame")
	v.Size = UDim2.new(0, 1, 1, 0)
	v.Position = UDim2.new(0, i * gridSize, 0, 0)
	v.BackgroundColor3 = C.grid
	v.BorderSizePixel = 0
	v.ZIndex = 1
	v.Parent = root
	table.insert(gridLines, v)
end

-- ═══════════════════════════════
-- TOP GLOW
-- ═══════════════════════════════
local glow = Instance.new("Frame")
glow.Size = UDim2.new(1, 0, 0, 80)
glow.BackgroundColor3 = C.accent
glow.BackgroundTransparency = 0.92
glow.BorderSizePixel = 0
glow.ZIndex = 2
glow.Parent = root

-- ═══════════════════════════════
-- MAIN SCROLL
-- ═══════════════════════════════
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 3
scroll.Parent = root

local mainLayout = Instance.new("UIListLayout")
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding = UDim.new(0, 0)
mainLayout.Parent = scroll

-- ═══════════════════════════════
-- THEME REGISTRY
-- ═══════════════════════════════
local themeRegistry = {}

local function reg(obj, prop, colorKey)
	table.insert(themeRegistry, {obj = obj, prop = prop, key = colorKey})
end

local function applyTheme()
	root.BackgroundColor3 = C.bg
	glow.BackgroundColor3 = C.accent
	scroll.ScrollBarImageColor3 = C.accent
	authScreen.BackgroundColor3 = C.bg
	authLogoMark.BackgroundColor3 = C.accent
	authTitle1.TextColor3 = C.text
	authSub1.TextColor3 = C.muted
	authTitle2.TextColor3 = C.text
	authSub2.TextColor3 = C.muted
	devHint.TextColor3 = C.warning
	actWrap.BackgroundColor3 = C.surface
	actStroke.Color = C.border
	actCodeInput.TextColor3 = C.text
	actCodeInput.PlaceholderColor3 = C.muted
	emailWrap.BackgroundColor3 = C.surface
	emailStroke.Color = C.border
	emailCodeInput.TextColor3 = C.text
	emailCodeInput.PlaceholderColor3 = C.muted
	authError1.TextColor3 = C.danger
	authError2.TextColor3 = C.danger
	verifyBtn.BackgroundColor3 = C.accent
	unlockBtn.BackgroundColor3 = C.success
	backBtn.TextColor3 = C.muted
	authNote1.TextColor3 = C.muted
	for _, gl in ipairs(gridLines) do
		gl.BackgroundColor3 = C.grid
	end
	for _, entry in ipairs(themeRegistry) do
		entry.obj[entry.prop] = C[entry.key]
	end
end

-- ═══════════════════════════════
-- HELPERS
-- ═══════════════════════════════
local function addPadding(parent, top, bottom, left, right)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.PaddingLeft   = UDim.new(0, left   or 0)
	p.PaddingRight  = UDim.new(0, right  or 0)
	p.Parent = parent
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function makeSection(order, pt, pb)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.BackgroundTransparency = 1
	f.LayoutOrder = order
	f.Parent = scroll
	addPadding(f, pt or 12, pb or 0, 14, 14)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 6)
	l.Parent = f
	return f
end

local function makeLabel(text, size, colorKey, parent, order)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, size + 4)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = C[colorKey]
	l.TextSize = size
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = order or 0
	l.Parent = parent
	reg(l, "TextColor3", colorKey)
	return l
end

local function makeInput(placeholder, height, parent, order, multiline)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, height)
	wrap.BackgroundColor3 = C.surface
	wrap.BorderSizePixel = 0
	wrap.LayoutOrder = order or 0
	wrap.Parent = parent
	addCorner(wrap, 6)
	local stroke = addStroke(wrap, C.border, 1)
	reg(wrap, "BackgroundColor3", "surface")
	reg(stroke, "Color", "border")

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -16, 1, -10)
	box.Position = UDim2.new(0, 8, 0, 5)
	box.BackgroundTransparency = 1
	box.TextColor3 = C.text
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = C.muted
	box.Text = ""
	box.TextSize = 12
	box.Font = Enum.Font.Gotham
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.MultiLine = multiline or false
	box.ClearTextOnFocus = false
	box.TextWrapped = true
	box.Parent = wrap
	reg(box, "TextColor3", "text")
	reg(box, "PlaceholderColor3", "muted")

	box.Focused:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Color = C.accent}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), {Color = C.border}):Play()
	end)

	return box, wrap
end

local function makeBtn(text, colorKey, parent, order, height)
	local h = height or 36
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, h)
	btn.BackgroundColor3 = C[colorKey]
	btn.TextColor3 = C.white
	btn.Text = text
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.LayoutOrder = order or 0
	addCorner(btn, 6)
	btn.Parent = parent
	reg(btn, "TextColor3", "white")
	reg(btn, "BackgroundColor3", colorKey)

	btn.MouseEnter:Connect(function()
		local col = C[colorKey]
		TweenService:Create(btn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.new(
				math.min(col.R + 0.08, 1),
				math.min(col.G + 0.08, 1),
				math.min(col.B + 0.08, 1)
			)
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C[colorKey]}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		playClick()
		TweenService:Create(btn, TweenInfo.new(0.06), {Size = UDim2.new(1, 0, 0, h - 2)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, h)}):Play()
	end)

	return btn
end

local function makeSplitBtns(t1, ck1, t2, ck2, parent, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundTransparency = 1
	row.LayoutOrder = order or 0
	row.Parent = parent

	local rl = Instance.new("UIListLayout")
	rl.FillDirection = Enum.FillDirection.Horizontal
	rl.Padding = UDim.new(0, 6)
	rl.Parent = row

	local function makeHalfBtn(text, ck)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5, -3, 1, 0)
		b.BackgroundColor3 = C[ck]
		b.TextColor3 = C.white
		b.Text = text
		b.TextSize = 12
		b.Font = Enum.Font.GothamBold
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		addCorner(b, 6)
		b.Parent = row
		reg(b, "BackgroundColor3", ck)
		reg(b, "TextColor3", "white")
		b.MouseEnter:Connect(function()
			local col = C[ck]
			TweenService:Create(b, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.new(math.min(col.R+0.08,1), math.min(col.G+0.08,1), math.min(col.B+0.08,1))
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = C[ck]}):Play()
		end)
		b.MouseButton1Down:Connect(function()
			playClick()
			TweenService:Create(b, TweenInfo.new(0.06), {Size = UDim2.new(0.5, -3, 1, -2)}):Play()
		end)
		b.MouseButton1Up:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.5, -3, 1, 0)}):Play()
		end)
		return b
	end

	local b1 = makeHalfBtn(t1, ck1)
	local b2 = makeHalfBtn(t2, ck2)
	return b1, b2, row
end

local function makeDivider(order)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1, -28, 0, 1)
	d.Position = UDim2.new(0, 14, 0, 0)
	d.BackgroundColor3 = C.border
	d.BorderSizePixel = 0
	d.LayoutOrder = order
	d.Parent = scroll
	reg(d, "BackgroundColor3", "border")
	return d
end

local function makeDropdown(options, parent, order)
	local selected = options[1]

	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, 34)
	wrap.BackgroundColor3 = C.surface
	wrap.BorderSizePixel = 0
	wrap.LayoutOrder = order or 0
	wrap.Parent = parent
	addCorner(wrap, 6)
	local stroke = addStroke(wrap, C.border, 1)
	reg(wrap, "BackgroundColor3", "surface")
	reg(stroke, "Color", "border")

	local selectedTxt = Instance.new("TextLabel")
	selectedTxt.Size = UDim2.new(1, -30, 1, 0)
	selectedTxt.Position = UDim2.new(0, 10, 0, 0)
	selectedTxt.BackgroundTransparency = 1
	selectedTxt.Text = selected
	selectedTxt.TextColor3 = C.text
	selectedTxt.TextSize = 12
	selectedTxt.Font = Enum.Font.Gotham
	selectedTxt.TextXAlignment = Enum.TextXAlignment.Left
	selectedTxt.Parent = wrap
	reg(selectedTxt, "TextColor3", "text")

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, 20, 1, 0)
	arrow.Position = UDim2.new(1, -24, 0, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "v"
	arrow.TextColor3 = C.muted
	arrow.TextSize = 10
	arrow.Font = Enum.Font.GothamBold
	arrow.Parent = wrap
	reg(arrow, "TextColor3", "muted")

	local optionsFrame = Instance.new("Frame")
	optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
	optionsFrame.BackgroundColor3 = C.surface2
	optionsFrame.BorderSizePixel = 0
	optionsFrame.LayoutOrder = (order or 0) + 1
	optionsFrame.Visible = false
	optionsFrame.ZIndex = 10
	optionsFrame.Parent = parent
	addCorner(optionsFrame, 6)
	local optStroke = addStroke(optionsFrame, C.border, 1)
	reg(optionsFrame, "BackgroundColor3", "surface2")
	reg(optStroke, "Color", "border")

	local optLayout = Instance.new("UIListLayout")
	optLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optLayout.Parent = optionsFrame

	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 30)
		optBtn.BackgroundTransparency = 1
		optBtn.TextColor3 = C.text
		optBtn.Text = opt
		optBtn.TextSize = 12
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.BorderSizePixel = 0
		optBtn.LayoutOrder = i
		optBtn.ZIndex = 10
		addPadding(optBtn, 0, 0, 10, 0)
		optBtn.Parent = optionsFrame
		reg(optBtn, "TextColor3", "text")

		optBtn.MouseEnter:Connect(function()
			TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.surface}):Play()
			optBtn.BackgroundTransparency = 0
		end)
		optBtn.MouseLeave:Connect(function()
			TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.surface2}):Play()
			optBtn.BackgroundTransparency = 1
		end)
		optBtn.MouseButton1Click:Connect(function()
			playClick()
			selected = opt
			selectedTxt.Text = opt
			optionsFrame.Visible = false
			TweenService:Create(arrow, TweenInfo.new(0.15), {TextColor3 = C.accent}):Play()
			task.delay(0.3, function()
				TweenService:Create(arrow, TweenInfo.new(0.15), {TextColor3 = C.muted}):Play()
			end)
		end)
	end

	local clickDetector = Instance.new("TextButton")
	clickDetector.Size = UDim2.new(1, 0, 1, 0)
	clickDetector.BackgroundTransparency = 1
	clickDetector.Text = ""
	clickDetector.BorderSizePixel = 0
	clickDetector.ZIndex = 5
	clickDetector.Parent = wrap
	clickDetector.MouseButton1Click:Connect(function()
		playClick()
		optionsFrame.Visible = not optionsFrame.Visible
		if optionsFrame.Visible then
			TweenService:Create(stroke, TweenInfo.new(0.15), {Color = C.accent}):Play()
		else
			TweenService:Create(stroke, TweenInfo.new(0.15), {Color = C.border}):Play()
		end
	end)

	return wrap, optionsFrame, function() return selected end
end

-- ═══════════════════════════════
-- HEADER
-- ═══════════════════════════════
local headerBg = Instance.new("Frame")
headerBg.Size = UDim2.new(1, 0, 0, 72)
headerBg.BackgroundColor3 = C.surface
headerBg.BackgroundTransparency = 0.2
headerBg.BorderSizePixel = 0
headerBg.LayoutOrder = 1
headerBg.Parent = scroll
local headerStroke = addStroke(headerBg, C.border, 1)
reg(headerBg, "BackgroundColor3", "surface")
reg(headerStroke, "Color", "border")

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.BackgroundColor3 = C.accent
accentLine.BorderSizePixel = 0
accentLine.Parent = headerBg
reg(accentLine, "BackgroundColor3", "accent")

local headerPad = Instance.new("Frame")
headerPad.Size = UDim2.new(1, -28, 1, 0)
headerPad.Position = UDim2.new(0, 14, 0, 0)
headerPad.BackgroundTransparency = 1
headerPad.Parent = headerBg

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 0, 0.4, -4)
dot.BackgroundColor3 = C.accent
dot.BorderSizePixel = 0
dot.Parent = headerPad
addCorner(dot, 99)
reg(dot, "BackgroundColor3", "accent")

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0.5, 0, 0, 22)
brand.Position = UDim2.new(0, 16, 0.2, 0)
brand.BackgroundTransparency = 1
brand.Text = "StudCoding"
brand.TextColor3 = C.text
brand.TextSize = 15
brand.Font = Enum.Font.GothamBold
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = headerPad
reg(brand, "TextColor3", "text")

local pulseBrandRunning = false
local function pulseBrand()
	if pulseBrandRunning then return end
	pulseBrandRunning = true
	while pulseBrandRunning do
		TweenService:Create(brand, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = C.accent}):Play()
		task.wait(1.8)
		if not pulseBrandRunning then break end
		TweenService:Create(brand, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = C.text}):Play()
		task.wait(1.8)
	end
end

local tagline = Instance.new("TextLabel")
tagline.Size = UDim2.new(0.7, 0, 0, 14)
tagline.Position = UDim2.new(0, 16, 0.62, 0)
tagline.BackgroundTransparency = 1
tagline.Text = "Your game. Perfected by AI."
tagline.TextColor3 = C.muted
tagline.TextSize = 10
tagline.Font = Enum.Font.Gotham
tagline.TextXAlignment = Enum.TextXAlignment.Left
tagline.Parent = headerPad
reg(tagline, "TextColor3", "muted")

-- CHANGE 4a: Theme toggle (same position as v14)
local themeToggle = Instance.new("TextButton")
themeToggle.Size = UDim2.new(0, 32, 0, 18)
themeToggle.Position = UDim2.new(1, -138, 0.5, -9)
themeToggle.BackgroundColor3 = C.surface2
themeToggle.TextColor3 = C.muted
themeToggle.Text = "Light"
themeToggle.TextSize = 9
themeToggle.Font = Enum.Font.GothamBold
themeToggle.BorderSizePixel = 0
themeToggle.AutoButtonColor = false
themeToggle.Parent = headerPad
addCorner(themeToggle, 4)
local themeStroke = addStroke(themeToggle, C.border, 1)
reg(themeToggle, "BackgroundColor3", "surface2")
reg(themeToggle, "TextColor3", "muted")
reg(themeStroke, "Color", "border")
themeToggle.MouseButton1Down:Connect(function() playClick() end)
themeToggle.MouseEnter:Connect(function()
	TweenService:Create(themeToggle, TweenInfo.new(0.1), {BackgroundColor3 = C.surface}):Play()
end)
themeToggle.MouseLeave:Connect(function()
	TweenService:Create(themeToggle, TweenInfo.new(0.1), {BackgroundColor3 = C.surface2}):Play()
end)

-- CHANGE 4b: Sign Out button (new for public — users need to be able to log out)
local signOutBtn = Instance.new("TextButton")
signOutBtn.Size = UDim2.new(0, 50, 0, 18)
signOutBtn.Position = UDim2.new(1, -100, 0.5, -9)
signOutBtn.BackgroundTransparency = 1
signOutBtn.TextColor3 = C.muted
signOutBtn.Text = "sign out"
signOutBtn.TextSize = 9
signOutBtn.Font = Enum.Font.GothamBold
signOutBtn.BorderSizePixel = 0
signOutBtn.AutoButtonColor = false
signOutBtn.Parent = headerPad
reg(signOutBtn, "TextColor3", "muted")
signOutBtn.MouseEnter:Connect(function()
	TweenService:Create(signOutBtn, TweenInfo.new(0.1), {TextColor3 = C.danger}):Play()
end)
signOutBtn.MouseLeave:Connect(function()
	TweenService:Create(signOutBtn, TweenInfo.new(0.1), {TextColor3 = C.muted}):Play()
end)
signOutBtn.MouseButton1Click:Connect(function()
	playClick()
	plugin:SetSetting(SESSION_KEY, "")
	plugin:SetSetting(PLUGKEY_KEY, "")
	savedSession = ""
	actCodeInput.Text = ""
	emailCodeInput.Text = ""
	authError1.Visible = false
	authError2.Visible = false
	devHint.Visible = false
	showAuthScreen(1)
	authScreen.BackgroundTransparency = 0
	authScreen.Visible = true
end)

local statusPill = Instance.new("Frame")
statusPill.Size = UDim2.new(0, 58, 0, 18)
statusPill.Position = UDim2.new(1, -44, 0.5, -9)
statusPill.BackgroundColor3 = Color3.fromRGB(15, 35, 20)
statusPill.BorderSizePixel = 0
statusPill.Parent = headerPad
addCorner(statusPill, 99)
local statusStroke = addStroke(statusPill, C.success, 1)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 5, 0, 5)
statusDot.Position = UDim2.new(0, 7, 0.5, -2.5)
statusDot.BackgroundColor3 = C.success
statusDot.BorderSizePixel = 0
statusDot.Parent = statusPill
addCorner(statusDot, 99)

local statusTxt = Instance.new("TextLabel")
statusTxt.Size = UDim2.new(1, -16, 1, 0)
statusTxt.Position = UDim2.new(0, 15, 0, 0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text = "ONLINE"
statusTxt.TextColor3 = C.success
statusTxt.TextSize = 8
statusTxt.Font = Enum.Font.GothamBold
statusTxt.Parent = statusPill

local function pulseStatusDot()
	while true do
		TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 7, 0, 7),
			Position = UDim2.new(0, 6, 0.5, -3.5)
		}):Play()
		task.wait(0.8)
		TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 5, 0, 5),
			Position = UDim2.new(0, 7, 0.5, -2.5)
		}):Play()
		task.wait(0.8)
	end
end

-- ═══════════════════════════════
-- NAV TABS
-- ═══════════════════════════════
local navSection = makeSection(2, 10, 0)

local navRow = Instance.new("Frame")
navRow.Size = UDim2.new(1, 0, 0, 34)
navRow.BackgroundColor3 = C.surface
navRow.BorderSizePixel = 0
navRow.LayoutOrder = 1
navRow.Parent = navSection
addCorner(navRow, 6)
local navStroke = addStroke(navRow, C.border, 1)
reg(navRow, "BackgroundColor3", "surface")
reg(navStroke, "Color", "border")

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navRow

local function makeNavBtn(text, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1/3, 0, 1, 0)
	btn.BackgroundColor3 = C.surface
	btn.TextColor3 = C.muted
	btn.Text = text
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	addCorner(btn, 6)
	btn.Parent = navRow
	reg(btn, "BackgroundColor3", "surface")
	reg(btn, "TextColor3", "muted")
	btn.MouseButton1Down:Connect(function() playClick() end)
	return btn
end

local navFix      = makeNavBtn("Fix",      1)
local navWrite    = makeNavBtn("Write",    2)
local navInsights = makeNavBtn("Insights", 3)

makeDivider(3)

-- ═══════════════════════════════
-- GAME MEMORY SECTION
-- ═══════════════════════════════
local memSection = makeSection(4, 10, 0)
makeLabel("GAME MEMORY", 10, "muted", memSection, 1)

local memCard = Instance.new("Frame")
memCard.Size = UDim2.new(1, 0, 0, 40)
memCard.BackgroundColor3 = C.surface
memCard.BorderSizePixel = 0
memCard.LayoutOrder = 2
memCard.Parent = memSection
addCorner(memCard, 6)
local memStroke = addStroke(memCard, C.border, 1)
reg(memCard, "BackgroundColor3", "surface")
reg(memStroke, "Color", "border")

local memIcon = Instance.new("TextLabel")
memIcon.Size = UDim2.new(0, 30, 1, 0)
memIcon.BackgroundTransparency = 1
memIcon.Text = "—"
memIcon.TextColor3 = C.muted
memIcon.TextSize = 14
memIcon.Font = Enum.Font.GothamBold
memIcon.Parent = memCard
addPadding(memIcon, 0, 0, 10, 0)
reg(memIcon, "TextColor3", "muted")

local memTxt = Instance.new("TextLabel")
memTxt.Size = UDim2.new(1, -40, 1, 0)
memTxt.Position = UDim2.new(0, 32, 0, 0)
memTxt.BackgroundTransparency = 1
memTxt.Text = "No game memory saved"
memTxt.TextColor3 = C.muted
memTxt.TextSize = 11
memTxt.Font = Enum.Font.Gotham
memTxt.TextXAlignment = Enum.TextXAlignment.Left
memTxt.TextTruncate = Enum.TextTruncate.AtEnd
memTxt.Parent = memCard
reg(memTxt, "TextColor3", "muted")

local scanBtn = makeBtn("Deep Scan Workspace", "accent", memSection, 3)

local sumCard = Instance.new("Frame")
sumCard.Size = UDim2.new(1, 0, 0, 0)
sumCard.BackgroundColor3 = C.surface
sumCard.BorderSizePixel = 0
sumCard.ClipsDescendants = true
sumCard.LayoutOrder = 4
sumCard.Parent = memSection
addCorner(sumCard, 6)
local sumStroke = addStroke(sumCard, C.border, 1)
reg(sumCard, "BackgroundColor3", "surface")
reg(sumStroke, "Color", "border")

local sumTxt = Instance.new("TextLabel")
sumTxt.Size = UDim2.new(1, -16, 1, -16)
sumTxt.Position = UDim2.new(0, 8, 0, 8)
sumTxt.BackgroundTransparency = 1
sumTxt.Text = ""
sumTxt.TextColor3 = C.text
sumTxt.TextSize = 11
sumTxt.Font = Enum.Font.Gotham
sumTxt.TextXAlignment = Enum.TextXAlignment.Left
sumTxt.TextYAlignment = Enum.TextYAlignment.Top
sumTxt.TextWrapped = true
sumTxt.Parent = sumCard
reg(sumTxt, "TextColor3", "text")

local approveBtn, rejectBtn, approveRow = makeSplitBtns(
	"Correct", "success",
	"Wrong",   "danger",
	memSection, 5
)
approveRow.Visible = false

makeDivider(5)

-- ═══════════════════════════════
-- FIX PANEL
-- ═══════════════════════════════
local fixPanel = makeSection(6, 10, 14)

makeLabel("SCRIPT NAME", 10, "muted", fixPanel, 1)
local scriptBox, _ = makeInput("e.g. ShopHandler", 34, fixPanel, 2, false)

makeLabel("DESCRIBE THE ISSUE", 10, "muted", fixPanel, 3)
local issueBox, _ = makeInput("e.g. Players are not getting coins...", 72, fixPanel, 4, true)

local attemptsCard = Instance.new("Frame")
attemptsCard.Size = UDim2.new(1, 0, 0, 0)
attemptsCard.BackgroundColor3 = C.surface
attemptsCard.BorderSizePixel = 0
attemptsCard.ClipsDescendants = true
attemptsCard.LayoutOrder = 5
attemptsCard.Parent = fixPanel
addCorner(attemptsCard, 6)
local attStroke = addStroke(attemptsCard, C.border, 1)
reg(attemptsCard, "BackgroundColor3", "surface")
reg(attStroke, "Color", "border")

local attemptsTxt = Instance.new("TextLabel")
attemptsTxt.Size = UDim2.new(1, -16, 1, -12)
attemptsTxt.Position = UDim2.new(0, 8, 0, 6)
attemptsTxt.BackgroundTransparency = 1
attemptsTxt.Text = ""
attemptsTxt.TextColor3 = C.warning
attemptsTxt.TextSize = 11
attemptsTxt.Font = Enum.Font.GothamBold
attemptsTxt.TextXAlignment = Enum.TextXAlignment.Left
attemptsTxt.Parent = attemptsCard
reg(attemptsTxt, "TextColor3", "warning")

local fixBtn   = makeBtn("Fix Script",             "accent",  fixPanel, 6, 40)
local watchBtn = makeBtn("Run + Watch for Errors", "green",   fixPanel, 7, 36)

local watchCard = Instance.new("Frame")
watchCard.Size = UDim2.new(1, 0, 0, 0)
watchCard.BackgroundColor3 = C.surface
watchCard.BorderSizePixel = 0
watchCard.ClipsDescendants = true
watchCard.LayoutOrder = 8
watchCard.Parent = fixPanel
addCorner(watchCard, 6)
local watchStroke = addStroke(watchCard, C.border, 1)
reg(watchCard, "BackgroundColor3", "surface")
reg(watchStroke, "Color", "border")

local watchTxt = Instance.new("TextLabel")
watchTxt.Size = UDim2.new(1, -16, 1, -12)
watchTxt.Position = UDim2.new(0, 8, 0, 6)
watchTxt.BackgroundTransparency = 1
watchTxt.Text = ""
watchTxt.TextColor3 = C.success
watchTxt.TextSize = 11
watchTxt.Font = Enum.Font.GothamBold
watchTxt.TextXAlignment = Enum.TextXAlignment.Left
watchTxt.Parent = watchCard
reg(watchTxt, "TextColor3", "success")

local stopWatchBtn = makeBtn("Stop Watching", "danger", fixPanel, 9, 30)
stopWatchBtn.Visible = false
stopWatchBtn.TextSize = 11

local clearFixBtn = makeBtn("Clear", "surface", fixPanel, 10, 28)
clearFixBtn.TextColor3 = C.muted
clearFixBtn.TextSize = 11
local clearFixStroke = addStroke(clearFixBtn, C.border, 1)
reg(clearFixBtn, "TextColor3", "muted")
reg(clearFixStroke, "Color", "border")

-- ═══════════════════════════════
-- WRITE PANEL
-- ═══════════════════════════════
local writePanel = makeSection(6, 10, 14)
writePanel.Visible = false

makeLabel("SCRIPT NAME", 10, "muted", writePanel, 1)
local writeNameBox, _ = makeInput("e.g. CoinGiver", 34, writePanel, 2, false)

makeLabel("WHERE DOES IT GO", 10, "muted", writePanel, 3)
local serviceOptions = {
	"ServerScriptService",
	"StarterPlayerScripts",
	"StarterGui",
	"ReplicatedStorage",
	"ServerStorage",
	"StarterCharacterScripts"
}
local _, serviceDropdown, getService = makeDropdown(serviceOptions, writePanel, 4)

makeLabel("DESCRIBE WHAT IT SHOULD DO", 10, "muted", writePanel, 6)
local descBox, _ = makeInput("e.g. Give players 10 coins every 30 seconds...", 100, writePanel, 7, true)

local writeAttemptsCard = Instance.new("Frame")
writeAttemptsCard.Size = UDim2.new(1, 0, 0, 0)
writeAttemptsCard.BackgroundColor3 = C.surface
writeAttemptsCard.BorderSizePixel = 0
writeAttemptsCard.ClipsDescendants = true
writeAttemptsCard.LayoutOrder = 8
writeAttemptsCard.Parent = writePanel
addCorner(writeAttemptsCard, 6)
local wattStroke = addStroke(writeAttemptsCard, C.border, 1)
reg(writeAttemptsCard, "BackgroundColor3", "surface")
reg(wattStroke, "Color", "border")

local writeAttemptsTxt = Instance.new("TextLabel")
writeAttemptsTxt.Size = UDim2.new(1, -16, 1, -12)
writeAttemptsTxt.Position = UDim2.new(0, 8, 0, 6)
writeAttemptsTxt.BackgroundTransparency = 1
writeAttemptsTxt.Text = ""
writeAttemptsTxt.TextColor3 = C.warning
writeAttemptsTxt.TextSize = 11
writeAttemptsTxt.Font = Enum.Font.GothamBold
writeAttemptsTxt.TextXAlignment = Enum.TextXAlignment.Left
writeAttemptsTxt.Parent = writeAttemptsCard
reg(writeAttemptsTxt, "TextColor3", "warning")

local writeBtn      = makeBtn("Write Script", "purple",  writePanel, 9, 40)
local clearWriteBtn = makeBtn("Clear",        "surface", writePanel, 10, 28)
clearWriteBtn.TextColor3 = C.muted
clearWriteBtn.TextSize = 11
local clearWriteStroke = addStroke(clearWriteBtn, C.border, 1)
reg(clearWriteBtn, "TextColor3", "muted")
reg(clearWriteStroke, "Color", "border")

-- ═══════════════════════════════
-- INSIGHTS PANEL
-- ═══════════════════════════════
local insightsPanel = makeSection(6, 10, 14)
insightsPanel.Visible = false

local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1, 0, 0, 30)
toggleRow.BackgroundColor3 = C.surface
toggleRow.BorderSizePixel = 0
toggleRow.LayoutOrder = 1
toggleRow.Parent = insightsPanel
addCorner(toggleRow, 6)
local toggleStroke = addStroke(toggleRow, C.border, 1)
reg(toggleRow, "BackgroundColor3", "surface")
reg(toggleStroke, "Color", "border")

local toggleLayout = Instance.new("UIListLayout")
toggleLayout.FillDirection = Enum.FillDirection.Horizontal
toggleLayout.SortOrder = Enum.SortOrder.LayoutOrder
toggleLayout.Parent = toggleRow

local lastFixBtn = Instance.new("TextButton")
lastFixBtn.Size = UDim2.new(0.5, 0, 1, 0)
lastFixBtn.BackgroundColor3 = C.accent
lastFixBtn.TextColor3 = C.white
lastFixBtn.Text = "Last Fix"
lastFixBtn.TextSize = 11
lastFixBtn.Font = Enum.Font.GothamBold
lastFixBtn.BorderSizePixel = 0
lastFixBtn.AutoButtonColor = false
lastFixBtn.LayoutOrder = 1
addCorner(lastFixBtn, 6)
lastFixBtn.Parent = toggleRow
lastFixBtn.MouseButton1Down:Connect(function() playClick() end)

local allFixesBtn = Instance.new("TextButton")
allFixesBtn.Size = UDim2.new(0.5, 0, 1, 0)
allFixesBtn.BackgroundColor3 = C.surface
allFixesBtn.TextColor3 = C.muted
allFixesBtn.Text = "All Fixes"
allFixesBtn.TextSize = 11
allFixesBtn.Font = Enum.Font.GothamBold
allFixesBtn.BorderSizePixel = 0
allFixesBtn.AutoButtonColor = false
allFixesBtn.LayoutOrder = 2
addCorner(allFixesBtn, 6)
allFixesBtn.Parent = toggleRow
reg(allFixesBtn, "BackgroundColor3", "surface")
reg(allFixesBtn, "TextColor3", "muted")
allFixesBtn.MouseButton1Down:Connect(function() playClick() end)

local noInsightsCard = Instance.new("Frame")
noInsightsCard.Size = UDim2.new(1, 0, 0, 50)
noInsightsCard.BackgroundColor3 = C.surface
noInsightsCard.BorderSizePixel = 0
noInsightsCard.LayoutOrder = 2
noInsightsCard.Parent = insightsPanel
addCorner(noInsightsCard, 6)
local noInsStroke = addStroke(noInsightsCard, C.border, 1)
reg(noInsightsCard, "BackgroundColor3", "surface")
reg(noInsStroke, "Color", "border")

local noInsightsTxt = Instance.new("TextLabel")
noInsightsTxt.Size = UDim2.new(1, -16, 1, 0)
noInsightsTxt.Position = UDim2.new(0, 8, 0, 0)
noInsightsTxt.BackgroundTransparency = 1
noInsightsTxt.Text = "No fixes yet — fix a script to see AI insights here"
noInsightsTxt.TextColor3 = C.muted
noInsightsTxt.TextSize = 11
noInsightsTxt.Font = Enum.Font.Gotham
noInsightsTxt.TextXAlignment = Enum.TextXAlignment.Left
noInsightsTxt.TextWrapped = true
noInsightsTxt.Parent = noInsightsCard
reg(noInsightsTxt, "TextColor3", "muted")

local lastInsightCard = Instance.new("Frame")
lastInsightCard.Size = UDim2.new(1, 0, 0, 0)
lastInsightCard.BackgroundColor3 = C.surface
lastInsightCard.BorderSizePixel = 0
lastInsightCard.LayoutOrder = 3
lastInsightCard.Visible = false
lastInsightCard.Parent = insightsPanel
addCorner(lastInsightCard, 6)
local lastInsStroke = addStroke(lastInsightCard, C.accent, 1)
reg(lastInsightCard, "BackgroundColor3", "surface")
reg(lastInsStroke, "Color", "accent")

local lastInsightAccent = Instance.new("Frame")
lastInsightAccent.Size = UDim2.new(0, 2, 1, -8)
lastInsightAccent.Position = UDim2.new(0, 0, 0, 4)
lastInsightAccent.BackgroundColor3 = C.accent
lastInsightAccent.BorderSizePixel = 0
lastInsightAccent.Parent = lastInsightCard
addCorner(lastInsightAccent, 2)
reg(lastInsightAccent, "BackgroundColor3", "accent")

local lastInsightHeader = Instance.new("TextLabel")
lastInsightHeader.Size = UDim2.new(1, -16, 0, 18)
lastInsightHeader.Position = UDim2.new(0, 12, 0, 8)
lastInsightHeader.BackgroundTransparency = 1
lastInsightHeader.Text = "LAST FIX"
lastInsightHeader.TextColor3 = C.accent
lastInsightHeader.TextSize = 9
lastInsightHeader.Font = Enum.Font.GothamBold
lastInsightHeader.TextXAlignment = Enum.TextXAlignment.Left
lastInsightHeader.Parent = lastInsightCard
reg(lastInsightHeader, "TextColor3", "accent")

local lastInsightScript = Instance.new("TextLabel")
lastInsightScript.Size = UDim2.new(1, -16, 0, 14)
lastInsightScript.Position = UDim2.new(0, 12, 0, 26)
lastInsightScript.BackgroundTransparency = 1
lastInsightScript.Text = ""
lastInsightScript.TextColor3 = C.cyan
lastInsightScript.TextSize = 10
lastInsightScript.Font = Enum.Font.GothamBold
lastInsightScript.TextXAlignment = Enum.TextXAlignment.Left
lastInsightScript.Parent = lastInsightCard
reg(lastInsightScript, "TextColor3", "cyan")

local lastInsightTxt = Instance.new("TextLabel")
lastInsightTxt.Size = UDim2.new(1, -20, 0, 0)
lastInsightTxt.Position = UDim2.new(0, 12, 0, 44)
lastInsightTxt.BackgroundTransparency = 1
lastInsightTxt.Text = ""
lastInsightTxt.TextColor3 = C.text
lastInsightTxt.TextSize = 11
lastInsightTxt.Font = Enum.Font.Gotham
lastInsightTxt.TextXAlignment = Enum.TextXAlignment.Left
lastInsightTxt.TextYAlignment = Enum.TextYAlignment.Top
lastInsightTxt.TextWrapped = true
lastInsightTxt.AutomaticSize = Enum.AutomaticSize.Y
lastInsightTxt.Parent = lastInsightCard
reg(lastInsightTxt, "TextColor3", "text")

local allFixesScroll = Instance.new("ScrollingFrame")
allFixesScroll.Size = UDim2.new(1, 0, 0, 300)
allFixesScroll.BackgroundTransparency = 1
allFixesScroll.BorderSizePixel = 0
allFixesScroll.ScrollBarThickness = 3
allFixesScroll.ScrollBarImageColor3 = C.gold
allFixesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
allFixesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
allFixesScroll.LayoutOrder = 4
allFixesScroll.Visible = false
allFixesScroll.Parent = insightsPanel

local allFixesContainer = Instance.new("Frame")
allFixesContainer.Size = UDim2.new(1, 0, 0, 0)
allFixesContainer.AutomaticSize = Enum.AutomaticSize.Y
allFixesContainer.BackgroundTransparency = 1
allFixesContainer.Parent = allFixesScroll

local allFixesLayout = Instance.new("UIListLayout")
allFixesLayout.SortOrder = Enum.SortOrder.LayoutOrder
allFixesLayout.Padding = UDim.new(0, 6)
allFixesLayout.Parent = allFixesContainer

local clearInsightsBtn = makeBtn("Clear All Insights", "surface", insightsPanel, 5, 28)
clearInsightsBtn.TextColor3 = C.muted
clearInsightsBtn.TextSize = 11
local clearInsStroke2 = addStroke(clearInsightsBtn, C.border, 1)
reg(clearInsightsBtn, "TextColor3", "muted")
reg(clearInsStroke2, "Color", "border")

makeDivider(7)

-- ═══════════════════════════════
-- LIVE LOG
-- ═══════════════════════════════
local logSection = makeSection(8, 10, 14)
makeLabel("LIVE LOG", 10, "muted", logSection, 1)

local logCard = Instance.new("Frame")
logCard.Size = UDim2.new(1, 0, 0, 200)
logCard.BackgroundColor3 = C.surface
logCard.BorderSizePixel = 0
logCard.LayoutOrder = 2
logCard.Parent = logSection
addCorner(logCard, 6)
local logCardStroke = addStroke(logCard, C.border, 1)
reg(logCard, "BackgroundColor3", "surface")
reg(logCardStroke, "Color", "border")

local logAccentBar = Instance.new("Frame")
logAccentBar.Size = UDim2.new(0, 2, 1, -8)
logAccentBar.Position = UDim2.new(0, 0, 0, 4)
logAccentBar.BackgroundColor3 = C.accent
logAccentBar.BorderSizePixel = 0
logAccentBar.Parent = logCard
addCorner(logAccentBar, 2)
reg(logAccentBar, "BackgroundColor3", "accent")

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -8, 1, -2)
logScroll.Position = UDim2.new(0, 4, 0, 1)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = C.accent
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.Parent = logCard
addPadding(logScroll, 6, 6, 10, 6)

local logLayout2 = Instance.new("UIListLayout")
logLayout2.SortOrder = Enum.SortOrder.LayoutOrder
logLayout2.Padding = UDim.new(0, 3)
logLayout2.Parent = logScroll

makeDivider(9)

-- ═══════════════════════════════
-- DANGER ZONE
-- ═══════════════════════════════
local dangerSection = makeSection(10, 10, 20)
makeLabel("DANGER ZONE", 10, "danger", dangerSection, 1)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 24)
resetBtn.BackgroundTransparency = 1
resetBtn.TextColor3 = C.danger
resetBtn.Text = "Reset Game Memory"
resetBtn.TextSize = 11
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BorderSizePixel = 0
resetBtn.AutoButtonColor = false
resetBtn.LayoutOrder = 2
resetBtn.Parent = dangerSection
reg(resetBtn, "TextColor3", "danger")

resetBtn.MouseEnter:Connect(function()
	TweenService:Create(resetBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 110, 140)}):Play()
end)
resetBtn.MouseLeave:Connect(function()
	TweenService:Create(resetBtn, TweenInfo.new(0.1), {TextColor3 = C.danger}):Play()
end)
resetBtn.MouseButton1Down:Connect(function() playClick() end)

local confirmBtn, cancelBtn, confirmRow = makeSplitBtns(
	"Yes, Reset Everything", "danger",
	"Cancel",                "surface2",
	dangerSection, 3
)
confirmRow.Visible = false

-- ═══════════════════════════════
-- LOG FUNCTION
-- ═══════════════════════════════
local logCount = 0

local function addLog(msg, color)
	logCount += 1
	local e = Instance.new("TextLabel")
	e.Size = UDim2.new(1, 0, 0, 14)
	e.BackgroundTransparency = 1
	e.Text = msg
	e.TextColor3 = color or C.muted
	e.TextTransparency = 1
	e.TextSize = 11
	e.Font = Enum.Font.Gotham
	e.TextXAlignment = Enum.TextXAlignment.Left
	e.TextTruncate = Enum.TextTruncate.AtEnd
	e.LayoutOrder = logCount
	e.Parent = logScroll

	logScroll.CanvasSize = UDim2.new(0, 0, 0, logCount * 17 + 12)
	logScroll.CanvasPosition = Vector2.new(0, math.huge)

	TweenService:Create(e, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
end

-- ═══════════════════════════════
-- INSIGHTS LOGIC
-- ═══════════════════════════════
local insightCount   = 0
local showingLastFix = true

local function addInsight(scriptName, explanation)
	if not explanation or explanation == "" then return end

	lastInsightScript.Text = scriptName
	lastInsightTxt.Text    = explanation
	lastInsightCard.Visible = true
	noInsightsCard.Visible  = false

	task.defer(function()
		local lines = 1
		for _ in explanation:gmatch("\n") do lines += 1 end
		lastInsightCard.Size = UDim2.new(1, 0, 0, 44 + lines * 14 + 16)
	end)

	insightCount += 1

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 0)
	card.BackgroundColor3 = C.surface
	card.BorderSizePixel  = 0
	card.LayoutOrder = insightCount
	card.Parent = allFixesContainer
	addCorner(card, 6)
	local cardStroke = addStroke(card, C.border, 1)
	reg(card, "BackgroundColor3", "surface")
	reg(cardStroke, "Color", "border")

	local cardAccent = Instance.new("Frame")
	cardAccent.Size = UDim2.new(0, 2, 1, -8)
	cardAccent.Position = UDim2.new(0, 0, 0, 4)
	cardAccent.BackgroundColor3 = C.gold
	cardAccent.BorderSizePixel  = 0
	cardAccent.Parent = card
	addCorner(cardAccent, 2)
	reg(cardAccent, "BackgroundColor3", "gold")

	local cardNum = Instance.new("TextLabel")
	cardNum.Size = UDim2.new(1, -16, 0, 14)
	cardNum.Position = UDim2.new(0, 12, 0, 6)
	cardNum.BackgroundTransparency = 1
	cardNum.Text = "FIX #" .. insightCount .. "  —  " .. scriptName
	cardNum.TextColor3 = C.gold
	cardNum.TextSize = 9
	cardNum.Font = Enum.Font.GothamBold
	cardNum.TextXAlignment = Enum.TextXAlignment.Left
	cardNum.Parent = card
	reg(cardNum, "TextColor3", "gold")

	local cardTxt = Instance.new("TextLabel")
	cardTxt.Size = UDim2.new(1, -20, 0, 0)
	cardTxt.Position = UDim2.new(0, 12, 0, 22)
	cardTxt.BackgroundTransparency = 1
	cardTxt.Text = explanation
	cardTxt.TextColor3 = C.text
	cardTxt.TextSize = 11
	cardTxt.Font = Enum.Font.Gotham
	cardTxt.TextXAlignment = Enum.TextXAlignment.Left
	cardTxt.TextYAlignment = Enum.TextYAlignment.Top
	cardTxt.TextWrapped = true
	cardTxt.AutomaticSize = Enum.AutomaticSize.Y
	cardTxt.Parent = card
	reg(cardTxt, "TextColor3", "text")

	task.defer(function()
		local lines = 1
		for _ in explanation:gmatch("\n") do lines += 1 end
		card.Size = UDim2.new(1, -6, 0, 22 + lines * 14 + 14)
	end)

	TweenService:Create(navInsights, TweenInfo.new(0.3), {TextColor3 = C.gold}):Play()
end

-- ═══════════════════════════════
-- CONNECTION STATUS
-- ═══════════════════════════════
local function setStatus(online)
	if online then
		statusPill.BackgroundColor3 = Color3.fromRGB(0, 35, 20)
		statusStroke.Color          = C.success
		statusDot.BackgroundColor3  = C.success
		statusTxt.TextColor3        = C.success
		statusTxt.Text              = "ONLINE"
	else
		statusPill.BackgroundColor3 = Color3.fromRGB(35, 10, 15)
		statusStroke.Color          = C.danger
		statusDot.BackgroundColor3  = C.danger
		statusTxt.TextColor3        = C.danger
		statusTxt.Text              = "OFFLINE"
	end
end

local function checkConnection()
	local ok = pcall(function()
		HttpService:GetAsync(BASE_URL .. "/health")
	end)
	setStatus(ok)
	return ok
end

-- ═══════════════════════════════
-- DEEP SCAN
-- ═══════════════════════════════
local workspaceContext = ""

local function deepScan()
	local context = "=== FULL GAME CONTEXT ===\n\n"
	local scripts, remotes, models = 0, 0, 0
	local services = {
		{game:GetService("ServerScriptService"), "ServerScriptService"},
		{game:GetService("StarterPlayer"),       "StarterPlayer"},
		{game:GetService("StarterGui"),          "StarterGui"},
		{game:GetService("ReplicatedStorage"),   "ReplicatedStorage"},
		{game:GetService("ServerStorage"),       "ServerStorage"},
		{game.Workspace,                         "Workspace"},
	}
	for _, pair in ipairs(services) do
		local svc, name = pair[1], pair[2]
		local section = "--- " .. name .. " ---\n"
		local hasContent = false
		for _, obj in pairs(svc:GetDescendants()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
				scripts += 1
				hasContent = true
				local lines   = obj.Source:split("\n")
				local preview = {}
				for j = 1, math.min(50, #lines) do
					preview[j] = lines[j]
				end
				section ..= "[" .. obj.ClassName .. "] " .. obj.Name .. ":\n"
					.. table.concat(preview, "\n") .. "\n\n"
			elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				remotes += 1
				hasContent = true
				section ..= "[" .. obj.ClassName .. "] " .. obj.Name .. "\n"
			elseif obj:IsA("Model") then
				models += 1
			end
		end
		if hasContent then
			context ..= section
		end
	end
	context ..= "\nScripts: " .. scripts .. " | Remotes: " .. remotes .. " | Models: " .. models
	workspaceContext = context
	return scripts, remotes, models
end

-- ═══════════════════════════════
-- LOAD MEMORY
-- ═══════════════════════════════
local function loadMemory()
	local ok, result = pcall(function()
		return HttpService:GetAsync("http://127.0.0.1:5000/get-memory")
	end)
	if ok then
		local mem = HttpService:JSONDecode(result)
		if mem.approved and mem.game_summary ~= "" then
			memIcon.Text = "+"
			memIcon.TextColor3 = C.success
			memTxt.Text = mem.game_summary:sub(1, 80) .. "..."
			memTxt.TextColor3 = C.success
			memCard.BackgroundColor3 = Color3.fromRGB(0, 25, 15)
			memStroke.Color = C.success
			addLog("Game memory loaded", C.success)
		end
	end
end

-- ═══════════════════════════════
-- NAV SWITCHING
-- ═══════════════════════════════
local function showPanel(panel)
	fixPanel.Visible      = false
	writePanel.Visible    = false
	insightsPanel.Visible = false
	panel.Visible         = true
end

local function setNavActive(btn, colorKey)
	for _, nb in ipairs({navFix, navWrite, navInsights}) do
		TweenService:Create(nb, TweenInfo.new(0.15), {
			BackgroundColor3 = C.surface,
			TextColor3       = C.muted
		}):Play()
	end
	TweenService:Create(btn, TweenInfo.new(0.15), {
		BackgroundColor3 = C[colorKey],
		TextColor3       = C.white
	}):Play()
end

navFix.MouseButton1Click:Connect(function()
	showPanel(fixPanel)
	setNavActive(navFix, "accent")
end)

navWrite.MouseButton1Click:Connect(function()
	showPanel(writePanel)
	setNavActive(navWrite, "purple")
end)

navInsights.MouseButton1Click:Connect(function()
	showPanel(insightsPanel)
	setNavActive(navInsights, "gold")
end)

lastFixBtn.MouseButton1Click:Connect(function()
	showingLastFix = true
	TweenService:Create(lastFixBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent, TextColor3 = C.white}):Play()
	TweenService:Create(allFixesBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface, TextColor3 = C.muted}):Play()
	lastInsightCard.Visible = insightCount > 0
	noInsightsCard.Visible  = insightCount == 0
	allFixesScroll.Visible  = false
end)

allFixesBtn.MouseButton1Click:Connect(function()
	showingLastFix = false
	TweenService:Create(allFixesBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = C.gold,
		TextColor3       = Color3.fromRGB(20, 15, 0)
	}):Play()
	TweenService:Create(lastFixBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = C.surface,
		TextColor3       = C.muted
	}):Play()
	lastInsightCard.Visible = false
	noInsightsCard.Visible  = insightCount == 0
	allFixesScroll.Visible  = insightCount > 0
end)

clearInsightsBtn.MouseButton1Click:Connect(function()
	for _, c in pairs(allFixesContainer:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	insightCount = 0
	lastInsightCard.Visible = false
	noInsightsCard.Visible  = true
	lastInsightTxt.Text     = ""
	lastInsightScript.Text  = ""
	addLog("Insights cleared", C.muted)
end)

themeToggle.MouseButton1Click:Connect(function()
	isDark = not isDark
	C = isDark and themes.dark or themes.light
	themeToggle.Text = isDark and "Light" or "Dark"
	pulseBrandRunning = false
	task.wait(0.05)
	task.spawn(pulseBrand)
	applyTheme()
	addLog("Switched to " .. (isDark and "dark" or "light") .. " mode", C.cyan)
end)

-- ═══════════════════════════════
-- FIX LOOP
-- ═══════════════════════════════
local MAX_ATTEMPTS = 4
local isFixing     = false
local isWriting    = false
local isWatching   = false
local watchConnection = nil

-- CHANGE 5: Helper to get session token for authenticated requests
local function getSessionToken()
	return plugin:GetSetting(SESSION_KEY) or ""
end

local function runFixLoop(target, issue)
	isFixing = true
	fixBtn.Text = "Working..."
	TweenService:Create(fixBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.surface2}):Play()

	local currentScript   = target.Source
	local finalScript     = currentScript
	local attempt         = 0
	local errors          = ""
	local passed          = false
	local lastExplanation = ""

	while attempt < MAX_ATTEMPTS and not passed do
		attempt += 1
		attemptsCard.Size = UDim2.new(1, 0, 0, 30)
		attemptsTxt.Text = "Attempt " .. attempt .. " of " .. MAX_ATTEMPTS .. "..."
		attemptsTxt.TextColor3 = C.warning
		addLog("--- Attempt " .. attempt .. " ---", C.muted)
		addLog("Sending to AI...", C.cyan)

		local fixOk, fixResult = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/fix-script",
				HttpService:JSONEncode({
					script            = currentScript,
					issue             = issue,
					workspace_context = workspaceContext,
					errors            = errors,
					attempt           = attempt,
					session_token     = getSessionToken()   -- CHANGE 5a: send token
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not fixOk then
			addLog("Fix request failed — is the server running?", C.danger)
			break
		end

		local fixRes  = HttpService:JSONDecode(fixResult)
		finalScript   = fixRes.fixed_script

		if fixRes.explanation and fixRes.explanation ~= "" then
			lastExplanation = fixRes.explanation
		end

		local wrote = pcall(function()
			ScriptEditorService:UpdateSourceAsync(target, function() return finalScript end)
		end)
		if not wrote then
			target.Source = finalScript
		end

		addLog("Fix written — reviewing...", C.warning)

		local reviewOk, reviewResult = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/review",
				HttpService:JSONEncode({
					fixed_script      = finalScript,
					issue             = issue,
					workspace_context = workspaceContext
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not reviewOk then
			addLog("Review failed — accepting fix", C.warning)
			passed = true
			break
		end

		local reviewRes = HttpService:JSONDecode(reviewResult)
		local score     = reviewRes.score
		passed          = reviewRes.passed
		errors          = reviewRes.errors or ""

		local scoreColor = score >= 8 and C.success or score >= 6 and C.warning or C.danger
		addLog("Score: " .. score .. "/10", scoreColor)

		if passed then
			addLog("Passed review!", C.success)
		else
			addLog("Issues found — retrying...", C.warning)
			if errors ~= "" and errors:upper() ~= "NONE" then
				addLog("Errors: " .. errors:sub(1, 60), C.danger)
			end
			currentScript = finalScript
		end

		task.wait(0.5)
	end

	if passed then
		attemptsCard.Size = UDim2.new(1, 0, 0, 30)
		attemptsTxt.Text = "Done in " .. attempt .. " attempt(s)"
		attemptsTxt.TextColor3 = C.success
		addLog("Script is ready!", C.success)
		addLog("Check Insights tab for explanation", C.gold)
	else
		attemptsCard.Size = UDim2.new(1, 0, 0, 30)
		attemptsTxt.Text = "Max attempts — best fix applied"
		attemptsTxt.TextColor3 = C.warning
		addLog("Max attempts reached", C.warning)
	end

	if lastExplanation ~= "" then
		addInsight(target.Name, lastExplanation)
	end

	fixBtn.Text = "Fix Script"
	TweenService:Create(fixBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
	isFixing = false
end

-- ═══════════════════════════════
-- WRITE LOOP
-- ═══════════════════════════════
local function runWriteLoop(scriptName, service, description)
	isWriting = true
	writeBtn.Text = "Writing..."
	TweenService:Create(writeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.surface2}):Play()

	local attempt     = 0
	local errors      = ""
	local passed      = false
	local finalScript = ""

	while attempt < MAX_ATTEMPTS and not passed do
		attempt += 1
		writeAttemptsCard.Size = UDim2.new(1, 0, 0, 30)
		writeAttemptsTxt.Text = "Attempt " .. attempt .. " of " .. MAX_ATTEMPTS .. "..."
		writeAttemptsTxt.TextColor3 = C.warning
		addLog("--- Write Attempt " .. attempt .. " ---", C.muted)
		addLog("Writing script from scratch...", C.purple)

		local writeOk, writeResult = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/write-script",
				HttpService:JSONEncode({
					script_name       = scriptName,
					service           = service,
					description       = description,
					workspace_context = workspaceContext,
					errors            = errors,
					attempt           = attempt,
					session_token     = getSessionToken()   -- CHANGE 5b: send token
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not writeOk then
			addLog("Write request failed", C.danger)
			break
		end

		local writeRes = HttpService:JSONDecode(writeResult)
		finalScript    = writeRes.script

		addLog("Script written — reviewing...", C.warning)

		local reviewOk, reviewResult = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/review",
				HttpService:JSONEncode({
					fixed_script      = finalScript,
					issue             = "New script: " .. description,
					workspace_context = workspaceContext
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not reviewOk then
			addLog("Review failed — accepting script", C.warning)
			passed = true
			break
		end

		local reviewRes = HttpService:JSONDecode(reviewResult)
		local score     = reviewRes.score
		passed          = reviewRes.passed
		errors          = reviewRes.errors or ""

		local scoreColor = score >= 8 and C.success or score >= 6 and C.warning or C.danger
		addLog("Score: " .. score .. "/10", scoreColor)

		if passed then
			addLog("Script passed review!", C.success)
		else
			addLog("Issues found — retrying...", C.warning)
		end

		task.wait(0.5)
	end

	if finalScript ~= "" then
		local ok, err = pcall(function()
			local targetService
			if service == "ServerScriptService" then
				targetService = game:GetService("ServerScriptService")
			elseif service == "StarterPlayerScripts" then
				targetService = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
			elseif service == "StarterGui" then
				targetService = game:GetService("StarterGui")
			elseif service == "ReplicatedStorage" then
				targetService = game:GetService("ReplicatedStorage")
			elseif service == "ServerStorage" then
				targetService = game:GetService("ServerStorage")
			elseif service == "StarterCharacterScripts" then
				targetService = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")
			else
				targetService = game:GetService("ServerScriptService")
			end

			local newScript
			if service == "StarterPlayerScripts" or service == "StarterGui" or service == "StarterCharacterScripts" then
				newScript = Instance.new("LocalScript")
			else
				newScript = Instance.new("Script")
			end
			newScript.Name   = scriptName
			newScript.Source = finalScript
			newScript.Parent = targetService
		end)

		if ok then
			writeAttemptsCard.Size = UDim2.new(1, 0, 0, 30)
			writeAttemptsTxt.Text = "Created in " .. service .. "!"
			writeAttemptsTxt.TextColor3 = C.success
			addLog("Script created: " .. scriptName .. " in " .. service, C.success)
		else
			addLog("Error creating script: " .. tostring(err), C.danger)
		end
	end

	writeBtn.Text = "Write Script"
	TweenService:Create(writeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.purple}):Play()
	isWriting = false
end

-- ═══════════════════════════════
-- BUTTON EVENTS
-- ═══════════════════════════════
fixBtn.MouseButton1Click:Connect(function()
	if isFixing then return end
	local scriptName = scriptBox.Text:match("^%s*(.-)%s*$")
	local issue      = issueBox.Text:match("^%s*(.-)%s*$")

	if scriptName == "" then
		addLog("Enter a script name first", C.danger)
		return
	end
	if issue == "" then
		addLog("Describe the issue first", C.danger)
		return
	end

	local target = nil
	local services = {
		game:GetService("ServerScriptService"),
		game:GetService("StarterPlayer"),
		game:GetService("StarterGui"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerStorage"),
		game.Workspace,
	}
	for _, svc in ipairs(services) do
		local found = svc:FindFirstChild(scriptName, true)
		if found and (found:IsA("Script") or found:IsA("LocalScript") or found:IsA("ModuleScript")) then
			target = found
			break
		end
	end

	if not target then
		addLog("Script '" .. scriptName .. "' not found in workspace", C.danger)
		return
	end

	addLog("Found: " .. target.Name, C.success)
	task.spawn(runFixLoop, target, issue)
end)

writeBtn.MouseButton1Click:Connect(function()
	if isWriting then return end
	local name = writeNameBox.Text:match("^%s*(.-)%s*$")
	local desc = descBox.Text:match("^%s*(.-)%s*$")
	local svc  = getService()

	if name == "" then
		addLog("Enter a script name first", C.danger)
		return
	end
	if desc == "" then
		addLog("Describe what the script should do", C.danger)
		return
	end

	task.spawn(runWriteLoop, name, svc, desc)
end)

clearFixBtn.MouseButton1Click:Connect(function()
	scriptBox.Text = ""
	issueBox.Text  = ""
	attemptsCard.Size = UDim2.new(1, 0, 0, 0)
	attemptsTxt.Text  = ""
	addLog("Cleared", C.muted)
end)

clearWriteBtn.MouseButton1Click:Connect(function()
	writeNameBox.Text = ""
	descBox.Text      = ""
	writeAttemptsCard.Size = UDim2.new(1, 0, 0, 0)
	writeAttemptsTxt.Text  = ""
	addLog("Cleared", C.muted)
end)

-- ═══════════════════════════════
-- SCAN BUTTON
-- ═══════════════════════════════
scanBtn.MouseButton1Click:Connect(function()
	addLog("Scanning workspace...", C.cyan)
	scanBtn.Text = "Scanning..."

	task.spawn(function()
		local scripts, remotes, models = deepScan()
		addLog("Found " .. scripts .. " scripts, " .. remotes .. " remotes, " .. models .. " models", C.success)

		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/scan",
				HttpService:JSONEncode({workspace_context = workspaceContext}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if ok then
			local data = HttpService:JSONDecode(result)
			if data.summary then
				sumTxt.Text = data.summary
				local lineCount = 1
				for _ in data.summary:gmatch("\n") do lineCount += 1 end
				sumCard.Size = UDim2.new(1, 0, 0, lineCount * 15 + 16)
				approveRow.Visible = true
				addLog("Summary ready — approve or reject", C.warning)
			end
		else
			addLog("Scan failed — is the server running?", C.danger)
		end

		scanBtn.Text = "Deep Scan Workspace"
	end)
end)

approveBtn.MouseButton1Click:Connect(function()
	local ok, _ = pcall(function()
		HttpService:PostAsync(
			BASE_URL .. "/approve",
			HttpService:JSONEncode({approved = true}),
			Enum.HttpContentType.ApplicationJson
		)
	end)
	if ok then
		memIcon.Text = "+"
		memIcon.TextColor3 = C.success
		memTxt.Text = sumTxt.Text:sub(1, 80) .. "..."
		memTxt.TextColor3 = C.success
		memCard.BackgroundColor3 = Color3.fromRGB(0, 25, 15)
		memStroke.Color = C.success
		approveRow.Visible = false
		sumCard.Size = UDim2.new(1, 0, 0, 0)
		addLog("Game memory saved!", C.success)
	end
end)

rejectBtn.MouseButton1Click:Connect(function()
	approveRow.Visible = false
	sumCard.Size = UDim2.new(1, 0, 0, 0)
	sumTxt.Text  = ""
	addLog("Summary rejected", C.muted)
end)

-- ═══════════════════════════════
-- WATCH MODE
-- ═══════════════════════════════
watchBtn.MouseButton1Click:Connect(function()
	if isWatching then return end
	local scriptName = scriptBox.Text:match("^%s*(.-)%s*$")
	if scriptName == "" then
		addLog("Enter the script name to watch first", C.danger)
		return
	end

	isWatching = true
	watchCard.Size = UDim2.new(1, 0, 0, 30)
	watchTxt.Text = "Watching: " .. scriptName
	stopWatchBtn.Visible = true
	addLog("Watch mode ON — play the game now", C.success)

	watchConnection = ScriptContext.Error:Connect(function(message, trace, script)
		if script and script.Name == scriptName then
			addLog("[ERROR] " .. message:sub(1, 60), C.danger)
			addLog("Auto-fixing...", C.warning)

			local target = nil
			local services2 = {
				game:GetService("ServerScriptService"),
				game:GetService("StarterPlayer"),
				game:GetService("StarterGui"),
				game:GetService("ReplicatedStorage"),
				game:GetService("ServerStorage"),
				game.Workspace,
			}
			for _, svc in ipairs(services2) do
				local found = svc:FindFirstChild(scriptName, true)
				if found and (found:IsA("Script") or found:IsA("LocalScript") or found:IsA("ModuleScript")) then
					target = found
					break
				end
			end

			if target then
				task.spawn(runFixLoop, target, "Runtime error: " .. message)
			end
		end
	end)
end)

stopWatchBtn.MouseButton1Click:Connect(function()
	if watchConnection then
		watchConnection:Disconnect()
		watchConnection = nil
	end
	isWatching = false
	watchCard.Size = UDim2.new(1, 0, 0, 0)
	watchTxt.Text  = ""
	stopWatchBtn.Visible = false
	addLog("Watch mode OFF", C.muted)
end)

-- ═══════════════════════════════
-- DANGER ZONE
-- ═══════════════════════════════
resetBtn.MouseButton1Click:Connect(function()
	confirmRow.Visible = not confirmRow.Visible
end)

confirmBtn.MouseButton1Click:Connect(function()
	local ok, _ = pcall(function()
		HttpService:PostAsync(
			BASE_URL .. "/reset-memory",
			HttpService:JSONEncode({}),
			Enum.HttpContentType.ApplicationJson
		)
	end)
	memIcon.Text = "—"
	memIcon.TextColor3 = C.muted
	memTxt.Text = "No game memory saved"
	memTxt.TextColor3 = C.muted
	memCard.BackgroundColor3 = C.surface
	memStroke.Color = C.border
	workspaceContext = ""
	confirmRow.Visible = false
	addLog("Game memory reset", C.danger)
end)

cancelBtn.MouseButton1Click:Connect(function()
	confirmRow.Visible = false
end)

-- ═══════════════════════════════
-- BUTTON OPEN/CLOSE
-- ═══════════════════════════════
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

-- ═══════════════════════════════
-- STARTUP
-- ═══════════════════════════════
task.spawn(function()
	setNavActive(navFix, "accent")
	task.spawn(pulseStatusDot)
	task.spawn(pulseBrand)

	task.spawn(function()
		while true do
			checkConnection()
			task.wait(10)
		end
	end)

	checkSavedSession()

	task.wait(1)
	loadMemory()

	addLog("Stud v15 ready", C.accent)
	addLog("Scan your workspace to get started", C.muted)
end)