-- ============================================
-- УНИВЕРСАЛЬНЫЙ ESP (финальная версия)
-- Подсвечивает: VoughtCrate, сыворотки, игроков и злодея
-- Кнопка ЗЛОДЕЙ работает отдельно, окно перемещается
-- ============================================

print("🟢 УНИВЕРСАЛЬНЫЙ ESP ЗАГРУЖЕН")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ===== ПЕРЕМЕННЫЕ =====
local syringeESP = true
local playerESP = true
local villainESP = true
local syringeHighlights = {}
local playerHighlights = {}
local villainHighlights = {}
local scanCompleted = false
local menuVisible = true

-- ===== ФУНКЦИЯ: ПРОВЕРКА, ЯВЛЯЕТСЯ ЛИ ИГРОК ЗЛОДЕЕМ =====
local function isPlayerVillain(character)
    if not character then return false end
    if character.Name == "VillainCostume" then return true end
    for _, child in pairs(character:GetChildren()) do
        if child.Name == "VillainCostume" then
            return true
        end
    end
    return false
end

-- ===== ФУНКЦИИ ПОДСВЕТКИ =====

-- Коробка (зелёная, без текста)
local function addCrateHighlight(obj)
    if syringeHighlights[obj] then return end
    syringeHighlights[obj] = true
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0, 255, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj
    end)
end

-- Сыворотка (зелёная + надпись)
local function addSyringeHighlight(obj)
    if syringeHighlights[obj] then return end
    syringeHighlights[obj] = true
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0, 255, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 180, 0, 50)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = obj

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "💉 СЫВОРОТКА V"
        label.TextColor3 = Color3.fromRGB(0, 255, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bill
    end)
end

-- Злодей (красный + надпись "ВРАГ")
local function addVillainHighlight(character)
    if villainHighlights[character] then return end
    villainHighlights[character] = true
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.1
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = character

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 150, 0, 40)
        bill.StudsOffset = Vector3.new(0, 3, 0)
        bill.AlwaysOnTop = true
        bill.Parent = character

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "👹 ВРАГ"
        label.TextColor3 = Color3.fromRGB(255, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bill
    end)
    print("[ESP] ЗЛОДЕЙ НАЙДЕН: " .. character.Name)
end

-- Игрок (оранжевый + имя)
local function addPlayerHighlight(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if playerHighlights[plr] then return end

    pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 100, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.3
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = plr.Character

        local bill = Instance.new("BillboardGui")
        bill.Size = UDim2.new(0, 150, 0, 40)
        bill.StudsOffset = Vector3.new(0, 2.5, 0)
        bill.AlwaysOnTop = true
        bill.Parent = plr.Character

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "👤 " .. plr.Name
        label.TextColor3 = Color3.fromRGB(255, 100, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Parent = bill
    end)
    playerHighlights[plr] = true
end

-- ===== ОПРЕДЕЛЕНИЕ ТИПА =====
local function getObjectType(obj)
    local name = obj.Name
    if name == "VoughtCrate" then return "crate" end
    if name == "TempVSyringe" or name == "Syringe" or name == "Vial" or name == "TempV" then return "syringe" end
    return nil
end

-- ===== СКАНИРОВАНИЕ =====
local function findAndHighlightAll()
    if scanCompleted then return end
    print("[ESP] Начинаю однократное сканирование...")
    local crates = 0
    local syringes = 0
    local villains = 0

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsDescendantOf(LocalPlayer.Character) then continue end

        local objType = getObjectType(obj)
        if objType == "crate" and syringeESP then
            addCrateHighlight(obj)
            crates = crates + 1
        elseif objType == "syringe" and syringeESP then
            addSyringeHighlight(obj)
            syringes = syringes + 1
        end
    end

    -- Злодеи и игроки
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if plr.Character then
            if isPlayerVillain(plr.Character) and villainESP then
                addVillainHighlight(plr.Character)
                villains = villains + 1
            elseif playerESP then
                addPlayerHighlight(plr)
            end
        end
    end

    scanCompleted = true
    print("[ESP] Сканирование завершено! Коробок: " .. crates .. ", Сывороток: " .. syringes .. ", Злодеев: " .. villains)
end

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalESP"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 200)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

-- Заголовок (за него перетаскиваем)
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.Text = "🔧 УНИВЕРСАЛЬНЫЙ ESP (тяни меня)"
titleBar.TextColor3 = Color3.fromRGB(0, 255, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BackgroundTransparency = 0.3
titleBar.TextXAlignment = Enum.TextXAlignment.Center
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 13
titleBar.Parent = mainFrame

-- Кнопка сворачивания
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 3)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = titleBar

-- Кнопка: Сыворотки
local syringeBtn = Instance.new("TextButton")
syringeBtn.Size = UDim2.new(0.9, 0, 0, 30)
syringeBtn.Position = UDim2.new(0.05, 0, 0, 45)
syringeBtn.Text = "🟢 СЫВОРОТКИ: ВКЛ"
syringeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
syringeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
syringeBtn.Font = Enum.Font.GothamBold
syringeBtn.TextSize = 12
syringeBtn.Parent = mainFrame

-- Кнопка: Игроки
local playerBtn = Instance.new("TextButton")
playerBtn.Size = UDim2.new(0.9, 0, 0, 30)
playerBtn.Position = UDim2.new(0.05, 0, 0, 85)
playerBtn.Text = "🟢 ИГРОКИ: ВКЛ"
playerBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerBtn.Font = Enum.Font.GothamBold
playerBtn.TextSize = 12
playerBtn.Parent = mainFrame

-- Кнопка: Злодей
local villainBtn = Instance.new("TextButton")
villainBtn.Size = UDim2.new(0.9, 0, 0, 30)
villainBtn.Position = UDim2.new(0.05, 0, 0, 125)
villainBtn.Text = "🔴 ЗЛОДЕЙ: ВКЛ"
villainBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
villainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
villainBtn.Font = Enum.Font.GothamBold
villainBtn.TextSize = 12
villainBtn.Parent = mainFrame

-- Кнопка открытия (квадратик)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 20, 0, 120)
openBtn.Text = "🔧"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 24
openBtn.BorderSizePixel = 2
openBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Visible = false
openBtn.Parent = screenGui

-- ===== ПЕРЕМЕЩЕНИЕ ОКНА (правильное!) =====
local dragData = {}

local function setupDragging(element)
    dragData[element] = {dragging = false, startPos = nil, dragStart = nil}
    
    element.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local data = dragData[element]
            data.dragging = true
            data.dragStart = input.Position
            data.startPos = mainFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, data in pairs(dragData) do
                data.dragging = false
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            for _, data in pairs(dragData) do
                if data.dragging then
                    local delta = input.Position - data.dragStart
                    mainFrame.Position = UDim2.new(data.startPos.X.Scale, data.startPos.X.Offset + delta.X, data.startPos.Y.Scale, data.startPos.Y.Offset + delta.Y)
                end
            end
        end
    end)
end

setupDragging(titleBar)

-- ===== ОБРАБОТЧИКИ КНОПОК =====
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Visible = true
    menuVisible = false
end)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
    menuVisible = true
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if menuVisible then
            mainFrame.Visible = false
            openBtn.Visible = true
            menuVisible = false
        else
            mainFrame.Visible = true
            openBtn.Visible = false
            menuVisible = true
        end
    end
end)

-- Кнопка: Сыворотки
syringeBtn.MouseButton1Click:Connect(function()
    syringeESP = not syringeESP
    if syringeESP then
        syringeBtn.Text = "🟢 СЫВОРОТКИ: ВКЛ"
        syringeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        for _, obj in pairs(workspace:GetDescendants()) do
            local objType = getObjectType(obj)
            if objType == "crate" and not syringeHighlights[obj] then
                addCrateHighlight(obj)
            elseif objType == "syringe" and not syringeHighlights[obj] then
                addSyringeHighlight(obj)
            end
        end
    else
        syringeBtn.Text = "🔴 СЫВОРОТКИ: ВЫКЛ"
        syringeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        for obj, _ in pairs(syringeHighlights) do
            local hl = obj:FindFirstChild("Highlight")
            if hl then hl:Destroy() end
            local bill = obj:FindFirstChild("BillboardGui")
            if bill then bill:Destroy() end
        end
        syringeHighlights = {}
    end
end)

-- Кнопка: Игроки
playerBtn.MouseButton1Click:Connect(function()
    playerESP = not playerESP
    if playerESP then
        playerBtn.Text = "🟢 ИГРОКИ: ВКЛ"
        playerBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not isPlayerVillain(plr.Character) then
                addPlayerHighlight(plr)
            end
        end
    else
        playerBtn.Text = "🔴 ИГРОКИ: ВЫКЛ"
        playerBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        for plr, _ in pairs(playerHighlights) do
            if plr.Character then
                local hl = plr.Character:FindFirstChild("Highlight")
                if hl then hl:Destroy() end
                local bill = plr.Character:FindFirstChild("BillboardGui")
                if bill then bill:Destroy() end
            end
        end
        playerHighlights = {}
    end
end)

-- Кнопка: Злодей
villainBtn.MouseButton1Click:Connect(function()
    villainESP = not villainESP
    if villainESP then
        villainBtn.Text = "🔴 ЗЛОДЕЙ: ВКЛ"
        villainBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and isPlayerVillain(plr.Character) then
                addVillainHighlight(plr.Character)
            end
        end
    else
        villainBtn.Text = "⚪ ЗЛОДЕЙ: ВЫКЛ"
        villainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        for obj, _ in pairs(villainHighlights) do
            local hl = obj:FindFirstChild("Highlight")
            if hl then hl:Destroy() end
            local bill = obj:FindFirstChild("BillboardGui")
            if bill then bill:Destroy() end
        end
        villainHighlights = {}
    end
end)

-- ===== ОБРАБОТЧИКИ СОБЫТИЙ =====
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if obj:IsDescendantOf(LocalPlayer.Character) then return end
    local objType = getObjectType(obj)
    if objType == "crate" and syringeESP and not syringeHighlights[obj] then
        addCrateHighlight(obj)
    elseif objType == "syringe" and syringeESP and not syringeHighlights[obj] then
        addSyringeHighlight(obj)
    end
end)

Players.PlayerAdded:Connect(function(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function()
        if villainESP and isPlayerVillain(plr.Character) then
            addVillainHighlight(plr.Character)
        elseif playerESP and not isPlayerVillain(plr.Character) then
            addPlayerHighlight(plr)
        end
    end)
end)

-- ===== ЗАПУСК =====
findAndHighlightAll()

-- ===== СТАРТ =====
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🟢 УНИВЕРСАЛЬНЫЙ ESP";
    Text = "Нажми G для меню. Кнопка ЗЛОДЕЙ работает отдельно!";
    Duration = 4;
})

print("═══════════════════════════════════════════")
print("🟢 УНИВЕРСАЛЬНЫЙ ESP ГОТОВ")
print("   📦 VoughtCrate — зелёные")
print("   💉 Сыворотки — зелёные с надписью")
print("   👤 Игроки — оранжевые с именем")
print("   👹 Злодей (VillainCostume) — красный 'ВРАГ'")
print("   ⌨️ Нажми G для показа/скрытия меню")
print("═══════════════════════════════════════════")
