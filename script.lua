local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UI = game:GetService("UserInputService")
local UIS = game:GetService("UserInputService")

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "TimeBombGUI"

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0.5, -125, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0

local Button = Instance.new("TextButton")
Button.Parent = Frame
Button.Size = UDim2.new(0.8, 0, 0.5, 0)
Button.Position = UDim2.new(0.1, 0, 0.1, 0)
Button.Text = "PLACE TIMEBOMBS"
Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.Font = Enum.Font.SourceSansBold

local Status = Instance.new("TextLabel")
Status.Parent = Frame
Status.Size = UDim2.new(0.8, 0, 0.3, 0)
Status.Position = UDim2.new(0.1, 0, 0.6, 0)
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1

local isRunning = false
local noclipEnabled = false

-- Функция ноклипа
local function enableNoclip(character)
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Функция поиска спавнпоинтов
local function findSpawnPoints()
    local spawnPoints = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            table.insert(spawnPoints, obj)
        elseif obj:IsA("Model") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("start")) then
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(spawnPoints, part)
                    break
                end
            end
        elseif obj:IsA("BasePart") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("start")) then
            table.insert(spawnPoints, obj)
        end
    end
    
    return spawnPoints
end

-- Функция поиска TimeBomb
local function FindTimeBomb()
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("timebomb") then
                return tool
            end
        end
        -- Если не нашел по имени, ищем любую бомбу
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:lower():find("bomb") then
                return tool
            end
        end
    end
    return nil
end

-- Функция получения позиции объекта
local function getObjectPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local primaryPart = obj.PrimaryPart
        if primaryPart then
            return primaryPart.Position
        else
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    return part.Position
                end
            end
        end
    elseif obj:IsA("SpawnLocation") then
        return obj.Position
    end
    return Vector3.new(0, 0, 0)
end

-- Улучшенная функция использования бомбы
local function useTimeBomb(tool, character)
    if tool and tool:IsA("Tool") then
        -- Экипируем бомбу
        local currentTool = character:FindFirstChildOfClass("Tool")
        if currentTool then
            currentTool.Parent = LP.Backpack
        end
        
        tool.Parent = character
        wait(0.5) -- Даем время на экипировку
        
        -- Эмулируем нажатие кнопки мыши для установки бомбы
        if tool:FindFirstChild("Handle") then
            -- Длительное удержание кнопки (как при реальной установке)
            for i = 1, 10 do
                tool:Activate()
                wait(0.1)
            end
            
            -- Дополнительная задержка для установки
            wait(1)
            
            -- Эмулируем отпускание кнопки
            wait(0.5)
        end
        
        -- Возвращаем бомбу в инвентарь
        tool.Parent = LP.Backpack
        return true
    end
    return false
end

-- Основная функция
local function startProcess()
    if isRunning then return end
    isRunning = true
    Status.Text = "Status: Starting..."
    
    local character = LP.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Status.Text = "Status: Character not found"
        isRunning = false
        return
    end
    
    -- Включаем ноклип
    noclipEnabled = true
    enableNoclip(character)
    
    -- Ищем TimeBomb
    Status.Text = "Status: Finding TimeBomb..."
    wait(1)
    
    local timeBomb = FindTimeBomb()
    
    if not timeBomb then
        Status.Text = "Status: TimeBomb not found!"
        isRunning = false
        noclipEnabled = false
        return
    end
    
    Status.Text = "Status: Found: " .. timeBomb.Name
    wait(1)
    
    -- Ищем спавнпоинты
    Status.Text = "Status: Finding spawn points..."
    local spawnPoints = findSpawnPoints()
    
    if #spawnPoints == 0 then
        Status.Text = "Status: No spawn points found"
        isRunning = false
        noclipEnabled = false
        return
    end
    
    Status.Text = "Status: Found " .. #spawnPoints .. " points"
    wait(1)
    
    -- Телепортируемся и ставим бомбы
    local humanoidRootPart = character.HumanoidRootPart
    
    for i, spawnPoint in ipairs(spawnPoints) do
        if not isRunning then break end
        
        Status.Text = "Status: Point " .. i .. "/" .. #spawnPoints
        
        -- Получаем позицию
        local position = getObjectPosition(spawnPoint)
        
        -- Телепортируемся к точке (ближе к земле)
        humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
        wait(0.5)
        
        -- Ставим бомбу
        Status.Text = "Status: Placing TimeBomb..."
        local success = useTimeBomb(timeBomb, character)
        
        if success then
            Status.Text = "Status: Bomb placed at point " .. i
        else
            Status.Text = "Status: Failed to place bomb"
        end
        
        wait(2) -- Большая задержка между установками
    end
    
    Status.Text = "Status: Completed!"
    isRunning = false
    noclipEnabled = false
end

-- Обработчики
Button.MouseButton1Click:Connect(function()
    if not isRunning then
        startProcess()
    else
        isRunning = false
        Status.Text = "Status: Stopped"
    end
end)

-- Постоянный ноклип
RS.Stepped:Connect(function()
    if noclipEnabled and LP.Character then
        enableNoclip(LP.Character)
    end
end)

-- Горячая клавиша
UI.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and UI:IsKeyDown(Enum.KeyCode.LeftControl) then
        if not isRunning then
            startProcess()
        else
            isRunning = false
            Status.Text = "Status: Stopped by hotkey"
        end
    end
end)

print("TimeBomb Placer Script loaded! Press button to place bombs.")
