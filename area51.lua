-- Survive and Kill the Killers in Area 51
-- Funcoes: ESP nos assassinos | Kill Aura | Auto Farm | Fuga automatica
-- RightShift = esconder/mostrar menu

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local GUI_NAME = "Area51Gui"

-- NPCs que NAO sao assassinos (lojistas, etc). Adicione o nome exato aqui:
local IGNORE_NAMES = {
	-- ["NomeDoNPC"] = true,
}

pcall(function()
	local old = (gethui and gethui() or CoreGui):FindFirstChild(GUI_NAME)
	if old then old:Destroy() end
end)

local running = true
local conns = {}
local function track(c) table.insert(conns, c) return c end

local cfg = {
	esp = false,
	aura = false,
	farm = false,
	escape = false,
	range = 15,      -- alcance do kill aura (studs)
	hpEscape = 60,   -- foge quando a vida estiver abaixo disso (%)
}

local function getParts()
	local char = player.Character
	if not char then return end
	return char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

local function rootOf(m)
	return m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso") or m:FindFirstChild("UpperTorso")
end

---------------------------------------------------------------- ASSASSINOS
local killers = {} -- [Model] = Humanoid
local refreshUI = function() end

local function scanKillers()
	local found = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Humanoid") and d.Health > 0 then
			local m = d.Parent
			if m and m:IsA("Model") and not IGNORE_NAMES[m.Name]
				and m ~= player.Character and not Players:GetPlayerFromCharacter(m)
				and rootOf(m) then
				found[m] = d
			end
		end
	end
	killers = found
end

local function nearestKiller()
	local root = getParts()
	if not root then return end
	local best, bestDist
	for m, hum in pairs(killers) do
		local r = rootOf(m)
		if r and m.Parent and hum.Health > 0 then
			local d = (r.Position - root.Position).Magnitude
			if not bestDist or d < bestDist then best, bestDist = m, d end
		end
	end
	return best, bestDist
end

---------------------------------------------------------------- ESP
local espObjs = {}

local function destroyESP(m)
	local o = espObjs[m]
	if o then
		o.hl:Destroy()
		o.bb:Destroy()
		espObjs[m] = nil
	end
end

local function createESP(m)
	local r = rootOf(m)
	if not r then return end

	local hl = Instance.new("Highlight")
	hl.FillColor = Color3.fromRGB(255, 120, 0)
	hl.OutlineColor = Color3.new(1, 1, 1)
	hl.FillTransparency = 0.55
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = m
	hl.Parent = m

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 150, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = r
	bb.Parent = r

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 200, 120)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.Text = m.Name
	label.Parent = bb

	espObjs[m] = { hl = hl, bb = bb, label = label }
end

local function updateESP()
	if not cfg.esp then
		for m in pairs(espObjs) do destroyESP(m) end
		return
	end
	local root = getParts()
	for m in pairs(killers) do
		if not espObjs[m] then createESP(m) end
	end
	for m, o in pairs(espObjs) do
		local hum = killers[m]
		local r = rootOf(m)
		if not hum or not m.Parent or not r then
			destroyESP(m)
		elseif root then
			o.label.Text = string.format("%s\n[%d studs | %d HP]", m.Name, (r.Position - root.Position).Magnitude, hum.Health)
		end
	end
end

---------------------------------------------------------------- ATAQUE
local function getTool()
	local root, hum = getParts()
	local char = player.Character
	if not char or not hum then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then
		local bp = player:FindFirstChildOfClass("Backpack")
		tool = bp and bp:FindFirstChildOfClass("Tool")
		if tool then hum:EquipTool(tool) end
	end
	return tool
end

local function attack(model)
	local tool = getTool()
	if not tool then return end
	pcall(function() tool:Activate() end)

	-- armas corpo a corpo que dependem de Touched
	local handle = tool:FindFirstChild("Handle")
	local troot = rootOf(model)
	if handle and troot and firetouchinterest then
		pcall(function()
			firetouchinterest(handle, troot, 0)
			firetouchinterest(handle, troot, 1)
		end)
	end
end

local escaping = false

task.spawn(function()
	while running do
		task.wait(0.1)
		if escaping or not (cfg.aura or cfg.farm) then continue end

		local root, hum = getParts()
		if not root or not hum or hum.Health <= 0 then continue end

		local target, dist = nearestKiller()
		if not target then continue end
		local troot = rootOf(target)

		if cfg.farm then
			-- teleporta pra tras do assassino e ataca
			local behind = (troot.CFrame * CFrame.new(0, 0, 3)).Position
			root.CFrame = CFrame.lookAt(behind, troot.Position)
			root.AssemblyLinearVelocity = Vector3.zero
			attack(target)
		elseif dist <= cfg.range then
			-- kill aura: so vira pro alvo e ataca
			root.CFrame = CFrame.lookAt(root.Position, Vector3.new(troot.Position.X, root.Position.Y, troot.Position.Z))
			attack(target)
		end
	end
end)

---------------------------------------------------------------- FUGA
local function escape()
	local root, hum = getParts()
	if not root or not hum or escaping then return end
	escaping = true

	local back = root.CFrame
	local plat = Instance.new("Part")
	plat.Anchored = true
	plat.Size = Vector3.new(60, 2, 60)
	plat.Transparency = 0.6
	plat.Position = root.Position + Vector3.new(0, 300, 0)
	plat.Parent = workspace

	root.AssemblyLinearVelocity = Vector3.zero
	root.CFrame = CFrame.new(plat.Position + Vector3.new(0, 4, 0))

	-- espera recuperar a vida (ou 10s) antes de voltar
	local t = os.clock()
	while running and os.clock() - t < 10 do
		task.wait(0.25)
		local _, h = getParts()
		if not h or h.Health <= 0 then break end
		if h.Health / h.MaxHealth * 100 >= 80 then break end
	end

	local r, h = getParts()
	if r and h and h.Health > 0 then
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = back
	end
	plat:Destroy()

	task.wait(3) -- cooldown pra nao ficar teleportando sem parar
	escaping = false
end

task.spawn(function()
	while running do
		task.wait(0.15)
		if cfg.escape and not escaping then
			local root, hum = getParts()
			if root and hum and hum.Health > 0 and hum.Health / hum.MaxHealth * 100 <= cfg.hpEscape then
				local _, d = nearestKiller()
				if d and d <= 25 then task.spawn(escape) end
			end
		end
	end
end)

-- atualiza lista de assassinos e ESP
task.spawn(function()
	while running do
		scanKillers()
		updateESP()
		refreshUI()
		task.wait(0.5)
	end
end)

track(RunService.RenderStepped:Connect(function()
	if cfg.esp then
		local root = getParts()
		if root then
			for m, o in pairs(espObjs) do
				local r = rootOf(m)
				local hum = killers[m]
				if r and hum then
					o.label.Text = string.format("%s\n[%d studs | %d HP]", m.Name, (r.Position - root.Position).Magnitude, hum.Health)
				end
			end
		end
	end
end))

---------------------------------------------------------------- UI
local COLOR_BG = Color3.fromRGB(24, 24, 28)
local COLOR_BTN = Color3.fromRGB(50, 50, 58)
local COLOR_ON = Color3.fromRGB(46, 160, 90)

local function new(class, props, parent)
	local i = Instance.new(class)
	for k, v in pairs(props) do i[k] = v end
	i.Parent = parent
	return i
end

local function corner(parent, r)
	new("UICorner", { CornerRadius = UDim.new(0, r or 6) }, parent)
end

local okGui, gui = pcall(function()
	return new("ScreenGui", { Name = GUI_NAME, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling },
		(gethui and gethui()) or CoreGui)
end)
if not okGui then
	gui = new("ScreenGui", { Name = GUI_NAME, ResetOnSpawn = false }, player:WaitForChild("PlayerGui"))
end

local FULL_H, MIN_H = 372, 34
local main = new("Frame", {
	Size = UDim2.new(0, 250, 0, FULL_H),
	Position = UDim2.new(0, 40, 0.5, -FULL_H / 2),
	BackgroundColor3 = COLOR_BG, BorderSizePixel = 0, ClipsDescendants = true,
}, gui)
corner(main, 8)

local title = new("Frame", { Size = UDim2.new(1, 0, 0, MIN_H), BackgroundColor3 = Color3.fromRGB(34, 34, 40), BorderSizePixel = 0 }, main)
new("TextLabel", {
	Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
	Text = "Area 51 Hub", TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 15,
}, title)

local btnMin = new("TextButton", {
	Size = UDim2.new(0, 26, 0, 22), Position = UDim2.new(1, -60, 0.5, -11), BackgroundColor3 = COLOR_BTN,
	Text = "-", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 16,
}, title)
corner(btnMin, 5)
local btnClose = new("TextButton", {
	Size = UDim2.new(0, 26, 0, 22), Position = UDim2.new(1, -30, 0.5, -11), BackgroundColor3 = Color3.fromRGB(180, 60, 60),
	Text = "X", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 13,
}, title)
corner(btnClose, 5)

local content = new("Frame", {
	Size = UDim2.new(1, 0, 1, -MIN_H), Position = UDim2.new(0, 0, 0, MIN_H), BackgroundTransparency = 1,
}, main)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, content)
new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, content)

local toggles = {}
local order = 0
local function addToggle(name, key)
	order += 1
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = COLOR_BTN, TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamMedium, TextSize = 14, LayoutOrder = order, Text = name,
	}, content)
	corner(b)
	b.MouseButton1Click:Connect(function()
		cfg[key] = not cfg[key]
		refreshUI()
		if key == "esp" then updateESP() end
	end)
	toggles[#toggles + 1] = { btn = b, name = name, key = key }
end

local adjusts = {}
local function addAdjust(text, key, step, min, max, suffix)
	order += 1
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = order }, content)
	local minus = new("TextButton", { Size = UDim2.new(0, 40, 1, 0), BackgroundColor3 = COLOR_BTN, Text = "-", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 18 }, row)
	local plus = new("TextButton", { Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), BackgroundColor3 = COLOR_BTN, Text = "+", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 18 }, row)
	local label = new("TextLabel", { Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 45, 0, 0), BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Gotham, TextSize = 13, Text = "" }, row)
	corner(minus) corner(plus)
	minus.MouseButton1Click:Connect(function() cfg[key] = math.max(cfg[key] - step, min) refreshUI() end)
	plus.MouseButton1Click:Connect(function() cfg[key] = math.min(cfg[key] + step, max) refreshUI() end)
	adjusts[#adjusts + 1] = { label = label, text = text, key = key, suffix = suffix }
end

addToggle("ESP Assassinos", "esp")
addToggle("Kill Aura", "aura")
addAdjust("Alcance", "range", 5, 5, 60, " studs")
addToggle("Auto Farm", "farm")
addToggle("Fuga Automatica", "escape")
addAdjust("Fugir com vida <", "hpEscape", 10, 10, 100, "%")

order += 1
local status = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = order,
	TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.Gotham, TextSize = 12, Text = "",
}, content)

refreshUI = function()
	for _, t in ipairs(toggles) do
		local on = cfg[t.key]
		t.btn.Text = t.name .. ": " .. (on and "ON" or "OFF")
		t.btn.BackgroundColor3 = on and COLOR_ON or COLOR_BTN
	end
	for _, a in ipairs(adjusts) do
		a.label.Text = a.text .. " " .. cfg[a.key] .. a.suffix
	end
	local n = 0
	for _ in pairs(killers) do n += 1 end
	status.Text = "Assassinos vivos: " .. n .. (escaping and "\nFugindo..." or "\nRightShift esconde o menu")
end

local minimized = false
btnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	main.Size = UDim2.new(0, 250, 0, minimized and MIN_H or FULL_H)
	btnMin.Text = minimized and "+" or "-"
end)

btnClose.MouseButton1Click:Connect(function()
	running = false
	cfg.esp = false
	updateESP()
	for _, c in ipairs(conns) do c:Disconnect() end
	gui:Destroy()
end)

local dragging, dragStart, startPos
title.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, i.Position, main.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
track(UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end))
track(UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
end))

refreshUI()
