-- ╔══════════════════════════════════════════════════════════════╗
-- ║         StudCoding Plugin v15 — PREMIUM EDITION             ║
-- ║         "Your game. Perfected by AI."                       ║
-- ╚══════════════════════════════════════════════════════════════╝

local HttpService        = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local ScriptContext      = game:GetService("ScriptContext")
local TweenService       = game:GetService("TweenService")

local toolbar = plugin:CreateToolbar("StudCoding")
local button  = toolbar:CreateButton("StudCoding", "Open StudCoding AI", "rbxassetid://4458901886")

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, true, false, 360, 720, 300, 400
)
local widget = plugin:CreateDockWidgetPluginGui("StudCoding", widgetInfo)
widget.Title = "StudCoding"

-- ══════════════════════════════════════════════════════════════
-- SOUND
-- ══════════════════════════════════════════════════════════════
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://5152885585"
clickSound.Volume  = 0.3
clickSound.Parent  = widget

local function playClick()
	clickSound:Stop()
	clickSound:Play()
end

-- ══════════════════════════════════════════════════════════════
-- PREMIUM THEME PALETTE
-- ══════════════════════════════════════════════════════════════
local themes = {
	dark = {
		bg         = Color3.fromRGB( 10,  10,  13),
		surface    = Color3.fromRGB( 16,  16,  21),
		surface2   = Color3.fromRGB( 22,  22,  29),
		surface3   = Color3.fromRGB( 30,  30,  39),
		surfaceHov = Color3.fromRGB( 38,  38,  50),
		border     = Color3.fromRGB( 44,  44,  58),
		border2    = Color3.fromRGB( 62,  62,  82),
		accent     = Color3.fromRGB( 99, 102, 241),
		accentHov  = Color3.fromRGB(118, 121, 255),
		accentDim  = Color3.fromRGB( 26,  27,  76),
		cyan       = Color3.fromRGB( 99, 102, 241),
		cyanDim    = Color3.fromRGB( 26,  27,  76),
		purple     = Color3.fromRGB(139,  92, 246),
		purpleDim  = Color3.fromRGB( 44,  28,  90),
		gold       = Color3.fromRGB(245, 158,  11),
		goldDim    = Color3.fromRGB( 72,  42,   8),
		success    = Color3.fromRGB( 34, 197,  94),
		successDim = Color3.fromRGB(  8,  56,  22),
		danger     = Color3.fromRGB(239,  68,  68),
		dangerDim  = Color3.fromRGB( 76,  16,  16),
		warning    = Color3.fromRGB(245, 158,  11),
		text       = Color3.fromRGB(240, 240, 248),
		textDim    = Color3.fromRGB(148, 148, 172),
		muted      = Color3.fromRGB( 84,  84, 108),
		faint      = Color3.fromRGB( 16,  16,  21),
		white      = Color3.fromRGB(255, 255, 255),
		black      = Color3.fromRGB( 10,  10,  13),
		green      = Color3.fromRGB( 34, 197,  94),
		grid       = Color3.fromRGB( 20,  20,  26),
	},
	light = {
		bg         = Color3.fromRGB(250, 250, 252),
		surface    = Color3.fromRGB(255, 255, 255),
		surface2   = Color3.fromRGB(244, 244, 248),
		surface3   = Color3.fromRGB(236, 236, 244),
		surfaceHov = Color3.fromRGB(226, 226, 238),
		border     = Color3.fromRGB(210, 210, 226),
		border2    = Color3.fromRGB(178, 178, 208),
		accent     = Color3.fromRGB( 79,  82, 221),
		accentHov  = Color3.fromRGB( 62,  65, 194),
		accentDim  = Color3.fromRGB(224, 224, 254),
		cyan       = Color3.fromRGB( 79,  82, 221),
		cyanDim    = Color3.fromRGB(224, 224, 254),
		purple     = Color3.fromRGB(124,  58, 237),
		purpleDim  = Color3.fromRGB(237, 233, 254),
		gold       = Color3.fromRGB(180, 100,   8),
		goldDim    = Color3.fromRGB(254, 240, 196),
		success    = Color3.fromRGB( 16, 185, 129),
		successDim = Color3.fromRGB(209, 250, 229),
		danger     = Color3.fromRGB(220,  38,  38),
		dangerDim  = Color3.fromRGB(254, 226, 226),
		warning    = Color3.fromRGB(180, 100,   8),
		text       = Color3.fromRGB( 12,  12,  18),
		textDim    = Color3.fromRGB( 72,  72,  96),
		muted      = Color3.fromRGB(144, 144, 172),
		faint      = Color3.fromRGB(248, 248, 252),
		white      = Color3.fromRGB( 12,  12,  18),
		black      = Color3.fromRGB(255, 255, 255),
		green      = Color3.fromRGB( 16, 185, 129),
		grid       = Color3.fromRGB(232, 232, 240),
	}
}

local isDark = true
local C      = themes.dark

-- ══════════════════════════════════════════════════════════════
-- ROOT
-- ══════════════════════════════════════════════════════════════
local root = Instance.new("Frame")
root.Size = UDim2.new(1,0,1,0)
root.BackgroundColor3 = C.bg
root.BorderSizePixel  = 0
root.ClipsDescendants = true
root.Parent = widget

-- Rich depth gradient background
local rootGrad = Instance.new("UIGradient")
rootGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(14,  10,  26)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,  10,  13)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,  12,  20)),
})
rootGrad.Rotation = 135
rootGrad.Parent   = root

-- ══════════════════════════════════════════════════════════════
-- CONSTANTS
-- ══════════════════════════════════════════════════════════════
local SESSION_KEY = "stud_session_v3"
local PLUGKEY_KEY = "stud_plugin_key_v3"
local BASE_URL    = "https://studcoding-production-3b79.up.railway.app"

local savedSession   = plugin:GetSetting(SESSION_KEY) or ""
local savedPluginKey = plugin:GetSetting(PLUGKEY_KEY) or ""

-- ══════════════════════════════════════════════════════════════
-- SUBTLE GRID BACKGROUND
-- ══════════════════════════════════════════════════════════════
local gridLines = {}
local gridSize  = 28
for i = 0, 55 do
	local h = Instance.new("Frame")
	h.Size             = UDim2.new(1,0,0,1)
	h.Position         = UDim2.new(0,0,0, i * gridSize)
	h.BackgroundColor3 = C.grid
	h.BorderSizePixel  = 0
	h.BackgroundTransparency = 1
	h.ZIndex = 1
	h.Parent = root
	table.insert(gridLines, h)

	local v = Instance.new("Frame")
	v.Size             = UDim2.new(0,1,1,0)
	v.Position         = UDim2.new(0, i * gridSize, 0, 0)
	v.BackgroundColor3 = C.grid
	v.BorderSizePixel  = 0
	v.BackgroundTransparency = 1
	v.ZIndex = 1
	v.Parent = root
	table.insert(gridLines, v)
end

-- Radial glow at top (hidden)
local topGlow = Instance.new("Frame")
topGlow.Size = UDim2.new(1,0,0,120)
topGlow.BackgroundColor3 = C.accent
topGlow.BackgroundTransparency = 1
topGlow.BorderSizePixel = 0
topGlow.ZIndex = 2
topGlow.Parent = root
local topGlowGrad = Instance.new("UIGradient")
topGlowGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
	ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
})
topGlowGrad.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(1, 1),
})
topGlowGrad.Rotation = 90
topGlowGrad.Parent   = topGlow

-- ══════════════════════════════════════════════════════════════
-- UI HELPERS (moved up to reduce local count in auth section)
-- ══════════════════════════════════════════════════════════════
local function addPadding(p, top, bottom, left, right)
	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, top    or 0)
	pad.PaddingBottom = UDim.new(0, bottom or 0)
	pad.PaddingLeft   = UDim.new(0, left   or 0)
	pad.PaddingRight  = UDim.new(0, right  or 0)
	pad.Parent = p
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color     = color or C.border
	s.Thickness = thickness or 1
	s.Parent    = parent
	return s
end

-- ══════════════════════════════════════════════════════════════
-- AUTH SCREEN  — PREMIUM FLOATING CARD
-- ══════════════════════════════════════════════════════════════
local authScreen = Instance.new("Frame")
authScreen.Size = UDim2.new(1,0,1,0)
authScreen.BackgroundColor3 = C.bg
authScreen.BorderSizePixel  = 0
authScreen.ZIndex   = 100
authScreen.Visible  = true
authScreen.Parent   = root

-- Auth grid overlay (hidden)
for i = 0, 28 do
	local ah = Instance.new("Frame")
	ah.Size = UDim2.new(1,0,0,1)
	ah.Position = UDim2.new(0,0,0, i*28)
	ah.BackgroundColor3 = C.grid
	ah.BackgroundTransparency = 1
	ah.BorderSizePixel = 0
	ah.ZIndex = 100
	ah.Parent = authScreen
end

-- Top gradient bar on auth screen
local authTopBar = Instance.new("Frame")
authTopBar.Size = UDim2.new(1,0,0,3)
authTopBar.BackgroundColor3 = C.accent
authTopBar.BorderSizePixel  = 0
authTopBar.ZIndex = 101
authTopBar.Parent = authScreen
local authBarGrad = Instance.new("UIGradient")
authBarGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(139,  92, 246)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB( 99, 102, 241)),
})
authBarGrad.Parent = authTopBar

-- Card wrapper (border effect)
local authCardBorder = Instance.new("Frame")
authCardBorder.Size = UDim2.new(1, -32, 0, 0)
authCardBorder.AutomaticSize = Enum.AutomaticSize.Y
authCardBorder.Position = UDim2.new(0, 16, 0, 48)
authCardBorder.BackgroundColor3 = C.border2
authCardBorder.BorderSizePixel  = 0
authCardBorder.ZIndex = 101
authCardBorder.Parent = authScreen
addCorner(authCardBorder, 16)

-- Inner card
local authCard = Instance.new("Frame")
authCard.Size = UDim2.new(1,-2,1,-2)
authCard.Position = UDim2.new(0,1,0,1)
authCard.AutomaticSize = Enum.AutomaticSize.Y
authCard.BackgroundColor3 = C.surface
authCard.BorderSizePixel  = 0
authCard.ZIndex = 102
authCard.Parent = authCardBorder
addCorner(authCard, 15)
addPadding(authCard, 28, 28, 20, 20)

local authCardLayout = Instance.new("UIListLayout")
authCardLayout.SortOrder = Enum.SortOrder.LayoutOrder
authCardLayout.Padding    = UDim.new(0, 12)
authCardLayout.Parent     = authCard

-- Logo mark with gradient
local authLogoWrap = Instance.new("Frame")
authLogoWrap.Size = UDim2.new(0, 48, 0, 48)
authLogoWrap.BackgroundColor3 = C.accent
authLogoWrap.BorderSizePixel  = 0
authLogoWrap.LayoutOrder = 1
authLogoWrap.ZIndex = 103
authLogoWrap.Parent = authCard
addCorner(authLogoWrap, 12)
local authLogoGrad = Instance.new("UIGradient")
authLogoGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139,  92, 246)),
})
authLogoGrad.Rotation = 135
authLogoGrad.Parent   = authLogoWrap

local authLogoTxt = Instance.new("TextLabel")
authLogoTxt.Size = UDim2.new(1,0,1,0)
authLogoTxt.BackgroundTransparency = 1
authLogoTxt.Text     = "SC"
authLogoTxt.TextColor3 = Color3.new(1,1,1)
authLogoTxt.TextSize   = 15
authLogoTxt.Font       = Enum.Font.GothamBold
authLogoTxt.ZIndex     = 104
authLogoTxt.Parent     = authLogoWrap

-- Title & subtitle
local authTitle = Instance.new("TextLabel")
authTitle.Size = UDim2.new(1,0,0,24)
authTitle.BackgroundTransparency = 1
authTitle.Text     = "Welcome to StudCoding"
authTitle.TextColor3 = C.text
authTitle.TextSize   = 16
authTitle.Font       = Enum.Font.GothamBold
authTitle.TextXAlignment = Enum.TextXAlignment.Left
authTitle.LayoutOrder = 2
authTitle.ZIndex = 103
authTitle.Parent = authCard

local authSub = Instance.new("TextLabel")
authSub.Size = UDim2.new(1,0,0,0)
authSub.AutomaticSize = Enum.AutomaticSize.Y
authSub.BackgroundTransparency = 1
authSub.Text     = "AI-powered Lua coding assistant for Roblox developers."
authSub.TextColor3 = C.textDim
authSub.TextSize   = 12
authSub.Font       = Enum.Font.Gotham
authSub.TextXAlignment = Enum.TextXAlignment.Left
authSub.TextWrapped = true
authSub.LayoutOrder = 3
authSub.ZIndex = 103
authSub.Parent = authCard

-- Divider
local authDivider = Instance.new("Frame")
authDivider.Size = UDim2.new(1,0,0,1)
authDivider.BackgroundColor3 = C.border
authDivider.BorderSizePixel  = 0
authDivider.LayoutOrder = 4
authDivider.ZIndex = 103
authDivider.Parent = authCard

-- ── SCREEN 1: SC Plugin Key ──
local screen1 = Instance.new("Frame")
screen1.Size = UDim2.new(1,0,0,0)
screen1.AutomaticSize = Enum.AutomaticSize.Y
screen1.BackgroundTransparency = 1
screen1.LayoutOrder = 5
screen1.ZIndex = 103
screen1.Parent = authCard

local s1Layout = Instance.new("UIListLayout")
s1Layout.SortOrder = Enum.SortOrder.LayoutOrder
s1Layout.Padding    = UDim.new(0, 10)
s1Layout.Parent     = screen1

-- Step label
local stepLabel1 = Instance.new("Frame")
stepLabel1.Size = UDim2.new(1,0,0,22)
stepLabel1.BackgroundTransparency = 1
stepLabel1.LayoutOrder = 1
stepLabel1.Parent = screen1

local stepNum1 = Instance.new("Frame")
stepNum1.Size = UDim2.new(0,20,0,20)
stepNum1.Position = UDim2.new(0,0,0,1)
stepNum1.BackgroundColor3 = C.accentDim
stepNum1.BorderSizePixel  = 0
stepNum1.Parent = stepLabel1
addCorner(stepNum1, 99)
local stepNum1Txt = Instance.new("TextLabel")
stepNum1Txt.Size = UDim2.new(1,0,1,0)
stepNum1Txt.BackgroundTransparency = 1
stepNum1Txt.Text = "1"
stepNum1Txt.TextColor3 = C.accent
stepNum1Txt.TextSize   = 12
stepNum1Txt.Font       = Enum.Font.GothamBold
stepNum1Txt.Parent     = stepNum1

local stepTxt1 = Instance.new("TextLabel")
stepTxt1.Size = UDim2.new(1,-28,1,0)
stepTxt1.Position = UDim2.new(0,28,0,0)
stepTxt1.BackgroundTransparency = 1
stepTxt1.Text = "Enter your Plugin Key"
stepTxt1.TextColor3 = C.textDim
stepTxt1.TextSize   = 12
stepTxt1.Font       = Enum.Font.GothamBold
stepTxt1.TextXAlignment = Enum.TextXAlignment.Left
stepTxt1.Parent = stepLabel1

-- Input wrapper with glow
local actWrap = Instance.new("Frame")
actWrap.Size = UDim2.new(1,0,0,44)
actWrap.BackgroundColor3 = C.surface2
actWrap.BorderSizePixel  = 0
actWrap.LayoutOrder = 2
actWrap.ZIndex = 104
actWrap.Parent = screen1
addCorner(actWrap, 8)
local actStroke = Instance.new("UIStroke")
actStroke.Color     = C.border2
actStroke.Thickness = 1.5
actStroke.Parent    = actWrap

local actCodeInput = Instance.new("TextBox")
actCodeInput.Size = UDim2.new(1,-44,1,-12)
actCodeInput.Position = UDim2.new(0,14,0,6)
actCodeInput.BackgroundTransparency = 1
actCodeInput.PlaceholderText  = "SC-XXXXX-XXXXX"
actCodeInput.PlaceholderColor3 = C.muted
actCodeInput.Text      = savedPluginKey
actCodeInput.TextColor3 = C.text
actCodeInput.TextSize   = 13
actCodeInput.Font       = Enum.Font.Code
actCodeInput.TextXAlignment = Enum.TextXAlignment.Left
actCodeInput.ClearTextOnFocus = false
actCodeInput.ZIndex = 105
actCodeInput.Parent = actWrap

-- Key icon indicator
local keyIcon = Instance.new("TextLabel")
keyIcon.Size = UDim2.new(0,28,0,28)
keyIcon.Position = UDim2.new(1,-36,0.5,-14)
keyIcon.BackgroundColor3 = C.border
keyIcon.BorderSizePixel  = 0
keyIcon.Text     = "#"
keyIcon.TextColor3 = C.muted
keyIcon.TextSize   = 12
keyIcon.Font       = Enum.Font.GothamBold
keyIcon.ZIndex     = 105
keyIcon.Parent     = actWrap
addCorner(keyIcon, 6)

actCodeInput.Focused:Connect(function()
	TweenService:Create(actStroke, TweenInfo.new(0.18), {Color = C.accent}):Play()
	TweenService:Create(actWrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface3}):Play()
	TweenService:Create(keyIcon,   TweenInfo.new(0.18), {BackgroundColor3 = C.accentDim, TextColor3 = C.accent}):Play()
end)
actCodeInput.FocusLost:Connect(function()
	TweenService:Create(actStroke, TweenInfo.new(0.18), {Color = C.border2}):Play()
	TweenService:Create(actWrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface2}):Play()
	TweenService:Create(keyIcon,   TweenInfo.new(0.18), {BackgroundColor3 = C.border, TextColor3 = C.muted}):Play()
end)

local authError1 = Instance.new("TextLabel")
authError1.Size = UDim2.new(1,0,0,0)
authError1.AutomaticSize = Enum.AutomaticSize.Y
authError1.BackgroundColor3 = C.dangerDim
authError1.BorderSizePixel  = 0
authError1.Text     = ""
authError1.TextColor3 = C.danger
authError1.TextSize   = 11
authError1.Font       = Enum.Font.GothamBold
authError1.TextXAlignment = Enum.TextXAlignment.Left
authError1.TextWrapped = true
authError1.Visible   = false
authError1.LayoutOrder = 3
authError1.ZIndex = 104
authError1.Parent = screen1
addCorner(authError1, 6)
addPadding(authError1, 6, 6, 10, 10)

-- CONNECT button with gradient
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1,0,0,44)
verifyBtn.BackgroundColor3 = C.accent
verifyBtn.TextColor3 = Color3.new(1,1,1)
verifyBtn.Text     = "Connect  →"
verifyBtn.TextSize  = 13
verifyBtn.Font      = Enum.Font.GothamBold
verifyBtn.BorderSizePixel = 0
verifyBtn.AutoButtonColor = false
verifyBtn.LayoutOrder = 4
verifyBtn.ZIndex = 104
verifyBtn.Parent = screen1
addCorner(verifyBtn, 8)
local verifyGrad = Instance.new("UIGradient")
verifyGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139,  92, 246)),
})
verifyGrad.Rotation = 135
verifyGrad.Parent = verifyBtn

verifyBtn.MouseEnter:Connect(function()
	TweenService:Create(verifyBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.accentHov}):Play()
end)
verifyBtn.MouseLeave:Connect(function()
	TweenService:Create(verifyBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.accent}):Play()
end)
verifyBtn.MouseButton1Down:Connect(function()
	playClick()
	TweenService:Create(verifyBtn, TweenInfo.new(0.06), {Size = UDim2.new(1,0,0,41)}):Play()
end)
verifyBtn.MouseButton1Up:Connect(function()
	TweenService:Create(verifyBtn, TweenInfo.new(0.1), {Size = UDim2.new(1,0,0,44)}):Play()
end)

local authNote1 = Instance.new("TextLabel")
authNote1.Size = UDim2.new(1,0,0,28)
authNote1.BackgroundTransparency = 1
authNote1.Text     = "Get your key at studcoding.app → Dashboard → Install Plugin"
authNote1.TextColor3 = C.muted
authNote1.TextSize   = 11
authNote1.Font       = Enum.Font.Gotham
authNote1.TextXAlignment = Enum.TextXAlignment.Center
authNote1.LayoutOrder = 5
authNote1.ZIndex = 104
authNote1.Parent = screen1

-- ── SCREEN 2: Email Code ──
local screen2 = Instance.new("Frame")
screen2.Size = UDim2.new(1,0,0,0)
screen2.AutomaticSize = Enum.AutomaticSize.Y
screen2.BackgroundTransparency = 1
screen2.LayoutOrder = 5
screen2.Visible = false
screen2.ZIndex  = 103
screen2.Parent  = authCard

local s2Layout = Instance.new("UIListLayout")
s2Layout.SortOrder = Enum.SortOrder.LayoutOrder
s2Layout.Padding    = UDim.new(0, 10)
s2Layout.Parent     = screen2

local stepLabel2 = Instance.new("Frame")
stepLabel2.Size = UDim2.new(1,0,0,22)
stepLabel2.BackgroundTransparency = 1
stepLabel2.LayoutOrder = 1
stepLabel2.Parent = screen2

local stepNum2 = Instance.new("Frame")
stepNum2.Size = UDim2.new(0,20,0,20)
stepNum2.Position = UDim2.new(0,0,0,1)
stepNum2.BackgroundColor3 = C.successDim
stepNum2.BorderSizePixel  = 0
stepNum2.Parent = stepLabel2
addCorner(stepNum2, 99)
local sn2t = Instance.new("TextLabel")
sn2t.Size = UDim2.new(1,0,1,0)
sn2t.BackgroundTransparency = 1
sn2t.Text = "2"
sn2t.TextColor3 = C.success
sn2t.TextSize   = 12
sn2t.Font       = Enum.Font.GothamBold
sn2t.Parent     = stepNum2

local stepTxt2 = Instance.new("TextLabel")
stepTxt2.Size = UDim2.new(1,-28,1,0)
stepTxt2.Position = UDim2.new(0,28,0,0)
stepTxt2.BackgroundTransparency = 1
stepTxt2.Text = "Check your email"
stepTxt2.TextColor3 = C.textDim
stepTxt2.TextSize   = 12
stepTxt2.Font       = Enum.Font.GothamBold
stepTxt2.TextXAlignment = Enum.TextXAlignment.Left
stepTxt2.Parent = stepLabel2

local authSub2 = Instance.new("TextLabel")
authSub2.Size = UDim2.new(1,0,0,0)
authSub2.AutomaticSize = Enum.AutomaticSize.Y
authSub2.BackgroundTransparency = 1
authSub2.Text     = "A 6-digit code was sent to your email. Check spam too."
authSub2.TextColor3 = C.textDim
authSub2.TextSize   = 11
authSub2.Font       = Enum.Font.Gotham
authSub2.TextXAlignment = Enum.TextXAlignment.Left
authSub2.TextWrapped = true
authSub2.LayoutOrder = 2
authSub2.ZIndex = 103
authSub2.Parent = screen2

local devHint = Instance.new("Frame")
devHint.Size = UDim2.new(1,0,0,0)
devHint.AutomaticSize = Enum.AutomaticSize.Y
devHint.BackgroundColor3 = C.goldDim
devHint.BorderSizePixel  = 0
devHint.Visible = false
devHint.LayoutOrder = 3
devHint.ZIndex = 103
devHint.Parent = screen2
addCorner(devHint, 6)
addPadding(devHint, 6, 6, 10, 10)

local devHintTxt = Instance.new("TextLabel")
devHintTxt.Size = UDim2.new(1,0,0,0)
devHintTxt.AutomaticSize = Enum.AutomaticSize.Y
devHintTxt.BackgroundTransparency = 1
devHintTxt.Text = ""
devHintTxt.TextColor3 = C.warning
devHintTxt.TextSize   = 11
devHintTxt.Font       = Enum.Font.GothamBold
devHintTxt.TextXAlignment = Enum.TextXAlignment.Left
devHintTxt.TextWrapped = true
devHintTxt.ZIndex = 104
devHintTxt.Parent = devHint

local emailWrap = Instance.new("Frame")
emailWrap.Size = UDim2.new(1,0,0,56)
emailWrap.BackgroundColor3 = C.surface2
emailWrap.BorderSizePixel  = 0
emailWrap.LayoutOrder = 4
emailWrap.ZIndex = 104
emailWrap.Parent = screen2
addCorner(emailWrap, 8)
local emailStroke = Instance.new("UIStroke")
emailStroke.Color     = C.border2
emailStroke.Thickness = 1.5
emailStroke.Parent    = emailWrap

local emailCodeInput = Instance.new("TextBox")
emailCodeInput.Size = UDim2.new(1,-24,1,-14)
emailCodeInput.Position = UDim2.new(0,12,0,7)
emailCodeInput.BackgroundTransparency = 1
emailCodeInput.PlaceholderText  = "000000"
emailCodeInput.PlaceholderColor3 = C.muted
emailCodeInput.Text      = ""
emailCodeInput.TextColor3 = C.text
emailCodeInput.TextSize   = 28
emailCodeInput.Font       = Enum.Font.GothamBold
emailCodeInput.TextXAlignment = Enum.TextXAlignment.Center
emailCodeInput.ClearTextOnFocus = false
emailCodeInput.ZIndex = 105
emailCodeInput.Parent = emailWrap

emailCodeInput.Focused:Connect(function()
	TweenService:Create(emailStroke, TweenInfo.new(0.18), {Color = C.success}):Play()
	TweenService:Create(emailWrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface3}):Play()
end)
emailCodeInput.FocusLost:Connect(function()
	TweenService:Create(emailStroke, TweenInfo.new(0.18), {Color = C.border2}):Play()
	TweenService:Create(emailWrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface2}):Play()
end)

local authError2 = Instance.new("TextLabel")
authError2.Size = UDim2.new(1,0,0,0)
authError2.AutomaticSize = Enum.AutomaticSize.Y
authError2.BackgroundColor3 = C.dangerDim
authError2.BorderSizePixel  = 0
authError2.Text     = ""
authError2.TextColor3 = C.danger
authError2.TextSize   = 11
authError2.Font       = Enum.Font.GothamBold
authError2.TextXAlignment = Enum.TextXAlignment.Left
authError2.TextWrapped = true
authError2.Visible   = false
authError2.LayoutOrder = 5
authError2.ZIndex = 104
authError2.Parent = screen2
addCorner(authError2, 6)
addPadding(authError2, 6, 6, 10, 10)

local unlockBtn = Instance.new("TextButton")
unlockBtn.Size = UDim2.new(1,0,0,44)
unlockBtn.BackgroundColor3 = C.success
unlockBtn.TextColor3 = Color3.new(1,1,1)
unlockBtn.Text     = "Unlock Plugin  →"
unlockBtn.TextSize  = 13
unlockBtn.Font      = Enum.Font.GothamBold
unlockBtn.BorderSizePixel = 0
unlockBtn.AutoButtonColor = false
unlockBtn.LayoutOrder = 6
unlockBtn.ZIndex = 104
unlockBtn.Parent = screen2
addCorner(unlockBtn, 8)
local unlockGrad = Instance.new("UIGradient")
unlockGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 197,  94)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 185, 129)),
})
unlockGrad.Rotation = 135
unlockGrad.Parent = unlockBtn

unlockBtn.MouseEnter:Connect(function()
	TweenService:Create(unlockBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(72, 231, 173)}):Play()
end)
unlockBtn.MouseLeave:Connect(function()
	TweenService:Create(unlockBtn, TweenInfo.new(0.12), {BackgroundColor3 = C.success}):Play()
end)
unlockBtn.MouseButton1Down:Connect(function()
	playClick()
	TweenService:Create(unlockBtn, TweenInfo.new(0.06), {Size = UDim2.new(1,0,0,41)}):Play()
end)
unlockBtn.MouseButton1Up:Connect(function()
	TweenService:Create(unlockBtn, TweenInfo.new(0.1), {Size = UDim2.new(1,0,0,44)}):Play()
end)

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(1,0,0,28)
backBtn.BackgroundTransparency = 1
backBtn.TextColor3 = C.muted
backBtn.Text     = "← Go Back"
backBtn.TextSize  = 12
backBtn.Font      = Enum.Font.GothamBold
backBtn.BorderSizePixel = 0
backBtn.AutoButtonColor = false
backBtn.LayoutOrder = 7
backBtn.ZIndex = 104
backBtn.Parent = screen2
backBtn.MouseEnter:Connect(function()
	TweenService:Create(backBtn, TweenInfo.new(0.12), {TextColor3 = C.textDim}):Play()
end)
backBtn.MouseLeave:Connect(function()
	TweenService:Create(backBtn, TweenInfo.new(0.12), {TextColor3 = C.muted}):Play()
end)
backBtn.MouseButton1Down:Connect(function() playClick() end)

-- ── AUTH STATE & FLOW ──
local pendingPluginKey = ""

local function showAuthScreen(n)
	screen1.Visible = (n == 1)
	screen2.Visible = (n == 2)
end

local function hideAuth()
	TweenService:Create(authScreen, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	task.delay(0.45, function()
		authScreen.Visible = false
	end)
end

local function showAuthError(scr, msg)
	if scr == 1 then
		authError1.Text    = "  ⚠  " .. msg
		authError1.Visible = true
	else
		authError2.Text    = "  ⚠  " .. msg
		authError2.Visible = true
	end
end

-- CONNECT button logic
verifyBtn.MouseButton1Click:Connect(function()
	local key = actCodeInput.Text:match("^%s*(.-)%s*$"):upper()
	if key == "" then showAuthError(1, "Paste your plugin key first."); return end
	if not key:match("^SC%-%w+%-%w+$") then showAuthError(1, "Format must be SC-XXXXX-XXXXX"); return end
	authError1.Visible = false
	verifyBtn.Text = "Connecting..."
	verifyBtn.BackgroundColor3 = C.surface3

	task.spawn(function()
		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/plugin/connect",
				HttpService:JSONEncode({plugin_key = key}),
				Enum.HttpContentType.ApplicationJson
			)
		end)
		verifyBtn.Text = "Connect  →"
		TweenService:Create(verifyBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()

		if not ok then showAuthError(1, "Cannot connect to server."); return end

		local data = HttpService:JSONDecode(result)
		if data.error then showAuthError(1, data.error); return end

		pendingPluginKey = key
		plugin:SetSetting(PLUGKEY_KEY, key)

		if data.email_preview then
			authSub2.Text = "Code sent to " .. data.email_preview .. ". Check spam too."
		end
		if data.dev_code then
			devHintTxt.Text = "⚡ Dev mode — your code is: " .. tostring(data.dev_code)
			devHint.Visible = true
		else
			devHint.Visible = false
		end

		emailCodeInput.Text = ""
		authError2.Visible  = false
		showAuthScreen(2)
	end)
end)

backBtn.MouseButton1Click:Connect(function()
	showAuthScreen(1)
end)

-- UNLOCK button logic
unlockBtn.MouseButton1Click:Connect(function()
	local code = emailCodeInput.Text:match("^%s*(.-)%s*$")
	if code == "" then showAuthError(2, "Enter the 6-digit code."); return end
	authError2.Visible = false
	unlockBtn.Text = "Unlocking..."
	unlockBtn.BackgroundColor3 = C.surface3

	task.spawn(function()
		local ok, result = pcall(function()
			return HttpService:PostAsync(
				BASE_URL .. "/plugin/confirm",
				HttpService:JSONEncode({plugin_key = pendingPluginKey, email_code = code}),
				Enum.HttpContentType.ApplicationJson
			)
		end)
		unlockBtn.Text = "Unlock Plugin  →"
		TweenService:Create(unlockBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.success}):Play()

		if not ok then showAuthError(2, "Cannot connect to server."); return end

		local data = HttpService:JSONDecode(result)
		if data.error then showAuthError(2, data.error); return end

		plugin:SetSetting(SESSION_KEY, data.session_token)
		savedSession = data.session_token
		hideAuth()
	end)
end)

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
			if data.valid then hideAuth(); return end
		end
		plugin:SetSetting(SESSION_KEY, "")
		savedSession = ""
		showAuthScreen(1)
		authScreen.Visible = true
	end)
end


-- ══════════════════════════════════════════════════════════════
-- MAIN SCROLL CONTAINER
-- ══════════════════════════════════════════════════════════════
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.accent
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ZIndex = 3
scroll.Parent = root

-- Panel crossfade overlay (sits above content, briefly flashes on tab switch)
local panelOverlay = Instance.new("Frame")
panelOverlay.Size = UDim2.new(1,0,1,0)
panelOverlay.BackgroundColor3 = C.bg
panelOverlay.BackgroundTransparency = 1
panelOverlay.BorderSizePixel = 0
panelOverlay.ZIndex = 50
panelOverlay.Active = false
panelOverlay.Parent = root

local mainLayout = Instance.new("UIListLayout")
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding    = UDim.new(0,0)
mainLayout.Parent     = scroll

-- ══════════════════════════════════════════════════════════════
-- THEME REGISTRY
-- ══════════════════════════════════════════════════════════════
local themeRegistry = {}
local function reg(obj, prop, colorKey)
	table.insert(themeRegistry, {obj=obj, prop=prop, key=colorKey})
end

local function applyTheme()
	root.BackgroundColor3       = C.bg
	topGlow.BackgroundColor3    = C.accent
	authScreen.BackgroundColor3 = C.bg
	scroll.ScrollBarImageColor3 = C.accent

	authLogoWrap.BackgroundColor3 = C.accent
	authTitle.TextColor3    = C.text
	authSub.TextColor3      = C.textDim
	authDivider.BackgroundColor3 = C.border
	stepTxt1.TextColor3 = C.textDim
	stepTxt2.TextColor3 = C.textDim
	stepNum1.BackgroundColor3 = C.accentDim
	stepNum1Txt.TextColor3    = C.accent
	stepNum2.BackgroundColor3 = C.successDim
	sn2t.TextColor3           = C.success
	actWrap.BackgroundColor3  = C.surface2
	actStroke.Color           = C.border2
	actCodeInput.TextColor3   = C.text
	actCodeInput.PlaceholderColor3 = C.muted
	keyIcon.BackgroundColor3  = C.border
	keyIcon.TextColor3        = C.muted
	emailWrap.BackgroundColor3 = C.surface2
	emailStroke.Color          = C.border2
	emailCodeInput.TextColor3  = C.text
	emailCodeInput.PlaceholderColor3 = C.muted
	authError1.BackgroundColor3 = C.dangerDim
	authError1.TextColor3       = C.danger
	authError2.BackgroundColor3 = C.dangerDim
	authError2.TextColor3       = C.danger
	devHint.BackgroundColor3    = C.goldDim
	devHintTxt.TextColor3       = C.warning
	verifyBtn.BackgroundColor3  = C.accent
	unlockBtn.BackgroundColor3  = C.success
	backBtn.TextColor3          = C.muted
	authNote1.TextColor3        = C.muted
	authSub2.TextColor3         = C.textDim
	authCardBorder.BackgroundColor3 = C.border2
	authCard.BackgroundColor3   = C.surface

	for _, gl in ipairs(gridLines) do
		gl.BackgroundColor3 = C.grid
	end
	for _, entry in ipairs(themeRegistry) do
		entry.obj[entry.prop] = C[entry.key]
	end
end

-- ══════════════════════════════════════════════════════════════
-- HELPERS (addPadding, addCorner, addStroke defined earlier)
-- ══════════════════════════════════════════════════════════════

local function makeSection(order, pt, pb)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1,0,0,0)
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.BackgroundTransparency = 1
	f.LayoutOrder = order
	f.Parent = scroll
	addPadding(f, pt or 10, pb or 0, 14, 14)
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding    = UDim.new(0, 7)
	l.Parent     = f
	return f
end

-- Section header label (left accent bar style)
local function makeSectionLabel(text, colorKey, parent, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,16)
	row.BackgroundTransparency = 1
	row.LayoutOrder = order or 0
	row.Parent = parent

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0,2,1,0)
	bar.BackgroundColor3 = C[colorKey]
	bar.BorderSizePixel  = 0
	bar.Parent = row
	addCorner(bar, 2)
	reg(bar, "BackgroundColor3", colorKey)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-10,1,0)
	lbl.Position = UDim2.new(0,8,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text     = text
	lbl.TextColor3 = C[colorKey]
	lbl.TextSize   = 11
	lbl.Font       = Enum.Font.GothamBold
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	reg(lbl, "TextColor3", colorKey)

	return row
end

local function makeInput(placeholder, height, parent, order, multiline)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1,0,0,height)
	wrap.BackgroundColor3 = C.surface2
	wrap.BorderSizePixel  = 0
	wrap.LayoutOrder = order or 0
	wrap.Parent = parent
	addCorner(wrap, 8)
	local stroke = addStroke(wrap, C.border2, 1.5)
	reg(wrap,   "BackgroundColor3", "surface2")
	reg(stroke, "Color",            "border2")

	-- Glass top-shine
	local inputShine = Instance.new("Frame")
	inputShine.Size = UDim2.new(1,-8,0,1)
	inputShine.Position = UDim2.new(0,4,0,2)
	inputShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
	inputShine.BackgroundTransparency = 0.82
	inputShine.BorderSizePixel = 0
	inputShine.ZIndex = wrap.ZIndex + 1
	inputShine.Active = false
	inputShine.Parent = wrap
	addCorner(inputShine, 2)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1,-20,1,-12)
	box.Position = UDim2.new(0,10,0,6)
	box.BackgroundTransparency = 1
	box.TextColor3 = C.text
	box.PlaceholderText  = placeholder
	box.PlaceholderColor3 = C.muted
	box.Text     = ""
	box.TextSize  = 12
	box.Font      = Enum.Font.Gotham
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.MultiLine   = multiline or false
	box.ClearTextOnFocus = false
	box.TextWrapped = true
	box.Parent = wrap
	reg(box, "TextColor3",        "text")
	reg(box, "PlaceholderColor3", "muted")

	box.Focused:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.18), {Color = C.accent}):Play()
		TweenService:Create(wrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface3}):Play()
	end)
	box.FocusLost:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.18), {Color = C.border2}):Play()
		TweenService:Create(wrap,   TweenInfo.new(0.18), {BackgroundColor3 = C.surface2}):Play()
	end)
	return box, wrap
end

local function makeBtn(text, colorKey, parent, order, height, isOutline)
	local h   = height or 38
	local btn = Instance.new("TextButton")
	btn.Size  = UDim2.new(1,0,0,h)
	btn.BackgroundColor3 = isOutline and C.surface2 or C[colorKey]
	btn.TextColor3 = isOutline and C[colorKey] or C.white
	btn.Text     = text
	btn.TextSize  = 12
	btn.Font      = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.LayoutOrder = order or 0
	addCorner(btn, 8)
	btn.Parent = parent
	if not isOutline then reg(btn, "BackgroundColor3", colorKey) end
	reg(btn, "TextColor3", isOutline and colorKey or "white")

	-- Glass top-shine highlight
	local topShine = Instance.new("Frame")
	topShine.Size = UDim2.new(1,-6,0,1)
	topShine.Position = UDim2.new(0,3,0,2)
	topShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
	topShine.BackgroundTransparency = isOutline and 0.82 or 0.72
	topShine.BorderSizePixel = 0
	topShine.ZIndex = btn.ZIndex + 1
	topShine.Active = false
	topShine.Parent = btn
	addCorner(topShine, 2)

	-- Glow stroke (animates on hover)
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = isOutline and C[colorKey] or Color3.fromRGB(255,255,255)
	glowStroke.Thickness = 0
	glowStroke.Transparency = isOutline and 0.4 or 0.7
	glowStroke.Parent = btn

	if isOutline then
		local s = addStroke(btn, C[colorKey], 1.5)
		reg(s, "Color", colorKey)
	end

	btn.MouseEnter:Connect(function()
		local col = C[colorKey]
		if isOutline then
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface3}):Play()
		else
			TweenService:Create(btn, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.new(
					math.min(col.R+0.08,1), math.min(col.G+0.08,1), math.min(col.B+0.08,1)
				)
			}):Play()
		end
		TweenService:Create(glowStroke, TweenInfo.new(0.15), {Thickness = 1.5}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isOutline and C.surface2 or C[colorKey]
		}):Play()
		TweenService:Create(glowStroke, TweenInfo.new(0.2), {Thickness = 0}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		playClick()
		TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad), {Size = UDim2.new(1,0,0,h-3)}):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,h)}):Play()
	end)
	return btn
end

local function makeSplitBtns(t1, ck1, t2, ck2, parent, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,38)
	row.BackgroundTransparency = 1
	row.LayoutOrder = order or 0
	row.Parent = parent
	local rl = Instance.new("UIListLayout")
	rl.FillDirection = Enum.FillDirection.Horizontal
	rl.Padding = UDim.new(0,7)
	rl.Parent  = row

	local function makeHalf(text, ck)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5,-4,1,0)
		b.BackgroundColor3 = C[ck]
		b.TextColor3 = C.white
		b.Text     = text
		b.TextSize  = 11
		b.Font      = Enum.Font.GothamBold
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		addCorner(b, 8)
		b.Parent = row
		reg(b, "BackgroundColor3", ck)
		reg(b, "TextColor3", "white")
		b.MouseEnter:Connect(function()
			local col = C[ck]
			TweenService:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = Color3.new(math.min(col.R+0.07,1), math.min(col.G+0.07,1), math.min(col.B+0.07,1))
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C[ck]}):Play()
		end)
		b.MouseButton1Down:Connect(function()
			playClick()
			TweenService:Create(b, TweenInfo.new(0.06), {Size = UDim2.new(0.5,-4,1,-2)}):Play()
		end)
		b.MouseButton1Up:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(0.5,-4,1,0)}):Play()
		end)
		return b
	end
	return makeHalf(t1,ck1), makeHalf(t2,ck2), row
end

local function makeDivider(order)
	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1,0,0,13)
	wrap.BackgroundTransparency = 1
	wrap.LayoutOrder = order
	wrap.Parent = scroll
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1,-28,0,1)
	d.Position = UDim2.new(0,14,0.5,0)
	d.BackgroundColor3 = C.border
	d.BorderSizePixel  = 0
	d.Parent = wrap
	reg(d, "BackgroundColor3", "border")
	return wrap
end

local function makeDropdown(options, parent, order)
	local selected = options[1]

	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1,0,0,40)
	wrap.BackgroundColor3 = C.surface2
	wrap.BorderSizePixel  = 0
	wrap.LayoutOrder = order or 0
	wrap.Parent = parent
	addCorner(wrap, 8)
	local stroke = addStroke(wrap, C.border2, 1.5)
	reg(wrap, "BackgroundColor3", "surface2")
	reg(stroke, "Color", "border2")

	local selectedTxt = Instance.new("TextLabel")
	selectedTxt.Size = UDim2.new(1,-40,1,0)
	selectedTxt.Position = UDim2.new(0,12,0,0)
	selectedTxt.BackgroundTransparency = 1
	selectedTxt.Text     = selected
	selectedTxt.TextColor3 = C.text
	selectedTxt.TextSize   = 12
	selectedTxt.Font       = Enum.Font.Gotham
	selectedTxt.TextXAlignment = Enum.TextXAlignment.Left
	selectedTxt.Parent = wrap
	reg(selectedTxt, "TextColor3", "text")

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0,28,0,28)
	arrow.Position = UDim2.new(1,-34,0.5,-14)
	arrow.BackgroundColor3 = C.border
	arrow.BorderSizePixel  = 0
	arrow.Text     = "▾"
	arrow.TextColor3 = C.muted
	arrow.TextSize   = 12
	arrow.Font       = Enum.Font.GothamBold
	arrow.Parent     = wrap
	addCorner(arrow, 6)
	reg(arrow, "BackgroundColor3", "border")
	reg(arrow, "TextColor3", "muted")

	local optionsFrame = Instance.new("Frame")
	optionsFrame.Size = UDim2.new(1,0,0, #options * 32)
	optionsFrame.BackgroundColor3 = C.surface3
	optionsFrame.BorderSizePixel  = 0
	optionsFrame.LayoutOrder = (order or 0) + 1
	optionsFrame.Visible = false
	optionsFrame.ZIndex  = 10
	optionsFrame.Parent  = parent
	addCorner(optionsFrame, 8)
	local optStroke = addStroke(optionsFrame, C.border2, 1.5)
	reg(optionsFrame, "BackgroundColor3", "surface3")
	reg(optStroke, "Color", "border2")

	local optLayout = Instance.new("UIListLayout")
	optLayout.SortOrder = Enum.SortOrder.LayoutOrder
	optLayout.Parent    = optionsFrame

	for i, opt in ipairs(options) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1,0,0,32)
		optBtn.BackgroundTransparency = 1
		optBtn.TextColor3 = C.text
		optBtn.Text     = opt
		optBtn.TextSize  = 12
		optBtn.Font      = Enum.Font.Gotham
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.BorderSizePixel = 0
		optBtn.LayoutOrder = i
		optBtn.ZIndex = 10
		addPadding(optBtn, 0, 0, 12, 0)
		optBtn.Parent = optionsFrame
		reg(optBtn, "TextColor3", "text")

		optBtn.MouseEnter:Connect(function()
			TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = C.surfaceHov}):Play()
			optBtn.BackgroundTransparency = 0
		end)
		optBtn.MouseLeave:Connect(function()
			optBtn.BackgroundTransparency = 1
		end)
		optBtn.MouseButton1Click:Connect(function()
			playClick()
			selected = opt
			selectedTxt.Text = opt
			optionsFrame.Visible = false
			TweenService:Create(stroke, TweenInfo.new(0.15), {Color = C.border2}):Play()
		end)
	end

	local clickDetect = Instance.new("TextButton")
	clickDetect.Size = UDim2.new(1,0,1,0)
	clickDetect.BackgroundTransparency = 1
	clickDetect.Text = ""
	clickDetect.BorderSizePixel = 0
	clickDetect.ZIndex = 5
	clickDetect.Parent = wrap
	clickDetect.MouseButton1Click:Connect(function()
		playClick()
		optionsFrame.Visible = not optionsFrame.Visible
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = optionsFrame.Visible and C.accent or C.border2
		}):Play()
	end)

	return wrap, optionsFrame, function() return selected end
end

-- ══════════════════════════════════════════════════════════════
-- PREMIUM HEADER
-- ══════════════════════════════════════════════════════════════
local brand, pulseBrandRunning, pulseBrand
local statusPill, statusStroke, statusDot, statusTxt
local themeToggle
do
local headerBg = Instance.new("Frame")
headerBg.Size = UDim2.new(1,0,0,84)
headerBg.BackgroundColor3 = C.surface
headerBg.BorderSizePixel  = 0
headerBg.LayoutOrder = 1
headerBg.Parent = scroll
reg(headerBg, "BackgroundColor3", "surface")

-- Bottom border on header
local headerBorder = Instance.new("Frame")
headerBorder.Size = UDim2.new(1,0,0,1)
headerBorder.Position = UDim2.new(0,0,1,-1)
headerBorder.BackgroundColor3 = C.border
headerBorder.BorderSizePixel  = 0
headerBorder.Parent = headerBg
reg(headerBorder, "BackgroundColor3", "border")

-- Gradient bar at top of header (3px, blue→cyan→purple)
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(1,0,0,3)
accentBar.BackgroundColor3 = C.accent
accentBar.BorderSizePixel  = 0
accentBar.Parent = headerBg
local accentBarGrad = Instance.new("UIGradient")
accentBarGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(139,  92, 246)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB( 99, 102, 241)),
})
accentBarGrad.Parent = accentBar

local headerPad = Instance.new("Frame")
headerPad.Size = UDim2.new(1,-28,1,-3)
headerPad.Position = UDim2.new(0,14,0,3)
headerPad.BackgroundTransparency = 1
headerPad.Parent = headerBg

-- Logo mark
local logoMark = Instance.new("Frame")
logoMark.Size = UDim2.new(0,38,0,38)
logoMark.Position = UDim2.new(0,0,0.5,-19)
logoMark.BackgroundColor3 = C.accent
logoMark.BorderSizePixel  = 0
logoMark.Parent = headerPad
addCorner(logoMark, 10)
local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139,  92, 246)),
})
logoGrad.Rotation = 135
logoGrad.Parent   = logoMark

local logoTxt = Instance.new("TextLabel")
logoTxt.Size = UDim2.new(1,0,1,0)
logoTxt.BackgroundTransparency = 1
logoTxt.Text     = "SC"
logoTxt.TextColor3 = Color3.new(1,1,1)
logoTxt.TextSize   = 13
logoTxt.Font       = Enum.Font.GothamBold
logoTxt.Parent     = logoMark

-- Brand text
brand = Instance.new("TextLabel")
brand.Size = UDim2.new(0,130,0,20)
brand.Position = UDim2.new(0,48,0,18)
brand.BackgroundTransparency = 1
brand.Text     = "StudCoding"
brand.TextColor3 = C.text
brand.TextSize   = 15
brand.Font       = Enum.Font.GothamBold
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.Parent = headerPad
reg(brand, "TextColor3", "text")

-- Version badge
local vBadge = Instance.new("Frame")
vBadge.Size = UDim2.new(0,26,0,14)
vBadge.Position = UDim2.new(0,182,0,22)
vBadge.BackgroundColor3 = C.accentDim
vBadge.BorderSizePixel  = 0
vBadge.Parent = headerPad
addCorner(vBadge, 4)
reg(vBadge, "BackgroundColor3", "accentDim")
local vBadgeTxt = Instance.new("TextLabel")
vBadgeTxt.Size = UDim2.new(1,0,1,0)
vBadgeTxt.BackgroundTransparency = 1
vBadgeTxt.Text     = "v16"
vBadgeTxt.TextColor3 = C.accent
vBadgeTxt.TextSize   = 10
vBadgeTxt.Font       = Enum.Font.GothamBold
vBadgeTxt.Parent     = vBadge
reg(vBadgeTxt, "TextColor3", "accent")

local tagline = Instance.new("TextLabel")
tagline.Size = UDim2.new(0,180,0,14)
tagline.Position = UDim2.new(0,48,0,40)
tagline.BackgroundTransparency = 1
tagline.Text     = "Your game. Perfected by AI."
tagline.TextColor3 = C.muted
tagline.TextSize   = 11
tagline.Font       = Enum.Font.Gotham
tagline.TextXAlignment = Enum.TextXAlignment.Left
tagline.Parent = headerPad
reg(tagline, "TextColor3", "muted")

-- Pulsing brand animation
pulseBrandRunning = false
pulseBrand = function()
	if pulseBrandRunning then return end
	pulseBrandRunning = true
	while pulseBrandRunning do
		TweenService:Create(brand, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{TextColor3 = C.accent}):Play()
		task.wait(2)
		if not pulseBrandRunning then break end
		TweenService:Create(brand, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{TextColor3 = C.text}):Play()
		task.wait(2)
	end
end

-- Theme toggle (pill style)
themeToggle = Instance.new("TextButton")
themeToggle.Size = UDim2.new(0,40,0,20)
themeToggle.Position = UDim2.new(1,-148,0.5,-10)
themeToggle.BackgroundColor3 = C.surface3
themeToggle.TextColor3 = C.muted
themeToggle.Text     = "Light"
themeToggle.TextSize  = 11
themeToggle.Font      = Enum.Font.GothamBold
themeToggle.BorderSizePixel = 0
themeToggle.AutoButtonColor = false
themeToggle.Parent = headerPad
addCorner(themeToggle, 6)
local themeStroke = addStroke(themeToggle, C.border2, 1)
reg(themeToggle, "BackgroundColor3", "surface3")
reg(themeToggle, "TextColor3", "muted")
reg(themeStroke, "Color", "border2")
themeToggle.MouseButton1Down:Connect(function() playClick() end)
themeToggle.MouseEnter:Connect(function()
	TweenService:Create(themeToggle, TweenInfo.new(0.12), {BackgroundColor3 = C.surfaceHov}):Play()
end)
themeToggle.MouseLeave:Connect(function()
	TweenService:Create(themeToggle, TweenInfo.new(0.12), {BackgroundColor3 = C.surface3}):Play()
end)

-- Sign out button
local signOutBtn = Instance.new("TextButton")
signOutBtn.Size = UDim2.new(0,52,0,20)
signOutBtn.Position = UDim2.new(1,-100,0.5,-10)
signOutBtn.BackgroundTransparency = 1
signOutBtn.TextColor3 = C.muted
signOutBtn.Text     = "sign out"
signOutBtn.TextSize  = 11
signOutBtn.Font      = Enum.Font.GothamBold
signOutBtn.BorderSizePixel = 0
signOutBtn.AutoButtonColor = false
signOutBtn.Parent = headerPad
reg(signOutBtn, "TextColor3", "muted")
signOutBtn.MouseEnter:Connect(function()
	TweenService:Create(signOutBtn, TweenInfo.new(0.12), {TextColor3 = C.danger}):Play()
end)
signOutBtn.MouseLeave:Connect(function()
	TweenService:Create(signOutBtn, TweenInfo.new(0.12), {TextColor3 = C.muted}):Play()
end)
signOutBtn.MouseButton1Click:Connect(function()
	playClick()
	plugin:SetSetting(SESSION_KEY, "")
	plugin:SetSetting(PLUGKEY_KEY, "")
	savedSession = ""
	actCodeInput.Text  = ""
	emailCodeInput.Text = ""
	authError1.Visible  = false
	authError2.Visible  = false
	devHint.Visible     = false
	showAuthScreen(1)
	authScreen.BackgroundTransparency = 0
	authScreen.Visible = true
end)

-- Status pill
statusPill = Instance.new("Frame")
statusPill.Size = UDim2.new(0,60,0,20)
statusPill.Position = UDim2.new(1,-44,0.5,-10)
statusPill.BackgroundColor3 = C.successDim
statusPill.BorderSizePixel  = 0
statusPill.Parent = headerPad
addCorner(statusPill, 99)
statusStroke = addStroke(statusPill, C.success, 1)

statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0,6,0,6)
statusDot.Position = UDim2.new(0,8,0.5,-3)
statusDot.BackgroundColor3 = C.success
statusDot.BorderSizePixel  = 0
statusDot.Parent = statusPill
addCorner(statusDot, 99)

statusTxt = Instance.new("TextLabel")
statusTxt.Size = UDim2.new(1,-18,1,0)
statusTxt.Position = UDim2.new(0,16,0,0)
statusTxt.BackgroundTransparency = 1
statusTxt.Text     = "ONLINE"
statusTxt.TextColor3 = C.success
statusTxt.TextSize   = 10
statusTxt.Font       = Enum.Font.GothamBold
statusTxt.Parent     = statusPill

end -- header do block

local function pulseStatusDot()
	while true do
		TweenService:Create(statusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0,8,0,8), Position = UDim2.new(0,7,0.5,-4)
		}):Play()
		task.wait(0.9)
		TweenService:Create(statusDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0,6,0,6), Position = UDim2.new(0,8,0.5,-3)
		}):Play()
		task.wait(0.9)
	end
end

-- ══════════════════════════════════════════════════════════════
-- NAV TABS — PILL STYLE
-- ══════════════════════════════════════════════════════════════
local navFix, navWrite, navInsights
do
local navSection = makeSection(2, 10, 0)
local navRow = Instance.new("Frame")
navRow.Size = UDim2.new(1,0,0,36)
navRow.BackgroundColor3 = C.surface2
navRow.BorderSizePixel  = 0
navRow.LayoutOrder = 1
navRow.Parent = navSection
addCorner(navRow, 8)
addStroke(navRow, C.border, 1)
reg(navRow, "BackgroundColor3", "surface2")

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.SortOrder     = Enum.SortOrder.LayoutOrder
navLayout.Parent        = navRow

local function makeNavBtn(text, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1/3,0,1,0)
	btn.BackgroundTransparency = 1
	btn.TextColor3 = C.muted
	btn.Text     = text
	btn.TextSize  = 12
	btn.Font      = Enum.Font.GothamBold
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	addCorner(btn, 8)
	btn.Parent = navRow
	reg(btn, "TextColor3", "muted")
	btn.MouseButton1Down:Connect(function() playClick() end)
	return btn
end

navFix      = makeNavBtn("⚡ Fix",     1)
navWrite    = makeNavBtn("✦ Write",   2)
navInsights = makeNavBtn("◈ Insights", 3)
end -- nav do block

makeDivider(3)

-- ══════════════════════════════════════════════════════════════
-- GAME MEMORY
-- ══════════════════════════════════════════════════════════════
local memSection = makeSection(4, 12, 0)

makeSectionLabel("GAME MEMORY", "muted", memSection, 1)

local memCard = Instance.new("Frame")
memCard.Size = UDim2.new(1,0,0,48)
memCard.BackgroundColor3 = C.surface
memCard.BorderSizePixel  = 0
memCard.LayoutOrder = 2
memCard.Parent = memSection
addCorner(memCard, 8)
local memStroke = addStroke(memCard, C.border, 1)
reg(memCard, "BackgroundColor3", "surface")
reg(memStroke, "Color", "border")

local memIconWrap = Instance.new("Frame")
memIconWrap.Size = UDim2.new(0,32,0,32)
memIconWrap.Position = UDim2.new(0,8,0.5,-16)
memIconWrap.BackgroundColor3 = C.faint
memIconWrap.BorderSizePixel  = 0
memIconWrap.Parent = memCard
addCorner(memIconWrap, 8)
reg(memIconWrap, "BackgroundColor3", "faint")
local memIcon = Instance.new("TextLabel")
memIcon.Size = UDim2.new(1,0,1,0)
memIcon.BackgroundTransparency = 1
memIcon.Text     = "○"
memIcon.TextColor3 = C.muted
memIcon.TextSize   = 14
memIcon.Font       = Enum.Font.GothamBold
memIcon.Parent     = memIconWrap
reg(memIcon, "TextColor3", "muted")

local memTxt = Instance.new("TextLabel")
memTxt.Size = UDim2.new(1,-56,0,16)
memTxt.Position = UDim2.new(0,48,0.5,-8)
memTxt.BackgroundTransparency = 1
memTxt.Text     = "No game memory saved"
memTxt.TextColor3 = C.muted
memTxt.TextSize   = 11
memTxt.Font       = Enum.Font.GothamBold
memTxt.TextXAlignment = Enum.TextXAlignment.Left
memTxt.TextTruncate   = Enum.TextTruncate.AtEnd
memTxt.Parent = memCard
reg(memTxt, "TextColor3", "muted")

local scanBtn = makeBtn("⊕  Deep Scan Workspace", "accent", memSection, 3, 38)

local sumCard = Instance.new("Frame")
sumCard.Size = UDim2.new(1,0,0,0)
sumCard.BackgroundColor3 = C.surface
sumCard.BorderSizePixel  = 0
sumCard.ClipsDescendants = true
sumCard.LayoutOrder = 4
sumCard.Parent = memSection
addCorner(sumCard, 8)
local sumStroke = addStroke(sumCard, C.cyanDim, 1.5)
reg(sumCard, "BackgroundColor3", "surface")
reg(sumStroke, "Color", "cyanDim")

local sumTxt = Instance.new("TextLabel")
sumTxt.Size = UDim2.new(1,-16,1,-16)
sumTxt.Position = UDim2.new(0,8,0,8)
sumTxt.BackgroundTransparency = 1
sumTxt.Text     = ""
sumTxt.TextColor3 = C.textDim
sumTxt.TextSize   = 11
sumTxt.Font       = Enum.Font.Gotham
sumTxt.TextXAlignment = Enum.TextXAlignment.Left
sumTxt.TextYAlignment = Enum.TextYAlignment.Top
sumTxt.TextWrapped    = true
sumTxt.Parent = sumCard
reg(sumTxt, "TextColor3", "textDim")

local approveBtn, rejectBtn, approveRow = makeSplitBtns(
	"✓  Looks Correct", "success",
	"✗  Wrong",         "danger",
	memSection, 5
)
approveRow.Visible = false

makeDivider(5)

-- ══════════════════════════════════════════════════════════════
-- FIX PANEL
-- ══════════════════════════════════════════════════════════════
local fixPanel = makeSection(6, 12, 14)

makeSectionLabel("FIX A SCRIPT", "accent", fixPanel, 1)
local scriptBox, _ = makeInput("Script name  (e.g. ShopHandler)", 40, fixPanel, 2, false)

makeSectionLabel("DESCRIBE THE ISSUE", "muted", fixPanel, 3)
local issueBox, _  = makeInput("e.g. Players are not getting coins after purchase...", 76, fixPanel, 4, true)

local attemptsCard = Instance.new("Frame")
attemptsCard.Size = UDim2.new(1,0,0,0)
attemptsCard.BackgroundColor3 = C.surface
attemptsCard.BorderSizePixel  = 0
attemptsCard.ClipsDescendants = true
attemptsCard.LayoutOrder = 5
attemptsCard.Parent = fixPanel
addCorner(attemptsCard, 8)
local attStroke = addStroke(attemptsCard, C.border, 1)
reg(attemptsCard, "BackgroundColor3", "surface")
reg(attStroke, "Color", "border")

local attemptsTxt = Instance.new("TextLabel")
attemptsTxt.Size = UDim2.new(1,-16,1,-12)
attemptsTxt.Position = UDim2.new(0,8,0,6)
attemptsTxt.BackgroundTransparency = 1
attemptsTxt.Text     = ""
attemptsTxt.TextColor3 = C.warning
attemptsTxt.TextSize   = 11
attemptsTxt.Font       = Enum.Font.GothamBold
attemptsTxt.TextXAlignment = Enum.TextXAlignment.Left
attemptsTxt.Parent = attemptsCard
reg(attemptsTxt, "TextColor3", "warning")

local fixBtn   = makeBtn("⚡  Fix Script",             "accent",  fixPanel, 6, 42)
local watchBtn = makeBtn("▶  Run + Watch for Errors",  "green",   fixPanel, 7, 36)

-- Gradient on fixBtn
local fixBtnGrad = Instance.new("UIGradient")
fixBtnGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB( 99, 102, 241)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(139,  92, 246)),
})
fixBtnGrad.Rotation = 135
fixBtnGrad.Parent = fixBtn

local watchCard = Instance.new("Frame")
watchCard.Size = UDim2.new(1,0,0,0)
watchCard.BackgroundColor3 = C.successDim
watchCard.BorderSizePixel  = 0
watchCard.ClipsDescendants = true
watchCard.LayoutOrder = 8
watchCard.Parent = fixPanel
addCorner(watchCard, 8)
local watchStroke = addStroke(watchCard, C.success, 1)
reg(watchCard, "BackgroundColor3", "successDim")
reg(watchStroke, "Color", "success")

local watchTxt = Instance.new("TextLabel")
watchTxt.Size = UDim2.new(1,-16,1,-12)
watchTxt.Position = UDim2.new(0,8,0,6)
watchTxt.BackgroundTransparency = 1
watchTxt.Text     = ""
watchTxt.TextColor3 = C.success
watchTxt.TextSize   = 11
watchTxt.Font       = Enum.Font.GothamBold
watchTxt.TextXAlignment = Enum.TextXAlignment.Left
watchTxt.Parent = watchCard
reg(watchTxt, "TextColor3", "success")

local stopWatchBtn = makeBtn("■  Stop Watching", "danger", fixPanel, 9, 32)
stopWatchBtn.Visible  = false
stopWatchBtn.TextSize = 11

local clearFixBtn = makeBtn("Clear", "textDim", fixPanel, 10, 28, true)
clearFixBtn.TextSize = 11

-- ══════════════════════════════════════════════════════════════
-- WRITE PANEL
-- ══════════════════════════════════════════════════════════════
local writePanel = makeSection(6, 12, 14)
writePanel.Visible = false

makeSectionLabel("WRITE A SCRIPT", "purple", writePanel, 1)
local writeNameBox, _ = makeInput("Script name  (e.g. CoinGiver)", 40, writePanel, 2, false)

makeSectionLabel("PLACE IT IN", "muted", writePanel, 3)
local serviceOptions = {
	"ServerScriptService",
	"StarterPlayerScripts",
	"StarterGui",
	"ReplicatedStorage",
	"ServerStorage",
	"StarterCharacterScripts"
}
local _, serviceDropdown, getService = makeDropdown(serviceOptions, writePanel, 4)

makeSectionLabel("DESCRIBE WHAT IT SHOULD DO", "muted", writePanel, 6)
local descBox, _  = makeInput("e.g. Give every player 10 coins every 30 seconds...", 100, writePanel, 7, true)

local writeAttemptsCard = Instance.new("Frame")
writeAttemptsCard.Size = UDim2.new(1,0,0,0)
writeAttemptsCard.BackgroundColor3 = C.surface
writeAttemptsCard.BorderSizePixel  = 0
writeAttemptsCard.ClipsDescendants = true
writeAttemptsCard.LayoutOrder = 8
writeAttemptsCard.Parent = writePanel
addCorner(writeAttemptsCard, 8)
local wattStroke = addStroke(writeAttemptsCard, C.border, 1)
reg(writeAttemptsCard, "BackgroundColor3", "surface")
reg(wattStroke, "Color", "border")

local writeAttemptsTxt = Instance.new("TextLabel")
writeAttemptsTxt.Size = UDim2.new(1,-16,1,-12)
writeAttemptsTxt.Position = UDim2.new(0,8,0,6)
writeAttemptsTxt.BackgroundTransparency = 1
writeAttemptsTxt.Text     = ""
writeAttemptsTxt.TextColor3 = C.warning
writeAttemptsTxt.TextSize   = 11
writeAttemptsTxt.Font       = Enum.Font.GothamBold
writeAttemptsTxt.TextXAlignment = Enum.TextXAlignment.Left
writeAttemptsTxt.Parent = writeAttemptsCard
reg(writeAttemptsTxt, "TextColor3", "warning")

local writeBtn = makeBtn("✦  Write Script", "purple", writePanel, 9, 42)
local writeBtnGrad = Instance.new("UIGradient")
writeBtnGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(139,  92, 246)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 139, 250)),
})
writeBtnGrad.Rotation = 135
writeBtnGrad.Parent = writeBtn

local clearWriteBtn = makeBtn("Clear", "textDim", writePanel, 10, 28, true)
clearWriteBtn.TextSize = 11

-- ══════════════════════════════════════════════════════════════
-- INSIGHTS PANEL
-- ══════════════════════════════════════════════════════════════
local insightsPanel = makeSection(6, 12, 14)
insightsPanel.Visible = false

makeSectionLabel("AI INSIGHTS", "gold", insightsPanel, 1)

local toggleRow = Instance.new("Frame")
toggleRow.Size = UDim2.new(1,0,0,32)
toggleRow.BackgroundColor3 = C.surface2
toggleRow.BorderSizePixel  = 0
toggleRow.LayoutOrder = 2
toggleRow.Parent = insightsPanel
addCorner(toggleRow, 8)
addStroke(toggleRow, C.border, 1)
reg(toggleRow, "BackgroundColor3", "surface2")

local toggleLayout = Instance.new("UIListLayout")
toggleLayout.FillDirection = Enum.FillDirection.Horizontal
toggleLayout.SortOrder     = Enum.SortOrder.LayoutOrder
toggleLayout.Parent        = toggleRow

local lastFixBtn = Instance.new("TextButton")
lastFixBtn.Size = UDim2.new(0.5,0,1,0)
lastFixBtn.BackgroundColor3 = C.gold
lastFixBtn.TextColor3 = Color3.fromRGB(30,20,5)
lastFixBtn.Text     = "Last Fix"
lastFixBtn.TextSize  = 11
lastFixBtn.Font      = Enum.Font.GothamBold
lastFixBtn.BorderSizePixel = 0
lastFixBtn.AutoButtonColor = false
lastFixBtn.LayoutOrder = 1
addCorner(lastFixBtn, 8)
lastFixBtn.Parent = toggleRow
lastFixBtn.MouseButton1Down:Connect(function() playClick() end)

local allFixesBtn = Instance.new("TextButton")
allFixesBtn.Size = UDim2.new(0.5,0,1,0)
allFixesBtn.BackgroundColor3 = C.surface2
allFixesBtn.TextColor3 = C.muted
allFixesBtn.Text     = "All Fixes"
allFixesBtn.TextSize  = 11
allFixesBtn.Font      = Enum.Font.GothamBold
allFixesBtn.BorderSizePixel = 0
allFixesBtn.AutoButtonColor = false
allFixesBtn.LayoutOrder = 2
addCorner(allFixesBtn, 8)
allFixesBtn.Parent = toggleRow
reg(allFixesBtn, "BackgroundColor3", "surface2")
reg(allFixesBtn, "TextColor3", "muted")
allFixesBtn.MouseButton1Down:Connect(function() playClick() end)

-- No insights placeholder
local noInsightsCard = Instance.new("Frame")
noInsightsCard.Size = UDim2.new(1,0,0,56)
noInsightsCard.BackgroundColor3 = C.surface
noInsightsCard.BorderSizePixel  = 0
noInsightsCard.LayoutOrder = 3
noInsightsCard.Parent = insightsPanel
addCorner(noInsightsCard, 8)
addStroke(noInsightsCard, C.border, 1)
reg(noInsightsCard, "BackgroundColor3", "surface")

local noInsightsTxt = Instance.new("TextLabel")
noInsightsTxt.Size = UDim2.new(1,-16,1,0)
noInsightsTxt.Position = UDim2.new(0,8,0,0)
noInsightsTxt.BackgroundTransparency = 1
noInsightsTxt.Text     = "Fix a script to see AI insights here"
noInsightsTxt.TextColor3 = C.muted
noInsightsTxt.TextSize   = 11
noInsightsTxt.Font       = Enum.Font.Gotham
noInsightsTxt.TextXAlignment = Enum.TextXAlignment.Left
noInsightsTxt.TextWrapped = true
noInsightsTxt.Parent = noInsightsCard
reg(noInsightsTxt, "TextColor3", "muted")

-- Last fix insight card
local lastInsightCard = Instance.new("Frame")
lastInsightCard.Size = UDim2.new(1,0,0,0)
lastInsightCard.BackgroundColor3 = C.surface
lastInsightCard.BorderSizePixel  = 0
lastInsightCard.LayoutOrder = 4
lastInsightCard.Visible = false
lastInsightCard.Parent  = insightsPanel
addCorner(lastInsightCard, 8)
local lastInsStroke = addStroke(lastInsightCard, C.goldDim, 1.5)
reg(lastInsightCard, "BackgroundColor3", "surface")
reg(lastInsStroke, "Color", "goldDim")

local lastInsAccent = Instance.new("Frame")
lastInsAccent.Size = UDim2.new(0,2,1,-12)
lastInsAccent.Position = UDim2.new(0,0,0,6)
lastInsAccent.BackgroundColor3 = C.gold
lastInsAccent.BorderSizePixel  = 0
lastInsAccent.Parent = lastInsightCard
addCorner(lastInsAccent, 2)
reg(lastInsAccent, "BackgroundColor3", "gold")

local lastInsHeader = Instance.new("TextLabel")
lastInsHeader.Size = UDim2.new(1,-16,0,16)
lastInsHeader.Position = UDim2.new(0,12,0,8)
lastInsHeader.BackgroundTransparency = 1
lastInsHeader.Text     = "LAST FIX"
lastInsHeader.TextColor3 = C.gold
lastInsHeader.TextSize   = 11
lastInsHeader.Font       = Enum.Font.GothamBold
lastInsHeader.TextXAlignment = Enum.TextXAlignment.Left
lastInsHeader.Parent = lastInsightCard
reg(lastInsHeader, "TextColor3", "gold")

local lastInsScript = Instance.new("TextLabel")
lastInsScript.Size = UDim2.new(1,-16,0,14)
lastInsScript.Position = UDim2.new(0,12,0,26)
lastInsScript.BackgroundTransparency = 1
lastInsScript.Text     = ""
lastInsScript.TextColor3 = C.cyan
lastInsScript.TextSize   = 12
lastInsScript.Font       = Enum.Font.GothamBold
lastInsScript.TextXAlignment = Enum.TextXAlignment.Left
lastInsScript.Parent = lastInsightCard
reg(lastInsScript, "TextColor3", "cyan")

local lastInsightTxt = Instance.new("TextLabel")
lastInsightTxt.Size = UDim2.new(1,-20,0,0)
lastInsightTxt.Position = UDim2.new(0,12,0,44)
lastInsightTxt.BackgroundTransparency = 1
lastInsightTxt.Text     = ""
lastInsightTxt.TextColor3 = C.textDim
lastInsightTxt.TextSize   = 11
lastInsightTxt.Font       = Enum.Font.Gotham
lastInsightTxt.TextXAlignment = Enum.TextXAlignment.Left
lastInsightTxt.TextYAlignment = Enum.TextYAlignment.Top
lastInsightTxt.TextWrapped    = true
lastInsightTxt.AutomaticSize  = Enum.AutomaticSize.Y
lastInsightTxt.Parent = lastInsightCard
reg(lastInsightTxt, "TextColor3", "textDim")

local allFixesScroll = Instance.new("ScrollingFrame")
allFixesScroll.Size = UDim2.new(1,0,0,300)
allFixesScroll.BackgroundTransparency = 1
allFixesScroll.BorderSizePixel = 0
allFixesScroll.ScrollBarThickness = 3
allFixesScroll.ScrollBarImageColor3 = C.gold
allFixesScroll.CanvasSize = UDim2.new(0,0,0,0)
allFixesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
allFixesScroll.LayoutOrder = 5
allFixesScroll.Visible = false
allFixesScroll.Parent  = insightsPanel

local allFixesContainer = Instance.new("Frame")
allFixesContainer.Size = UDim2.new(1,0,0,0)
allFixesContainer.AutomaticSize = Enum.AutomaticSize.Y
allFixesContainer.BackgroundTransparency = 1
allFixesContainer.Parent = allFixesScroll
local allFixesLayout = Instance.new("UIListLayout")
allFixesLayout.SortOrder = Enum.SortOrder.LayoutOrder
allFixesLayout.Padding   = UDim.new(0,6)
allFixesLayout.Parent    = allFixesContainer

local clearInsightsBtn = makeBtn("Clear All Insights", "textDim", insightsPanel, 6, 28, true)
clearInsightsBtn.TextSize = 11

makeDivider(7)

-- ══════════════════════════════════════════════════════════════
-- LIVE LOG
-- ══════════════════════════════════════════════════════════════
local logSection = makeSection(8, 12, 14)

makeSectionLabel("LIVE LOG", "muted", logSection, 1)

local logCard = Instance.new("Frame")
logCard.Size = UDim2.new(1,0,0,210)
logCard.BackgroundColor3 = C.surface
logCard.BorderSizePixel  = 0
logCard.LayoutOrder = 2
logCard.Parent = logSection
addCorner(logCard, 8)
local logCardStroke = addStroke(logCard, C.border, 1)
reg(logCard, "BackgroundColor3", "surface")
reg(logCardStroke, "Color", "border")

-- Left accent bar on log card
local logAccentBar = Instance.new("Frame")
logAccentBar.Size = UDim2.new(0,2,1,-12)
logAccentBar.Position = UDim2.new(0,0,0,6)
logAccentBar.BackgroundColor3 = C.accent
logAccentBar.BorderSizePixel  = 0
logAccentBar.Parent = logCard
addCorner(logAccentBar, 2)
reg(logAccentBar, "BackgroundColor3", "accent")

-- Log header row
local logHeaderRow = Instance.new("Frame")
logHeaderRow.Size = UDim2.new(1,-8,0,28)
logHeaderRow.Position = UDim2.new(0,4,0,0)
logHeaderRow.BackgroundTransparency = 1
logHeaderRow.Parent = logCard

local logHeaderTxt = Instance.new("TextLabel")
logHeaderTxt.Size = UDim2.new(0.5,0,1,0)
logHeaderTxt.Position = UDim2.new(0,10,0,0)
logHeaderTxt.BackgroundTransparency = 1
logHeaderTxt.Text     = "ACTIVITY"
logHeaderTxt.TextColor3 = C.muted
logHeaderTxt.TextSize   = 11
logHeaderTxt.Font       = Enum.Font.GothamBold
logHeaderTxt.TextXAlignment = Enum.TextXAlignment.Left
logHeaderTxt.Parent = logHeaderRow
reg(logHeaderTxt, "TextColor3", "muted")

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1,-10,1,-32)
logScroll.Position = UDim2.new(0,5,0,28)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 2
logScroll.ScrollBarImageColor3 = C.accent
logScroll.CanvasSize = UDim2.new(0,0,0,0)
logScroll.Parent = logCard
addPadding(logScroll, 0, 6, 8, 4)

local logLayout2 = Instance.new("UIListLayout")
logLayout2.SortOrder = Enum.SortOrder.LayoutOrder
logLayout2.Padding   = UDim.new(0,2)
logLayout2.Parent    = logScroll

makeDivider(9)

-- ══════════════════════════════════════════════════════════════
-- DANGER ZONE
-- ══════════════════════════════════════════════════════════════
local dangerSection = makeSection(10, 12, 24)

makeSectionLabel("DANGER ZONE", "danger", dangerSection, 1)

local dangerCard = Instance.new("Frame")
dangerCard.Size = UDim2.new(1,0,0,44)
dangerCard.BackgroundColor3 = C.dangerDim
dangerCard.BorderSizePixel  = 0
dangerCard.LayoutOrder = 2
dangerCard.Parent = dangerSection
addCorner(dangerCard, 8)
addStroke(dangerCard, C.danger, 1)
reg(dangerCard, "BackgroundColor3", "dangerDim")

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1,-16,1,-12)
resetBtn.Position = UDim2.new(0,8,0,6)
resetBtn.BackgroundTransparency = 1
resetBtn.TextColor3 = C.danger
resetBtn.Text     = "⚠  Reset Game Memory"
resetBtn.TextSize  = 12
resetBtn.Font      = Enum.Font.GothamBold
resetBtn.TextXAlignment = Enum.TextXAlignment.Left
resetBtn.BorderSizePixel = 0
resetBtn.AutoButtonColor = false
resetBtn.LayoutOrder = 1
resetBtn.Parent = dangerCard
reg(resetBtn, "TextColor3", "danger")

resetBtn.MouseEnter:Connect(function()
	TweenService:Create(resetBtn, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(255, 160, 160)}):Play()
end)
resetBtn.MouseLeave:Connect(function()
	TweenService:Create(resetBtn, TweenInfo.new(0.12), {TextColor3 = C.danger}):Play()
end)
resetBtn.MouseButton1Down:Connect(function() playClick() end)

local confirmBtn, cancelBtn, confirmRow = makeSplitBtns(
	"Yes, Reset", "danger",
	"Cancel",     "surface3",
	dangerSection, 3
)
confirmRow.Visible = false


-- ══════════════════════════════════════════════════════════════
-- LOG FUNCTION
-- ══════════════════════════════════════════════════════════════
local logCount = 0

local function addLog(msg, color)
	logCount += 1
	local e = Instance.new("TextLabel")
	e.Size = UDim2.new(1,0,0,15)
	e.BackgroundTransparency = 1
	e.Text     = msg
	e.TextColor3 = color or C.textDim
	e.TextTransparency = 1
	e.TextSize  = 11
	e.Font      = Enum.Font.Gotham
	e.TextXAlignment = Enum.TextXAlignment.Left
	e.TextTruncate   = Enum.TextTruncate.AtEnd
	e.LayoutOrder = logCount
	e.Parent = logScroll

	logScroll.CanvasSize = UDim2.new(0,0,0, logCount * 17 + 8)
	logScroll.CanvasPosition = Vector2.new(0, math.huge)

	TweenService:Create(e, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
end

-- ══════════════════════════════════════════════════════════════
-- INSIGHTS LOGIC
-- ══════════════════════════════════════════════════════════════
local insightCount   = 0
local showingLastFix = true

local function addInsight(scriptName, explanation)
	if not explanation or explanation == "" then return end

	lastInsScript.Text = "→ " .. scriptName
	lastInsightTxt.Text = explanation
	lastInsightCard.Visible = true
	noInsightsCard.Visible  = false

	task.defer(function()
		local lines = 1
		for _ in explanation:gmatch("\n") do lines += 1 end
		lastInsightCard.Size = UDim2.new(1,0,0, 44 + lines * 14 + 20)
	end)

	insightCount += 1

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1,-4,0,0)
	card.BackgroundColor3 = C.surface
	card.BorderSizePixel  = 0
	card.LayoutOrder = insightCount
	card.Parent = allFixesContainer
	addCorner(card, 8)
	local cardStroke = addStroke(card, C.border, 1)
	reg(card, "BackgroundColor3", "surface")
	reg(cardStroke, "Color", "border")

	local cardAccent = Instance.new("Frame")
	cardAccent.Size = UDim2.new(0,2,1,-10)
	cardAccent.Position = UDim2.new(0,0,0,5)
	cardAccent.BackgroundColor3 = C.gold
	cardAccent.BorderSizePixel  = 0
	cardAccent.Parent = card
	addCorner(cardAccent, 2)
	reg(cardAccent, "BackgroundColor3", "gold")

	local cardNum = Instance.new("TextLabel")
	cardNum.Size = UDim2.new(1,-16,0,14)
	cardNum.Position = UDim2.new(0,12,0,6)
	cardNum.BackgroundTransparency = 1
	cardNum.Text     = "FIX #" .. insightCount .. "  ·  " .. scriptName
	cardNum.TextColor3 = C.gold
	cardNum.TextSize   = 11
	cardNum.Font       = Enum.Font.GothamBold
	cardNum.TextXAlignment = Enum.TextXAlignment.Left
	cardNum.Parent = card
	reg(cardNum, "TextColor3", "gold")

	local cardTxt = Instance.new("TextLabel")
	cardTxt.Size = UDim2.new(1,-20,0,0)
	cardTxt.Position = UDim2.new(0,12,0,22)
	cardTxt.BackgroundTransparency = 1
	cardTxt.Text     = explanation
	cardTxt.TextColor3 = C.textDim
	cardTxt.TextSize   = 11
	cardTxt.Font       = Enum.Font.Gotham
	cardTxt.TextXAlignment = Enum.TextXAlignment.Left
	cardTxt.TextYAlignment = Enum.TextYAlignment.Top
	cardTxt.TextWrapped    = true
	cardTxt.AutomaticSize  = Enum.AutomaticSize.Y
	cardTxt.Parent = card
	reg(cardTxt, "TextColor3", "textDim")

	task.defer(function()
		local lines = 1
		for _ in explanation:gmatch("\n") do lines += 1 end
		card.Size = UDim2.new(1,-4,0, 22 + lines * 14 + 16)
	end)

	TweenService:Create(navInsights, TweenInfo.new(0.3), {TextColor3 = C.gold}):Play()
end

-- ══════════════════════════════════════════════════════════════
-- CONNECTION STATUS
-- ══════════════════════════════════════════════════════════════
local function setStatus(online)
	if online then
		statusPill.BackgroundColor3 = C.successDim
		statusStroke.Color          = C.success
		statusDot.BackgroundColor3  = C.success
		statusTxt.TextColor3        = C.success
		statusTxt.Text              = "ONLINE"
	else
		statusPill.BackgroundColor3 = C.dangerDim
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

-- ══════════════════════════════════════════════════════════════
-- DEEP SCAN
-- ══════════════════════════════════════════════════════════════
local workspaceContext = ""

local function deepScan()
	local context  = "=== FULL GAME CONTEXT ===\n\n"
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
		local section, hasContent = "--- " .. name .. " ---\n", false
		for _, obj in pairs(svc:GetDescendants()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
				scripts += 1; hasContent = true
				local lines   = obj.Source:split("\n")
				local preview = {}
				for j = 1, math.min(50, #lines) do preview[j] = lines[j] end
				section ..= "[" .. obj.ClassName .. "] " .. obj.Name .. ":\n"
					.. table.concat(preview, "\n") .. "\n\n"
			elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				remotes += 1; hasContent = true
				section ..= "[" .. obj.ClassName .. "] " .. obj.Name .. "\n"
			elseif obj:IsA("Model") then
				models += 1
			end
		end
		if hasContent then context ..= section end
	end
	context ..= "\nScripts: " .. scripts .. " | Remotes: " .. remotes .. " | Models: " .. models
	workspaceContext = context
	return scripts, remotes, models
end

-- ══════════════════════════════════════════════════════════════
-- LOAD MEMORY  (BUG FIX: was hardcoded to 127.0.0.1)
-- ══════════════════════════════════════════════════════════════
local function loadMemory()
	local ok, result = pcall(function()
		return HttpService:GetAsync(BASE_URL .. "/get-memory")   -- ← FIXED
	end)
	if ok then
		local mem = HttpService:JSONDecode(result)
		if mem.approved and mem.game_summary ~= "" then
			memIconWrap.BackgroundColor3 = C.successDim
			memIcon.Text      = "●"
			memIcon.TextColor3 = C.success
			memTxt.Text       = mem.game_summary:sub(1, 70) .. "..."
			memTxt.TextColor3  = C.success
			memCard.BackgroundColor3 = C.successDim
			memStroke.Color = C.success
			addLog("Game memory loaded ✓", C.success)
		end
	end
end

-- ══════════════════════════════════════════════════════════════
-- NAV SWITCHING
-- ══════════════════════════════════════════════════════════════
local function showPanel(panel)
	panelOverlay.BackgroundTransparency = 1
	TweenService:Create(panelOverlay, TweenInfo.new(0.09, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.45}):Play()
	task.delay(0.1, function()
		fixPanel.Visible      = false
		writePanel.Visible    = false
		insightsPanel.Visible = false
		panel.Visible         = true
		TweenService:Create(panelOverlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	end)
end

local function setNavActive(btn, colorKey)
	for _, nb in ipairs({navFix, navWrite, navInsights}) do
		TweenService:Create(nb, TweenInfo.new(0.18), {
			BackgroundColor3 = C.surface2,
			TextColor3       = C.muted
		}):Play()
		nb.BackgroundTransparency = 1
	end
	TweenService:Create(btn, TweenInfo.new(0.18), {
		BackgroundColor3 = C[colorKey],
		TextColor3       = C.white
	}):Play()
	btn.BackgroundTransparency = 0
end

navFix.MouseButton1Click:Connect(function()
	showPanel(fixPanel); setNavActive(navFix, "accent")
end)
navWrite.MouseButton1Click:Connect(function()
	showPanel(writePanel); setNavActive(navWrite, "purple")
end)
navInsights.MouseButton1Click:Connect(function()
	showPanel(insightsPanel); setNavActive(navInsights, "gold")
end)

lastFixBtn.MouseButton1Click:Connect(function()
	showingLastFix = true
	TweenService:Create(lastFixBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.gold, TextColor3 = Color3.fromRGB(30,20,5)}):Play()
	TweenService:Create(allFixesBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface2, TextColor3 = C.muted}):Play()
	lastInsightCard.Visible = insightCount > 0
	noInsightsCard.Visible  = insightCount == 0
	allFixesScroll.Visible  = false
end)

allFixesBtn.MouseButton1Click:Connect(function()
	showingLastFix = false
	TweenService:Create(allFixesBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.gold, TextColor3 = Color3.fromRGB(30,20,5)}):Play()
	TweenService:Create(lastFixBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface2, TextColor3 = C.muted}):Play()
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
	lastInsScript.Text      = ""
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

-- ══════════════════════════════════════════════════════════════
-- SESSION TOKEN HELPER
-- ══════════════════════════════════════════════════════════════
local function getSessionToken()
	return plugin:GetSetting(SESSION_KEY) or ""
end

-- ══════════════════════════════════════════════════════════════
-- FIX LOOP
-- ══════════════════════════════════════════════════════════════
local MAX_ATTEMPTS = 4
local isFixing     = false
local isWriting    = false
local isWatching   = false
local watchConnection = nil

local function runFixLoop(target, issue)
	isFixing = true
	fixBtn.Text = "Working..."
	TweenService:Create(fixBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.surface3}):Play()

	local currentScript   = target.Source
	local finalScript     = currentScript
	local attempt         = 0
	local errors          = ""
	local passed          = false
	local lastExplanation = ""

	while attempt < MAX_ATTEMPTS and not passed do
		attempt += 1
		TweenService:Create(attemptsCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
		attemptsTxt.Text  = "Attempt " .. attempt .. " / " .. MAX_ATTEMPTS .. "  →  analyzing..."
		attemptsTxt.TextColor3 = C.warning
		addLog("── Attempt " .. attempt .. " ──", C.muted)
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
					session_token     = getSessionToken()
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not fixOk then
			addLog("Request failed — server unreachable", C.danger)
			break
		end

		local fixRes = HttpService:JSONDecode(fixResult)
		finalScript  = fixRes.fixed_script

		if fixRes.explanation and fixRes.explanation ~= "" then
			lastExplanation = fixRes.explanation
		end

		local wrote = pcall(function()
			ScriptEditorService:UpdateSourceAsync(target, function() return finalScript end)
		end)
		if not wrote then target.Source = finalScript end

		addLog("Fix written — reviewing quality...", C.warning)

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
			addLog("Review failed — accepting current fix", C.warning)
			passed = true; break
		end

		local reviewRes = HttpService:JSONDecode(reviewResult)
		local score     = reviewRes.score
		passed          = reviewRes.passed
		errors          = reviewRes.errors or ""

		local scoreColor = score >= 8 and C.success or score >= 5 and C.warning or C.danger
		addLog("Quality score: " .. score .. " / 10", scoreColor)

		if passed then
			addLog("Review passed ✓", C.success)
		else
			addLog("Issues found — retrying...", C.warning)
			if errors ~= "" and errors:upper() ~= "NONE" then
				addLog("  " .. errors:sub(1, 64), C.danger)
			end
			currentScript = finalScript
		end
		task.wait(0.5)
	end

	if passed then
		TweenService:Create(attemptsCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
		attemptsTxt.Text  = "✓  Fixed in " .. attempt .. " attempt" .. (attempt > 1 and "s" or "")
		attemptsTxt.TextColor3 = C.success
		addLog("Script is ready!", C.success)
		addLog("See Insights tab for explanation", C.gold)
	else
		TweenService:Create(attemptsCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
		attemptsTxt.Text  = "⚠  Max attempts — best fix applied"
		attemptsTxt.TextColor3 = C.warning
		addLog("Max attempts reached", C.warning)
	end

	if lastExplanation ~= "" then
		addInsight(target.Name, lastExplanation)
	end

	fixBtn.Text = "⚡  Fix Script"
	TweenService:Create(fixBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.accent}):Play()
	isFixing = false
end

-- ══════════════════════════════════════════════════════════════
-- WRITE LOOP
-- ══════════════════════════════════════════════════════════════
local function runWriteLoop(scriptName, service, description)
	isWriting = true
	writeBtn.Text = "Writing..."
	TweenService:Create(writeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.surface3}):Play()

	local attempt     = 0
	local errors      = ""
	local passed      = false
	local finalScript = ""

	while attempt < MAX_ATTEMPTS and not passed do
		attempt += 1
		TweenService:Create(writeAttemptsCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
		writeAttemptsTxt.Text  = "Attempt " .. attempt .. " / " .. MAX_ATTEMPTS .. "  →  writing..."
		writeAttemptsTxt.TextColor3 = C.warning
		addLog("── Write Attempt " .. attempt .. " ──", C.muted)
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
					session_token     = getSessionToken()
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if not writeOk then addLog("Write request failed", C.danger); break end

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
			passed = true; break
		end

		local reviewRes = HttpService:JSONDecode(reviewResult)
		local score     = reviewRes.score
		passed          = reviewRes.passed
		errors          = reviewRes.errors or ""

		local scoreColor = score >= 8 and C.success or score >= 5 and C.warning or C.danger
		addLog("Quality score: " .. score .. " / 10", scoreColor)
		if passed then addLog("Script passed review ✓", C.success)
		else addLog("Issues found — retrying...", C.warning) end
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

			local isLocalScript = (service == "StarterPlayerScripts" or service == "StarterGui" or service == "StarterCharacterScripts")
			local newScript = Instance.new(isLocalScript and "LocalScript" or "Script")
			newScript.Name   = scriptName
			newScript.Source = finalScript
			newScript.Parent = targetService
		end)

		if ok then
			TweenService:Create(writeAttemptsCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
			writeAttemptsTxt.Text  = "✓  Created in " .. service
			writeAttemptsTxt.TextColor3 = C.success
			addLog("Script created: " .. scriptName .. " → " .. service, C.success)
		else
			addLog("Error placing script: " .. tostring(err), C.danger)
		end
	end

	writeBtn.Text = "✦  Write Script"
	TweenService:Create(writeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.purple}):Play()
	isWriting = false
end

-- ══════════════════════════════════════════════════════════════
-- FIX BUTTON
-- ══════════════════════════════════════════════════════════════
fixBtn.MouseButton1Click:Connect(function()
	if isFixing then return end
	local scriptName = scriptBox.Text:match("^%s*(.-)%s*$")
	local issue      = issueBox.Text:match("^%s*(.-)%s*$")
	if scriptName == "" then addLog("Enter a script name first", C.danger); return end
	if issue      == "" then addLog("Describe the issue first",  C.danger); return end

	local target = nil
	local searchSvcs = {
		game:GetService("ServerScriptService"),
		game:GetService("StarterPlayer"),
		game:GetService("StarterGui"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerStorage"),
		game.Workspace,
	}
	for _, svc in ipairs(searchSvcs) do
		local found = svc:FindFirstChild(scriptName, true)
		if found and (found:IsA("Script") or found:IsA("LocalScript") or found:IsA("ModuleScript")) then
			target = found; break
		end
	end

	if not target then
		addLog("Script '" .. scriptName .. "' not found", C.danger); return
	end

	addLog("Found: " .. target.Name .. " (" .. target.ClassName .. ")", C.success)
	task.spawn(runFixLoop, target, issue)
end)

-- ══════════════════════════════════════════════════════════════
-- WRITE BUTTON
-- ══════════════════════════════════════════════════════════════
writeBtn.MouseButton1Click:Connect(function()
	if isWriting then return end
	local name = writeNameBox.Text:match("^%s*(.-)%s*$")
	local desc = descBox.Text:match("^%s*(.-)%s*$")
	local svc  = getService()
	if name == "" then addLog("Enter a script name first",         C.danger); return end
	if desc == "" then addLog("Describe what the script should do", C.danger); return end
	task.spawn(runWriteLoop, name, svc, desc)
end)

-- ══════════════════════════════════════════════════════════════
-- CLEAR BUTTONS
-- ══════════════════════════════════════════════════════════════
clearFixBtn.MouseButton1Click:Connect(function()
	scriptBox.Text = ""; issueBox.Text = ""
	TweenService:Create(attemptsCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)}):Play()
	attemptsTxt.Text = ""
	addLog("Cleared", C.muted)
end)
clearWriteBtn.MouseButton1Click:Connect(function()
	writeNameBox.Text = ""; descBox.Text = ""
	TweenService:Create(writeAttemptsCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)}):Play()
	writeAttemptsTxt.Text = ""
	addLog("Cleared", C.muted)
end)

-- ══════════════════════════════════════════════════════════════
-- SCAN BUTTON
-- ══════════════════════════════════════════════════════════════
scanBtn.MouseButton1Click:Connect(function()
	addLog("Scanning workspace...", C.cyan)
	scanBtn.Text = "Scanning..."
	TweenService:Create(scanBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.surface3}):Play()

	task.spawn(function()
		local scripts, remotes, models = deepScan()
		addLog("Found " .. scripts .. " scripts · " .. remotes .. " remotes · " .. models .. " models", C.textDim)

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
				TweenService:Create(sumCard, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0, lineCount * 15 + 20)}):Play()
				approveRow.Visible = true
				addLog("Summary ready — review below", C.warning)
			end
		else
			addLog("Scan failed — server unreachable", C.danger)
		end

		scanBtn.Text = "⊕  Deep Scan Workspace"
		TweenService:Create(scanBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.accent}):Play()
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
		memIconWrap.BackgroundColor3 = C.successDim
		memIcon.Text      = "●"
		memIcon.TextColor3 = C.success
		memTxt.Text       = sumTxt.Text:sub(1, 70) .. "..."
		memTxt.TextColor3  = C.success
		memCard.BackgroundColor3 = C.successDim
		memStroke.Color = C.success
		approveRow.Visible = false
		TweenService:Create(sumCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)}):Play()
		addLog("Game memory saved ✓", C.success)
	end
end)

rejectBtn.MouseButton1Click:Connect(function()
	approveRow.Visible = false
	TweenService:Create(sumCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)}):Play()
	sumTxt.Text  = ""
	addLog("Summary rejected", C.muted)
end)

-- ══════════════════════════════════════════════════════════════
-- WATCH MODE
-- ══════════════════════════════════════════════════════════════
watchBtn.MouseButton1Click:Connect(function()
	if isWatching then return end
	local scriptName = scriptBox.Text:match("^%s*(.-)%s*$")
	if scriptName == "" then addLog("Enter the script name to watch", C.danger); return end

	isWatching = true
	TweenService:Create(watchCard, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,32)}):Play()
	watchTxt.Text  = "▶  Watching: " .. scriptName
	stopWatchBtn.Visible = true
	addLog("Watch mode ON — run your game now", C.success)

	watchConnection = ScriptContext.Error:Connect(function(message, trace, script)
		if script and script.Name == scriptName then
			addLog("[ERROR] " .. message:sub(1,70), C.danger)
			addLog("Auto-fixing...", C.warning)
			local target = nil
			local searchSvcs2 = {
				game:GetService("ServerScriptService"),
				game:GetService("StarterPlayer"),
				game:GetService("StarterGui"),
				game:GetService("ReplicatedStorage"),
				game:GetService("ServerStorage"),
				game.Workspace,
			}
			for _, svc in ipairs(searchSvcs2) do
				local found = svc:FindFirstChild(scriptName, true)
				if found and (found:IsA("Script") or found:IsA("LocalScript") or found:IsA("ModuleScript")) then
					target = found; break
				end
			end
			if target then
				task.spawn(runFixLoop, target, "Runtime error: " .. message)
			end
		end
	end)
end)

stopWatchBtn.MouseButton1Click:Connect(function()
	if watchConnection then watchConnection:Disconnect(); watchConnection = nil end
	isWatching = false
	TweenService:Create(watchCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)}):Play()
	watchTxt.Text = ""
	stopWatchBtn.Visible = false
	addLog("Watch mode OFF", C.muted)
end)

-- ══════════════════════════════════════════════════════════════
-- DANGER ZONE
-- ══════════════════════════════════════════════════════════════
resetBtn.MouseButton1Click:Connect(function()
	confirmRow.Visible = not confirmRow.Visible
end)

confirmBtn.MouseButton1Click:Connect(function()
	pcall(function()
		HttpService:PostAsync(BASE_URL .. "/reset-memory", HttpService:JSONEncode({}), Enum.HttpContentType.ApplicationJson)
	end)
	memIconWrap.BackgroundColor3 = C.faint
	memIcon.Text      = "○"
	memIcon.TextColor3 = C.muted
	memTxt.Text       = "No game memory saved"
	memTxt.TextColor3  = C.muted
	memCard.BackgroundColor3 = C.surface
	memStroke.Color = C.border
	workspaceContext = ""
	confirmRow.Visible = false
	addLog("Game memory reset", C.danger)
end)
cancelBtn.MouseButton1Click:Connect(function()
	confirmRow.Visible = false
end)

-- ══════════════════════════════════════════════════════════════
-- TOOLBAR OPEN/CLOSE
-- ══════════════════════════════════════════════════════════════
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

-- Entrance animation: scroll slides up when plugin opens
widget:GetPropertyChangedSignal("Enabled"):Connect(function()
	if widget.Enabled then
		scroll.Position = UDim2.new(0,0,0,18)
		TweenService:Create(scroll, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
	end
end)

-- ══════════════════════════════════════════════════════════════
-- STARTUP
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
	-- Set default nav
	setNavActive(navFix, "accent")

	-- Start ambient animations
	task.spawn(pulseStatusDot)
	task.spawn(pulseBrand)

	-- Periodic connection check
	task.spawn(function()
		while true do
			checkConnection()
			task.wait(10)
		end
	end)

	-- Auth check
	checkSavedSession()

	-- Load existing memory
	task.wait(1.2)
	loadMemory()

	-- Welcome log
	addLog("StudCoding v16 ready ✓", C.accent)
	addLog("Scan workspace to enable AI context", C.muted)
end)