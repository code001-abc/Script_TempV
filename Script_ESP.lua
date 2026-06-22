-- ============================================
-- УНИВЕРСАЛЬНЫЙ ESP (только точные названия)
-- Подсвечивает: VoughtCrate, TempVSyringe, Syringe, Vial, TempV
-- ============================================

print("🟢 УНИВЕРСАЛЬНЫЙ ESP ЗАГРУЖЕН")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ===== ПЕРЕМЕННЫЕ =====
local syringeESP = true
local playerESP = true
local syringeHighlights = {}
local playerHighlights = {}
local scanCompleted = false

-- ===== ФУНКЦИЯ: ПОДСВЕТКА КОРОБКИ VoughtCrate (только зелёный, без текста) =====
local function addCrateHighlight(obj)
    if syringeHighlights[obj] then return end
    syringeHighlights[obj] = true

    local success, err = pcall(function()
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(0, 255, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.15
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj
    end)

    if not success then
        warn("[ESP] Ошибка подсветки коробки: " .. err)
    end
end

-- ===== ФУНКЦИЯ: ПОДСВЕТКА СЫВОРОТКИ (с надписью) =====
local function addSyringeHighlight(obj)
    if syringeHighlights[obj] then return end
    syringeHighlights[obj] = true

    local success, err = pcall(function()
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

    if not success then
        warn("[ESP] Ошибка подсветки сыворотки: " .. err)
    end
end

-- ===== ФУНКЦИЯ: ОПРЕДЕЛЕНИЕ ТИПА ОБЪЕКТА (только точные названия) =====
local function getObjectType(obj)
    local name = obj.Name

    -- Коробка VoughtCrate (точное совпадение)
    if name == "VoughtCrate" then
        return "crate"
    end

    -- Сыворотки (точные названия)
    if name == "TempVSyringe" or name == "Syringe" or name == "Vial" or name == "TempV" then
        return "syringe"
    end

    return nil
end

-- ===== ФУНКЦИЯ: ОДНОКРАТНОЕ СКАНИРОВАНИЕ =====
local function findAndHighlightAll()
    if scanCompleted then return end

    print("[ESP] Начинаю однократное сканирование...")
    local crates = 0
    local syringes = 0

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsDescendantOf(LocalPlayer.Character) then continue end

        local objType = getObjectType(obj)
        if objType == "crate" then
            addCrateHighlight(obj)
            crates = crates + 1
        elseif objType == "syringe" then
            addSyringeHighlight(obj)
            syringes = syringes + 1
        end
    end

    scanCompleted = true
    print("[ESP] Сканирование завершено! Коробок VoughtCrate: " .. crates .. ", Сывороток: " .. syringes)
end

-- ===== ПОДСВЕТКА ИГРОКОВ =====
local function addPlayerHighlight(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if playerHighlights[plr] then return end

    local success, err = pcall(function()
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

    if not success then
        warn("[ESP] Ошибка подсветки игрока: " .. err)
    else
        playerHighlights[plr] = true
    end
end

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalESP"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 160)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Parent = screenGui

-- Заголовок
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, -60, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.Text = "🔧 УНИВЕРСАЛЬНЫЙ ESP (тяни)"
titleBar.TextColor3 = Color3.fromRGB(0, 255, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleBar.BackgroundTransparency = 0.3
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 13
titleBar.Parent = mainFrame

-- Кнопка СВЕРНУТЬ (минус)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -55, 0, 3)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.Parent = titleBar

-- Кнопка закрытия (крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = titleBar

-- Кнопка: ESP на сыворотку
local syringeBtn = Instance.new("TextButton")
syringeBtn.Size = UDim2.new(0.9, 0, 0, 35)
syringeBtn.Position = UDim2.new(0.05, 0, 0, 45)
syringeBtn.Text = "🟢 СЫВОРОТКИ: ВКЛ"
syringeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
syringeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
syringeBtn.Font = Enum.Font.GothamBold
syringeBtn.TextSize = 13
syringeBtn.Parent = mainFrame

-- Кнопка: ESP на игроков
local playerBtn = Instance.new("TextButton")
playerBtn.Size = UDim2.new(0.9, 0, 0, 35)
playerBtn.Position = UDim2.new(0.05, 0, 0, 90)
playerBtn.Text = "🟢 ИГРОКИ: ВКЛ"
playerBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerBtn.Font = Enum.Font.GothamBold
playerBtn.TextSize = 13
playerBtn.Parent = mainFrame

-- ===== КНОПКА ДЛЯ РАЗВОРАЧИВАНИЯ =====
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

-- ===== ОБРАБОТЧИКИ =====
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openBtn.Visible = false
end)

syringeBtn.MouseButton1Click:Connect(function()
    syringeESP = not syringeESP
    if syringeESP then
        syringeBtn.Text = "🟢 СЫВОРОТКИ: ВКЛ"
        syringeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        for _, obj in pairs(workspace:GetDescendants()) do
            if not syringeHighlights[obj] then
                local objType = getObjectType(obj)
                if objType == "crate" then
                    addCrateHighlight(obj)
                elseif objType == "syringe" then
                    addSyringeHighlight(obj)
                end
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

playerBtn.MouseButton1Click:Connect(function()
    playerESP = not playerESP
    if playerESP then
        playerBtn.Text = "🟢 ИГРОКИ: ВКЛ"
        playerBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
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

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ===== ОБРАБОТЧИК НОВЫХ ОБЪЕКТОВ =====
workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if not syringeESP then return end
    if syringeHighlights[obj] then return end

    local objType = getObjectType(obj)
    if objType == "crate" then
        addCrateHighlight(obj)
    elseif objType == "syringe" then
        addSyringeHighlight(obj)
    end
end)

-- ===== ОБРАБОТЧИК НОВЫХ ИГРОКОВ =====
Players.PlayerAdded:Connect(function(plr)
    if playerESP then
        plr.CharacterAdded:Connect(function()
            addPlayerHighlight(plr)
        end)
    end
end)

-- ===== ЗАПУСК =====
findAndHighlightAll()

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        addPlayerHighlight(plr)
    end
end

-- ===== ПЕРЕМЕЩЕНИЕ ОКНА =====
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== СТАРТ =====
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🟢 УНИВЕРСАЛЬНЫЙ ESP";
    Text = "Ищу: VoughtCrate, TempVSyringe, Syringe, Vial, TempV";
    Duration = 4;
})

print("═══════════════════════════════════════════")
print("🟢 УНИВЕРСАЛЬНЫЙ ESP ГОТОВ")
print("   📦 VoughtCrate — просто зелёные")
print("   💉 Сыворотки — с надписью 'СЫВОРОТКА V'")
print("   👤 Игроки — оранжевые с именем")
print("═══════════════════════════════════════════")
