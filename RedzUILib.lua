--[[
    Redz UI Library v1.0
    Professional Roblox UI Library inspired by Redz Hub
    Compatible with most executors (Synapse, Fluxus, KRNL, etc.)
    
    Usage:
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/username/repo/main/RedzUILib.lua"))()
]]--

local RedzUILib = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Color Palette
local Colors = {
    Background = Color3.fromHex("#1A1A1A"),
    Accent = Color3.fromHex("#E74C3C"),
    Text = Color3.fromHex("#FFFFFF"),
    Secondary = Color3.fromHex("#2A2A2A"),
    Hover = Color3.fromHex("#3A3A3A"),
    Success = Color3.fromHex("#27AE60"),
    Warning = Color3.fromHex("#F39C12")
}

-- Animation Settings
local AnimationSpeed = 0.3
local EasingStyle = Enum.EasingStyle.Quad
local EasingDirection = Enum.EasingDirection.Out

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    duration = duration or AnimationSpeed
    easingStyle = easingStyle or EasingStyle
    easingDirection = easingDirection or EasingDirection
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, 3, 0, 3)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    CreateCorner(shadow, 8)
    return shadow
end

local function CreateBlur(parent)
    local blur = Instance.new("Frame")
    blur.Name = "BlurBackground"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.Position = UDim2.new(0, 0, 0, 0)
    blur.BackgroundColor3 = Color3.new(0, 0, 0)
    blur.BackgroundTransparency = 0.5
    blur.ZIndex = parent.ZIndex - 1
    blur.Parent = parent
    return blur
end

-- Notification System
local NotificationContainer
local function CreateNotificationContainer()
    if NotificationContainer then return end
    
    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "RedzNotifications"
    NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
    NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = PlayerGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = NotificationContainer
end

local function ShowNotification(title, message, duration, notificationType)
    CreateNotificationContainer()
    
    duration = duration or 3
    notificationType = notificationType or "info"
    
    -- Mobile-friendly notification sizing
    local isMobile = UserInputService.TouchEnabled
    local notificationHeight = isMobile and 90 or 80
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(1, 0, 0, notificationHeight)
    notification.BackgroundColor3 = Colors.Secondary
    notification.Position = UDim2.new(1, 0, 0, 0)
    notification.Parent = NotificationContainer
    CreateCorner(notification, isMobile and 12 or 8)
    CreateShadow(notification)
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = notificationType == "success" and Colors.Success or 
                                  notificationType == "warning" and Colors.Warning or Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notification
    CreateCorner(accentBar, 2)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 35)
    messageLabel.Position = UDim2.new(0, 15, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Colors.Text
    messageLabel.TextSize = 14
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Animations
    local slideIn = CreateTween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
    slideIn:Play()
    
    -- Auto-hide
    wait(duration)
    local slideOut = CreateTween(notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
    slideOut:Play()
    slideOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Mobile-Friendly Toggle Box (Persistent On-Screen Button)
local ToggleBox = {}
ToggleBox.__index = ToggleBox

function ToggleBox.new(imageUrl, position, isMobile)
    local self = setmetatable({}, ToggleBox)
    
    -- Auto-detect mobile or use parameter
    isMobile = isMobile or UserInputService.TouchEnabled
    
    -- Mobile-optimized positioning and sizing
    if isMobile then
        position = position or UDim2.new(1, -80, 0, 80) -- Top-right, mobile friendly
        self.ButtonSize = UDim2.new(0, 60, 0, 60) -- Larger for touch
    else
        position = position or UDim2.new(0, 20, 0, 20) -- Top-left for PC
        self.ButtonSize = UDim2.new(0, 50, 0, 50)
    end
    
    imageUrl = imageUrl or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    self.IsMobile = isMobile
    
    -- Main frame
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "RedzToggleBox"
    self.Frame.Size = self.ButtonSize
    self.Frame.Position = position
    self.Frame.BackgroundColor3 = Colors.Secondary
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = PlayerGui
    self.Frame.ZIndex = 999 -- Always on top
    CreateCorner(self.Frame, isMobile and 15 or 10)
    CreateShadow(self.Frame)
    
    -- Image button
    self.ImageButton = Instance.new("ImageButton")
    self.ImageButton.Size = UDim2.new(0.7, 0, 0.7, 0)
    self.ImageButton.Position = UDim2.new(0.15, 0, 0.15, 0)
    self.ImageButton.BackgroundTransparency = 1
    self.ImageButton.Image = imageUrl
    self.ImageButton.ImageColor3 = Colors.Text
    self.ImageButton.ZIndex = 1000
    self.ImageButton.Parent = self.Frame
    
    -- Mobile-friendly touch feedback
    if isMobile then
        self.ImageButton.TouchTap:Connect(function()
            self:HandleActivation()
        end)
    end
    
    -- Standard click support
    self.ImageButton.MouseButton1Click:Connect(function()
        self:HandleActivation()
    end)
    
    -- Callbacks
    self.Callbacks = {}
    
    -- Touch/hover feedback
    local function ShowFeedback()
        CreateTween(self.Frame, {
            BackgroundColor3 = Colors.Accent,
            Size = UDim2.new(self.ButtonSize.X.Scale, self.ButtonSize.X.Offset + 5, 
                            self.ButtonSize.Y.Scale, self.ButtonSize.Y.Offset + 5)
        }, 0.2):Play()
        CreateTween(self.ImageButton, {ImageColor3 = Colors.Text}, 0.2):Play()
    end
    
    local function HideFeedback()
        CreateTween(self.Frame, {
            BackgroundColor3 = Colors.Secondary,
            Size = self.ButtonSize
        }, 0.2):Play()
        CreateTween(self.ImageButton, {ImageColor3 = Colors.Text}, 0.2):Play()
    end
    
    -- Touch/mouse events for feedback
    if isMobile then
        self.ImageButton.TouchTapInWorld:Connect(ShowFeedback)
        self.ImageButton.TouchEnded:Connect(HideFeedback)
    else
        self.ImageButton.MouseEnter:Connect(ShowFeedback)
        self.ImageButton.MouseLeave:Connect(HideFeedback)
    end
    
    -- Make draggable (with mobile support)
    self:MakeDraggable()
    
    return self
end

function ToggleBox:HandleActivation()
    -- Visual feedback for tap/click
    local originalSize = self.ButtonSize
    CreateTween(self.Frame, {
        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, 
                        originalSize.Y.Scale, originalSize.Y.Offset - 4)
    }, 0.1):Play()
    
    wait(0.1)
    CreateTween(self.Frame, {Size = originalSize}, 0.1):Play()
    
    -- Execute callbacks
    for _, callback in pairs(self.Callbacks) do
        callback()
    end
end

function ToggleBox:MakeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragThreshold = 10 -- Minimum movement to start drag
    local hasMoved = false
    
    -- Handle input start (mouse or touch)
    self.ImageButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = self.Frame.Position
        end
    end)
    
    -- Handle movement (mouse or touch)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            
            -- Check if movement exceeds threshold
            if not hasMoved and (math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold) then
                hasMoved = true
            end
            
            -- Only move if threshold exceeded
            if hasMoved then
                self.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
    
    -- Handle input end (mouse or touch)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not hasMoved then
                -- This was a tap/click, not a drag - allow normal button function
                -- The HandleActivation will be called by the click event
            end
            dragging = false
            hasMoved = false
        end
    end)
end

function ToggleBox:OnClick(callback)
    table.insert(self.Callbacks, callback)
end

function ToggleBox:SetImage(imageUrl)
    self.ImageButton.Image = imageUrl
end

function ToggleBox:SetVisible(visible)
    self.Frame.Visible = visible
end

-- Main Library (Mobile-Friendly)
function RedzUILib:CreateWindow(title, size, toggleBoxImage, isMobile)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- Auto-detect mobile or use parameter
    isMobile = isMobile or UserInputService.TouchEnabled
    Window.IsMobile = isMobile
    
    -- Mobile-optimized sizing
    if isMobile then
        size = size or UDim2.new(0.95, 0, 0.8, 0) -- Use scale for mobile responsiveness
    else
        size = size or UDim2.new(0, 600, 0, 400)
    end
    
    -- Create main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RedzUI_" .. title
    ScreenGui.Parent = PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = isMobile -- Better mobile experience
    
    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    
    -- Mobile-friendly positioning
    if isMobile then
        MainFrame.Position = UDim2.new(0.025, 0, 0.1, 0) -- Offset positioning for mobile
    else
        MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    end
    
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame, isMobile and 15 or 10)
    CreateShadow(MainFrame)
    CreateBlur(MainFrame)
    
    -- Title bar (mobile-friendly height)
    local titleBarHeight = isMobile and 50 or 40
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Colors.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    CreateCorner(TitleBar, isMobile and 15 or 10)
    
    -- Title label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0) -- More space for mobile close button
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextSize = isMobile and 20 or 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close button (larger for mobile touch)
    local closeButtonSize = isMobile and 40 or 30
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, closeButtonSize, 0, closeButtonSize)
    CloseButton.Position = UDim2.new(1, -closeButtonSize - 5, 0, 5)
    CloseButton.BackgroundColor3 = Colors.Accent
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Colors.Text
    CloseButton.TextSize = isMobile and 22 or 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    CreateCorner(CloseButton, isMobile and 10 or 6)
    
    -- Tab container (mobile-responsive)
    local tabContainerWidth = isMobile and 0 or 150 -- Full width on mobile
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    
    if isMobile then
        -- Mobile: Horizontal tab bar at top
        TabContainer.Size = UDim2.new(1, 0, 0, 50)
        TabContainer.Position = UDim2.new(0, 0, 0, titleBarHeight)
    else
        -- Desktop: Vertical sidebar
        TabContainer.Size = UDim2.new(0, 150, 1, -titleBarHeight)
        TabContainer.Position = UDim2.new(0, 0, 0, titleBarHeight)
    end
    
    TabContainer.BackgroundColor3 = Colors.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, isMobile and 2 or 5)
    
    if isMobile then
        TabLayout.FillDirection = Enum.FillDirection.Horizontal -- Horizontal tabs for mobile
    else
        TabLayout.FillDirection = Enum.FillDirection.Vertical -- Vertical tabs for desktop
    end
    
    TabLayout.Parent = TabContainer
    
    -- Content container (mobile-responsive)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    
    if isMobile then
        -- Mobile: Content below tabs
        local tabsHeight = 50
        ContentContainer.Size = UDim2.new(1, -20, 1, -titleBarHeight - tabsHeight - 20)
        ContentContainer.Position = UDim2.new(0, 10, 0, titleBarHeight + tabsHeight + 10)
    else
        -- Desktop: Content beside tabs
        ContentContainer.Size = UDim2.new(1, -150, 1, -titleBarHeight)
        ContentContainer.Position = UDim2.new(0, 150, 0, titleBarHeight)
    end
    
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Create Toggle Box (with mobile support)
    if toggleBoxImage then
        Window.ToggleBox = ToggleBox.new(toggleBoxImage, nil, isMobile)
        Window.ToggleBox:OnClick(function()
            Window:Toggle()
        end)
    end
    
    -- Window functions
    function Window:Show()
        MainFrame.Visible = true
        CreateTween(MainFrame, {Size = size}, 0.5, Enum.EasingStyle.Back):Play()
    end
    
    function Window:Hide()
        local hideTween = CreateTween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        hideTween:Play()
        hideTween.Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
    
    function Window:Toggle()
        if MainFrame.Visible then
            self:Hide()
        else
            self:Show()
        end
    end
    
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Components = {}
        
        -- Tab button (mobile-responsive)
        local TabButton = Instance.new("TextButton")
        
        if isMobile then
            -- Mobile: Equal width horizontal tabs
            local tabCount = #Window.Tabs + 1
            TabButton.Size = UDim2.new(1/3, -4, 1, -10) -- Assume max 3 tabs for mobile
            TabButton.Position = UDim2.new(0, 2, 0, 5)
        else
            -- Desktop: Full width vertical tabs
            TabButton.Size = UDim2.new(1, -10, 0, 35)
            TabButton.Position = UDim2.new(0, 5, 0, 0)
        end
        
        TabButton.BackgroundColor3 = Colors.Background
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = Colors.Text
        TabButton.TextSize = isMobile and 12 or 14 -- Smaller text for mobile tabs
        TabButton.Font = Enum.Font.Gotham
        TabButton.LayoutOrder = #Window.Tabs + 1
        TabButton.Parent = TabContainer
        CreateCorner(TabButton, isMobile and 8 or 6)
        
        -- Tab content (mobile-responsive)
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = isMobile and 10 or 6 -- Thicker scrollbar for mobile
        TabContent.ScrollBarImageColor3 = Colors.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, isMobile and 15 or 10) -- More padding for mobile
        ContentLayout.Parent = TabContent
        
        -- Tab selection
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                CreateTween(tab.Button, {BackgroundColor3 = Colors.Background}):Play()
            end
            
            TabContent.Visible = true
            CreateTween(TabButton, {BackgroundColor3 = Colors.Hover}):Play()
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Layout = ContentLayout
        
        -- Component creation functions (mobile-friendly)
        function Tab:CreateToggle(name, default, callback)
            local toggleHeight = isMobile and 50 or 40
            local toggle = Instance.new("Frame")
            toggle.Size = UDim2.new(1, 0, 0, toggleHeight)
            toggle.BackgroundColor3 = Colors.Secondary
            toggle.BorderSizePixel = 0
            toggle.LayoutOrder = #self.Components + 1
            toggle.Parent = TabContent
            CreateCorner(toggle, isMobile and 10 or 6)
            
            local labelMargin = isMobile and 80 or 60
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -labelMargin, 1, 0)
            label.Position = UDim2.new(0, 15, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Colors.Text
            label.TextSize = isMobile and 16 or 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggle
            
            -- Mobile-friendly toggle button
            local toggleSize = isMobile and {width = 50, height = 25} or {width = 40, height = 20}
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, toggleSize.width, 0, toggleSize.height)
            toggleButton.Position = UDim2.new(1, -toggleSize.width - 15, 0.5, -toggleSize.height/2)
            toggleButton.BackgroundColor3 = default and Colors.Accent or Colors.Hover
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggle
            CreateCorner(toggleButton, isMobile and 12 or 10)
            
            local indicatorSize = isMobile and 21 or 16
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, indicatorSize, 0, indicatorSize)
            toggleIndicator.Position = default and UDim2.new(1, -indicatorSize - 2, 0.5, -indicatorSize/2) or UDim2.new(0, 2, 0.5, -indicatorSize/2)
            toggleIndicator.BackgroundColor3 = Colors.Text
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleButton
            CreateCorner(toggleIndicator, indicatorSize/2)
            
            local state = default
            
            toggleButton.MouseButton1Click:Connect(function()
                state = not state
                
                local buttonColor = state and Colors.Accent or Colors.Hover
                local indicatorPos = state and UDim2.new(1, -indicatorSize - 2, 0.5, -indicatorSize/2) or UDim2.new(0, 2, 0.5, -indicatorSize/2)
                
                CreateTween(toggleButton, {BackgroundColor3 = buttonColor}):Play()
                CreateTween(toggleIndicator, {Position = indicatorPos}):Play()
                
                if callback then
                    callback(state)
                end
            end)
            
            table.insert(self.Components, toggle)
            return toggle
        end
        
        function Tab:CreateButton(name, callback)
            local buttonHeight = isMobile and 45 or 35
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 0, buttonHeight)
            button.BackgroundColor3 = Colors.Accent
            button.BorderSizePixel = 0
            button.Text = name
            button.TextColor3 = Colors.Text
            button.TextSize = isMobile and 16 or 14
            button.Font = Enum.Font.GothamBold
            button.LayoutOrder = #self.Components + 1
            button.Parent = TabContent
            CreateCorner(button, isMobile and 10 or 6)
            
            button.MouseButton1Click:Connect(function()
                CreateTween(button, {BackgroundColor3 = Colors.Text}, 0.1):Play()
                wait(0.1)
                CreateTween(button, {BackgroundColor3 = Colors.Accent}, 0.1):Play()
                
                if callback then
                    callback()
                end
            end)
            
            button.MouseEnter:Connect(function()
                CreateTween(button, {BackgroundColor3 = Color3.fromHex("#C0392B")}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                CreateTween(button, {BackgroundColor3 = Colors.Accent}):Play()
            end)
            
            table.insert(self.Components, button)
            return button
        end
        
        function Tab:CreateSlider(name, min, max, default, callback)
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, 0, 0, 60)
            sliderFrame.BackgroundColor3 = Colors.Secondary
            sliderFrame.BorderSizePixel = 0
            sliderFrame.LayoutOrder = #self.Components + 1
            sliderFrame.Parent = TabContent
            CreateCorner(sliderFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 25)
            label.Position = UDim2.new(0, 15, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = name .. ": " .. default
            label.TextColor3 = Colors.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Size = UDim2.new(1, -30, 0, 6)
            sliderTrack.Position = UDim2.new(0, 15, 0, 35)
            sliderTrack.BackgroundColor3 = Colors.Background
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            CreateCorner(sliderTrack, 3)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BackgroundColor3 = Colors.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            CreateCorner(sliderFill, 3)
            
            local sliderButton = Instance.new("TextButton")
            sliderButton.Size = UDim2.new(0, 16, 0, 16)
            sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
            sliderButton.BackgroundColor3 = Colors.Text
            sliderButton.BorderSizePixel = 0
            sliderButton.Text = ""
            sliderButton.Parent = sliderTrack
            CreateCorner(sliderButton, 8)
            
            local dragging = false
            local value = default
            
            sliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position.X
                    local trackPos = sliderTrack.AbsolutePosition.X
                    local trackSize = sliderTrack.AbsoluteSize.X
                    local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                    
                    value = min + (max - min) * percent
                    label.Text = name .. ": " .. math.floor(value)
                    
                    CreateTween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    CreateTween(sliderButton, {Position = UDim2.new(percent, -8, 0.5, -8)}):Play()
                    
                    if callback then
                        callback(value)
                    end
                end
            end)
            
            table.insert(self.Components, sliderFrame)
            return sliderFrame
        end
        
        function Tab:CreateTextBox(name, placeholder, callback)
            local textboxFrame = Instance.new("Frame")
            textboxFrame.Size = UDim2.new(1, 0, 0, 60)
            textboxFrame.BackgroundColor3 = Colors.Secondary
            textboxFrame.BorderSizePixel = 0
            textboxFrame.LayoutOrder = #self.Components + 1
            textboxFrame.Parent = TabContent
            CreateCorner(textboxFrame, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 25)
            label.Position = UDim2.new(0, 15, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Colors.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = textboxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -30, 0, 25)
            textbox.Position = UDim2.new(0, 15, 0, 30)
            textbox.BackgroundColor3 = Colors.Background
            textbox.BorderSizePixel = 0
            textbox.Text = ""
            textbox.PlaceholderText = placeholder
            textbox.TextColor3 = Colors.Text
            textbox.PlaceholderColor3 = Color3.fromHex("#888888")
            textbox.TextSize = 12
            textbox.Font = Enum.Font.Gotham
            textbox.TextXAlignment = Enum.TextXAlignment.Left
            textbox.Parent = textboxFrame
            CreateCorner(textbox, 4)
            
            textbox.FocusLost:Connect(function(enterPressed)
                if callback then
                    callback(textbox.Text, enterPressed)
                end
            end)
            
            table.insert(self.Components, textboxFrame)
            return textboxFrame
        end
        
        function Tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 30)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Colors.Text
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.LayoutOrder = #self.Components + 1
            label.Parent = TabContent
            
            table.insert(self.Components, label)
            return label
        end
        
        function Tab:CreateDivider()
            local divider = Instance.new("Frame")
            divider.Size = UDim2.new(1, 0, 0, 1)
            divider.BackgroundColor3 = Colors.Hover
            divider.BorderSizePixel = 0
            divider.LayoutOrder = #self.Components + 1
            divider.Parent = TabContent
            
            table.insert(self.Components, divider)
            return divider
        end
        
        Window.Tabs[name] = Tab
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            TabButton.MouseButton1Click:Fire()
        end
        
        return Tab
    end
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                          startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        Window:Hide()
    end)
    
    -- Store references
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    
    return Window
end

-- Notification function for external use
function RedzUILib:Notify(title, message, duration, notificationType)
    ShowNotification(title, message, duration, notificationType)
end

return RedzUILib
