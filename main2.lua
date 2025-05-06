--!strict
-- Rayfield-Inspired UI Library (Astra Hub)
-- Made by bloxi199 on discord (concept)
-- Developed by [Your Name/Alias Here]

local Library = {}
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer or Players.LocalPlayer:GetPropertyChangedSignal("PlayerGui"):Wait() -- Wait for LocalPlayer if it's not immediately available (e.g., in some contexts)
local PlayerGui = LocalPlayer.PlayerGui
local UserSettings = UserSettings()
local SavedSettings = UserSettings.Data or {}

-- Define Global State and Constants
Library.Name = "AstraHub"
Library.Version = "1.0.0"
Library.Author = "bloxi199 (concept), [Your Name/Alias Here] (dev)" -- Update this
Library.Theme = {} -- Will hold the current theme colors
Library.Flags = {} -- Stores flag values for configuration saving
Library.Elements = {} -- Stores references to elements by flag
Library.ConfigName = "AstraHubConfig" -- Default config file name
Library.ConfigFolder = "AstraHub" -- Default config folder name

-- Predefined Themes (Matches Rayfield structure)
local Themes = {
   Default = {
      TextColor = Color3.fromRGB(240, 240, 240), -- White-ish

      Background = Color3.fromRGB(25, 25, 25), -- Dark Grey Background
      Topbar = Color3.fromRGB(34, 34, 34),    -- Slightly Lighter Dark Grey Topbar
      Shadow = Color3.fromRGB(20, 20, 20),    -- Even Darker Grey for Shadow (Optional, not implemented visually here)

      NotificationBackground = Color3.fromRGB(20, 20, 20), -- Dark grey notification
      NotificationActionsBackground = Color3.fromRGB(230, 230, 230), -- Light grey notification actions (not implemented)

      TabBackground = Color3.fromRGB(80, 80, 80),       -- Medium Grey Tab
      TabStroke = Color3.fromRGB(85, 85, 85),         -- Slightly Lighter Grey Tab Stroke (Optional)
      TabBackgroundSelected = Color3.fromRGB(210, 210, 210), -- Light Grey Selected Tab Background
      TabTextColor = Color3.fromRGB(240, 240, 240),     -- White-ish Tab Text
      SelectedTabTextColor = Color3.fromRGB(50, 50, 50),  -- Dark Grey Selected Tab Text

      ElementBackground = Color3.fromRGB(35, 35, 35, 0.8), -- Dark Grey Elements with Transparency
      ElementBackgroundHover = Color3.fromRGB(40, 40, 40, 0.9), -- Hover with slight transparency change
      SecondaryElementBackground = Color3.fromRGB(25, 25, 25, 0.7), -- Darker Grey Secondary (Input/Dropdown) with Transparency
      ElementStroke = Color3.fromRGB(50, 50, 50),          -- Dark Grey Stroke (Optional)
      SecondaryElementStroke = Color3.fromRGB(40, 40, 40),       -- Even Darker Grey Stroke (Optional)

      SliderBackground = Color3.fromRGB(50, 138, 220), -- Blue Slider Bar
      SliderProgress = Color3.fromRGB(50, 138, 220),   -- Same Blue for Progress
      SliderStroke = Color3.fromRGB(58, 163, 255),     -- Slightly Lighter Blue Stroke (Optional)

      ToggleBackground = Color3.fromRGB(30, 30, 30),       -- Dark Grey Toggle Base
      ToggleEnabled = Color3.fromRGB(0, 146, 214),       -- Blue Enabled State
      ToggleDisabled = Color3.fromRGB(100, 100, 100),      -- Grey Disabled State
      ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),   -- Lighter Blue Stroke (Optional)
      ToggleDisabledStroke = Color3.fromRGB(125, 125, 125), -- Lighter Grey Stroke (Optional)
      ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100), -- Grey Outer Stroke (Optional)
      ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),   -- Darker Grey Outer Stroke (Optional)

      DropdownSelected = Color3.fromRGB(40, 40, 40),    -- Dark Grey Selected Dropdown Option
      DropdownUnselected = Color3.fromRGB(30, 30, 30),  -- Even Darker Grey Unselected Option

      InputBackground = Color3.fromRGB(30, 30, 30),     -- Dark Grey Input Field
      InputStroke = Color3.fromRGB(65, 65, 65),       -- Dark Grey Input Stroke (Optional)
      PlaceholderColor = Color3.fromRGB(178, 178, 178) -- Grey Placeholder Text
   },
   -- Add other theme definitions here if needed, e.g., AmberGlow, Amethyst, etc.
   -- AmberGlow = { ... },
   -- Amethyst = { ... },
   -- ...
}

-- Helper to apply theme colors to a UI element
local function applyTheme(element: Instance, themeColors: any)
   if not element or not themeColors then return end
   -- This is a simplified application. A real library would map element types
   -- and names (e.g., "ButtonFrame", "ButtonText") to specific theme colors.
   -- For this example, we'll just apply basic background/text colors where applicable.

   if element:IsA("Frame") or element:IsA("TextButton") or element:IsA("TextBox") or element:IsA("ImageLabel") then
      element.BackgroundColor3 = themeColors.ElementBackground or themeColors.Background
      element.BackgroundTransparency = (themeColors.ElementBackground or themeColors.Background).A -- Use Alpha for transparency
   end

   if element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") then
      element.TextColor3 = themeColors.TextColor or Color3.fromRGB(255, 255, 255)
   end

   -- Add more specific rules for toggles, sliders, etc., within their creation functions
end

-- Configuration Loading and Saving
local function getConfigTable()
   -- Uses a simple structure within UserSettings
   local config = SavedSettings[Library.ConfigFolder] or {}
   SavedSettings[Library.ConfigFolder] = config
   return config[Library.ConfigName] or {}
end

local function saveConfig(configTable: any)
   local config = SavedSettings[Library.ConfigFolder] or {}
   config[Library.ConfigName] = configTable
   SavedSettings[Library.ConfigFolder] = config
   -- UserSettings automatically saves on game exit/state change,
   -- but explicit save is good for exploits or dynamic changes.
   -- If using writefile/readfile, implement that logic here.
   -- Example (Executor specific, might need adjustment):
   -- pcall(function() writefile(Library.ConfigFolder .. "/" .. Library.ConfigName .. ".json", game:GetService("HttpService"):JSONEncode(configTable)) end)
end

local currentConfig = getConfigTable()

local function loadFlag(flag: string, defaultValue: any): any
   local value = currentConfig[flag]
   if value == nil then
      Library.Flags[flag] = defaultValue
      return defaultValue
   else
      Library.Flags[flag] = value
      return value
   end
end

local function saveFlag(flag: string, value: any)
   Library.Flags[flag] = value
   currentConfig[flag] = value
   saveConfig(currentConfig)
end

-- Helper for creating basic UI elements
local function createUI(class: string, props: any, parent: Instance)
   local ui = Instance.new(class)
   for prop, value in props do
      if prop == "BackgroundColor3" or prop == "BorderColor3" or prop == "TextColor3" then
         -- Apply color and alpha (transparency) if provided in the Color3 itself
         ui[prop] = value
         if prop == "BackgroundColor3" then
            ui.BackgroundTransparency = value.A
         end
      elseif prop == "Size" or prop == "Position" then
         ui[prop] = UDim2.new(value[1], value[2], value[3], value[4]) -- Expecting { xScale, xOffset, yScale, yOffset }
      elseif prop == "AnchorPoint" then
         ui[prop] = Vector2.new(value[1], value[2]) -- Expecting { x, y }
      else
         ui[prop] = value
      end
   end
   ui.Parent = parent
   return ui
end

-- --- Loading Screen ---
local loadingGui = createUI("ScreenGui", {
   Name = "AstraHubLoading",
   DisplayOrder = 100, -- Ensure it's on top
   ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
   Parent = CoreGui or PlayerGui -- Try CoreGui first
}, CoreGui or PlayerGui) -- Need to parent immediately to be visible

local loadingBackground = createUI("Frame", {
   Name = "Background",
   Size = {1, 0, 1, 0},
   Position = {0, 0, 0, 0},
   BackgroundColor3 = Color3.fromRGB(0, 0, 0),
   BackgroundTransparency = 0.7,
}, loadingGui)

local loadingLabel = createUI("TextLabel", {
   Name = "Label",
   Size = {1, -20, 0, 100},
   Position = {0, 10, 0.5, -50},
   AnchorPoint = {0, 0.5},
   BackgroundTransparency = 1,
   TextColor3 = Color3.fromRGB(255, 255, 255),
   TextScaled = true,
   TextWrap = true,
   Font = Enum.Font.SourceSansBold,
   Text = "Astra hub \n loading... \n Made by bloxi199 on discord!",
   TextXAlignment = Enum.TextXAlignment.Center,
   TextYAlignment = Enum.TextYAlignment.Center,
}, loadingBackground)

-- --- Main Library Object ---

-- Notification System
local notificationQueue = {}
local notificationVisible = false
local notificationFrame: Frame? = nil

local function createNotification()
   local gui = Library.ScreenGui
   if not gui then return nil end -- GUI not created yet

   local notify = createUI("Frame", {
      Name = "Notification",
      Size = {0, 250, 0, 80},
      Position = {1, -260, 0, 10}, -- Start off-screen right
      AnchorPoint = {1, 0},
      BackgroundColor3 = Library.Theme.NotificationBackground or Color3.fromRGB(20, 20, 20),
      BackgroundTransparency = (Library.Theme.NotificationBackground or Color3.fromRGB(20,20,20)).A,
      BorderSizePixel = 0,
      ZIndex = 10, -- Above window
      ClipsDescendants = true,
   }, gui)

   local padding = createUI("UIPadding", {
       PaddingLeft = UDim.new(0, 10),
       PaddingRight = UDim.new(0, 10),
       PaddingTop = UDim.new(0, 10),
       PaddingBottom = UDim.new(0, 10),
   }, notify)

   local listLayout = createUI("UIListLayout", {
       FillDirection = Enum.FillDirection.Vertical,
       HorizontalAlignment = Enum.HorizontalAlignment.Left,
       VerticalAlignment = Enum.VerticalAlignment.Top,
       SortOrder = Enum.SortOrder.LayoutOrder,
       Padding = UDim.new(0, 5),
   }, notify)

   local iconArea = createUI("Frame", { -- Area for Icon and Text
      Name = "IconArea",
      Size = {1, 0, 0, 60}, -- Fills horizontal, fixed height
      BackgroundTransparency = 1,
   }, notify)

   local iconLayout = createUI("UIListLayout", {
      FillDirection = Enum.FillDirection.Horizontal,
      HorizontalAlignment = Enum.HorizontalAlignment.Left,
      VerticalAlignment = Enum.VerticalAlignment.Center,
      SortOrder = Enum.SortOrder.LayoutOrder,
      Padding = UDim.new(0, 10),
   }, iconArea)


   local icon = createUI("ImageLabel", {
      Name = "Icon",
      Size = {0, 40, 0, 40},
      BackgroundTransparency = 1,
      Image = "", -- Set later
      ScaleType = Enum.ScaleType.Fit,
   }, iconArea)

   local textFrame = createUI("Frame", {
      Name = "TextFrame",
      Size = {1, -50, 1, 0}, -- Fill remaining space horizontally
      BackgroundTransparency = 1,
   }, iconArea)

    local textLayout = createUI("UIListLayout", {
       FillDirection = Enum.FillDirection.Vertical,
       HorizontalAlignment = Enum.HorizontalAlignment.Left,
       VerticalAlignment = Enum.VerticalAlignment.Center,
       SortOrder = Enum.SortOrder.LayoutOrder,
       Padding = UDim.new(0, 2),
    }, textFrame)


   local titleLabel = createUI("TextLabel", {
      Name = "Title",
      Size = {1, 0, 0, 20},
      BackgroundTransparency = 1,
      TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
      TextScaled = true,
      TextWrapped = true,
      Font = Enum.Font.SourceSansBold,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Center,
   }, textFrame)
    titleLabel.MinimumSize = UDim2.new(0,0,0,0) -- Allow scaling down

   local contentLabel = createUI("TextLabel", {
      Name = "Content",
      Size = {1, 0, 0, 0}, -- Will auto-size with LayoutOrder
      BackgroundTransparency = 1,
      TextColor3 = (Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)),
      TextScaled = true,
      TextWrapped = true,
      Font = Enum.Font.SourceSansLight,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Top,
   }, textFrame)
    contentLabel.MinimumSize = UDim2.new(0,0,0,0)

    return notify
end

local function processNotificationQueue()
   if notificationVisible or #notificationQueue == 0 then return end

   notificationVisible = true
   local notifyData = table.remove(notificationQueue, 1)

   if not notificationFrame or not notificationFrame.Parent then
       notificationFrame = createNotification()
       if not notificationFrame then
           notificationVisible = false
           warn("AstraHub: Could not create notification frame.")
           return
       end
   end

   local frame = notificationFrame
   local icon = frame:FindFirstChild("IconArea", true):FindFirstChild("Icon") as ImageLabel
   local titleLabel = frame:FindFirstChild("IconArea", true):FindFirstChild("TextFrame"):FindFirstChild("Title") as TextLabel
   local contentLabel = frame:FindFirstChild("IconArea", true):FindFirstChild("TextFrame"):FindFirstChild("Content") as TextLabel

   titleLabel.Text = notifyData.Title or "Notification"
   contentLabel.Text = notifyData.Content or "Content"

   -- Handle Icon: ImageId (number) or Lucide (string)
   if type(notifyData.Image) == "number" then
      icon.Image = "rbxassetid://" .. notifyData.Image
      icon.Visible = true
   elseif type(notifyData.Image) == "string" then
       warn("AstraHub: Lucide icon requested ('" .. notifyData.Image .. "'). Lucide icons are not supported in this loadstring version. Showing placeholder or no icon.")
       -- Optional: Display the icon name as text or use a generic image
       icon.Visible = false -- Hide icon for now
   else
       icon.Visible = false -- Hide icon if no valid input
   end

    -- Adjust text frame size based on icon visibility
    local textFrame = icon.Parent:FindFirstChild("TextFrame") as Frame
    if icon.Visible then
        textFrame.Size = UDim2.new(1, -50, 1, 0) -- Keep space for icon
    else
         textFrame.Size = UDim2.new(1, 0, 1, 0) -- Fill space
    end


   -- Tween in
   local inTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(1, -260, 0, 10) })
   inTween:Play()

   inTween.Completed:Wait()

   -- Wait for duration
   task.wait(notifyData.Duration or 6.5)

   -- Tween out
   local outTween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 10, 0, 10) })
   outTween:Play()

   outTween.Completed:Wait()

   notificationVisible = false

   -- Process next notification
   processNotificationQueue()
end

function Library:Notify(config: { Title: string, Content: string, Duration: number?, Image: number? | string? })
   table.insert(notificationQueue, config)
   if not notificationVisible then
      processNotificationQueue()
   end
end


function Library:CreateWindow(config: {
   Name: string,
   Icon: number? | string?, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle: string,
   LoadingSubtitle: string,
   Theme: string | { [string]: Color3 }?, -- Check https://docs.sirius.menu/rayfield/configuration/themes or use custom table
   DisableRayfieldPrompts: boolean?,
   DisableBuildWarnings: boolean?, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
   ConfigurationSaving: { Enabled: boolean, FolderName: string?, FileName: string? }?,
   Discord: { Enabled: boolean, Invite: string, RememberJoins: boolean? }?,
   KeySystem: boolean?,
   KeySettings: {
      Title: string,
      Subtitle: string,
      Note: string, -- Use this to tell the user how to get a key
      FileName: string, -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey: boolean?, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite: boolean?, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key: { string } -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }?,
})
   -- Hide loading screen
   if loadingGui and loadingGui.Parent then
      loadingGui:Destroy()
   end

   if Library.ScreenGui and Library.ScreenGui.Parent then
      warn("AstraHub: Window already created. Destroying existing GUI.")
      Library:Destroy()
   end

   local screenGui = createUI("ScreenGui", {
      Name = "AstraHubGui",
      DisplayOrder = 50, -- Standard order
      ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
      Parent = CoreGui or PlayerGui -- Try CoreGui first
   }, CoreGui or PlayerGui)

   Library.ScreenGui = screenGui

   -- --- Window Structure ---
   local windowFrame = createUI("Frame", {
      Name = "WindowFrame",
      Size = {0, 600, 0, 400}, -- Example size
      Position = {0.5, -300, 0.5, -200}, -- Centered
      AnchorPoint = {0.5, 0.5},
      BackgroundColor3 = Library.Theme.Background or Color3.fromRGB(25, 25, 25),
      BackgroundTransparency = (Library.Theme.Background or Color3.fromRGB(25,25,25)).A,
      BorderSizePixel = 1,
      BorderColor3 = Library.Theme.Shadow or Color3.fromRGB(20, 20, 20), -- Simple border as shadow
      ClipsDescendants = true,
   }, screenGui)

    local windowPadding = createUI("UIPadding", {
        PaddingBottom = UDim.new(0, 5) -- Space below content
    }, windowFrame)

   -- --- Top Bar ---
   local topBar = createUI("Frame", {
      Name = "TopBar",
      Size = {1, 0, 0, 30},
      Position = {0, 0, 0, 0},
      BackgroundColor3 = Library.Theme.Topbar or Color3.fromRGB(34, 34, 34),
      BackgroundTransparency = (Library.Theme.Topbar or Color3.fromRGB(34,34,34)).A,
      BorderSizePixel = 0,
   }, windowFrame)

   local topBarPadding = createUI("UIPadding", {
       PaddingLeft = UDim.new(0, 5),
       PaddingRight = UDim.new(0, 5),
   }, topBar)

    local topBarLayout = createUI("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    }, topBar)


   local windowIcon = createUI("ImageLabel", {
      Name = "WindowIcon",
      Size = {0, 20, 0, 20},
      BackgroundTransparency = 1,
      Image = "", -- Set later
      ScaleType = Enum.ScaleType.Fit,
      LayoutOrder = 1,
      Visible = false, -- Hidden by default
   }, topBar)


   local windowTitle = createUI("TextLabel", {
      Name = "WindowTitle",
      Size = {1, -60, 0, 20}, -- Fill space minus icon and buttons
      BackgroundTransparency = 1,
      TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
      TextScaled = true,
      TextWrapped = true,
      Font = Enum.Font.SourceSansBold,
      Text = config.Name or "Astra Hub",
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Center,
      LayoutOrder = 2,
   }, topBar)
    windowTitle.MinimumSize = UDim2.new(0,0,0,0) -- Allow scaling down


    local buttonFrame = createUI("Frame", {
        Name = "Buttons",
        Size = {0, 50, 1, 0}, -- Fixed width for buttons
        BackgroundTransparency = 1,
        LayoutOrder = 3,
    }, topBar)

    local buttonLayout = createUI("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.YAlignment.Center, -- Use YAlignment for frame
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = buttonFrame,
    })

   local minimizeButton = createUI("TextButton", {
      Name = "MinimizeButton",
      Size = {0, 20, 0, 20},
      BackgroundTransparency = 1,
      TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
      TextScaled = true,
      Font = Enum.Font.SourceSansBold,
      Text = "-", -- Use text for simplicity
      TextXAlignment = Enum.TextXAlignment.Center,
      TextYAlignment = Enum.TextYAlignment.Center,
      LayoutOrder = 1,
   }, buttonFrame)

   local closeButton = createUI("TextButton", {
      Name = "CloseButton",
      Size = {0, 20, 0, 20},
      BackgroundTransparency = 1,
      TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
      TextScaled = true,
      Font = Enum.Font.SourceSansBold,
      Text = "X", -- Use text for simplicity
      TextXAlignment = Enum.TextXAlignment.Center,
      TextYAlignment = Enum.TextYAlignment.Center,
      LayoutOrder = 2,
   }, buttonFrame)


    -- Handle Window Icon
    if type(config.Icon) == "number" and config.Icon ~= 0 then
        windowIcon.Image = "rbxassetid://" .. config.Icon
        windowIcon.Visible = true
        windowTitle.Size = UDim2.new(1, -85, 0, 20) -- Make space for icon
    elseif type(config.Icon) == "string" then
         warn("AstraHub: Lucide icon requested for Window ('" .. config.Icon .. "'). Lucide icons are not supported in this loadstring version.")
         -- windowIcon.Visible = false
    else
        windowIcon.Visible = false
         windowTitle.Size = UDim2.new(1, -60, 0, 20) -- No space for icon
    end


   -- --- Tab Bar ---
   local tabBar = createUI("Frame", {
      Name = "TabBar",
      Size = {0, 150, 1, -30}, -- Fixed width tab bar on the left
      Position = {0, 0, 0, 30}, -- Below top bar
      BackgroundColor3 = Library.Theme.TabBackground or Color3.fromRGB(80, 80, 80),
      BackgroundTransparency = (Library.Theme.TabBackground or Color3.fromRGB(80,80,80)).A,
      BorderSizePixel = 0,
   }, windowFrame)

    local tabListLayout = createUI("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabBar,
    })

   -- --- Content Area ---
   local contentArea = createUI("Frame", {
      Name = "ContentArea",
      Size = {1, -150, 1, -30}, -- Fills remaining space
      Position = {0, 150, 0, 30}, -- Right of tab bar, below top bar
      BackgroundColor3 = Library.Theme.ElementBackground or Color3.fromRGB(35, 35, 35),
      BackgroundTransparency = (Library.Theme.ElementBackground or Color3.fromRGB(35,35,35)).A,
      BorderSizePixel = 0,
      ClipsDescendants = true,
   }, windowFrame)

   local contentPadding = createUI("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    }, contentArea)


   local contentListLayout = createUI("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8), -- Spacing between sections/elements
        Parent = contentArea,
    })


   -- --- Window Object ---
   local Window = {}
   Window.Frame = windowFrame
   Window.TopBar = topBar
   Window.TabBar = tabBar
   Window.ContentArea = contentArea
   Window.Tabs = {}
   Window.CurrentTab = nil
   Window.IsMinimized = false

    -- Dragging Logic
    local dragging = false
    local dragStartPos = Vector2.zero
    local initialPos = UDim2.new()

    topBar.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        dragStartPos = input.Position
        initialPos = windowFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            windowFrame.Position = UDim2.new(
                initialPos.X.Scale, initialPos.X.Offset + delta.X,
                initialPos.Y.Scale, initialPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Minimize Logic
    minimizeButton.MouseButton1Click:Connect(function()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            -- Store current size before minimizing
            windowFrame.Size = UDim2.new(windowFrame.Size.X.Scale, windowFrame.Size.X.Offset, 0, topBar.Size.Y.Offset)
            contentArea.Visible = false
            tabBar.Visible = false
            minimizeButton.Text = "+" -- Change icon
        else
            -- Restore size (example size, could store actual previous size)
            windowFrame.Size = UDim2.new(0, 600, 0, 400) -- Restore example size
            contentArea.Visible = true
             tabBar.Visible = true
            minimizeButton.Text = "-" -- Change icon back
        end
    end)

    -- Close Logic
    closeButton.MouseButton1Click:Connect(function()
        -- This only closes the window, not the whole library (Library:Destroy does that)
        windowFrame:Destroy()
        Library.Window = nil -- Clear the window reference
    end)


    -- Apply initial theme
    function Window.ModifyTheme(themeIdentifier: string | { [string]: Color3 })
        local themeColors
        if type(themeIdentifier) == "string" then
            themeColors = Themes[themeIdentifier]
            if not themeColors then
                warn("AstraHub: Theme '" .. themeIdentifier .. "' not found. Using Default.")
                themeColors = Themes.Default
            end
        elseif type(themeIdentifier) == "table" then
            themeColors = themeIdentifier -- Use custom theme table
        else
             warn("AstraHub: Invalid theme type provided. Using Default.")
             themeColors = Themes.Default
        end

        Library.Theme = themeColors or Themes.Default -- Ensure Library.Theme is set

        -- Apply theme to window elements
        windowFrame.BackgroundColor3 = Library.Theme.Background
        windowFrame.BackgroundTransparency = Library.Theme.Background.A
        windowFrame.BorderColor3 = Library.Theme.Shadow or Color3.fromRGB(20, 20, 20)

        topBar.BackgroundColor3 = Library.Theme.Topbar
        topBar.BackgroundTransparency = Library.Theme.Topbar.A

        windowTitle.TextColor3 = Library.Theme.TextColor
        minimizeButton.TextColor3 = Library.Theme.TextColor
        closeButton.TextColor3 = Library.Theme.TextColor

        tabBar.BackgroundColor3 = Library.Theme.TabBackground
        tabBar.BackgroundTransparency = Library.Theme.TabBackground.A

        contentArea.BackgroundColor3 = Library.Theme.ElementBackground
        contentArea.BackgroundTransparency = Library.Theme.ElementBackground.A

        -- Re-apply theme to all existing tabs and elements
        for _, tab in pairs(Window.Tabs) do
            -- Apply theme to tab button
            if tab.Button == Window.CurrentTab.Button then -- Assuming CurrentTab holds the tab object
                 tab.Button.BackgroundColor3 = Library.Theme.TabBackgroundSelected
                 tab.Button.BackgroundTransparency = Library.Theme.TabBackgroundSelected.A
                 tab.Button.TextColor3 = Library.Theme.SelectedTabTextColor
            else
                tab.Button.BackgroundColor3 = Library.Theme.TabBackground
                tab.Button.BackgroundTransparency = Library.Theme.TabBackground.A
                 tab.Button.TextColor3 = Library.Theme.TabTextColor
            end
            -- Apply theme to tab icon (if ImageLabel)
            if tab.Button.Icon:IsA("ImageLabel") then
                 -- Icon color logic is complex and not standard across libraries/themes
                 -- Usually icons are grayscale and tinted, or multi-color.
                 -- Simple approach: just ensure it's visible if set, color might be ignored.
            end


            -- Apply theme to elements within the tab content frame
            -- This would require each element type to have an applyTheme method or similar logic
            -- For simplicity in this example, elements primarily get colors from parent containers
            -- or apply colors during their creation based on the *current* Library.Theme.
            -- A full re-apply requires iterating deeply or having element-specific methods.
            -- We'll skip deep re-application for this example's complexity level.
        end
         -- Notify system might need color updates too
         if notificationFrame then
             notificationFrame.BackgroundColor3 = Library.Theme.NotificationBackground or Color3.fromRGB(20, 20, 20)
             notificationFrame.BackgroundTransparency = (Library.Theme.NotificationBackground or Color3.fromRGB(20, 20, 20)).A
              local titleLbl = notificationFrame:FindFirstChild("IconArea", true):FindFirstChild("TextFrame"):FindFirstChild("Title") as TextLabel
             local contentLbl = notificationFrame:FindFirstChild("IconArea", true):FindFirstChild("TextFrame"):FindFirstChild("Content") as TextLabel
             titleLbl.TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)
             contentLbl.TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)
         end
    end

    -- Initialize Theme
    Window.ModifyTheme(config.Theme or "Default")


   -- --- Tab Creation ---
   function Window:CreateTab(title: string, icon: number? | string?)
      local tabButton = createUI("TextButton", {
         Name = title:gsub(" ", "_") .. "TabButton",
         Size = {1, -10, 0, 25}, -- Full width minus padding, fixed height
         BackgroundTransparency = 1, -- Initially transparent, color set by theme
         TextColor3 = Library.Theme.TabTextColor or Color3.fromRGB(240, 240, 240),
         TextScaled = true,
         TextWrapped = true,
         Font = Enum.Font.SourceSansBold,
         Text = title,
         TextXAlignment = Enum.TextXAlignment.Left,
         TextYAlignment = Enum.TextYAlignment.Center,
         LayoutOrder = #Window.Tabs + 1,
      }, tabBar)

      local tabButtonLayout = createUI("UIListLayout", {
           FillDirection = Enum.FillDirection.Horizontal,
           HorizontalAlignment = Enum.HorizontalAlignment.Left,
           VerticalAlignment = Enum.VerticalAlignment.Center,
           SortOrder = Enum.SortOrder.LayoutOrder,
           Padding = UDim.new(0, 5),
           Parent = tabButton,
       })

      local tabIcon = createUI("ImageLabel", {
          Name = "Icon",
          Size = {0, 20, 0, 20},
          BackgroundTransparency = 1,
          Image = "", -- Set later
          ScaleType = Enum.ScaleType.Fit,
          LayoutOrder = 1,
          Visible = false, -- Hidden by default
      }, tabButton)

      local tabTitleLabel = createUI("TextLabel", {
         Name = "Title",
         Size = {1, -25, 1, 0}, -- Fill remaining width
         BackgroundTransparency = 1,
         TextColor3 = Library.Theme.TabTextColor or Color3.fromRGB(240, 240, 240),
         TextScaled = true,
         TextWrapped = true,
         Font = Enum.Font.SourceSansBold,
         Text = title,
         TextXAlignment = Enum.TextXAlignment.Left,
         TextYAlignment = Enum.TextYAlignment.Center,
         LayoutOrder = 2,
      }, tabButton)
        tabTitleLabel.MinimumSize = UDim2.new(0,0,0,0) -- Allow scaling down

       -- Handle Tab Icon
        if type(icon) == "number" and icon ~= 0 then
            tabIcon.Image = "rbxassetid://" .. icon
            tabIcon.Visible = true
             tabTitleLabel.Size = UDim2.new(1, -25, 1, 0) -- Make space for icon
        elseif type(icon) == "string" then
             warn("AstraHub: Lucide icon requested for tab ('" .. icon .. "'). Lucide icons are not supported in this loadstring version.")
            -- tabIcon.Visible = false
             tabTitleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
        else
            tabIcon.Visible = false
             tabTitleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
        end
        tabButton.Icon = tabIcon -- Store reference


      local tabContentFrame = createUI("Frame", {
         Name = title:gsub(" ", "_") .. "Content",
         Size = {1, 0, 1, 0}, -- Fills content area
         Position = {0, 0, 0, 0},
         BackgroundTransparency = 1, -- See-through content frame
         Visible = false, -- Hidden by default
      }, contentArea)

       local tabContentListLayout = contentArea:FindFirstChild("UIListLayout") -- Use the main content area layout

      local Tab = {}
      Tab.Title = title
      Tab.Icon = icon
      Tab.Button = tabButton
      Tab.Frame = tabContentFrame
      Tab.Elements = {} -- List of elements in this tab

      -- Add element creation functions to Tab object
      function Tab:CreateSection(name: string)
          local sectionFrame = createUI("Frame", {
              Name = name:gsub(" ", "_") .. "Section",
              Size = {1, 0, 0, 0}, -- Auto size height
              BackgroundTransparency = 1,
          }, tabContentFrame)

          local sectionLayout = createUI("UIListLayout", {
              FillDirection = Enum.FillDirection.Vertical,
              HorizontalAlignment = Enum.HorizontalAlignment.Center,
              VerticalAlignment = Enum.VerticalAlignment.Top,
              SortOrder = Enum.SortOrder.LayoutOrder,
              Padding = UDim.new(0, 5), -- Spacing between elements in the section
              Parent = sectionFrame,
          })

          local sectionTitle = createUI("TextLabel", {
              Name = "Title",
              Size = {1, 0, 0, 20},
              BackgroundTransparency = 1,
              TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
              TextScaled = true,
              TextWrapped = true,
              Font = Enum.Font.SourceSansBold,
              Text = name,
              TextXAlignment = Enum.TextXAlignment.Left,
              TextYAlignment = Enum.TextYAlignment.Center,
          }, sectionFrame)
           sectionTitle.MinimumSize = UDim2.new(0,0,0,0)

          local Section = {}
          Section.Frame = sectionFrame
          Section.TitleLabel = sectionTitle
          Section.Elements = {} -- Elements directly in this section

          function Section:Set(newName: string)
              Section.TitleLabel.Text = newName
          end

          table.insert(Tab.Elements, Section)
          return Section
      end

        function Tab:CreateDivider()
            local dividerFrame = createUI("Frame", {
                 Name = "Divider",
                 Size = {1, 0, 0, 1}, -- Full width, 1 pixel height
                 BackgroundColor3 = Library.Theme.ElementStroke or Color3.fromRGB(50, 50, 50),
                 BackgroundTransparency = (Library.Theme.ElementStroke or Color3.fromRGB(50,50,50)).A,
                 BorderSizePixel = 0,
            }, tabContentFrame)

            local Divider = {}
            Divider.Frame = dividerFrame

            function Divider:Set(isVisible: boolean)
                Divider.Frame.Visible = isVisible
            end

            table.insert(Tab.Elements, Divider)
            return Divider
        end

      -- Generic element creation helper (to avoid repeating boilerplates)
      local function createElementFrame(parent: Instance, name: string, config: { Flag: string? }): Frame
           local elementFrame = createUI("Frame", {
               Name = name:gsub(" ", "_") .. "Element",
               Size = {1, 0, 0, 30}, -- Auto height, full width
               BackgroundColor3 = Library.Theme.ElementBackground or Color3.fromRGB(35, 35, 35),
               BackgroundTransparency = (Library.Theme.ElementBackground or Color3.fromRGB(35,35,35)).A,
               BorderSizePixel = 0,
           }, parent)

           local padding = createUI("UIPadding", {
               PaddingLeft = UDim.new(0, 5),
               PaddingRight = UDim.new(0, 5),
               PaddingTop = UDim.new(0, 5),
               PaddingBottom = UDim.new(0, 5),
           }, elementFrame)

           local layout = createUI("UIListLayout", {
               FillDirection = Enum.FillDirection.Horizontal, -- Default horizontal layout
               HorizontalAlignment = Enum.HorizontalAlignment.Left,
               VerticalAlignment = Enum.VerticalAlignment.Center,
               SortOrder = Enum.SortOrder.LayoutOrder,
               Padding = UDim.new(0, 5),
               Parent = elementFrame,
           })

           if config and config.Flag then
                Library.Elements[config.Flag] = { Frame = elementFrame, Type = name, Flag = config.Flag } -- Store reference
           end

           return elementFrame
       end

       local function createElementLabel(parent: Instance, text: string): TextLabel
           local label = createUI("TextLabel", {
               Name = "Label",
               Size = {0, 100, 1, 0}, -- Example size, adjust as needed
               BackgroundTransparency = 1,
               TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
               TextScaled = true,
               TextWrapped = true,
               Font = Enum.Font.SourceSansSemibold,
               Text = text,
               TextXAlignment = Enum.TextXAlignment.Left,
               TextYAlignment = Enum.TextYAlignment.Center,
               LayoutOrder = 1,
           }, parent)
            label.MinimumSize = UDim2.new(0,0,0,0)
            return label
       end

        -- Button
      function Tab:CreateButton(config: { Name: string, Callback: (() -> ()) })
          local frame = createElementFrame(tabContentFrame, "Button", config)
          frame.Size = UDim2.new(1, 0, 0, 30) -- Fixed size for simple elements

          local button = createUI("TextButton", {
              Name = "Button",
              Size = {1, 0, 1, 0}, -- Fill parent frame
              BackgroundTransparency = 1,
              TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
              TextScaled = true,
              TextWrapped = true,
              Font = Enum.Font.SourceSansSemibold,
              Text = config.Name,
              TextXAlignment = Enum.TextXAlignment.Center,
              TextYAlignment = Enum.TextYAlignment.Center,
              LayoutOrder = 2, -- After potential label if horizontal
          }, frame)
           button.MinimumSize = UDim2.new(0,0,0,0)


          button.MouseButton1Click:Connect(function()
              if config.Callback then
                  pcall(config.Callback)
              end
          end)

          local Button = {}
          Button.Frame = frame
          Button.TextButton = button
          Button.CurrentValue = config.Name -- Rayfield docs show Button.Set updates name?

          function Button:Set(newName: string)
             Button.TextButton.Text = newName
             Button.CurrentValue = newName
             -- Rayfield doc doesn't show callback on set for button? Assuming no callback needed here.
          end

          if config.Flag then Library.Elements[config.Flag].Set = Button.Set end
          table.insert(Tab.Elements, Button)
          return Button
      end

        -- Toggle
       function Tab:CreateToggle(config: { Name: string, CurrentValue: boolean, Flag: string, Callback: ((value: boolean) -> ()) })
           local frame = createElementFrame(tabContentFrame, "Toggle", config)
            frame.Size = UDim2.new(1, 0, 0, 30)

           local label = createElementLabel(frame, config.Name)
           label.Size = UDim2.new(1, -40, 1, 0) -- Make space for the toggle switch
           label.LayoutOrder = 1

           local toggleFrame = createUI("Frame", {
               Name = "ToggleSwitch",
               Size = {0, 30, 0, 20},
               BackgroundColor3 = config.CurrentValue and (Library.Theme.ToggleEnabled or Color3.fromRGB(0, 146, 214)) or (Library.Theme.ToggleDisabled or Color3.fromRGB(100, 100, 100)),
               BackgroundTransparency = (config.CurrentValue and (Library.Theme.ToggleEnabled or Color3.fromRGB(0, 146, 214)) or (Library.Theme.ToggleDisabled or Color3.fromRGB(100, 100, 100))).A,
               BorderSizePixel = 1,
               BorderColor3 = config.CurrentValue and (Library.Theme.ToggleEnabledStroke or Color3.fromRGB(0, 170, 255)) or (Library.Theme.ToggleDisabledStroke or Color3.fromRGB(125, 125, 125)),
               LayoutOrder = 2,
           }, frame)

            local toggleCircle = createUI("Frame", {
               Name = "ToggleCircle",
               Size = {0, 16, 0, 16},
               Position = UDim2.new(0, config.CurrentValue and 12 or 2, 0, 2), -- Position based on state
               BackgroundColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
               BackgroundTransparency = (Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)).A,
               BorderSizePixel = 1,
               BorderColor3 = config.CurrentValue and (Library.Theme.ToggleEnabledOuterStroke or Color3.fromRGB(100, 100, 100)) or (Library.Theme.ToggleDisabledOuterStroke or Color3.fromRGB(65, 65, 65)),
           }, toggleFrame)

           createUI("UICorner", { CornerRadius = UDim.new(1, 0) }, toggleFrame)
           createUI("UICorner", { CornerRadius = UDim.new(1, 0) }, toggleCircle)

           local toggleCurrentValue = loadFlag(config.Flag, config.CurrentValue)
           toggleCircle.Position = UDim2.new(0, toggleCurrentValue and 12 or 2, 0, 2)
           toggleFrame.BackgroundColor3 = toggleCurrentValue and (Library.Theme.ToggleEnabled or Color3.fromRGB(0, 146, 214)) or (Library.Theme.ToggleDisabled or Color3.fromRGB(100, 100, 100))
           toggleFrame.BackgroundTransparency = (toggleCurrentValue and (Library.Theme.ToggleEnabled or Color3.fromRGB(0, 146, 214)) or (Library.Theme.ToggleDisabled or Color3.fromRGB(100, 100, 100))).A
           toggleFrame.BorderColor3 = toggleCurrentValue and (Library.Theme.ToggleEnabledStroke or Color3.fromRGB(0, 170, 255)) or (Library.Theme.ToggleDisabledStroke or Color3.fromRGB(125, 125, 125))
           toggleCircle.BorderColor3 = toggleCurrentValue and (Library.Theme.ToggleEnabledOuterStroke or Color3.fromRGB(100, 100, 100)) or (Library.Theme.ToggleDisabledOuterStroke or Color3.fromRGB(65, 65, 65))


           local Toggle = {}
           Toggle.Frame = frame
           Toggle.CurrentValue = toggleCurrentValue
           Toggle.Label = label
           Toggle.SwitchFrame = toggleFrame
           Toggle.SwitchCircle = toggleCircle

           local function updateVisualState(value: boolean)
               local targetPos = value and 12 or 2
               local targetColor = value and (Library.Theme.ToggleEnabled or Color3.fromRGB(0, 146, 214)) or (Library.Theme.ToggleDisabled or Color3.fromRGB(100, 100, 100))
                local targetBorderColor = value and (Library.Theme.ToggleEnabledStroke or Color3.fromRGB(0, 170, 255)) or (Library.Theme.ToggleDisabledStroke or Color3.fromRGB(125, 125, 125))
               local targetCircleBorderColor = value and (Library.Theme.ToggleEnabledOuterStroke or Color3.fromRGB(100, 100, 100)) or (Library.Theme.ToggleDisabledOuterStroke or Color3.fromRGB(65, 65, 65))


               TweenService:Create(toggleCircle, TweenInfo.new(0.1), { Position = UDim2.new(0, targetPos, 0, 2) }):Play()
               TweenService:Create(toggleFrame, TweenInfo.new(0.1), { BackgroundColor3 = targetColor, BackgroundTransparency = targetColor.A }):Play()
                TweenService:Create(toggleFrame, TweenInfo.new(0.1), { BorderColor3 = targetBorderColor }):Play()
                TweenService:Create(toggleCircle, TweenInfo.new(0.1), { BorderColor3 = targetCircleBorderColor }):Play()
           end

           local function toggleSwitch()
               Toggle.CurrentValue = not Toggle.CurrentValue
               updateVisualState(Toggle.CurrentValue)
               saveFlag(config.Flag, Toggle.CurrentValue)
               if config.Callback then
                   pcall(config.Callback, Toggle.CurrentValue)
               end
           end

           toggleFrame.MouseButton1Click:Connect(toggleSwitch)
            -- Make the label clickable too for easier interaction
           label.MouseButton1Click:Connect(toggleSwitch)

           function Toggle:Set(value: boolean)
                if type(value) ~= "boolean" or Toggle.CurrentValue == value then return end
               Toggle.CurrentValue = value
               updateVisualState(Toggle.CurrentValue)
               saveFlag(config.Flag, Toggle.CurrentValue)
               -- Rayfield docs imply callback is only on user interaction?
               -- If you want callback on Set, uncomment the lines below:
               -- if config.Callback then
               --     pcall(config.Callback, Toggle.CurrentValue)
               -- end
           end

           if config.Flag then Library.Elements[config.Flag].Set = Toggle.Set end
           table.insert(Tab.Elements, Toggle)

           -- Apply initial state from loaded config
           updateVisualState(Toggle.CurrentValue)
           if config.Callback then
                -- Callback on initial load if flag exists
                if currentConfig[config.Flag] ~= nil then
                     pcall(config.Callback, Toggle.CurrentValue)
                end
            end

           return Toggle
       end

        -- Color Picker (Simplified)
        function Tab:CreateColorPicker(config: { Name: string, Color: Color3, Flag: string, Callback: ((value: Color3) -> ()) })
             local frame = createElementFrame(tabContentFrame, "ColorPicker", config)
             frame.Size = UDim2.new(1, 0, 0, 50) -- Taller for color preview/picker

             local label = createElementLabel(frame, config.Name)
             label.Size = UDim2.new(0.5, 0, 1, 0) -- Half width for label
             label.LayoutOrder = 1

             local colorPreview = createUI("Frame", {
                 Name = "ColorPreview",
                 Size = {0.5, 0, 1, 0}, -- Half width for preview
                 BackgroundColor3 = config.Color, -- Default color
                 BackgroundTransparency = config.Color.A,
                 BorderSizePixel = 1,
                 BorderColor3 = Library.Theme.ElementStroke or Color3.fromRGB(50, 50, 50),
                 LayoutOrder = 2,
             }, frame)

            -- Load initial color from config
            local loadedColorValue = loadFlag(config.Flag, config.Color)
            colorPreview.BackgroundColor3 = loadedColorValue
            colorPreview.BackgroundTransparency = loadedColorValue.A

             -- Simple Color Picker Implementation (Click to open prompt)
             -- A real in-UI color picker requires complex UI/logic (spectrum, slider, input boxes).
             -- For this example, we'll use a simple method like a prompt or a predefined palette.
             -- Rayfield likely has a custom UI element for this. We'll simulate by changing color on click.
             -- *** NOTE: This is a placeholder. A real ColorPicker needs proper UI interaction. ***
             local ColorPicker = {}
             ColorPicker.Frame = frame
             ColorPicker.CurrentValue = loadedColorValue
             ColorPicker.Label = label
             ColorPicker.ColorPreview = colorPreview
             ColorPicker.DefaultColor = config.Color

             function ColorPicker:Set(color: Color3)
                if not (typeof(color) == "Color3") or ColorPicker.CurrentValue == color then return end
                ColorPicker.CurrentValue = color
                ColorPicker.ColorPreview.BackgroundColor3 = color
                ColorPicker.ColorPreview.BackgroundTransparency = color.A
                saveFlag(config.Flag, color)
                -- Callback on Set is common for ColorPickers
                if config.Callback then
                    pcall(config.Callback, ColorPicker.CurrentValue)
                end
             end

              -- Placeholder Interaction: Click to cycle through a few colors or prompt (prompt hard in loadstring)
             colorPreview.MouseButton1Click:Connect(function()
                local newColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)) -- Example: random color
                 ColorPicker:Set(newColor) -- Call Set to update visuals, save, and trigger callback
                  if config.Callback then
                     pcall(config.Callback, ColorPicker.CurrentValue)
                 end
             end)


             if config.Flag then Library.Elements[config.Flag].Set = ColorPicker.Set end
             table.insert(Tab.Elements, ColorPicker)

            -- Callback on initial load if flag exists
            if currentConfig[config.Flag] ~= nil then
                 if config.Callback then
                     pcall(config.Callback, ColorPicker.CurrentValue)
                 end
             end

             return ColorPicker
        end

        -- Slider
       function Tab:CreateSlider(config: { Name: string, Range: { number, number }, Increment: number, Suffix: string, CurrentValue: number, Flag: string, Callback: ((value: number) -> ()) })
            local frame = createElementFrame(tabContentFrame, "Slider", config)
            frame.Size = UDim2.new(1, 0, 0, 40) -- Taller for slider visuals

            local labelFrame = createUI("Frame", { -- Frame for label and value display
                 Name = "LabelFrame",
                 Size = {1, 0, 0, 15}, -- Fixed height
                 BackgroundTransparency = 1,
                 LayoutOrder = 1,
            }, frame)
             createUI("UIListLayout", {
                  FillDirection = Enum.FillDirection.Horizontal,
                  HorizontalAlignment = Enum.HorizontalAlignment.Left,
                  VerticalAlignment = Enum.VerticalAlignment.Center,
                  SortOrder = Enum.SortOrder.LayoutOrder,
                  Parent = labelFrame,
             })

            local label = createElementLabel(labelFrame, config.Name)
            label.Size = UDim2.new(1, -60, 1, 0) -- Make space for value text
             label.LayoutOrder = 1
            label.TextXAlignment = Enum.TextXAlignment.Left


            local valueLabel = createUI("TextLabel", {
                 Name = "ValueLabel",
                 Size = {0, 60, 1, 0}, -- Fixed width for value
                 BackgroundTransparency = 1,
                 TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                 TextScaled = true,
                 Font = Enum.Font.SourceSansSemibold,
                 Text = tostring(config.CurrentValue) .. (config.Suffix or ""),
                 TextXAlignment = Enum.TextXAlignment.Right,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 2,
            }, labelFrame)
             valueLabel.MinimumSize = UDim2.new(0,0,0,0)


            local sliderBar = createUI("Frame", {
                 Name = "SliderBar",
                 Size = {1, -10, 0, 5}, -- Full width minus padding, fixed height
                 Position = {0.5, -0, 0.5, 0}, -- Centered vertically below label
                 AnchorPoint = {0.5, 0},
                 BackgroundColor3 = Library.Theme.SecondaryElementBackground or Color3.fromRGB(25, 25, 25),
                 BackgroundTransparency = (Library.Theme.SecondaryElementBackground or Color3.fromRGB(25,25,25)).A,
                 BorderSizePixel = 0,
                  LayoutOrder = 2, -- Below label frame
            }, frame)

            local sliderProgress = createUI("Frame", {
                 Name = "SliderProgress",
                 Size = {0, 0, 1, 0}, -- Width set dynamically
                 Position = {0, 0, 0, 0},
                 BackgroundColor3 = Library.Theme.SliderProgress or Color3.fromRGB(50, 138, 220),
                 BackgroundTransparency = (Library.Theme.SliderProgress or Color3.fromRGB(50, 138, 220)).A,
                 BorderSizePixel = 0,
            }, sliderBar)

             local sliderThumb = createUI("Frame", {
                  Name = "SliderThumb",
                  Size = {0, 10, 0, 10}, -- Fixed size
                  Position = {0, 0, 0.5, -5}, -- Position set dynamically
                  AnchorPoint = {0.5, 0.5},
                  BackgroundColor3 = Library.Theme.SliderProgress or Color3.fromRGB(50, 138, 220),
                   BackgroundTransparency = (Library.Theme.SliderProgress or Color3.fromRGB(50, 138, 220)).A,
                   BorderSizePixel = 1,
                   BorderColor3 = Library.Theme.SliderStroke or Color3.fromRGB(58, 163, 255),
             }, sliderBar)
              createUI("UICorner", { CornerRadius = UDim.new(1, 0) }, sliderThumb)


            local sliderMin = config.Range[1]
            local sliderMax = config.Range[2]
            local sliderIncrement = config.Increment
            local sliderSuffix = config.Suffix or ""

            local loadedSliderValue = loadFlag(config.Flag, math.clamp(config.CurrentValue, sliderMin, sliderMax))


            local Slider = {}
            Slider.Frame = frame
            Slider.CurrentValue = loadedSliderValue
            Slider.Label = label
            Slider.ValueLabel = valueLabel
            Slider.SliderBar = sliderBar
            Slider.SliderProgress = sliderProgress
            Slider.SliderThumb = sliderThumb

            local function updateSliderVisuals(value: number)
                 local clampedValue = math.clamp(value, sliderMin, sliderMax)
                 -- Round to the nearest increment
                 clampedValue = math.round(clampedValue / sliderIncrement) * sliderIncrement

                 Slider.CurrentValue = clampedValue
                 Slider.ValueLabel.Text = tostring(clampedValue) .. sliderSuffix

                 local percentage = (clampedValue - sliderMin) / (sliderMax - sliderMin)
                 local barWidth = sliderBar.AbsoluteSize.X
                 local thumbOffset = percentage * barWidth

                 Slider.SliderProgress.Size = UDim2.new(0, thumbOffset, 1, 0)
                 Slider.SliderThumb.Position = UDim2.new(0, thumbOffset, 0.5, -5) -- Position thumb based on offset
            end

            local function updateValueFromPosition(positionX: number)
                 local barWidth = sliderBar.AbsoluteSize.X
                 local percentage = math.clamp(positionX / barWidth, 0, 1)
                 local newValue = sliderMin + percentage * (sliderMax - sliderMin)
                 -- Apply increment and clamp
                 newValue = math.round(newValue / sliderIncrement) * sliderIncrement
                 newValue = math.clamp(newValue, sliderMin, sliderMax)

                 if Slider.CurrentValue ~= newValue then
                     Slider.CurrentValue = newValue
                     updateSliderVisuals(newValue)
                     saveFlag(config.Flag, newValue)
                     if config.Callback then
                         pcall(config.Callback, newValue)
                     end
                 end
            end

            local draggingSlider = false

            sliderBar.InputBegan:Connect(function(input, gameProcessedEvent)
                if gameProcessedEvent or (input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch) then return end
                draggingSlider = true
                local barPos = sliderBar.AbsolutePosition
                updateValueFromPosition(input.Position.X - barPos.X) -- Position relative to the bar start

                 input.Changed:Connect(function()
                     if input.UserInputState == Enum.UserInputState.End then
                         draggingSlider = false
                     end
                 end)
            end)

            UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
                 if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                      local barPos = sliderBar.AbsolutePosition
                      updateValueFromPosition(input.Position.X - barPos.X)
                 end
            end)

            -- Also allow clicking directly on the bar to jump
            sliderBar.MouseButton1Click:Connect(function(x, y) -- x, y are relative to the bar frame
                updateValueFromPosition(x)
            end)


            function Slider:Set(value: number)
                 if type(value) ~= "number" or Slider.CurrentValue == value then return end
                 updateSliderVisuals(value) -- This also updates .CurrentValue internally
                 saveFlag(config.Flag, value)
                 -- Rayfield docs imply callback is only on user interaction?
                 -- If you want callback on Set, uncomment the lines below:
                 -- if config.Callback then
                 --     pcall(config.Callback, Slider.CurrentValue)
                 -- end
            end

            if config.Flag then Library.Elements[config.Flag].Set = Slider.Set end
            table.insert(Tab.Elements, Slider)

            -- Apply initial state from loaded config
            updateSliderVisuals(Slider.CurrentValue)
             if config.Callback then
                -- Callback on initial load if flag exists
                if currentConfig[config.Flag] ~= nil then
                     pcall(config.Callback, Slider.CurrentValue)
                 end
             end

            return Slider
       end

        -- Adaptive Input (TextBox)
        function Tab:CreateInput(config: { Name: string, CurrentValue: string, PlaceholderText: string, RemoveTextAfterFocusLost: boolean, Flag: string, Callback: ((text: string) -> ()) })
            local frame = createElementFrame(tabContentFrame, "Input", config)
            frame.Size = UDim2.new(1, 0, 0, 40) -- Taller for input field

             local label = createElementLabel(frame, config.Name)
             label.Size = UDim2.new(0, 100, 1, 0) -- Fixed width label
             label.LayoutOrder = 1

             local inputField = createUI("TextBox", {
                 Name = "Input",
                 Size = {1, -100, 1, 0}, -- Fill remaining width
                 BackgroundTransparency = 1, -- Use element background from parent frame
                 TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                 PlaceholderColor3 = Library.Theme.PlaceholderColor or Color3.fromRGB(178, 178, 178),
                 PlaceholderText = config.PlaceholderText or "",
                 Text = "", -- Initial text from config/default
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansSemibold,
                 TextXAlignment = Enum.TextXAlignment.Left,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 2,
                 ClearTextOnFocus = false, -- Rayfield default is false
             }, frame)
             inputField.MinimumSize = UDim2.new(0,0,0,0) -- Allow scaling down


            local loadedInputValue = loadFlag(config.Flag, config.CurrentValue)
            inputField.Text = loadedInputValue

            local Input = {}
            Input.Frame = frame
            Input.CurrentValue = loadedInputValue
            Input.Label = label
            Input.InputField = inputField

            inputField.FocusLost:Connect(function(enterPressed, inputObject)
                 local finalValue = inputField.Text
                 Input.CurrentValue = finalValue
                 saveFlag(config.Flag, finalValue)
                 if config.Callback then
                      pcall(config.Callback, finalValue)
                 end
                 if config.RemoveTextAfterFocusLost and not enterPressed then
                      inputField.Text = "" -- Clear only if not enter pressed
                 end
             end)

             inputField.Changed:Connect(function(property)
                  if property == "Text" then
                     -- Optional: callback on every text change, but Rayfield docs imply on FocusLost
                     -- If you want live updates, uncomment and adjust logic.
                     -- if config.Callback then
                     --    pcall(config.Callback, inputField.Text)
                     -- end
                  end
             end)

            function Input:Set(text: string)
                if type(text) ~= "string" or Input.CurrentValue == text then return end
                 Input.InputField.Text = text
                 Input.CurrentValue = text
                 saveFlag(config.Flag, text)
                 -- Rayfield docs don't show callback on Set for Input
                 -- If you want callback on Set, uncomment the lines below:
                 -- if config.Callback then
                 --     pcall(config.Callback, Input.CurrentValue)
                 -- end
             end


             if config.Flag then Library.Elements[config.Flag].Set = Input.Set end
             table.insert(Tab.Elements, Input)

            -- Callback on initial load if flag exists
            if currentConfig[config.Flag] ~= nil then
                 if config.Callback then
                     pcall(config.Callback, Input.CurrentValue)
                 end
             end

            return Input
        end


         -- Dropdown Menu
        function Tab:CreateDropdown(config: { Name: string, Options: { string }, CurrentOption: { string }, MultipleOptions: boolean, Flag: string, Callback: ((options: { string }) -> ()) })
             local frame = createElementFrame(tabContentFrame, "Dropdown", config)
             frame.Size = UDim2.new(1, 0, 0, 30)

             local label = createElementLabel(frame, config.Name)
             label.Size = UDim2.new(0.5, 0, 1, 0) -- Half width for label
             label.LayoutOrder = 1

             local dropdownButton = createUI("TextButton", {
                 Name = "DropdownButton",
                 Size = {0.5, 0, 1, 0}, -- Half width for button
                 BackgroundTransparency = 1, -- Use parent background
                 TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansSemibold,
                 Text = "Select...", -- Initial text
                 TextXAlignment = Enum.TextXAlignment.Right,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 2,
             }, frame)
            dropdownButton.MinimumSize = UDim2.new(0,0,0,0)

             local dropdownFrame: Frame? = nil -- Placeholder for the options list frame

             local loadedOptionsValue = loadFlag(config.Flag, config.CurrentOption or {})
             if type(loadedOptionsValue) ~= "table" then -- Ensure it's a table
                 loadedOptionsValue = {}
             end
            -- Validate loaded options against available options
            local validLoadedOptions: {string} = {}
            for _, opt in ipairs(loadedOptionsValue) do
                 if table.find(config.Options, opt) then
                      table.insert(validLoadedOptions, opt)
                 end
            end
            if not config.MultipleOptions and #validLoadedOptions > 1 then
                 validLoadedOptions = {validLoadedOptions[1]} -- If single select, take only the first valid one
            end


             local Dropdown = {}
             Dropdown.Frame = frame
             Dropdown.CurrentOption = validLoadedOptions
             Dropdown.Label = label
             Dropdown.Button = dropdownButton
             Dropdown.Options = config.Options
             Dropdown.MultipleOptions = config.MultipleOptions
             Dropdown.OptionsFrame = nil -- Will be set when created

             local function updateButtonText()
                 if #Dropdown.CurrentOption == 0 then
                      Dropdown.Button.Text = "Select..."
                 elseif #Dropdown.CurrentOption == 1 then
                      Dropdown.Button.Text = Dropdown.CurrentOption[1]
                 else
                      Dropdown.Button.Text = tostring(#Dropdown.CurrentOption) .. " selected"
                 end
             end
             updateButtonText()

             local function createOptionsFrame()
                 if dropdownFrame and dropdownFrame.Parent then dropdownFrame:Destroy() end

                 dropdownFrame = createUI("Frame", {
                     Name = "DropdownOptions",
                      Size = {0, dropdownButton.AbsoluteSize.X, 0, 0}, -- Match button width
                     Position = UDim2.new(0, dropdownButton.AbsolutePosition.X, 0, dropdownButton.AbsolutePosition.Y + dropdownButton.AbsoluteSize.Y), -- Position below button
                     BackgroundColor3 = Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30),
                     BackgroundTransparency = (Library.Theme.DropdownUnselected or Color3.fromRGB(30,30,30)).A,
                     BorderSizePixel = 1,
                     BorderColor3 = Library.Theme.ElementStroke or Color3.fromRGB(50, 50, 50),
                     ZIndex = (Window.Frame.ZIndex or 0) + 1, -- Above the main window
                     ClipsDescendants = true,
                 }, Library.ScreenGui) -- Parent to ScreenGui so it appears above the window

                 local optionsLayout = createUI("UIListLayout", {
                     FillDirection = Enum.FillDirection.Vertical,
                     HorizontalAlignment = Enum.HorizontalAlignment.Left,
                     VerticalAlignment = Enum.VerticalAlignment.Top,
                     SortOrder = Enum.SortOrder.LayoutOrder,
                     Padding = UDim.new(0, 2),
                     Parent = dropdownFrame,
                 })

                 local totalHeight = 0
                 for i, optionText in ipairs(Dropdown.Options) do
                     local isSelected = table.find(Dropdown.CurrentOption, optionText) ~= nil

                     local optionButton = createUI("TextButton", {
                         Name = optionText:gsub(" ", "_") .. "Option",
                         Size = {1, 0, 0, 20}, -- Full width, fixed height
                         BackgroundColor3 = isSelected and (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)) or (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30)),
                          BackgroundTransparency = (isSelected and (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)) or (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30))).A,
                         BorderSizePixel = 0,
                         TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                         TextScaled = true,
                         TextWrapped = true,
                         Font = Enum.Font.SourceSansSemibold,
                         Text = optionText,
                         TextXAlignment = Enum.TextXAlignment.Left,
                         TextYAlignment = Enum.TextYAlignment.Center,
                         LayoutOrder = i,
                     }, dropdownFrame)
                     optionButton.MinimumSize = UDim2.new(0,0,0,0) -- Allow scaling down

                     totalHeight = totalHeight + 20 + optionsLayout.Padding.Offset -- Add button height + padding

                     optionButton.MouseButton1Click:Connect(function()
                         if Dropdown.MultipleOptions then
                             if isSelected then
                                 -- Deselect
                                 local index = table.find(Dropdown.CurrentOption, optionText)
                                 if index then table.remove(Dropdown.CurrentOption, index) end
                                 optionButton.BackgroundColor3 = Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30)
                                  optionButton.BackgroundTransparency = (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30)).A
                             else
                                 -- Select
                                 table.insert(Dropdown.CurrentOption, optionText)
                                 optionButton.BackgroundColor3 = Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)
                                  optionButton.BackgroundTransparency = (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)).A
                             end
                         else
                             -- Single select: deselect all others, select this one
                             Dropdown.CurrentOption = {optionText}
                             for _, btn in pairs(dropdownFrame:GetChildren()) do
                                  if btn:IsA("TextButton") then
                                       btn.BackgroundColor3 = Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30)
                                        btn.BackgroundTransparency = (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30)).A
                                  end
                             end
                             optionButton.BackgroundColor3 = Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)
                              optionButton.BackgroundTransparency = (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)).A
                             dropdownFrame:Destroy() -- Close the dropdown after single selection
                             Dropdown.OptionsFrame = nil
                         end

                         updateButtonText()
                         saveFlag(config.Flag, Dropdown.CurrentOption)
                         if config.Callback then
                              pcall(config.Callback, Dropdown.CurrentOption)
                         end
                     end)
                 end

                 dropdownFrame.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, math.min(totalHeight, 200)) -- Limit max height
                  Dropdown.OptionsFrame = dropdownFrame -- Store reference
             end

             dropdownButton.MouseButton1Click:Connect(function()
                  if dropdownFrame and dropdownFrame.Parent then
                      dropdownFrame:Destroy() -- Close if open
                       Dropdown.OptionsFrame = nil
                  else
                      createOptionsFrame() -- Open if closed
                  end
             end)

             -- Close dropdown if clicking anywhere else
             UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                 if dropdownFrame and dropdownFrame.Parent and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                     -- Check if click is outside the dropdown frame
                     local mousePos = input.Position
                     local frameAbsolutePos = dropdownFrame.AbsolutePosition
                     local frameAbsoluteSize = dropdownFrame.AbsoluteSize

                     if not (mousePos.X >= frameAbsolutePos.X and mousePos.X <= frameAbsolutePos.X + frameAbsoluteSize.X and
                             mousePos.Y >= frameAbsolutePos.Y and mousePos.Y <= frameAbsolutePos.Y + frameAbsoluteSize.Y) then
                          dropdownFrame:Destroy()
                           Dropdown.OptionsFrame = nil
                     end
                 end
             end)


            function Dropdown:Set(options: { string })
                 if type(options) ~= "table" then warn("AstraHub: Dropdown:Set requires a table of strings."); return end
                 -- Validate and update selected options
                 local newSelected: {string} = {}
                 for _, opt in ipairs(options) do
                      if table.find(Dropdown.Options, opt) then
                           if Dropdown.MultipleOptions or #newSelected == 0 then -- Add if multi-select or single-select and first valid
                                table.insert(newSelected, opt)
                           else
                                warn("AstraHub: Attempted to set multiple options on single-select dropdown via Set(). Using only the first valid option.")
                                break -- Stop if single select
                           end
                      else
                           warn("AstraHub: Attempted to set invalid option '" .. tostring(opt) .. "' on dropdown.")
                      end
                 end
                  -- If single select and no options provided, set to empty
                 if not Dropdown.MultipleOptions and #newSelected == 0 then
                      Dropdown.CurrentOption = {}
                 else
                     Dropdown.CurrentOption = newSelected
                 end


                 updateButtonText()
                 saveFlag(config.Flag, Dropdown.CurrentOption)
                 -- Rayfield docs don't show callback on Set for Dropdown
                 -- If you want callback on Set, uncomment the lines below:
                 -- if config.Callback then
                 --      pcall(config.Callback, Dropdown.CurrentOption)
                 -- end

                 -- If options frame is open, update its selection display
                 if dropdownFrame and dropdownFrame.Parent then
                     for _, btn in pairs(dropdownFrame:GetChildren()) do
                          if btn:IsA("TextButton") then
                                local isSelected = table.find(Dropdown.CurrentOption, btn.Text) ~= nil
                                btn.BackgroundColor3 = isSelected and (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)) or (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30))
                                btn.BackgroundTransparency = (isSelected and (Library.Theme.DropdownSelected or Color3.fromRGB(40, 40, 40)) or (Library.Theme.DropdownUnselected or Color3.fromRGB(30, 30, 30))).A
                          end
                     end
                 end
            end

            function Dropdown:Refresh(options: { string })
                 if type(options) ~= "table" then warn("AstraHub: Dropdown:Refresh requires a table of strings."); return end
                 Dropdown.Options = options
                 -- Clear current selection if options are no longer valid
                 local newCurrentOptions: {string} = {}
                 for _, opt in ipairs(Dropdown.CurrentOption) do
                      if table.find(Dropdown.Options, opt) then
                          table.insert(newCurrentOptions, opt)
                      end
                 end
                 Dropdown.CurrentOption = newCurrentOptions
                 updateButtonText()
                 saveFlag(config.Flag, Dropdown.CurrentOption) -- Save updated selection
                 -- If options frame is open, close and recreate it on next click
                 if dropdownFrame and dropdownFrame.Parent then
                      dropdownFrame:Destroy()
                      Dropdown.OptionsFrame = nil
                 end
                 -- Rayfield docs don't show callback on Refresh
             end


            if config.Flag then
                 Library.Elements[config.Flag].Set = Dropdown.Set
                 Library.Elements[config.Flag].Refresh = Dropdown.Refresh
            end
             table.insert(Tab.Elements, Dropdown)

             -- Callback on initial load if flag exists
            if currentConfig[config.Flag] ~= nil then
                 if config.Callback then
                     pcall(config.Callback, Dropdown.CurrentOption)
                 end
             end


             return Dropdown
        end

        -- Keybind
       function Tab:CreateKeybind(config: { Name: string, CurrentKeybind: string, HoldToInteract: boolean, Flag: string, Callback: ((isHolding: boolean) -> ()) })
            local frame = createElementFrame(tabContentFrame, "Keybind", config)
            frame.Size = UDim2.new(1, 0, 0, 30)

             local label = createElementLabel(frame, config.Name)
             label.Size = UDim2.new(0.5, 0, 1, 0) -- Half width for label
             label.LayoutOrder = 1

             local keybindButton = createUI("TextButton", {
                 Name = "KeybindButton",
                 Size = {0.5, 0, 1, 0}, -- Half width for button
                 BackgroundTransparency = 1, -- Use parent background
                 TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansSemibold,
                 Text = "None", -- Set later
                 TextXAlignment = Enum.TextXAlignment.Right,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 2,
             }, frame)
            keybindButton.MinimumSize = UDim2.new(0,0,0,0)


            local loadedKeybind = loadFlag(config.Flag, config.CurrentKeybind or "None")
             if type(loadedKeybind) ~= "string" then loadedKeybind = "None" end -- Ensure string

            local Keybind = {}
            Keybind.Frame = frame
            Keybind.CurrentKeybind = loadedKeybind
            Keybind.Label = label
            Keybind.Button = keybindButton
            Keybind.IsListening = false -- State for when button is clicked and waiting for input
            Keybind.HoldToInteract = config.HoldToInteract or false
            Keybind.IsHolding = false -- State for HoldToInteract

            local function updateButtonText()
                 Keybind.Button.Text = Keybind.CurrentKeybind == "None" or Keybind.CurrentKeybind == "" or Keybind.CurrentKeybind == "Unknown"
                     and "None"
                     or Keybind.CurrentKeybind
            end
            updateButtonText()

            local function setKeybind(keyName: string)
                Keybind.CurrentKeybind = keyName
                updateButtonText()
                saveFlag(config.Flag, keyName)
            end

            local function startListening()
                 Keybind.IsListening = true
                 Keybind.Button.Text = "Press a key..."
                 -- Optional: Change button color while listening
            end

            local function stopListening(success: boolean, keyName: string?)
                 Keybind.IsListening = false
                 -- Optional: Restore button color
                 if success and keyName then
                     setKeybind(keyName)
                 else
                     updateButtonText() -- Restore previous text
                 end
            end

            keybindButton.MouseButton1Click:Connect(function()
                 if not Keybind.IsListening then
                     startListening()
                 else
                     stopListening(false, nil) -- Cancel listening
                 end
            end)

            -- Key press handling
            local connections = {} -- Store connections to disconnect when not listening

            local function connectListeners()
                if #connections > 0 then return end -- Already connected

                table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                     if gameProcessedEvent then return end

                     if Keybind.IsListening and input.UserInputType == Enum.UserInputType.Keyboard then
                         local keyName = input.KeyCode.Name
                         stopListening(true, keyName)
                     elseif Keybind.HoldToInteract and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == Keybind.CurrentKeybind then
                         Keybind.IsHolding = true
                         if config.Callback then
                             pcall(config.Callback, true)
                         end
                     end
                end))

                table.insert(connections, UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
                     if gameProcessedEvent then return end

                     if Keybind.HoldToInteract and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == Keybind.CurrentKeybind then
                          Keybind.IsHolding = false
                         if config.Callback then
                             pcall(config.Callback, false)
                         end
                     end
                end))

                -- Optional: Handle MouseButtons if needed (Rayfield example uses keyboard)
                -- table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessedEvent) ... MouseButton1, MouseButton2 ... end))
            end

            local function disconnectListeners()
                 for _, conn in pairs(connections) do
                     conn:Disconnect()
                 end
                 connections = {}
            end

            -- Connect listeners initially to handle key presses outside listening state for HoldToInteract
            connectListeners()

            -- Check key state on load for HoldToInteract
            if Keybind.HoldToInteract and Keybind.CurrentKeybind ~= "None" and Keybind.CurrentKeybind ~= "" then
                if UserInputService:IsKeyDown(Enum.KeyCode[Keybind.CurrentKeybind]) then
                    Keybind.IsHolding = true
                     if config.Callback then
                         pcall(config.Callback, true)
                     end
                end
            end

             -- For non-HoldToInteract, trigger callback on key press down if it matches
            if not Keybind.HoldToInteract and Keybind.CurrentKeybind ~= "None" and Keybind.CurrentKeybind ~= "" then
                UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
                    if gameProcessedEvent or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if input.KeyCode.Name == Keybind.CurrentKeybind then
                         if config.Callback then
                              -- Note: Callback for non-hold is triggered on press DOWN
                             pcall(config.Callback, true) -- Pass 'true' like HoldToInteract does on press
                         end
                    end
                end)
                 -- No InputEnded listener needed for non-HoldToInteract
            end


            function Keybind:Set(keyName: string)
                 if type(keyName) ~= "string" then warn("AstraHub: Keybind:Set requires a string."); return end
                Keybind.IsListening = false -- Cancel listening mode if active
                setKeybind(keyName)
                -- Rayfield docs don't show callback on Set for Keybind
            end

            if config.Flag then Library.Elements[config.Flag].Set = Keybind.Set end
            table.insert(Tab.Elements, Keybind)

             -- Callback on initial load if flag exists and HoldToInteract was already true
             -- (Handled by the initial Keybind.IsHolding check)

            return Keybind
       end

         -- Label
       function Tab:CreateLabel(title: string, icon: number? | string?, color: Color3?, ignoreTheme: boolean?)
            local frame = createElementFrame(tabContentFrame, "Label", {}) -- Label doesn't use config saving/flags
            frame.Size = UDim2.new(1, 0, 0, 30) -- Fixed size

             local iconLabel = createUI("ImageLabel", {
                 Name = "Icon",
                 Size = {0, 20, 0, 20},
                 BackgroundTransparency = 1,
                 Image = "", -- Set later
                 ScaleType = Enum.ScaleType.Fit,
                 LayoutOrder = 1,
                 Visible = false, -- Hidden by default
             }, frame)

             local titleLabel = createUI("TextLabel", {
                 Name = "Title",
                 Size = {1, -25, 1, 0}, -- Fill space minus potential icon
                 BackgroundTransparency = 1,
                 TextColor3 = ignoreTheme and (color or Color3.fromRGB(255, 255, 255)) or (Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)),
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansSemibold,
                 Text = title,
                 TextXAlignment = Enum.TextXAlignment.Left,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 2,
             }, frame)
              titleLabel.MinimumSize = UDim2.new(0,0,0,0)

            -- Handle Icon
            if type(icon) == "number" and icon ~= 0 then
                 iconLabel.Image = "rbxassetid://" .. icon
                 iconLabel.Visible = true
                 titleLabel.Size = UDim2.new(1, -25, 1, 0) -- Make space for icon
            elseif type(icon) == "string" then
                 warn("AstraHub: Lucide icon requested for label ('" .. icon .. "'). Lucide icons are not supported in this loadstring version.")
                 -- iconLabel.Visible = false
                 titleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
            else
                 iconLabel.Visible = false
                 titleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
            end

             local Label = {}
             Label.Frame = frame
             Label.TitleLabel = titleLabel
             Label.IconLabel = iconLabel
             Label.CurrentTitle = title
             Label.CurrentIcon = icon
             Label.CurrentColor = color
             Label.IgnoreTheme = ignoreTheme

             function Label:Set(newTitle: string, newIcon: number? | string?, newColor: Color3?, newIgnoreTheme: boolean?)
                 Label.CurrentTitle = newTitle
                 Label.CurrentIcon = newIcon
                 Label.CurrentColor = newColor
                 Label.IgnoreTheme = newIgnoreTheme or false

                 Label.TitleLabel.Text = newTitle
                 Label.TitleLabel.TextColor3 = Label.IgnoreTheme and (Label.CurrentColor or Color3.fromRGB(255, 255, 255)) or (Library.Theme.TextColor or Color3.fromRGB(240, 240, 240))

                  -- Update Icon
                 if type(newIcon) == "number" and newIcon ~= 0 then
                      Label.IconLabel.Image = "rbxassetid://" .. newIcon
                      Label.IconLabel.Visible = true
                      Label.TitleLabel.Size = UDim2.new(1, -25, 1, 0) -- Make space for icon
                 elseif type(newIcon) == "string" then
                      warn("AstraHub: Lucide icon requested for label ('" .. newIcon .. "'). Lucide icons are not supported in this loadstring version.")
                      -- Label.IconLabel.Visible = false
                       Label.TitleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
                 else
                      Label.IconLabel.Visible = false
                      Label.TitleLabel.Size = UDim2.new(1, 0, 1, 0) -- No space for icon
                 end
             end

             table.insert(Tab.Elements, Label)
             return Label
        end

         -- Paragraph
        function Tab:CreateParagraph(config: { Title: string, Content: string })
            local frame = createElementFrame(tabContentFrame, "Paragraph", {}) -- Paragraph doesn't use config saving/flags
             frame.Size = UDim2.new(1, 0, 0, 0) -- Auto size height

             local layout = frame:FindFirstChildOfClass("UIListLayout") as UIListLayout
             if layout then layout.FillDirection = Enum.FillDirection.Vertical end -- Vertical layout for title and content

             local titleLabel = createUI("TextLabel", {
                 Name = "Title",
                 Size = {1, 0, 0, 20}, -- Fixed height title
                 BackgroundTransparency = 1,
                 TextColor3 = Library.Theme.TextColor or Color3.fromRGB(240, 240, 240),
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansBold,
                 Text = config.Title,
                 TextXAlignment = Enum.TextXAlignment.Left,
                 TextYAlignment = Enum.TextYAlignment.Center,
                 LayoutOrder = 1,
             }, frame)
              titleLabel.MinimumSize = UDim2.new(0,0,0,0)

             local contentLabel = createUI("TextLabel", {
                 Name = "Content",
                 Size = {1, 0, 0, 0}, -- Auto size height based on content
                 BackgroundTransparency = 1,
                 TextColor3 = (Library.Theme.TextColor or Color3.fromRGB(240, 240, 240)):Lerp(Color3.fromRGB(0,0,0), 0.3), -- Slightly dimmer text for content
                 TextScaled = true,
                 TextWrapped = true,
                 Font = Enum.Font.SourceSansRegular,
                 Text = config.Content,
                 TextXAlignment = Enum.TextXAlignment.Left,
                 TextYAlignment = Enum.TextYAlignment.Top,
                 LayoutOrder = 2,
             }, frame)
              contentLabel.MinimumSize = UDim2.new(0,0,0,0)
             contentLabel.AutomaticSize = Enum.AutomaticSize.Y -- Allow height to adjust to text

             local Paragraph = {}
             Paragraph.Frame = frame
             Paragraph.TitleLabel = titleLabel
             Paragraph.ContentLabel = contentLabel
             Paragraph.CurrentConfig = config

             function Paragraph:Set(newConfig: { Title: string, Content: string })
                 Paragraph.CurrentConfig = newConfig
                 Paragraph.TitleLabel.Text = newConfig.Title
                 Paragraph.ContentLabel.Text = newConfig.Content
             end

             table.insert(Tab.Elements, Paragraph)
             return Paragraph
        end


      Window.Tabs[#Window.Tabs + 1] = Tab

      -- Initial tab selection (select the first one created)
      if Window.CurrentTab == nil then
         Window.CurrentTab = Tab
         Tab.Frame.Visible = true
         Tab.Button.BackgroundColor3 = Library.Theme.TabBackgroundSelected or Color3.fromRGB(210, 210, 210)
         Tab.Button.BackgroundTransparency = (Library.Theme.TabBackgroundSelected or Color3.fromRGB(210, 210, 210)).A
         Tab.Button.TextColor3 = Library.Theme.SelectedTabTextColor or Color3.fromRGB(50, 50, 50)
      end

      -- Tab button click logic
      tabButton.MouseButton1Click:Connect(function()
         if Window.CurrentTab then
            Window.CurrentTab.Frame.Visible = false
            Window.CurrentTab.Button.BackgroundColor3 = Library.Theme.TabBackground or Color3.fromRGB(80, 80, 80)
             Window.CurrentTab.Button.BackgroundTransparency = (Library.Theme.TabBackground or Color3.fromRGB(80,80,80)).A
            Window.CurrentTab.Button.TextColor3 = Library.Theme.TabTextColor or Color3.fromRGB(240, 240, 240)
         end
         Window.CurrentTab = Tab
         Tab.Frame.Visible = true
         Tab.Button.BackgroundColor3 = Library.Theme.TabBackgroundSelected or Color3.fromRGB(210, 210, 210)
          Tab.Button.BackgroundTransparency = (Library.Theme.TabBackgroundSelected or Color3.fromRGB(210, 210, 210)).A
         Tab.Button.TextColor3 = Library.Theme.SelectedTabTextColor or Color3.fromRGB(50, 50, 50)
      end)


       table.insert(Window.Tabs, Tab) -- Add to the list of tabs

      return Tab
   end

   Library.Window = Window -- Store reference to the created window
   return Window
end

function Library:Destroy()
   if Library.ScreenGui and Library.ScreenGui.Parent then
      Library.ScreenGui:Destroy()
      Library.ScreenGui = nil
      Library.Window = nil
      Library.Tabs = {}
      Library.CurrentTab = nil
      Library.Flags = {} -- Clear flags? Maybe keep them if config save is enabled?
      Library.Elements = {}
       -- Clean up notifications if any
       if notificationFrame and notificationFrame.Parent then
           notificationFrame:Destroy()
           notificationFrame = nil
           notificationVisible = false
           notificationQueue = {}
       end
   end
end

-- --- Initial Loading and Setup ---

-- This part runs immediately when the loadstring script is executed.
-- The loading screen is shown right away.
-- The CreateWindow call (made by the user script *after* getting the library object)
-- will hide the loading screen and build the main UI.

-- Ensure the script returns the Library object
return Library
