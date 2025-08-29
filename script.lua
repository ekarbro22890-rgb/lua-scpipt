local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UI = game:GetService("UserInputService")

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "FifthItemGUI"

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
Button.Text = "USE 5TH ITEM"
Button.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
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

-- Функция поиска спавнпоинтов (упрощенная)
local function findSpawnPoints()
    local spawnPoints = {}
    
    -- Ищем любые части с spawn в названии
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("start")) then
            table.insert(spawnPoints, obj)
        end
    end
    
    -- Если не нашли, создаем тестовые точки
    if #spawnPoints == 0 then
        for i = 1, 5 do
            local part = Instance.new("Part")
            part.Position = Vector3.new(i * 10, 5, 0)
            part.Name = "SpawnPoint_" .. i
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 1
            part.Parent = workspace
            table.insert(spawnPoints, part)
        end
    end
    
    return spawnPoints
end

-- Функция поиска 5-го инструмента
local function findFifthTool()
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        local tools = {}
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, item)
            end
        end
        
        print("Found tools:", #tools)
        for i, tool in ipairs(tools) do
            print(i, tool.Name)
        end
        
        if #tools >= 5 then
            return tools[5]
        elseif #tools > 0 then
            return tools[#tools] -- Берем последний если меньше 5
        end
    end
    return nil
end

-- Функция использования инструмента
local function useTool(tool, character)
    if tool and tool:IsA("Tool") then
        -- Экипируем инструмент
        tool.Parent = character
        wait(0.2)
        
        -- Активируем инструмент
        if tool:FindFirstChild("Handle") then
            tool:Activate()
            
            -- Создаем визуальный эффект
            local effect = Instance.new("Part")
            effect.Name = "Used_" .. tool.Name
            effect.Size = Vector3.new(3, 3, 3)
            effect.Position = character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
            effect.BrickColor = BrickColor.new("Bright orange")
            effect.Anchored = true
            effect.CanCollide = false
            effect.Material = Enum.Material.Neon
            effect.Parent = workspace
            
            wait(0.3)
            
            -- Возвращаем инструмент в инвентарь
            tool.Parent = LP.Backpack
            
            return effect
        end
    end
    return nil
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
    
    -- Ищем 5-й инструмент
    Status.Text = "Status: Finding 5th tool..."
    local fifthTool = findFifthTool()
    
    if not fifthTool then
        Status.Text = "Status: No tools found in backpack!"
        isRunning = false
        noclipEnabled = false
        return
    end
    
    Status.Text = "Status: Using: " .. fifthTool.Name
    
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
    
    -- Телепортируемся и используем инструмент
    local humanoidRootPart = character.HumanoidRootPart
    
    for i, spawnPoint in ipairs(spawnPoints) do
        if not isRunning then break end
        
        Status.Text = "Status: Point " .. i .. "/" .. #spawnPoints
        
        -- Телепортируемся
        humanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 3, 0))
        wait(0.5)
        
        -- Используем инструмент
        Status.Text = "Status: Using " .. fifthTool.Name
        local effect = useTool(fifthTool, character)
        
        if effect then
            Status.Text = "Status: Placed at point " .. i
        end
        
        wait(1)
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

print("Fifth Item Script loaded! Check F9 for debug info.")
