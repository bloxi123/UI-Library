--[[
    Advanced Roblox GUI Library
    Version: 1.0.0
    
    A comprehensive GUI library for Roblox Lua that creates stylish, 
    functional user interfaces with multiple UI elements.
    
    Features:
    - Window creation with dragging, minimizing, and closing
    - Tab system for organizing UI elements
    - Various UI elements (Labels, Buttons, Toggles, Sliders, Dropdowns)
    - Customizable themes and animations
    - Responsive design for different screen sizes
    - Toggle visibility with RightShift
    
    Usage:
    local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/library.lua"))()
    local window = library:CreateWindow("My Cool Script")
    local tab = window:CreateTab("Main Features")
    tab:CreateLabel("Welcome to the GUI!")
--]]

-- Initialize library
local Library = {}
Library.__index = Library

-- Configuration
local Config = {
    WindowWidth = 500,
    WindowHeight = 350,
    ElementHeight = 40,
    ElementPadding = 5,
    TabHeight = 35,
    CornerRadius = 5,
    Font = Enum.Font.Gotham,
    FontSize = Enum.FontSize.Size14,
    Themes = {
        Default = {
            Background = Color3.fromRGB(40, 40, 40),
            Foreground = Color3.fromRGB(50, 50, 50),
            TextColor = Color3.fromRGB(255, 255, 255),
            AccentColor = Color3.fromRGB(85, 170, 255),
            Transparency = 0.95,
            BorderColor = Color3.fromRGB(60, 60, 60)
        },
        Light = {
            Background = Color3.fromRGB(230, 230, 230),
            Foreground = Color3.fromRGB(240, 240, 240),
            TextColor = Color3.fromRGB(40, 40, 40),
            AccentColor = Color3.fromRGB(0, 120, 215),
            Transparency = 0.95,
            BorderColor = Color3.fromRGB(200, 200, 200)
        },
        Dark = {
            Background = Color3.fromRGB(30, 30, 30),
            Foreground = Color3.fromRGB(40, 40, 40),
            TextColor = Color3.fromRGB(255, 255, 255),
            AccentColor = Color3.fromRGB(100, 100, 255),
            Transparency = 0.95,
            BorderColor = Color3.fromRGB(50, 50, 50)
        }
    }
}

-- Utility Functions
local Utility = {}

-- Creates a new instance with properties
function Utility.Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

-- Creates a rounded UI corner
function Utility.AddCorner(instance, radius)
    local uiCorner = Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Config.CornerRadius)
    })
    uiCorner.Parent = instance
    return uiCorner
end

-- Creates a basic UI stroke
function Utility.AddStroke(instance, color, thickness)
    local uiStroke = Utility.Create("UIStroke", {
        Color = color or Config.Themes.Default.BorderColor,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    uiStroke.Parent = instance
    return uiStroke
end

-- Adds a smooth tween to a property change
function Utility.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Check if mouse is within a UI element
function Utility.IsMouseOver(guiObject, mousePosition)
    local absolutePosition = guiObject.AbsolutePosition
    local absoluteSize = guiObject.AbsoluteSize
    
    local minX, maxX = absolutePosition.X, absolutePosition.X + absoluteSize.X
    local minY, maxY = absolutePosition.Y, absolutePosition.Y + absoluteSize.Y
    
    return mousePosition.X >= minX and mousePosition.X <= maxX and 
           mousePosition.Y >= minY and mousePosition.Y <= maxY
end

-- Gets a safe area inside the viewport for GUI placement
function Utility.GetSafeViewport()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local safeX = math.clamp(screenSize.X * 0.05, 10, 50)
    local safeY = math.clamp(screenSize.Y * 0.05, 10, 50)
    return {
        X = safeX,
        Y = safeY,
        Width = screenSize.X - (safeX * 2),
        Height = screenSize.Y - (safeY * 2)
    }
end

-- Element Classes
local Elements = {}

-- Base Element class from which other elements inherit
Elements.Base = {}
Elements.Base.__index = Elements.Base

-- Create a new base element
function Elements.Base.new(parent, properties)
    local self = setmetatable({}, Elements.Base)
    self.Parent = parent
    self.Properties = properties or {}
    self.Visible = true
    self.Destroyed = false
    return self
end

-- Label Element
Elements.Label = {}
Elements.Label.__index = Elements.Label
setmetatable(Elements.Label, Elements.Base)

-- Create a new label element
function Elements.Label.new(parent, text, properties)
    local self = setmetatable(Elements.Base.new(parent, properties), Elements.Label)
    
    local theme = Config.Themes.Default
    local elementHeight = properties.Height or Config.ElementHeight
    
    -- Create the main frame
    self.Frame = Utility.Create("Frame", {
        Name = "Label_" .. text,
        Parent = parent.ElementsContainer,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.7,
        Size = UDim2.new(1, -20, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, parent:GetNextElementPosition()),
        BorderSizePixel = 0
    })
    
    -- Add the text label
    self.TextLabel = Utility.Create("TextLabel", {
        Name = "LabelText",
        Parent = self.Frame,
        Text = text,
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Add corner radius
    Utility.AddCorner(self.Frame)
    
    -- Register for cleanup
    parent:RegisterElement(self)
    
    return self
end

-- Destroy the label element
function Elements.Label:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Frame:Destroy()
end

-- Set visibility of the label
function Elements.Label:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

-- Button Element
Elements.Button = {}
Elements.Button.__index = Elements.Button
setmetatable(Elements.Button, Elements.Base)

-- Create a new button element
function Elements.Button.new(parent, text, callback, properties)
    local self = setmetatable(Elements.Base.new(parent, properties), Elements.Button)
    
    local theme = Config.Themes.Default
    local elementHeight = properties.Height or Config.ElementHeight
    
    -- Create the main frame
    self.Frame = Utility.Create("Frame", {
        Name = "Button_" .. text,
        Parent = parent.ElementsContainer,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, parent:GetNextElementPosition()),
        BorderSizePixel = 0
    })
    
    -- Add the text button
    self.Button = Utility.Create("TextButton", {
        Name = "ButtonText",
        Parent = self.Frame,
        Text = text,
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Config.Font,
        TextSize = 14
    })
    
    -- Add corner radius
    Utility.AddCorner(self.Frame)
    Utility.AddStroke(self.Frame, theme.BorderColor)
    
    -- Connect mouse events for button effects
    self.Button.MouseEnter:Connect(function()
        Utility.Tween(self.Frame, {BackgroundColor3 = theme.AccentColor}, 0.2)
    end)
    
    self.Button.MouseLeave:Connect(function()
        Utility.Tween(self.Frame, {BackgroundColor3 = theme.Foreground}, 0.2)
    end)
    
    self.Button.MouseButton1Down:Connect(function()
        Utility.Tween(self.Frame, {BackgroundTransparency = 0.2}, 0.1)
    end)
    
    self.Button.MouseButton1Up:Connect(function()
        Utility.Tween(self.Frame, {BackgroundTransparency = 0.5}, 0.1)
        
        -- Execute callback
        if type(callback) == "function" then
            callback()
        end
    end)
    
    -- Register for cleanup
    parent:RegisterElement(self)
    
    return self
end

-- Destroy the button element
function Elements.Button:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Frame:Destroy()
end

-- Set visibility of the button
function Elements.Button:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

-- Toggle Element
Elements.Toggle = {}
Elements.Toggle.__index = Elements.Toggle
setmetatable(Elements.Toggle, Elements.Base)

-- Create a new toggle element
function Elements.Toggle.new(parent, text, defaultState, callback, properties)
    local self = setmetatable(Elements.Base.new(parent, properties), Elements.Toggle)
    
    local theme = Config.Themes.Default
    local elementHeight = properties.Height or Config.ElementHeight
    
    -- State tracking
    self.State = defaultState or false
    
    -- Create the main frame
    self.Frame = Utility.Create("Frame", {
        Name = "Toggle_" .. text,
        Parent = parent.ElementsContainer,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, parent:GetNextElementPosition()),
        BorderSizePixel = 0
    })
    
    -- Add the text label
    self.TextLabel = Utility.Create("TextLabel", {
        Name = "ToggleText",
        Parent = self.Frame,
        Text = text,
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create toggle indicator background
    self.ToggleBackground = Utility.Create("Frame", {
        Name = "ToggleBackground",
        Parent = self.Frame,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BorderSizePixel = 0
    })
    
    -- Create toggle indicator knob
    self.ToggleKnob = Utility.Create("Frame", {
        Name = "ToggleKnob",
        Parent = self.ToggleBackground,
        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BorderSizePixel = 0
    })
    
    -- Add corner radius to elements
    Utility.AddCorner(self.Frame)
    Utility.AddCorner(self.ToggleBackground, 10)
    Utility.AddCorner(self.ToggleKnob, 8)
    Utility.AddStroke(self.Frame, theme.BorderColor)
    
    -- Update toggle visual state
    self:UpdateState(self.State, false)
    
    -- Create the click detector
    self.ClickDetector = Utility.Create("TextButton", {
        Name = "ClickDetector",
        Parent = self.Frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    -- Connect click event
    self.ClickDetector.MouseButton1Click:Connect(function()
        self:Toggle()
        
        -- Execute callback
        if type(callback) == "function" then
            callback(self.State)
        end
    end)
    
    -- Register for cleanup
    parent:RegisterElement(self)
    
    return self
end

-- Toggle the state
function Elements.Toggle:Toggle()
    self:UpdateState(not self.State)
end

-- Update the visual state of the toggle
function Elements.Toggle:UpdateState(state, animate)
    self.State = state
    
    if animate ~= false then
        if state then
            -- On state
            Utility.Tween(self.ToggleKnob, {
                Position = UDim2.new(0, 22, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, 0.2)
            Utility.Tween(self.ToggleBackground, {
                BackgroundColor3 = Config.Themes.Default.AccentColor
            }, 0.2)
        else
            -- Off state
            Utility.Tween(self.ToggleKnob, {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            }, 0.2)
            Utility.Tween(self.ToggleBackground, {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            }, 0.2)
        end
    else
        -- Instant update without animation
        if state then
            self.ToggleKnob.Position = UDim2.new(0, 22, 0.5, -8)
            self.ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            self.ToggleBackground.BackgroundColor3 = Config.Themes.Default.AccentColor
        else
            self.ToggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
            self.ToggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            self.ToggleBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- Destroy the toggle element
function Elements.Toggle:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Frame:Destroy()
end

-- Set visibility of the toggle
function Elements.Toggle:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

-- Dropdown Element
Elements.Dropdown = {}
Elements.Dropdown.__index = Elements.Dropdown
setmetatable(Elements.Dropdown, Elements.Base)

-- Create a new dropdown element
function Elements.Dropdown.new(parent, text, options, callback, properties)
    local self = setmetatable(Elements.Base.new(parent, properties), Elements.Dropdown)
    
    local theme = Config.Themes.Default
    local elementHeight = properties.Height or Config.ElementHeight
    
    -- State tracking
    self.Open = false
    self.Selected = options[1] or "Select..."
    self.Options = options or {}
    
    -- Create the main frame
    self.Frame = Utility.Create("Frame", {
        Name = "Dropdown_" .. text,
        Parent = parent.ElementsContainer,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, parent:GetNextElementPosition()),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Add the text label
    self.TextLabel = Utility.Create("TextLabel", {
        Name = "DropdownText",
        Parent = self.Frame,
        Text = text,
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Add the selected value display
    self.SelectedDisplay = Utility.Create("TextButton", {
        Name = "SelectedDisplay",
        Parent = self.Frame,
        Text = self.Selected,
        TextColor3 = theme.TextColor,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, elementHeight - 10),
        Position = UDim2.new(0, 10, 0, elementHeight),
        Font = Config.Font,
        TextSize = 14,
        BorderSizePixel = 0
    })
    
    -- Add the dropdown icon
    self.DropdownIcon = Utility.Create("ImageLabel", {
        Name = "DropdownIcon",
        Parent = self.SelectedDisplay,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091004", -- Dropdown arrow icon
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        ImageColor3 = theme.TextColor
    })
    
    -- Create the dropdown container
    self.DropdownContainer = Utility.Create("Frame", {
        Name = "DropdownContainer",
        Parent = self.Frame,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, -20, 0, 0), -- Will expand when opened
        Position = UDim2.new(0, 10, 0, elementHeight * 2),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Add corner radius to elements
    Utility.AddCorner(self.Frame)
    Utility.AddCorner(self.SelectedDisplay)
    Utility.AddCorner(self.DropdownContainer)
    Utility.AddStroke(self.Frame, theme.BorderColor)
    
    -- Connect click events
    self.SelectedDisplay.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Create option buttons
    self:CreateOptions(callback)
    
    -- Register for cleanup
    parent:RegisterElement(self)
    
    return self
end

-- Create dropdown options
function Elements.Dropdown:CreateOptions(callback)
    local theme = Config.Themes.Default
    local optionHeight = 30
    
    -- Clear existing options
    for _, child in pairs(self.DropdownContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create new options
    for i, optionText in ipairs(self.Options) do
        local option = Utility.Create("TextButton", {
            Name = "Option_" .. i,
            Parent = self.DropdownContainer,
            Text = optionText,
            TextColor3 = theme.TextColor,
            BackgroundColor3 = theme.Background,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, optionHeight),
            Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
            Font = Config.Font,
            TextSize = 14,
            BorderSizePixel = 0
        })
        
        -- Add hover effect
        option.MouseEnter:Connect(function()
            Utility.Tween(option, {BackgroundColor3 = theme.AccentColor, BackgroundTransparency = 0.7}, 0.2)
        end)
        
        option.MouseLeave:Connect(function()
            Utility.Tween(option, {BackgroundColor3 = theme.Background, BackgroundTransparency = 0.5}, 0.2)
        end)
        
        -- Connect click event
        option.MouseButton1Click:Connect(function()
            self.Selected = optionText
            self.SelectedDisplay.Text = optionText
            self:Toggle()
            
            -- Execute callback
            if type(callback) == "function" then
                callback(optionText)
            end
        end)
    end
    
    -- Set the container size based on number of options
    self.DropdownContainer.Size = UDim2.new(1, -20, 0, #self.Options * optionHeight)
end

-- Toggle the dropdown state
function Elements.Dropdown:Toggle()
    self.Open = not self.Open
    
    if self.Open then
        -- Open the dropdown
        Utility.Tween(self.Frame, {Size = UDim2.new(1, -20, 0, self.Frame.Size.Y.Offset + self.DropdownContainer.Size.Y.Offset)}, 0.3)
        Utility.Tween(self.DropdownIcon, {Rotation = 180}, 0.3)
    else
        -- Close the dropdown
        Utility.Tween(self.Frame, {Size = UDim2.new(1, -20, 0, Config.ElementHeight * 2)}, 0.3)
        Utility.Tween(self.DropdownIcon, {Rotation = 0}, 0.3)
    end
end

-- Destroy the dropdown element
function Elements.Dropdown:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    self.Frame:Destroy()
end

-- Set visibility of the dropdown
function Elements.Dropdown:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

-- Slider Element
Elements.Slider = {}
Elements.Slider.__index = Elements.Slider
setmetatable(Elements.Slider, Elements.Base)

-- Create a new slider element
function Elements.Slider.new(parent, text, min, max, default, callback, properties)
    local self = setmetatable(Elements.Base.new(parent, properties), Elements.Slider)
    
    local theme = Config.Themes.Default
    local elementHeight = properties.Height or Config.ElementHeight * 1.5
    
    -- Value tracking
    self.Min = min or 0
    self.Max = max or 100
    self.Value = default or self.Min
    self.Dragging = false
    
    -- Create the main frame
    self.Frame = Utility.Create("Frame", {
        Name = "Slider_" .. text,
        Parent = parent.ElementsContainer,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(1, -20, 0, elementHeight),
        Position = UDim2.new(0, 10, 0, parent:GetNextElementPosition()),
        BorderSizePixel = 0
    })
    
    -- Add the text label
    self.TextLabel = Utility.Create("TextLabel", {
        Name = "SliderText",
        Parent = self.Frame,
        Text = text,
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, elementHeight / 2),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create value display
    self.ValueLabel = Utility.Create("TextLabel", {
        Name = "ValueLabel",
        Parent = self.Frame,
        Text = tostring(self.Value),
        TextColor3 = theme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, elementHeight / 2),
        Position = UDim2.new(1, -60, 0, 0),
        Font = Config.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    -- Create slider track
    self.SliderTrack = Utility.Create("Frame", {
        Name = "SliderTrack",
        Parent = self.Frame,
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0.7, 0),
        BorderSizePixel = 0
    })
    
    -- Create slider fill
    self.SliderFill = Utility.Create("Frame", {
        Name = "SliderFill",
        Parent = self.SliderTrack,
        BackgroundColor3 = theme.AccentColor,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Create slider knob
    self.SliderKnob = Utility.Create("Frame", {
        Name = "SliderKnob",
        Parent = self.SliderTrack,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, -8, 0.5, -8),
        BorderSizePixel = 0
    })
    
    -- Add corner radius to elements
    Utility.AddCorner(self.Frame)
    Utility.AddCorner(self.SliderTrack, 4)
    Utility.AddCorner(self.SliderFill, 4)
    Utility.AddCorner(self.SliderKnob, 8)
    Utility.AddStroke(self.Frame, theme.BorderColor)
    
    -- Set initial value
    self:SetValue(self.Value, false)
    
    -- Create the click detector
    self.ClickDetector = Utility.Create("TextButton", {
        Name = "ClickDetector",
        Parent = self.SliderTrack,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    -- Handle slider functionality
    local inputService = game:GetService("UserInputService")
    
    -- Mouse down event
    self.ClickDetector.MouseButton1Down:Connect(function()
        self.Dragging = true
        self:UpdateFromMouse()
        
        -- Execute callback
        if type(callback) == "function" then
            callback(self.Value)
        end
    end)
    
    -- Mouse move event
    self.MouseMoveConnection = inputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            self:UpdateFromMouse()
            
            -- Execute callback
            if type(callback) == "function" then
                callback(self.Value)
            end
        end
    end)
    
    -- Mouse up event
    self.MouseUpConnection = inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    -- Register for cleanup
    parent:RegisterElement(self)
    
    return self
end

-- Update the slider position based on mouse position
function Elements.Slider:UpdateFromMouse()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local trackPos = self.SliderTrack.AbsolutePosition
    local trackSize = self.SliderTrack.AbsoluteSize
    local mousePos = mouse.X
    
    -- Calculate the percentage
    local percentage = math.clamp((mousePos - trackPos.X) / trackSize.X, 0, 1)
    
    -- Calculate the value based on min and max
    local value = math.floor(self.Min + (percentage * (self.Max - self.Min)))
    
    -- Update slider
    self:SetValue(value)
end

-- Set the slider value
function Elements.Slider:SetValue(value, animate)
    -- Clamp the value
    self.Value = math.clamp(value, self.Min, self.Max)
    
    -- Calculate the percentage
    local percentage = (self.Value - self.Min) / (self.Max - self.Min)
    -- Update visual elements
    if animate ~= false then
        -- Animated update
        Utility.Tween(self.SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
        Utility.Tween(self.SliderKnob, {Position = UDim2.new(percentage, -8, 0.5, -8)}, 0.1)
    else
        -- Instant update without animation
        self.SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        self.SliderKnob.Position = UDim2.new(percentage, -8, 0.5, -8)
    end
    
    -- Update the value label
    self.ValueLabel.Text = tostring(self.Value)
end

-- Destroy the slider element
function Elements.Slider:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    
    -- Disconnect events
    if self.MouseMoveConnection then
        self.MouseMoveConnection:Disconnect()
    end
    
    if self.MouseUpConnection then
        self.MouseUpConnection:Disconnect()
    end
    
    self.Frame:Destroy()
end

-- Set visibility of the slider
function Elements.Slider:SetVisible(visible)
    self.Visible = visible
    self.Frame.Visible = visible
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

-- Create a new tab
function Tab.new(window, name)
    local self = setmetatable({}, Tab)
    self.Window = window
    self.Name = name
    self.Elements = {}
    self.ElementsCount = 0
    self.ContentHeight = 0
    
    local theme = Config.Themes.Default
    
    -- Create the tab button
    self.TabButton = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Parent = window.TabsContainer,
        Text = name,
        TextColor3 = theme.TextColor,
        BackgroundColor3 = theme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(0, (#window.Tabs * 85), 0, 0),
        Font = Config.Font,
        TextSize = 14,
        BorderSizePixel = 0
    })
    
    -- Add corner radius
    Utility.AddCorner(self.TabButton)
    
    -- Create the tab content
    self.ContentFrame = Utility.Create("Frame", {
        Name = "Content_" .. name,
        Parent = window.ContentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    -- Create scrolling frame for elements
    self.ElementsContainer = Utility.Create("ScrollingFrame", {
        Name = "ElementsContainer",
        Parent = self.ContentFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = theme.AccentColor,
        BottomImage = "",
        TopImage = "",
        MidImage = "",
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    -- Add automatic canvas size update
    self.ElementsContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        -- Update the canvas size based on content
        self:UpdateCanvasSize()
    end)
    
    -- Connect tab button click
    self.TabButton.MouseButton1Click:Connect(function()
        window:SelectTab(self)
    end)
    
    -- Set up tab hover effects
    self.TabButton.MouseEnter:Connect(function()
        if not self.Selected then
            Utility.Tween(self.TabButton, {BackgroundColor3 = theme.Background}, 0.2)
        end
    end)
    
    self.TabButton.MouseLeave:Connect(function()
        if not self.Selected then
            Utility.Tween(self.TabButton, {BackgroundColor3 = theme.Foreground}, 0.2)
        end
    end)
    
    return self
end

-- Get the position for the next element
function Tab:GetNextElementPosition()
    return self.ContentHeight
end

-- Register an element for tracking and cleanup
function Tab:RegisterElement(element)
    table.insert(self.Elements, element)
    self.ElementsCount = self.ElementsCount + 1
    
    -- Update content height
    self.ContentHeight = self.ContentHeight + element.Frame.Size.Y.Offset + Config.ElementPadding
    
    -- Update canvas size
    self:UpdateCanvasSize()
    
    return element
end

-- Update the canvas size based on content
function Tab:UpdateCanvasSize()
    self.ElementsContainer.CanvasSize = UDim2.new(0, 0, 0, self.ContentHeight + 20)
end

-- Set the tab as selected or deselected
function Tab:SetSelected(selected)
    self.Selected = selected
    
    if selected then
        -- Selected state
        self.ContentFrame.Visible = true
        Utility.Tween(self.TabButton, {
            BackgroundColor3 = Config.Themes.Default.AccentColor,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }, 0.2)
    else
        -- Deselected state
        self.ContentFrame.Visible = false
        Utility.Tween(self.TabButton, {
            BackgroundColor3 = Config.Themes.Default.Foreground,
            TextColor3 = Config.Themes.Default.TextColor
        }, 0.2)
    end
end

-- Create a label element
function Tab:CreateLabel(text, properties)
    return Elements.Label.new(self, text, properties or {})
end

-- Create a button element
function Tab:CreateButton(text, callback, properties)
    return Elements.Button.new(self, text, callback, properties or {})
end

-- Create a toggle element
function Tab:CreateToggle(text, defaultState, callback, properties)
    return Elements.Toggle.new(self, text, defaultState, callback, properties or {})
end

-- Create a slider element
function Tab:CreateSlider(text, min, max, default, callback, properties)
    return Elements.Slider.new(self, text, min, max, default, callback, properties or {})
end

-- Create a dropdown element
function Tab:CreateDropdown(text, options, callback, properties)
    return Elements.Dropdown.new(self, text, options, callback, properties or {})
end

-- Destroy all elements in the tab
function Tab:DestroyElements()
    for _, element in pairs(self.Elements) do
        if element.Destroy then
            element:Destroy()
        end
    end
    
    self.Elements = {}
    self.ElementsCount = 0
    self.ContentHeight = 0
end

-- Destroy the tab
function Tab:Destroy()
    self:DestroyElements()
    self.TabButton:Destroy()
    self.ContentFrame:Destroy()
end

-- Window Class
local Window = {}
Window.__index = Window

-- Create a new window
function Window.new(title, theme)
    local self = setmetatable({}, Window)
    self.Title = title
    self.Tabs = {}
    self.CurrentTab = nil
    self.Dragging = false
    self.DragStart = nil
    self.StartPosition = nil
    
    -- Apply theme if provided
    local activeTheme = theme and Config.Themes[theme] or Config.Themes.Default
    
    -- Create the main GUI
    self.GUI = Utility.Create("ScreenGui", {
        Name = "LibraryGUI_" .. title,
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Create the main frame
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Parent = self.GUI,
        BackgroundColor3 = activeTheme.Background,
        BackgroundTransparency = 1 - activeTheme.Transparency,
        Size = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight),
        Position = UDim2.new(0.5, -Config.WindowWidth / 2, 0.5, -Config.WindowHeight / 2),
        BorderSizePixel = 0
    })
    
    -- Add corner radius and border
    Utility.AddCorner(self.MainFrame)
    Utility.AddStroke(self.MainFrame, activeTheme.BorderColor)
    
    -- Create the title bar
    self.TitleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        BackgroundColor3 = activeTheme.Foreground,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    -- Add corner radius to top corners only
    local titleCorner = Utility.AddCorner(self.TitleBar)
    titleCorner.CornerRadius = UDim.new(0, Config.CornerRadius)
    
    -- Create the title label
    self.TitleLabel = Utility.Create("TextLabel", {
        Name = "TitleLabel",
        Parent = self.TitleBar,
        Text = title,
        TextColor3 = activeTheme.TextColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = Config.Font,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Create window controls (minimize, close buttons)
    self.MinimizeButton = Utility.Create("TextButton", {
        Name = "MinimizeButton",
        Parent = self.TitleBar,
        Text = "-",
        TextColor3 = activeTheme.TextColor,
        BackgroundColor3 = activeTheme.Foreground,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        Font = Config.Font,
        TextSize = 18,
        BorderSizePixel = 0
    })
    
    self.CloseButton = Utility.Create("TextButton", {
        Name = "CloseButton",
        Parent = self.TitleBar,
        Text = "×",
        TextColor3 = activeTheme.TextColor,
        BackgroundColor3 = Color3.fromRGB(255, 70, 70),
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        Font = Config.Font,
        TextSize = 18,
        BorderSizePixel = 0
    })
    
    -- Add corner radius to buttons
    Utility.AddCorner(self.MinimizeButton)
    Utility.AddCorner(self.CloseButton)
    
    -- Create tabs container
    self.TabsContainer = Utility.Create("Frame", {
        Name = "TabsContainer",
        Parent = self.MainFrame,
        BackgroundColor3 = activeTheme.Background,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, -20, 0, Config.TabHeight),
        Position = UDim2.new(0, 10, 0, 40),
        BorderSizePixel = 0
    })
    
    -- Add corner radius
    Utility.AddCorner(self.TabsContainer)
    
    -- Create content container
    self.ContentContainer = Utility.Create("Frame", {
        Name = "ContentContainer",
        Parent = self.MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -(40 + Config.TabHeight + 20)),
        Position = UDim2.new(0, 10, 0, 40 + Config.TabHeight + 10),
        BorderSizePixel = 0
    })
    
    -- Create minimize animation values
    self.MinimizedSize = UDim2.new(0, Config.WindowWidth, 0, 30)
    self.FullSize = UDim2.new(0, Config.WindowWidth, 0, Config.WindowHeight)
    self.Minimized = false
    
    -- Connect window control events
    self:ConnectControls()
    
    -- Initialize window dragging
    self:InitializeDragging()
    
    -- Set up global visibility toggle with RightShift
    self:SetupVisibilityToggle()
    
    -- Apply initial animation
    self:AnimateIn()
    
    return self
end

-- Select a tab
function Window:SelectTab(tab)
    -- Deselect the current tab if there is one
    if self.CurrentTab then
        self.CurrentTab:SetSelected(false)
    end
    
    -- Select the new tab
    self.CurrentTab = tab
    tab:SetSelected(true)
end

-- Create a new tab
function Window:CreateTab(name)
    local tab = Tab.new(self, name)
    table.insert(self.Tabs, tab)
    
    -- Select the first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

-- Connect window control events
function Window:ConnectControls()
    -- Close button
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Minimize button
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Add hover effects
    self.CloseButton.MouseEnter:Connect(function()
        Utility.Tween(self.CloseButton, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        Utility.Tween(self.CloseButton, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    self.MinimizeButton.MouseEnter:Connect(function()
        Utility.Tween(self.MinimizeButton, {BackgroundTransparency = 0.2}, 0.2)
    end)
    
    self.MinimizeButton.MouseLeave:Connect(function()
        Utility.Tween(self.MinimizeButton, {BackgroundTransparency = 0.5}, 0.2)
    end)
end

-- Initialize window dragging
function Window:InitializeDragging()
    local UserInputService = game:GetService("UserInputService")
    
    -- Make title bar draggable
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPosition = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            local targetPosition = UDim2.new(
                self.StartPosition.X.Scale, 
                self.StartPosition.X.Offset + delta.X,
                self.StartPosition.Y.Scale, 
                self.StartPosition.Y.Offset + delta.Y
            )
            
            -- Constrain to safe viewport area
            local safeArea = Utility.GetSafeViewport()
            local absX = math.clamp(targetPosition.X.Offset, safeArea.X, safeArea.Width - self.MainFrame.AbsoluteSize.X)
            local absY = math.clamp(targetPosition.Y.Offset, safeArea.Y, safeArea.Height - self.MainFrame.AbsoluteSize.Y)
            
            Utility.Tween(self.MainFrame, {
                Position = UDim2.new(targetPosition.X.Scale, absX, targetPosition.Y.Scale, absY)
            }, 0.1)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
end

-- Toggle window between minimized and expanded states
function Window:ToggleMinimize()
    self.Minimized = not self.Minimized
    
    if self.Minimized then
        -- Minimize
        Utility.Tween(self.MainFrame, {Size = self.MinimizedSize}, 0.3)
        self.ContentContainer.Visible = false
        self.TabsContainer.Visible = false
        self.MinimizeButton.Text = "+"
    else
        -- Expand
        Utility.Tween(self.MainFrame, {Size = self.FullSize}, 0.3)
        self.ContentContainer.Visible = true
        self.TabsContainer.Visible = true
        self.MinimizeButton.Text = "-"
    end
end

-- Set up global visibility toggle with RightShift
function Window:SetupVisibilityToggle()
    local UserInputService = game:GetService("UserInputService")
    
    -- Keep track of visibility state
    self.Visible = true
    
    -- Create connection
    self.KeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            self:ToggleVisibility()
        end
    end)
end

-- Toggle UI visibility
function Window:ToggleVisibility()
    self.Visible = not self.Visible
    self.GUI.Enabled = self.Visible
end

-- Animate window appearing
function Window:AnimateIn()
    self.MainFrame.Position = UDim2.new(0.5, -Config.WindowWidth / 2, 0.6, -Config.WindowHeight / 2)
    self.MainFrame.BackgroundTransparency = 1
    
    -- Animate to final position
    Utility.Tween(self.MainFrame, {
        Position = UDim2.new(0.5, -Config.WindowWidth / 2, 0.5, -Config.WindowHeight / 2),
        BackgroundTransparency = 1 - Config.Themes.Default.Transparency
    }, 0.5, Enum.EasingStyle.Back)
end

-- Destroy the window and clean up
function Window:Destroy()
    -- Animate out
    Utility.Tween(self.MainFrame, {
        Position = UDim2.new(0.5, -Config.WindowWidth / 2, 0.6, -Config.WindowHeight / 2),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
        -- Clean up tabs
        for _, tab in pairs(self.Tabs) do
            tab:Destroy()
        end
        
        -- Disconnect events
        if self.KeyConnection then
            self.KeyConnection:Disconnect()
        end
        
        -- Remove GUI
        self.GUI:Destroy()
    end)
end

-- Library Functions
function Library:CreateWindow(title, theme)
    local window = Window.new(title, theme)
    return window
end

-- Set the library theme
function Library:SetTheme(themeName)
    if Config.Themes[themeName] then
        Config.Themes.Default = Config.Themes[themeName]
    end
end

-- Get a copy of the current theme
function Library:GetTheme()
    return table.clone(Config.Themes.Default)
end

-- Create a custom theme
function Library:CreateTheme(themeName, themeData)
    Config.Themes[themeName] = themeData
    return themeData
end

-- Initialize default settings
local function Init()
    -- Apply safe defaults
    local success, err = pcall(function()
        -- Check if CoreGui is accessible
        if not pcall(function() return game:GetService("CoreGui") end) then
            -- Fallback to PlayerGui if CoreGui isn't accessible
            Library.UsePlayerGui = true
        end
    end)
    
    -- Return the initialized library
    return Library
end

-- Return the initialized library
return Init()
