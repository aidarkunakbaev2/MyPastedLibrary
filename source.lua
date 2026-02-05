--[[// UPDATE V2.2!!!!
   +dropdown (finaly)
   +config manager
   +theme changer
   =fixed shit code
]]

-- // Library Tables
local library = {}
local utility = {}
local celestial = {
    connections = {},
    theme = {
        Background = Color3.fromRGB(51, 51, 51),
        Primary = Color3.fromRGB(170, 85, 235),
        Secondary = Color3.fromRGB(101, 51, 141),
        Text = Color3.fromRGB(142, 142, 142),
        Dark = Color3.fromRGB(13, 13, 13),
        Light = Color3.fromRGB(142, 142, 142)
    },
    configs = {}
}
-- // Variables
local uis = game:GetService("UserInputService")
local cre = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
-- // Indexing
library.__index = library
-- // Functions
do
    function utility:Create(createInfo)
        local createInfo = createInfo or {}
        --
        if createInfo.Type then
            local instance = Instance.new(createInfo.Type)
            --
            if createInfo.Properties and typeof(createInfo.Properties) == "table" then
                for property, value in pairs(createInfo.Properties) do
                    pcall(function()
                        instance[property] = value
                    end)
                end
            end
            --
            return instance
        end
    end
    
    function utility:Tween(object, tweenInfo, properties)
        local tween = tweenService:Create(object, TweenInfo.new(
            tweenInfo.Time or 0.2,
            tweenInfo.EasingStyle or Enum.EasingStyle.Quad,
            tweenInfo.EasingDirection or Enum.EasingDirection.Out
        ), properties)
        tween:Play()
        return tween
    end
    
    function utility:Connection(connectionInfo)
        local connectionInfo = connectionInfo or {}
        --
        if connectionInfo.Type then
            local connection = connectionInfo.Type:Connect(connectionInfo.Callback or function() end)
            --
            celestial.connections[#celestial.connections + 1] = connection
            --
            return connection
        end
    end
    
    function utility:RemoveConnection(connectionInfo)
        local connectionInfo = connectionInfo or {}
        --
        if connectionInfo.Connection then
            local found = table.find(celestial.connections, connectionInfo.Connection)
            --
            if found then
                connectionInfo.Connection:Disconnect()
                --
                table.remove(celestial.connections, found)
            end
        end
    end
    
    function utility:Round(num, decimals)
        decimals = decimals or 2
        local multiplier = 10 ^ decimals
        return math.floor(num * multiplier + 0.5) / multiplier
    end
end

-- // Config System
do
    local config = {}
    
    function config:Save(configName)
        local data = {}
        
        for _, window in pairs(library.Windows or {}) do
            for _, page in pairs(window.Pages) do
                for _, section in pairs(page.Sections or {}) do
                    for _, element in pairs(section.Elements or {}) do
                        if element.Get then
                            data[element.Name or element.Type] = element:Get()
                        end
                    end
                end
            end
        end
        
        local json = game:GetService("HttpService"):JSONEncode(data)
        if isfolder and makefolder and writefile then
            if not isfolder("celestial_configs") then
                makefolder("celestial_configs")
            end
            writefile("celestial_configs/" .. configName .. ".json", json)
        else
            print("[celestial] Config saved", configName)
            celestial.configs[configName] = json
        end
    end
    
    function config:Load(configName)
        local data
        if readfile and isfile then
            local path = "celestial_configs/" .. configName .. ".json"
            if isfile(path) then
                data = game:GetService("HttpService"):JSONDecode(readfile(path))
            else
                warn("[celestial] Config not found:", configName)
                return
            end
        else
            data = celestial.configs[configName]
            if not data then
                warn("[celestial] Config not found:", configName)
                return
            end
            data = game:GetService("HttpService"):JSONDecode(data)
        end
        
        for _, window in pairs(library.Windows or {}) do
            for _, page in pairs(window.Pages) do
                for _, section in pairs(page.Sections or {}) do
                    for _, element in pairs(section.Elements or {}) do
                        local key = element.Name or element.Type
                        if data[key] and element.Set then
                            element:Set(data[key])
                        end
                    end
                end
            end
        end
    end
    
    function config:Delete(configName)
        if delfile and isfile then
            local path = "celestial_configs/" .. configName .. ".json"
            if isfile(path) then
                delfile(path)
            end
        else
            celestial.configs[configName] = nil
        end
    end
    
    function config:GetConfigs()
        local configs = {}
        if listfiles and isfolder then
            if isfolder("celestial_configs") then
                for _, file in pairs(listfiles("celestial_configs")) do
                    local name = file:match("celestial_configs/(.+)%.json")
                    if name then
                        table.insert(configs, name)
                    end
                end
            end
        else
            for name, _ in pairs(celestial.configs) do
                table.insert(configs, name)
            end
        end
        return configs
    end
    
    library.Config = config
end

-- // Theme Manager
do
    function library:SetTheme(themeInfo)
        local themeInfo = themeInfo or {}
        
        -- Update theme colors
        celestial.theme.Background = themeInfo.Background or celestial.theme.Background
        celestial.theme.Primary = themeInfo.Primary or celestial.theme.Primary
        celestial.theme.Secondary = themeInfo.Secondary or celestial.theme.Secondary
        celestial.theme.Text = themeInfo.Text or celestial.theme.Text
        celestial.theme.Dark = themeInfo.Dark or celestial.theme.Dark
        celestial.theme.Light = themeInfo.Light or celestial.theme.Light
        
        -- Apply to all existing UI elements
        if library.Windows then
            for _, window in pairs(library.Windows) do
                -- Update window colors
                if window.MainFrame then
                    window.MainFrame.BackgroundColor3 = celestial.theme.Background
                end
                
                if window.AccentFirst then
                    window.AccentFirst.BackgroundColor3 = celestial.theme.Primary
                    window.AccentSecond.BackgroundColor3 = celestial.theme.Secondary
                end
                
                -- Update pages
                for _, page in pairs(window.Pages) do
                    if page.TabTitle then
                        if page.Open then
                            page.TabTitle.TextColor3 = celestial.theme.Primary
                        else
                            page.TabTitle.TextColor3 = celestial.theme.Text
                        end
                    end
                    
                    -- Update sections
                    for _, section in pairs(page.Sections or {}) do
                        -- Update elements
                        for _, element in pairs(section.Elements or {}) do
                            if element.Type == "Toggle" and element.ToggleFrame then
                                if element:Get() then
                                    element.ToggleFrame.BackgroundColor3 = celestial.theme.Primary
                                end
                            elseif element.Type == "Slider" and element.SliderSlide then
                                element.SliderSlide.BackgroundColor3 = celestial.theme.Primary
                            elseif element.Type == "Dropdown" and element.DropdownTitle then
                                element.DropdownTitle.TextColor3 = celestial.theme.Text
                            end
                        end
                    end
                end
            end
        end
    end
    
    function library:GetTheme()
        return celestial.theme
    end
end

-- // Ui Functions
do
    library.Windows = {}
    
    function library:Window(windowInfo)
        -- // Variables
        local info = windowInfo or {}
        local window = {
            Pages = {}, 
            Dragging = false, 
            Delta = UDim2.new(), 
            Delta2 = Vector3.new(),
            Sections = {}
        }
        
        table.insert(library.Windows, window)
        
        -- // Utilisation
        local screen = utility:Create({Type = "ScreenGui", Properties = {
            Parent = cre,
            DisplayOrder = 8888,
            IgnoreGuiInset = true,
            Name = "celestial",
            ZIndexBehavior = "Global",
            ResetOnSpawn = false
        }})

        game:GetService("UserInputService").InputBegan:Connect(function(k,g)
            if not g then 
                if k.KeyCode == Enum.KeyCode.RightShift then 
                    screen.Enabled = not screen.Enabled 
                end
            end
        end)
        
        local main = utility:Create({Type = "Frame", Properties = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = celestial.theme.Background,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderMode = "Inset",
            BorderSizePixel = 1,
            Parent = screen,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 516, 0, 563)
        }})
        
        window.MainFrame = main
        
        local frame = utility:Create({Type = "Frame", Properties = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = celestial.theme.Dark,
            BorderSizePixel = 0,
            Parent = main,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -2, 1, -2),
        }})

        local draggingButton = utility:Create({Type = "TextButton", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 24),
            Text = ""
        }})
        
        local title = utility:Create({Type = "TextLabel", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(1, -16, 0, 15),
            Font = "Code",
            RichText = true,
            Text = info.Name or info.name or "celestial",
            TextColor3 = celestial.theme.Text,
            TextStrokeTransparency = 0.5,
            TextSize = 13,
            TextXAlignment = "Left"
        }})
        
        local accent = utility:Create({Type = "Frame", Properties = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 8, 0, 22),
            Size = UDim2.new(1, -16, 0, 2)
        }})
        
        local accentFirst = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = celestial.theme.Primary,
            BorderSizePixel = 0,
            Parent = accent,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1)
        }})
        
        local accentSecond = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = celestial.theme.Secondary,
            BorderSizePixel = 0,
            Parent = accent,
            Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(1, 0, 0, 1)
        }})
        
        window.AccentFirst = accentFirst
        window.AccentSecond = accentSecond
        
        local tabs = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = Color3.fromRGB(1, 1, 1),
            BorderSizePixel = 0,
            Parent = frame,
            Position = UDim2.new(0, 8, 0, 29),
            Size = UDim2.new(1, -16, 0, 30)
        }})
        
        local tabsInline = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = Color3.fromRGB(1, 1, 1),
            BorderSizePixel = 0,
            Parent = tabs,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -1, 1, 0)
        }})
        
        utility:Create({Type = "UIListLayout", Properties = {
            Padding = UDim.new(0, 0),
            Parent = tabsInline,
            FillDirection = "Horizontal"
        }})
        
        local pagesHolder = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = celestial.theme.Background,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderMode = "Inset",
            BorderSizePixel = 1,
            Parent = frame,
            Position = UDim2.new(0, 8, 0, 65),
            Size = UDim2.new(1, -16, 1, -76)
        }})
        
        local pagesFrame = utility:Create({Type = "Frame", Properties = {
            BackgroundColor3 = celestial.theme.Dark,
            BorderSizePixel = 0,
            Parent = pagesHolder,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2)
        }})
        
        local pagesFolder = utility:Create({Type = "Folder", Properties = {
            Parent = pagesFrame
        }})
        
        -- // Functions / Connections
        local connection = utility:Connection({Type = draggingButton.InputBegan, Callback = function(Input)
            if not window.Dragging and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                window.Dragging = true
                window.Delta = main.Position
                window.Delta2 = Input.Position
            end
        end})
        
        local connection2 = utility:Connection({Type = uis.InputEnded, Callback = function(Input)
            if window.Dragging and Input.UserInputType == Enum.UserInputType.MouseButton1 then
                window.Dragging = false
                window.Delta = UDim2.new()
                window.Delta2 = Vector3.new()
            end
        end})
        
        local connection3 = utility:Connection({Type = uis.InputChanged, Callback = function(Input)
            if window.Dragging then
                local Delta = Input.Position - window.Delta2
                main.Position = UDim2.new(window.Delta.X.Scale, window.Delta.X.Offset + Delta.X, window.Delta.Y.Scale, window.Delta.Y.Offset + Delta.Y)
            end
        end})
        
        -- // Nested Functions
        function window:RefreshTabs()
            for index, page in pairs(window.Pages) do
                if page.Tab then
                    page.Tab.Size = UDim2.new(1 / (#window.Pages), 0, 1, 0)
                end
            end
        end
        
        function window:Page(pageInfo)
            -- // Variables
            local info = pageInfo or {}
            local page = {Open = false, Sections = {}}
            
            -- // Utilisation
            local tab = utility:Create({Type = "Frame", Properties = {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = tabsInline,
                Size = UDim2.new(1, 0, 1, 0)
            }})
            
            local tabButton = utility:Create({Type = "TextButton", Properties = {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = tab,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0)
            }})
            
            local tabInline = utility:Create({Type = "Frame", Properties = {
                BackgroundColor3 = Color3.fromRGB(41, 41, 41),
                BorderSizePixel = 0,
                Parent = tab,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -1, 1, -2)
            }})
            
            local tabInlineGradient = utility:Create({Type = "Frame", Properties = {
                BackgroundColor3 = Color3.fromRGB(41, 41, 41),
                BorderSizePixel = 0,
                Parent = tabInline,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2)
            }})
            
            local tabGradient = utility:Create({Type = "UIGradient", Properties = {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))}),
                Rotation = 90,
                Parent = tabInlineGradient
            }})
            
            local tabTitle = utility:Create({Type = "TextLabel", Properties = {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = tabInlineGradient,
                Position = UDim2.new(0, 4, 0.5, 0),
                Size = UDim2.new(1, -8, 0, 15),
                Font = "Code",
                RichText = true,
                Text = info.Name or info.name or "tab",
                TextColor3 = celestial.theme.Text,
                TextStrokeTransparency = 0.5,
                TextSize = 13,
                TextXAlignment = "Center"
            }})
            
            page.TabTitle = tabTitle
            
            local pageHolder = utility:Create({Type = "Frame", Properties = {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = pagesFolder,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 1, -20),
                Visible = false
            }})
            
            local leftHolder = utility:Create({Type = "Frame", Properties = {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = pageHolder,
                Position = UDim2.new(0, 0, 0 ,0),
                Size = UDim2.new(0.5, -5, 1, 0)
            }})
            
            local rightHolder = utility:Create({Type = "Frame", Properties = {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = pageHolder,
                Position = UDim2.new(1, 0, 0 ,0),
                Size = UDim2.new(0.5, -5, 1, 0)
            }})
            
            -- // Nested Functions
            function page:Turn(state)
                if tabTitle and tabGradient and pageHolder then
                    tabTitle.TextColor3 = state and celestial.theme.Primary or celestial.theme.Text
                    tabGradient.Color = state and ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 155, 155))}) or ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))})
                    
                    pageHolder.Visible = state
                    page.Open = state
                end
            end
            
            -- // Functions / Connections
            utility:Connection({Type = tabButton.MouseButton1Down, Callback = function()
                if not page.Open then
                    for index, other_page in pairs(window.Pages) do
                        if other_page ~= page then
                            other_page:Turn(false)
                        end
                    end
                end
                
                page:Turn(true)
            end})
            
            function page:Section(sectionInfo)
                -- // Variables
                local info = sectionInfo or {}
                local section = {Elements = {}}
                table.insert(page.Sections, section)
                
                -- // Utilisation
                local side = ((info.Side and info.Side:lower() == "right") or (info.side and info.side:lower() == "right")) and rightHolder or leftHolder
                
                local sectionMain = utility:Create({Type = "Frame", Properties = {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BorderColor3 = celestial.theme.Dark,
                    BorderMode = "Inset",
                    BorderSizePixel = 1,
                    Parent = side,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, (info.Size or info.size or 200) + 4)
                }})
                
                local sectionFrame = utility:Create({Type = "Frame", Properties = {
                    BackgroundColor3 = celestial.theme.Dark,
                    BorderSizePixel = 0,
                    Parent = sectionMain,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2)
                }})
                
                local sectionTitle = utility:Create({Type = "TextLabel", Properties = {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = sectionMain,
                    Position = UDim2.new(0, 13, 0, 0),
                    Size = UDim2.new(1, -26, 0, 15),
                    Font = "Code",
                    RichText = true,
                    Text = info.Name or info.name or "new section",
                    TextColor3 = Color3.fromRGB(205, 205, 205),
                    TextStrokeTransparency = 0.5,
                    TextSize = 13,
                    TextXAlignment = "Left",
                    ZIndex = 2
                }})
                
                local sectionTitleLine = utility:Create({Type = "Frame", Properties = {
                    BackgroundColor3 = celestial.theme.Dark,
                    BorderSizePixel = 0,
                    Parent = sectionMain,
                    Position = UDim2.new(0, 9, 0, 0),
                    Size = UDim2.new(0, (sectionTitle.TextBounds and sectionTitle.TextBounds.X or 100) + 6, 0, 1)
                }})
                
                local sectionScrolling = utility:Create({Type = "Frame", Properties = {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = sectionMain,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    Visible = false
                }})
                
                local sectionScrollingBar = utility:Create({Type = "Frame", Properties = {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BorderSizePixel = 0,
                    Parent = sectionScrolling,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 5, 1, 0),
                    ZIndex = 3
                }})
                
                local sectionScrollingGradient = utility:Create({Type = "ImageLabel", Properties = {
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = sectionScrolling,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    ZIndex = 2,
                    Image = "rbxassetid://7783533907",
                    ImageTransparency = 0,
                    ImageColor3 = celestial.theme.Dark,
                    ScaleType = "Stretch"
                }})
                
                local sectionContentHolder = utility:Create({Type = "ScrollingFrame", Properties = {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent = sectionFrame,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 4,
                    AutomaticCanvasSize = "Y",
                    BottomImage = "rbxassetid://7783554086",
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    MidImage = "rbxassetid://7783554086",
                    ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
                    ScrollBarThickness = 4,
                    TopImage = "rbxassetid://7783554086",
                    VerticalScrollBarInset = "ScrollBar"
                }})
                
                utility:Create({Type = "UIListLayout", Properties = {
                    Padding = UDim.new(0, 5),
                    Parent = sectionContentHolder,
                    FillDirection = "Vertical"
                }})
                
                local sectionInline = utility:Create({Type = "Frame", Properties = {
                    BackgroundColor3 = celestial.theme.Dark,
                    BorderSizePixel = 0,
                    Parent = sectionContentHolder,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, 0, 0, 10)
                }})
                
                -- // Nested Functions
                function section:Update()
                    if sectionContentHolder.AbsoluteCanvasSize and sectionContentHolder.AbsoluteCanvasSize.Y > ((info.Size or info.size or 200) + 4) then
                        sectionScrolling.Visible = true
                    else
                        sectionScrolling.Visible = false
                    end
                end
                
                function section:Label(labelInfo)
                    -- // Variables
                    local info = labelInfo or {}
                    local label = {Type = "Label", Name = info.Name or info.Text or info.text}
                    table.insert(section.Elements, label)
                    
                    -- // Utilisation
                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sectionContentHolder,
                        Size = UDim2.new(1, 0, 0, 14)
                    }})
                    
                    local labelTitle = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Size = UDim2.new(1, -(info.Offset or 36), 1, 0),
                        Position = UDim2.new(0, info.Offset or 36, 0, 0),
                        Font = "Code",
                        RichText = true,
                        Text = info.Name or info.name or info.Text or info.text or "new label",
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Left"
                    }})
                    
                    -- // Nested Functions
                    function label:Remove()
                        contentHolder:Remove()
                        table.remove(section.Elements, table.find(section.Elements, label))
                        label = nil
                        
                        section:Update()
                    end
                    
                    -- // Returning + Other
                    section:Update()
                    
                    return label
                end
                
                function section:Toggle(toggleInfo)
                    -- // Variables
                    local info = toggleInfo or {}
                    local toggle = {
                        Type = "Toggle",
                        Name = info.Name or info.Text or info.text,
                        state = (info.Default or info.default or info.Def or info.def or false),
                        callback = (info.Callback or info.callback or function() end)
                    }
                    table.insert(section.Elements, toggle)
                    
                    -- // Utilisation
                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sectionContentHolder,
                        Size = UDim2.new(1, 0, 0, 14)
                    }})
                    
                    local toggleButton = utility:Create({Type = "TextButton", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = ""
                    }})
                    
                    local toggleTitle = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Size = UDim2.new(1, -36, 1, 0),
                        Position = UDim2.new(0, 36, 0, 0),
                        Font = "Code",
                        RichText = true,
                        Text = info.Name or info.name or info.Text or info.text or "new toggle",
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Left"
                    }})
                    
                    local toggleFrame = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 16, 0, 2),
                        Size = UDim2.new(0, 10, 0, 10)
                    }})
                    
                    toggle.ToggleFrame = toggleFrame
                    
                    local toggleInlineGradient = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = toggle.state and celestial.theme.Primary or Color3.fromRGB(63, 63, 63),
                        BorderSizePixel = 0,
                        Parent = toggleFrame,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local toggleGradient = utility:Create({Type = "UIGradient", Properties = {
                        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}),
                        Rotation = 90,
                        Parent = toggleInlineGradient
                    }})
                    
                    -- // Functions / Connections
                    local connection = utility:Connection({Type = toggleButton.MouseButton1Down, Callback = function()
                        toggle.state = not toggle.state
                        toggleInlineGradient.BackgroundColor3 = toggle.state and celestial.theme.Primary or Color3.fromRGB(63, 63, 63)
                        toggle.callback(toggle.state)
                    end})
                    
                    -- // Nested Functions
                    function toggle:Remove()
                        contentHolder:Remove()
                        table.remove(section.Elements, table.find(section.Elements, toggle))
                        toggle = nil
                        
                        utility:RemoveConnection({Connection = connection})
                        connection = nil
                        
                        section:Update()
                    end
                    
                    function toggle:Get()
                        return toggle.state
                    end
                    
                    function toggle:Set(value)
                        if typeof(value) == "boolean" then
                            toggle.state = value
                            toggleInlineGradient.BackgroundColor3 = toggle.state and celestial.theme.Primary or Color3.fromRGB(63, 63, 63)
                            toggle.callback(toggle.state)
                        end
                    end
                    
                    -- // Returning + Other
                    section:Update()
                    
                    return toggle
                end
                
                function section:Button(buttonInfo)
                    -- // Variables
                    local info = buttonInfo or {}
                    local button = {
                        Type = "Button",
                        Name = info.Name or info.Text or info.text,
                        callback = (info.Callback or info.callback or function() end)
                    }
                    table.insert(section.Elements, button)
                    
                    -- // Utilisation
                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sectionContentHolder,
                        Size = UDim2.new(1, 0, 0, 20)
                    }})
                    
                    local buttonButton = utility:Create({Type = "TextButton", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = ""
                    }})
                    
                    local buttonFrame = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                        BorderColor3 = Color3.fromRGB(1, 1, 1),
                        BorderMode = "Inset",
                        BorderSizePixel = 1,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 16, 0, 0),
                        Size = UDim2.new(1, -32, 1, 0)
                    }})
                    
                    local buttonInline = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        BorderSizePixel = 0,
                        Parent = buttonFrame,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local buttonTitle = utility:Create({Type = "TextLabel", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Size = UDim2.new(1, -32, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        Font = "Code",
                        RichText = true,
                        Text = info.Name or info.name or info.Text or info.text or "new button",
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Center"
                    }})
                    
                    -- // Functions / Connections
                    local connection = utility:Connection({Type = buttonButton.MouseButton1Down, Callback = function()
                        button.callback()
                    end})
                    
                    -- // Nested Functions
                    function button:Remove()
                        contentHolder:Remove()
                        table.remove(section.Elements, table.find(section.Elements, button))
                        button = nil
                        
                        utility:RemoveConnection({Connection = connection})
                        connection = nil
                        
                        section:Update()
                    end
                    
                    -- // Returning + Other
                    section:Update()
                    
                    return button
                end
                
                function section:Slider(sliderInfo)
                    -- // Variables
                    local info = sliderInfo or {}
                    local slider = {
                        Type = "Slider",
                        Name = info.Name or info.Text or info.text,
                        state = (info.Default or info.default or info.Def or info.def or 0),
                        min = (info.Minimum or info.minimum or info.Min or info.min or 0),
                        max = (info.Maximum or info.maximum or info.Max or info.max or 10),
                        decimals = (info.Decimals or info.decimals or info.Tick or info.tick or 1),
                        suffix = (info.Suffix or info.suffix or info.Ending or info.ending or ""),
                        callback = (info.Callback or info.callback or function() end),
                        holding = false
                    }
                    table.insert(section.Elements, slider)
                    
                    slider.decimals = 10 ^ slider.decimals
                    
                    -- // Utilisation
                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sectionContentHolder,
                        Size = UDim2.new(1, 0, 0, (info.Name or info.name or info.Text or info.text) and 24 or 10)
                    }})
                    
                    local sliderButton = utility:Create({Type = "TextButton", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = ""
                    }})
                    
                    local sliderTitle
                    if (info.Name or info.name or info.Text or info.text) then
                        sliderTitle = utility:Create({Type = "TextLabel", Properties = {
                            AnchorPoint = Vector2.new(0, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Parent = contentHolder,
                            Size = UDim2.new(1, -16, 0, 14),
                            Position = UDim2.new(0, 16, 0, 0),
                            Font = "Code",
                            RichText = true,
                            Text = (info.Name or info.name or info.Text or info.text),
                            TextColor3 = Color3.fromRGB(180, 180, 180),
                            TextStrokeTransparency = 0.5,
                            TextSize = 13,
                            TextXAlignment = "Left"
                        }})
                    end
                    
                    local sliderFrame = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(1, 1, 1),
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 16, 0, (info.Name or info.name or info.Text or info.text) and 14 or 0),
                        Size = UDim2.new(1, -32, 0, 10)
                    }})
                    
                    local sliderInlineGradient = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(63, 63, 63),
                        BorderSizePixel = 0,
                        Parent = sliderFrame,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local sliderGradient = utility:Create({Type = "UIGradient", Properties = {
                        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}),
                        Rotation = 90,
                        Parent = sliderInlineGradient
                    }})
                    
                    local sliderSlideHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sliderFrame,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local sliderSlide = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = celestial.theme.Primary,
                        BorderSizePixel = 0,
                        Parent = sliderSlideHolder,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, 0)
                    }})
                    
                    slider.SliderSlide = sliderSlide
                    
                    local sliderSlideGradient = utility:Create({Type = "UIGradient", Properties = {
                        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 125, 125))}),
                        Rotation = 90,
                        Parent = sliderSlide
                    }})
                    
                    local sliderValue = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(0.5, 0.25),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sliderSlide,
                        Size = UDim2.new(0, 10, 0, 14),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Font = "Code",
                        RichText = true,
                        Text = tostring(utility:Round(slider.state, 2)) .. tostring(slider.suffix),
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Left"
                    }})
                    
                    -- // Functions / Connections
                    local connection = utility:Connection({Type = sliderButton.MouseButton1Down, Callback = function()
                        slider.holding = true
                        slider:Refresh()
                    end})
                    
                    local connection2 = utility:Connection({Type = uis.InputEnded, Callback = function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            slider.holding = false
                        end
                    end})
                    
                    local connection3 = utility:Connection({Type = uis.InputChanged, Callback = function(Input)
                        if slider.holding and Input.UserInputType == Enum.UserInputType.MouseMovement then
                            slider:Refresh()
                        end
                    end})
                    
                    -- // Nested Functions
                    function slider:Remove()
                        contentHolder:Remove()
                        table.remove(section.Elements, table.find(section.Elements, slider))
                        slider = nil
                        
                        utility:RemoveConnection({Connection = connection})
                        connection = nil
                        utility:RemoveConnection({Connection = connection2})
                        connection2 = nil
                        utility:RemoveConnection({Connection = connection3})
                        connection3 = nil
                        
                        section:Update()
                    end
                    
                    function slider:Get()
                        return slider.state
                    end
                    
                    function slider:Set(value)
                        slider.state = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
                        sliderSlide.Size = UDim2.new(1 - ((slider.max - slider.state) / (slider.max - slider.min)), 0, 1, 0)
                        sliderValue.Text = tostring(utility:Round(slider.state, 2)) .. tostring(slider.suffix)
                        pcall(slider.callback, slider.state)
                    end
                    
                    function slider:Refresh()
                        if slider.holding then
                            local mouseLocation = uis:GetMouseLocation()
                            local relativeX = math.clamp(mouseLocation.X - sliderSlideHolder.AbsolutePosition.X, 0, sliderSlideHolder.AbsoluteSize.X)
                            local percentage = relativeX / sliderSlideHolder.AbsoluteSize.X
                            local value = slider.min + (slider.max - slider.min) * percentage
                            slider:Set(value)
                        end
                    end
                    
                    -- // Returning + Other
                    section:Update()
                    slider:Set(slider.state)
                    
                    return slider
                end
                
                -- // DROPDOWN ELEMENT
                function section:Dropdown(dropdownInfo)
                    -- // Variables
                    local info = dropdownInfo or {}
                    local dropdown = {
                        Type = "Dropdown",
                        Name = info.Name or "dropdown",
                        options = info.Options or {},
                        selected = info.Default or "",
                        open = false,
                        callback = (info.Callback or info.callback or function() end)
                    }
                    table.insert(section.Elements, dropdown)
                    
                    -- // Utilisation
                    local contentHolder = utility:Create({Type = "Frame", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = sectionContentHolder,
                        Size = UDim2.new(1, 0, 0, 20)
                    }})
                    
                    local dropdownButton = utility:Create({Type = "TextButton", Properties = {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = ""
                    }})
                    
                    local dropdownFrame = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                        BorderColor3 = Color3.fromRGB(1, 1, 1),
                        BorderMode = "Inset",
                        BorderSizePixel = 1,
                        Parent = contentHolder,
                        Position = UDim2.new(0, 16, 0, 0),
                        Size = UDim2.new(1, -32, 1, 0)
                    }})
                    
                    local dropdownInline = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        BorderSizePixel = 0,
                        Parent = dropdownFrame,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local dropdownTitle = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Size = UDim2.new(1, -52, 1, 0),
                        Position = UDim2.new(0, 36, 0.5, 0),
                        Font = "Code",
                        RichText = true,
                        Text = info.Name or info.name or "dropdown",
                        TextColor3 = celestial.theme.Text,
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Left"
                    }})
                    
                    dropdown.DropdownTitle = dropdownTitle
                    
                    local dropdownValue = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Size = UDim2.new(0, 100, 1, 0),
                        Position = UDim2.new(1, -16, 0.5, 0),
                        Font = "Code",
                        RichText = true,
                        Text = dropdown.selected,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextStrokeTransparency = 0.5,
                        TextSize = 13,
                        TextXAlignment = "Right"
                    }})
                    
                    local dropdownArrow = utility:Create({Type = "TextLabel", Properties = {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Parent = contentHolder,
                        Position = UDim2.new(1, -8, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        Font = "Code",
                        RichText = true,
                        Text = "▼",
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextSize = 10
                    }})
                    
                    -- Dropdown options frame
                    local dropdownOptions = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                        BorderColor3 = Color3.fromRGB(1, 1, 1),
                        BorderMode = "Inset",
                        BorderSizePixel = 1,
                        Parent = sectionContentHolder,
                        Position = UDim2.new(0, 16, 0, 25),
                        Size = UDim2.new(1, -32, 0, 0),
                        Visible = false,
                        ClipsDescendants = true
                    }})
                    
                    local dropdownOptionsInner = utility:Create({Type = "Frame", Properties = {
                        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                        BorderSizePixel = 0,
                        Parent = dropdownOptions,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2)
                    }})
                    
                    local dropdownOptionsList = utility:Create({Type = "UIListLayout", Properties = {
                        Padding = UDim.new(0, 1),
                        Parent = dropdownOptionsInner,
                        SortOrder = "LayoutOrder"
                    }})
                    
                    -- // Functions / Connections
                    local function updateDropdownSize()
                        local optionCount = #dropdown.options
                        local maxHeight = 150
                        local optionHeight = 20
                        local totalHeight = math.min(optionCount * optionHeight, maxHeight)
                        
                        dropdownOptions.Size = UDim2.new(1, -32, 0, totalHeight)
                        
                        for _, optionFrame in pairs(dropdownOptionsInner:GetChildren()) do
                            if optionFrame:IsA("Frame") then
                                optionFrame.Size = UDim2.new(1, 0, 0, optionHeight)
                            end
                        end
                    end
                    
                    local function createOption(optionText)
                        local optionFrame = utility:Create({Type = "Frame", Properties = {
                            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                            BorderSizePixel = 0,
                            Parent = dropdownOptionsInner,
                            Size = UDim2.new(1, 0, 0, 20),
                            LayoutOrder = #dropdownOptionsInner:GetChildren()
                        }})
                        
                        local optionButton = utility:Create({Type = "TextButton", Properties = {
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Parent = optionFrame,
                            Size = UDim2.new(1, 0, 1, 0),
                            Text = ""
                        }})
                        
                        local optionTitle = utility:Create({Type = "TextLabel", Properties = {
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Parent = optionFrame,
                            Size = UDim2.new(1, -4, 1, 0),
                            Position = UDim2.new(0, 4, 0, 0),
                            Font = "Code",
                            RichText = true,
                            Text = optionText,
                            TextColor3 = Color3.fromRGB(180, 180, 180),
                            TextStrokeTransparency = 0.5,
                            TextSize = 13,
                            TextXAlignment = "Left"
                        }})
                        
                        utility:Connection({Type = optionButton.MouseButton1Down, Callback = function()
                            dropdown.selected = optionText
                            dropdownValue.Text = optionText
                            dropdown.callback(optionText)
                            dropdown:Toggle(false)
                        end})
                        
                        return optionFrame
                    end
                    
                    -- Create initial options
                    for _, option in pairs(dropdown.options) do
                        createOption(option)
                    end
                    
                    updateDropdownSize()
                    
                    local dropdownConnection = utility:Connection({Type = dropdownButton.MouseButton1Down, Callback = function()
                        dropdown:Toggle(not dropdown.open)
                    end})
                    
                    -- // Nested Functions
                    function dropdown:Toggle(state)
                        dropdown.open = state
                        
                        if state then
                            dropdownOptions.Visible = true
                            utility:Tween(dropdownOptions, {Time = 0.2}, {Size = UDim2.new(1, -32, 0, dropdownOptions.Size.Y.Offset)})
                            dropdownArrow.Text = "▲"
                        else
                            utility:Tween(dropdownOptions, {Time = 0.2}, {Size = UDim2.new(1, -32, 0, 0)})
                            task.wait(0.2)
                            dropdownOptions.Visible = false
                            dropdownArrow.Text = "▼"
                        end
                        
                        section:Update()
                    end
                    
                    function dropdown:Remove()
                        contentHolder:Remove()
                        dropdownOptions:Remove()
                        table.remove(section.Elements, table.find(section.Elements, dropdown))
                        dropdown = nil
                        
                        utility:RemoveConnection({Connection = dropdownConnection})
                        dropdownConnection = nil
                        
                        section:Update()
                    end
                    
                    function dropdown:Get()
                        return dropdown.selected
                    end
                    
                    function dropdown:Set(value)
                        if table.find(dropdown.options, value) then
                            dropdown.selected = value
                            dropdownValue.Text = value
                            dropdown.callback(value)
                        end
                    end
                    
                    function dropdown:UpdateOptions(newOptions)
                        dropdown.options = newOptions or {}
                        
                        -- Clear existing options
                        for _, child in pairs(dropdownOptionsInner:GetChildren()) do
                            if child:IsA("Frame") then
                                child:Remove()
                            end
                        end
                        
                        -- Create new options
                        for _, option in pairs(dropdown.options) do
                            createOption(option)
                        end
                        
                        updateDropdownSize()
                        
                        -- Reset selection if current selection is not in new options
                        if not table.find(dropdown.options, dropdown.selected) then
                            dropdown.selected = ""
                            dropdownValue.Text = ""
                        end
                    end
                    
                    -- // Returning + Other
                    section:Update()
                    
                    return dropdown
                end
                -- // End of Dropdown
                
                -- // Returning + Other
                return section
            end
            
            -- // Returning + Other
            page.Tab = tab
            page.PageHolder = pageHolder
            page.Left = leftHolder
            page.Right = rightHolder
            
            window.Pages[#window.Pages + 1] = page
            window:RefreshTabs()
            
            return page
        end
        
        -- // Returning
        return window
    end
end
