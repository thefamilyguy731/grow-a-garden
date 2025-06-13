local rawRayfield = game:HttpGet("https://sirius.menu/rayfield")
local success, Rayfield = pcall(loadstring, rawRayfield)

if success and typeof(Rayfield) == "function" then
    Rayfield = Rayfield()

    local Window = Rayfield:CreateWindow({
        Name = "Grow a Garden Hub",
        LoadingTitle = "Loading...",
        LoadingSubtitle = "Made for Private Use",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "GrowAGarden",
            FileName = "Settings"
        },
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Automation", 4483362458)

    -- State
    local autoHarvest = false
    local autoBuy = false
    local autoSell = false
    local autoPlant = true
    local selectedSeed = "Basic"
    local harvestedCount, soldCount, plantedCount = 0, 0, 0

    local statsLabel = MainTab:CreateParagraph({
        Title = "Stats",
        Content = "Harvested: 0\nSold: 0\nPlanted: 0"
    })

    -- Auto Harvest
    local function harvestFruits()
        local farm = workspace:FindFirstChild("Farm")
        if not farm then return end
        local plants = farm:FindFirstChild("Farm") and farm.Farm:FindFirstChild("Important") and farm.Farm.Important:FindFirstChild("Plants_Physical")
        if not plants then return end

        for _, plantType in pairs(plants:GetChildren()) do
            local fruits = plantType:FindFirstChild("Fruits")
            if fruits then
                for _, fruit in pairs(fruits:GetChildren()) do
                    local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        prompt.HoldDuration = 0
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                        harvestedCount += 1
                        statsLabel:Set({
                            Title = "Stats",
                            Content = "Harvested: " .. harvestedCount .. "\nSold: " .. soldCount .. "\nPlanted: " .. plantedCount
                        })
                    end
                end
            end
        end
    end

    -- Auto Plant
    local function plantSeeds()
        local plantRemote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvents") and game:GetService("ReplicatedStorage").GameEvents:FindFirstChild("Plant_Seed")
        if plantRemote then
            plantRemote:FireServer()
            plantedCount += 1
            statsLabel:Set({
                Title = "Stats",
                Content = "Harvested: " .. harvestedCount .. "\nSold: " .. soldCount .. "\nPlanted: " .. plantedCount
            })
        end
    end

    -- UI Elements
    MainTab:CreateToggle({
        Name = "Auto Harvest",
        CurrentValue = false,
        Callback = function(Value)
            autoHarvest = Value
            while autoHarvest do
                harvestFruits()
                task.wait(1)
            end
        end,
    })

    MainTab:CreateDropdown({
        Name = "Seed Type",
        Options = {"Basic", "Carrot", "Tomato", "Golden"},
        CurrentOption = "Basic",
        Callback = function(Option)
            selectedSeed = Option
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Buy Seeds",
        CurrentValue = false,
        Callback = function(Value)
            autoBuy = Value
            while autoBuy do
                local rs = game:GetService("ReplicatedStorage")
                local buyRemote = rs:FindFirstChild("BuySeed")
                if buyRemote then
                    buyRemote:FireServer(selectedSeed)
                    task.wait(0.5)
                    if autoPlant then
                        plantSeeds()
                    end
                end
                task.wait(2)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Plant After Buying",
        CurrentValue = true,
        Callback = function(Value)
            autoPlant = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Sell",
        CurrentValue = false,
        Callback = function(Value)
            autoSell = Value
            while autoSell do
                local sellRemote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvents")
                if sellRemote and sellRemote:FindFirstChild("Sell_Inventory") then
                    sellRemote.Sell_Inventory:FireServer()
                    soldCount += 1
                    statsLabel:Set({
                        Title = "Stats",
                        Content = "Harvested: " .. harvestedCount .. "\nSold: " .. soldCount .. "\nPlanted: " .. plantedCount
                    })
                end
                task.wait(2)
            end
        end,
    })
else
    warn("❌ Rayfield failed to load. Check your executor or network.")
end
