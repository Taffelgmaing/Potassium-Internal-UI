
local GuiName = "Qyrix"
local Library = {
    Colors = {
        ["Main Background"]     = Color3.fromRGB(22, 22, 22),
        ["Background"]          = Color3.fromRGB(22, 22, 22),
        ["Section Background"]  = Color3.fromRGB(22, 22, 22),
        ["Text"]          = Color3.fromRGB(255, 255, 255),
        ["Accent"]              = Color3.fromRGB(83, 116, 0),
        ["Stroke"]        = Color3.fromRGB(60, 60, 60),
    },

    Flags   =   {},
    Folders =   {
        Main    = GuiName,
        Utility = GuiName.."/Utility",
        Configs = GuiName.."/Configs",
    },

    Name = GuiName,
    UtilityModule = {},
}

Library.__index = {}

Library.Files = {
    Version = Library.Folders.Utility.."/__version__.lua"
}

Library.ThemeObjects = {}

local FileName = Library.Folders.Utility.."/Utility.lua" or "Utility.lua"
local Utility = game:HttpGetAsync("https://raw.githubusercontent.com/Mana-scripts/Neverlose-UI/refs/heads/main/Utility.lua")
if isfile and dofile then
    if isfile(FileName) then
        local CheckVersion = loadstring(readfile(FileName))()
        if CheckVersion.Version == loadstring(Utility)().Version then
            Library.UtilityModule = CheckVersion
			print("Correct Version!")
        else
            print("Updated to Correct Version!")
            writefile(FileName, tostring(Utility))
            Library.UtilityModule = loadstring(readfile(FileName))()
        end
	else
        print("Writing UtilityModule!")
        Library.UtilityModule = loadstring(Utility)()
		writefile(FileName, Utility)
    end
else
    warn("FileSystem Not supported Switching to httpservice")
    Library.UtilityModule = loadstring(Utility)()
end



Library.UtilityModule.Visual_Loader()({
    Load = true,
    KeyPath = "Key.txt"
})

function Library:Notify(options)
    -- Module:Notify({
    --     Title = "Script",
    --     Duration = 5,
    --     Description = "Script is currently down!"
    -- })
    
    Library.UtilityModule:Notify(options)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local GuiScaleValue = 1

local LocalPlayer = Players.LocalPlayer
local MainParent = LocalPlayer.PlayerGui

if gethui then
    MainParent = gethui()
else
    MainParent = CoreGui
end

if MainParent:FindFirstChild(Library.Name) then
    MainParent[Library.Name]:Destroy()
end

local SupGang = Instance.new("ScreenGui")
SupGang.Name = Library.Name
SupGang.IgnoreGuiInset = true
SupGang.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SupGang.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
SupGang.ScreenInsets = Enum.ScreenInsets.None
SupGang.Parent = MainParent

-- Generated with Readable GUI Dumper V11

function TweenItem(Data)
    local TweenItemData = {}

    local inst = Data.Inst
    local Property = Data.Property
    -- local Value = Data.Value

    local Speed = Data.Speed -- pixels per second
    local Time = Data.Time or 0.3
    local Style = Data.Style or Enum.EasingStyle.Quad
    local Direction = Data.Direction or ""

    if Speed then
        local Distance = 0

        if Property.Position then
            local CurrentPos = inst.AbsolutePosition

            local TargetX = Property.Position.X.Offset
            local TargetY = Property.Position.Y.Offset

            Distance = (Vector2.new(TargetX, TargetY) - CurrentPos).Magnitude
            Time = Distance / Speed

        elseif Property.Size then
            local CurrentSize = inst.AbsoluteSize

            local TargetX = Property.Size.X.Offset
            local TargetY = Property.Size.Y.Offset

            Distance = (Vector2.new(TargetX, TargetY) - CurrentSize).Magnitude
            Time = Distance / Speed

        elseif Property.Rotation then
            Distance = math.abs(inst.Rotation - Property.Rotation)
            Time = Distance / Speed
        end

        Time = math.clamp(Time, 0.05, Data.MaxTime or 1)
    end

    local Tween = TweenService:Create(
        inst,
        Direction ~= "" and TweenInfo.new(
            Time,
            Style,
            Enum.EasingDirection[Direction]
        ) or TweenInfo.new(
            Time,
            Style
        ),
        Property
    )

    function TweenItemData:Play()
        local TweenPlay = {}
        Tween:Play()
        function TweenPlay:Completed(callback)
            Tween.Completed:Connect(callback)
        end
        return TweenPlay
    end

    function TweenItemData:Stop()
        Tween:Cancel()
    end

    function TweenItemData:Cancel()
        Tween:Cancel()
    end

    function TweenItemData:Completed(callback)
        Tween.Completed:Connect(callback)
    end

    return TweenItemData
end

local function AutoScaleListLayout(ListLayout, Options)
    Options = Options or {}

    local Parent = ListLayout.Parent

    local Axis = Options.Axis or "Y"
    local UseScale = Options.UseScale or false

    local ExtraX = Options.ExtraX or 0
    local ExtraY = Options.ExtraY or 0

    local MinX = Options.MinX or 0
    local MinY = Options.MinY or 0

    local MaxX = Options.MaxX or math.huge
    local MaxY = Options.MaxY or math.huge

    local ClosedY = Options.ClosedY or MinY
    local ClosedX = Options.ClosedX or MinX

    local IsOpen = Options.DefaultOpen or false

    local CurrentTween

    local function GetOpenSize()
        local ContentSize = ListLayout.AbsoluteContentSize

        local NewX = math.clamp((ContentSize.X + ExtraX) / GuiScaleValue, MinX, MaxX)
        local NewY = math.clamp((ContentSize.Y + ExtraY) / GuiScaleValue, MinY, MaxY)

        if Axis == "Y" then
            if UseScale then
                local ParentParent = Parent.Parent

                if ParentParent then
                    return UDim2.new(
                        Parent.Size.X.Scale,
                        Parent.Size.X.Offset,
                        NewY / ParentParent.AbsoluteSize.Y,
                        0
                    )
                end
            else
                return UDim2.new(
                    Parent.Size.X.Scale,
                    Parent.Size.X.Offset,
                    0,
                    NewY
                )
            end
        elseif Axis == "X" then
            if UseScale then
                local ParentParent = Parent.Parent

                if ParentParent then
                    return UDim2.new(
                        NewX / ParentParent.AbsoluteSize.X,
                        0,
                        Parent.Size.Y.Scale,
                        Parent.Size.Y.Offset
                    )
                end
            else
                return UDim2.new(
                    0,
                    NewX,
                    Parent.Size.Y.Scale,
                    Parent.Size.Y.Offset
                )
            end
        end
    end

    local function GetClosedSize()
        if Axis == "Y" then
            return UDim2.new(
                Parent.Size.X.Scale,
                Parent.Size.X.Offset,
                0,
                ClosedY
            )
        elseif Axis == "X" then
            return UDim2.new(
                0,
                ClosedX,
                Parent.Size.Y.Scale,
                Parent.Size.Y.Offset
            )
        end
    end

    local function TweenSize(TargetSize)
        if not TargetSize then
            return
        end

        if CurrentTween then
            CurrentTween:Stop()
        end

        CurrentTween = TweenItem({
            Inst = Parent,
            Property = {
                Size = TargetSize
            }
        })

        CurrentTween:Play()
    end

    local function SetOpen(State)
        IsOpen = State

        if IsOpen then
            TweenSize(GetOpenSize())
        else
            TweenSize(GetClosedSize())
        end
    end

    local function Update()
        if IsOpen then
            TweenSize(GetOpenSize())
        end
    end

    local function ForceUpdate()
        TweenSize(GetOpenSize())
    end

    local UpdateQueued = false

    local function QueueUpdate()
        if UpdateQueued then
            return
        end

        UpdateQueued = true

        task.defer(function()
            RunService.Heartbeat:Wait()

            UpdateQueued = false

            if not ListLayout or not Parent then
                return
            end

            Update()
        end)
    end

    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueUpdate)
    Parent.ChildAdded:Connect(QueueUpdate)
    Parent.ChildRemoved:Connect(QueueUpdate)

    SetOpen(IsOpen)

    return {
        Update = QueueUpdate,

        ForceUpdate = function()
            QueueUpdate()
        end,

        SetOpen = SetOpen,

        IsOpen = function()
            return IsOpen
        end
    }
end

local function AutoScaleSectionContainer(Container, Holder1, Layout1, Holder2, Layout2)
	local function Update()
        local Height1 = (Layout1.AbsoluteContentSize.Y + 10) / GuiScaleValue
        local Height2 = 0

        if Holder2 and Layout2 then
            Height2 = (Layout2.AbsoluteContentSize.Y + 10) / GuiScaleValue
        end

		local MaxHeight = math.max(Height1, Height2)

		Holder1.Size = UDim2.new(
			Holder1.Size.X.Scale,
			Holder1.Size.X.Offset,
			0,
			Height1
		)

		if Holder2 then
			Holder2.Size = UDim2.new(
				Holder2.Size.X.Scale,
				Holder2.Size.X.Offset,
				0,
				Height2
			)
		end

		Container.CanvasSize = UDim2.new(0, 0, 0, MaxHeight + 10)
	end

	Layout1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)

	Holder1.ChildAdded:Connect(function()
		task.defer(Update)
	end)

	Holder1.ChildRemoved:Connect(function()
		task.defer(Update)
	end)

	if Holder2 and Layout2 then
		Layout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update)

		Holder2.ChildAdded:Connect(function()
			task.defer(Update)
		end)

		Holder2.ChildRemoved:Connect(function()
			task.defer(Update)
		end)
	end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        task.defer(Update)
    end)

	task.defer(Update)

	return Update
end


local function AutoScaleGui(GuiObject, Options)
	Options = Options or {}

	local Camera = workspace.CurrentCamera

	local BaseResolution = Options.BaseResolution or Vector2.new(1920, 1080)
	local MinScale = Options.MinScale or 0.65
	local MaxScale = Options.MaxScale or 1
	local Center = Options.Center ~= false

	local ScaleObject = GuiObject:FindFirstChild("AutoResolutionScale")

	if not ScaleObject then
		ScaleObject = Instance.new("UIScale")
		ScaleObject.Name = "AutoResolutionScale"
		ScaleObject.Parent = GuiObject
	end

	local function Update()
		local ViewportSize = Camera.ViewportSize

		local ScaleX = ViewportSize.X / BaseResolution.X
		local ScaleY = ViewportSize.Y / BaseResolution.Y

		GuiScaleValue = math.clamp(math.min(ScaleX, ScaleY), MinScale, MaxScale)
		ScaleObject.Scale = GuiScaleValue

		if Center then
			GuiObject.AnchorPoint = Vector2.new(0.5, 0.5)
			GuiObject.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
	end

	Update()
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Update)

	return {
		Update = Update,
		Scale = ScaleObject
	}
end

function Library:RegisterTheme(Object, Property, ColorName)
	if not Object or not Property or not ColorName then
		return
	end

	if not Library.ThemeObjects[ColorName] then
		Library.ThemeObjects[ColorName] = {}
	end

	table.insert(Library.ThemeObjects[ColorName], {
		Object = Object,
		Property = Property
	})

	if Library.Colors[ColorName] then
		Object[Property] = Library.Colors[ColorName]
	end
end

function Library:SetColor(ColorName, ColorValue)
	if not Library.Colors[ColorName] then
		warn("Invalid library color:", ColorName)
		return
	end

	if typeof(ColorValue) ~= "Color3" then
		warn("Color value must be Color3")
		return
	end

	Library.Colors[ColorName] = ColorValue

	local Objects = Library.ThemeObjects[ColorName]

	if not Objects then
		return
	end

	for Index = #Objects, 1, -1 do
		local Data = Objects[Index]
		local Object = Data.Object

		if Object and Object.Parent then
			local success = pcall(function()
                TweenItem({
                    Inst = Object,
                    Property = {
                        [Data.Property] = ColorValue
                    },
                    Time = 0.3
                }):Play()
			end)

			if not success then
				table.remove(Objects, Index)
			end
		else
			table.remove(Objects, Index)
		end
	end
end

local function GetFixedMouseLocation()
	local Mouse = UserInputService:GetMouseLocation()
	local GuiInset = GuiService:GetGuiInset()

	return Vector2.new(
		Mouse.X - GuiInset.X,
		Mouse.Y - GuiInset.Y
	)
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        local Tween = TweenService:Create(object, TweenInfo.new(0.2), {Position = pos})
        Tween:Play()
    end
    
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
    
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    topbarobject.InputChanged:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local ToolTipQueueId = 0
local CurrentTween
local FollowConnection

local function CreateToolTip(Data)
	local HoverObject = Data.HoverObject
	local ToolTip = Data.ToolTip
	local Text = Data.Text or "Tooltip"

	local PaddingX = Data.PaddingX or 12
	local Height = Data.Height or 20
	local TweenTime = Data.TweenTime or 0.2

	local OffsetX = 12 --Data.OffsetX or 12
	local OffsetY = Data.OffsetY or 12

	local BackgroundOpenTransparency = Data.BackgroundOpenTransparency or 0.25
	local ClosedSize = UDim2.new(0, 0, 0, Height)

	local function GetCurrentText()
		local CurrentText

		if typeof(Text) == "function" then
			CurrentText = Text()
		else
			CurrentText = Text
		end

		if not CurrentText or CurrentText == "" then
			return nil
		end

		return tostring(CurrentText)
	end

    local function CountStringInfo(Text)
        local Characters = 0
        local Spaces = 0
        local Numbers = 0

        for i = 1, #Text do
            local Char = Text:sub(i, i)

            Characters += 1

            if Char == " " then
                Spaces += 1
            elseif tonumber(Char) then
                Numbers += 1
            end
        end

        local Total = Characters

        return {
            Characters = Characters,
            Spaces = Spaces,
            Numbers = Numbers,
            Total = Total
        }
    end
    
	local function GetTextSize(CurrentText)
		local TextBounds = TextService:GetTextSize(
			CurrentText,
			ToolTip.TextSize,
			ToolTip.Font,
			Vector2.new(math.huge, Height)
		)

		return UDim2.new(0, TextBounds.X - CountStringInfo(CurrentText).Total, 0, Height)
	end

	local function UpdatePosition()
		local MouseLocation = UserInputService:GetMouseLocation()

		ToolTip.Position = UDim2.new(
			0,
			MouseLocation.X + OffsetX,
			0,
			MouseLocation.Y + OffsetY
		)
	end

	local function StartFollowing()
		if FollowConnection then
			return
		end

		FollowConnection = RunService.RenderStepped:Connect(function()
			if ToolTip.Visible then
				UpdatePosition()
			end
		end)
	end

	local function StopFollowing()
		if FollowConnection then
			FollowConnection:Disconnect()
			FollowConnection = nil
		end
	end

	local function TweenToolTip(Properties, Callback)
		if CurrentTween then
			CurrentTween:Cancel()
			CurrentTween = nil
		end

		CurrentTween = TweenService:Create(
			ToolTip,
			TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			Properties
		)

		if Callback then
			CurrentTween.Completed:Once(Callback)
		end

		CurrentTween:Play()
	end

	HoverObject.MouseEnter:Connect(function()
		local CurrentText = GetCurrentText()

		if not CurrentText then
			return
		end

		ToolTipQueueId += 1
		local MyQueueId = ToolTipQueueId

		ToolTip.Visible = true
		ToolTip.Text = CurrentText
		ToolTip.ClipsDescendants = true

		UpdatePosition()
		StartFollowing()

		TweenToolTip({
			Size = GetTextSize(CurrentText),
			TextTransparency = 0,
			BackgroundTransparency = BackgroundOpenTransparency
		}, function()
			if MyQueueId ~= ToolTipQueueId then
				return
			end
		end)
	end)

	HoverObject.MouseLeave:Connect(function()
		ToolTipQueueId += 1
		local MyQueueId = ToolTipQueueId

		TweenToolTip({
			Size = ClosedSize,
			TextTransparency = 1,
			BackgroundTransparency = 1
		}, function()
			if MyQueueId ~= ToolTipQueueId then
				return
			end

			ToolTip.Visible = false
			StopFollowing()
		end)
	end)
end


















function Library:SetOpen(State)
    SupGang.Enabled = State
end





local Globals = {}
Globals["UITOGGLED"] = false
Globals["SETTINGSTOGGLED"] = false

function Library:Window(Data)
    local Tab_Toggled = false
    local Window_Table = {}
    local Name = Data.Name or "Project Qyrix"
    local _GameName = Data.GameName or "Mana is the best!"

    local MainFrame = Instance.new("Frame")
    local ContainerHolder = Instance.new("Frame")
    local SettingsFrame = Instance.new("Frame")

    local ToggleButton = Instance.new("ImageButton")
    local UICorner = Instance.new("UICorner")



    ToggleButton.Name = "ToggleButton"
    ToggleButton.Position = UDim2.new(0.5066050291061401, -34, 0.5549374222755432, -498)
    ToggleButton.Size = UDim2.new(0, 43, 0, 43)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Image = "rbxassetid://108751890179023"
    ToggleButton.Parent = SupGang
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.ImageTransparency = 1

    ToggleButton:SetAttribute("Ignore", true)


    UICorner.Parent = ToggleButton

    function Library:ToggleButton(state)
        TweenItem({
            Inst = ToggleButton,
            Property = {
                ImageTransparency = state and 0 or 1
            }
        }):Play()
    end

    function Library:ToggleSettings(state)
        TweenItem({
            Inst = SettingsFrame,
            Property = {
                Size = state and UDim2.new(0, 283, 0, 298) or UDim2.new(0, 283, 0, 0)
            }, 
        }):Play()
    end

    function Library:ToggleUI(state)
        -- for i,v in pairs(SupGang:GetDescendants()) do
        --     if not v:GetAttribute("Ignore") and v:IsA("GuiObject") then
        --         if string.find(v.ClassName, "Image") then
        --             Original_Values[v.Name] = v.ImageTransparency
        --         elseif string.find(v.ClassName, "TextButton") then
        --             Original_Values[v.Name] = v.BackgroundTransparency
        --         elseif string.find(v.ClassName, "TextLabel") then
        --             Original_Values[v.Name] = v.TextTransparency
        --         elseif string.find(v.ClassName, "TextButton") then

        --         elseif string.find(v.ClassName, "TextButton") then

        --         end
        --     end
        -- end
        MainFrame.ClipsDescendants = true
        -- Library:TweenColorpickerFrame(false)
        TweenItem({
            Inst = MainFrame,
            Property = {
                Size = state and UDim2.new(0, 590, 0, 567) or UDim2.new(0, 590, 0, 0)
            },
        }):Play()
        if not state then
            Globals["SETTINGSTOGGLED"] = false
            Library:ToggleSettings(false)
        end
    end
        -- Colorpicker_Table.Toggled = false


    ToggleButton.MouseButton1Click:Connect(function()
        Globals["UITOGGLED"] = not Globals["UITOGGLED"]
        Library:ToggleUI(Globals["UITOGGLED"])
    end)

    Library:ToggleSettings(Globals["SETTINGSTOGGLED"])

    SettingsFrame.ClipsDescendants = true

    MakeDraggable(ToggleButton, ToggleButton)

    local MainHolder = Instance.new("Folder")
    local LibraryTitle = Instance.new("TextLabel")
    local UITextSizeConstraint_29 = Instance.new("UITextSizeConstraint")
    local line1_3 = Instance.new("Frame")
    local line2 = Instance.new("Frame")
    local OptionsFrame = Instance.new("Frame")
    local UICorner_35 = Instance.new("UICorner")
    local UIListLayout_9 = Instance.new("UIListLayout")
    local UIPadding_9 = Instance.new("UIPadding")
    local SettingsOption = Instance.new("TextButton")
    local SettingsIcon = Instance.new("ImageLabel")
    local SearchOption = Instance.new("TextButton")
    local SearchIcon = Instance.new("ImageLabel")
    Library:RegisterTheme(SettingsIcon, "ImageColor3", "Accent")
    Library:RegisterTheme(SearchIcon, "ImageColor3", "Accent")
    local OptionsFrameFolder = Instance.new("Folder")
    local OptionsSearch = Instance.new("TextBox")
    local UICorner_36 = Instance.new("UICorner")
    local UITextSizeConstraint_30 = Instance.new("UITextSizeConstraint")
    local UIStroke_33 = Instance.new("UIStroke")
    local UICorner_37 = Instance.new("UICorner")

    local UICorner_43 = Instance.new("UICorner")
    local SettingsHolder = Instance.new("Folder")
    local LibraryTitle_2 = Instance.new("TextLabel")
    local UITextSizeConstraint_33 = Instance.new("UITextSizeConstraint")
    local line1_4 = Instance.new("Frame")
    local UIListLayout_11 = Instance.new("UIListLayout")
    local _0NoItemHere = Instance.new("Frame")

    -- Library:RegisterTheme(LibraryTitle, "TextColor3", "Text")

    Library:RegisterTheme(UIStroke_33, "Color", "Stroke")

    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0, 0)
    MainFrame.Position = UDim2.new(0.3446079194545746, 0, 0.4499991834163666, 0)
    MainFrame.Size = UDim2.new(0, 590, 0, 567)
    MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.Parent = SupGang
    MainFrame.ClipsDescendants = true

    local MainFrameScaler = AutoScaleGui(MainFrame, {
        BaseResolution = Vector2.new(1920, 1080),
        MinScale = 0.65,
        MaxScale = 1,
        Center = false,
        KeepOnScreen = true
    })

    local ToggleButtonScaler = AutoScaleGui(ToggleButton, {
        BaseResolution = Vector2.new(1920, 1080),
        MinScale = 0.65,
        MaxScale = 1,
        Center = false,
        KeepOnScreen = true
    })

    Library:RegisterTheme(MainFrame, "BackgroundColor3", "Main Background")

    MakeDraggable(MainFrame, MainFrame)

    UICorner_37.CornerRadius = UDim.new(0, 3)
    UICorner_37.Parent = MainFrame

    ContainerHolder.Name = "ContainerHolder"
    ContainerHolder.Position = UDim2.new(0.24919098615646362, 0, 0.0849618911743164, 0)
    ContainerHolder.Size = UDim2.new(0.7388231158256531, 0, 0.9150381088256836, 0)
    ContainerHolder.BackgroundTransparency = 1
    ContainerHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContainerHolder.BorderSizePixel = 0
    ContainerHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContainerHolder.Parent = MainFrame


    MainHolder.Name = "MainHolder"
    MainHolder.Parent = MainFrame

    LibraryTitle.Name = "LibraryTitle"
    LibraryTitle.Position = UDim2.new(1.7478352276611986e-07, 0, 0, 0)
    LibraryTitle.Size = UDim2.new(0.2382681518793106, 0, 0, 42)
    LibraryTitle.BackgroundTransparency = 1
    LibraryTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LibraryTitle.BorderSizePixel = 0
    LibraryTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LibraryTitle.Text = Name
    LibraryTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LibraryTitle.TextSize = 23
    LibraryTitle.TextScaled = true
    LibraryTitle.TextWrapped = true
    LibraryTitle.Font = Enum.Font.Gotham
    LibraryTitle.Parent = MainHolder

    UITextSizeConstraint_29.MaxTextSize = 25
    UITextSizeConstraint_29.Parent = LibraryTitle

    line1_3.Name = "line1"
    line1_3.Position = UDim2.new(-9.803861900081756e-08, 0, 0.07725074887275696, 0)
    line1_3.Size = UDim2.new(1, 0, 0, 1)
    line1_3.BackgroundColor3 = Library.Colors["Stroke"]
    line1_3.BorderSizePixel = 0
    line1_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    line1_3.Parent = MainHolder

    Library:RegisterTheme(line1_3, "BackgroundColor3", "Stroke")

    line2.Name = "line2"
    line2.Position = UDim2.new(0.23624595999717712, 0, 0, 0)
    line2.Size = UDim2.new(0, 1, 1, 0)
    line2.BackgroundColor3 = Library.Colors["Stroke"]
    line2.BorderSizePixel = 0
    line2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    line2.Parent = MainHolder

    Library:RegisterTheme(line2, "BackgroundColor3", "Stroke")

    OptionsFrame.Name = "OptionsFrame"
    OptionsFrame.Position = UDim2.new(0.2494552582502365, 0, 0.006437560077756643, 0)
    OptionsFrame.Size = UDim2.new(0.7385588884353638, 0, 0, 40)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    OptionsFrame.Parent = MainHolder
    OptionsFrame.BackgroundTransparency = 1
    OptionsFrame.Visible = true

    UICorner_35.CornerRadius = UDim.new(0, 3)
    UICorner_35.Parent = OptionsFrame

    UIListLayout_9.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_9.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout_9.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout_9.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_9.Padding = UDim.new(0, 4)
    UIListLayout_9.Parent = OptionsFrame

    UIPadding_9.PaddingLeft = UDim.new(0, 10)
    UIPadding_9.PaddingRight = UDim.new(0, 10)
    UIPadding_9.Parent = OptionsFrame

    SettingsOption.Name = "SettingsOption"
    SettingsOption.AnchorPoint = Vector2.new(0.5, 0.5)
    SettingsOption.Size = UDim2.new(0, 22, 0, 22)
    SettingsOption.BackgroundTransparency = 1
    SettingsOption.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SettingsOption.BorderSizePixel = 0
    SettingsOption.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SettingsOption.Text = ""
    SettingsOption.TextColor3 = Color3.fromRGB(0, 0, 0)
    SettingsOption.TextSize = 14
    SettingsOption.Font = Enum.Font.Gotham
    SettingsOption.Parent = OptionsFrame

    SettingsOption.MouseButton1Click:Connect(function()
        Globals["SETTINGSTOGGLED"] = not Globals["SETTINGSTOGGLED"]
        Library:ToggleSettings(Globals["SETTINGSTOGGLED"])
    end)

    SettingsIcon.Name = "SettingsIcon"
    SettingsIcon.Size = UDim2.new(0, 22, 0, 22)
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SettingsIcon.BorderSizePixel = 0
    SettingsIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SettingsIcon.Image = "http://www.roblox.com/asset/?id=6031280882"
    SettingsIcon.ImageColor3 = Color3.fromRGB(83, 116, 0)
    SettingsIcon.Parent = SettingsOption

    SearchOption.Name = "SearchOption"
    SearchOption.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchOption.Size = UDim2.new(0, 22, 0, 22)
    SearchOption.BackgroundTransparency = 1
    SearchOption.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchOption.BorderSizePixel = 0
    SearchOption.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchOption.Text = ""
    SearchOption.TextColor3 = Color3.fromRGB(0, 0, 0)
    SearchOption.TextSize = 14
    SearchOption.Font = Enum.Font.Gotham
    SearchOption.Parent = OptionsFrame
    SearchOption.Visible = false

    SearchIcon.Name = "SearchIcon"
    SearchIcon.Position = UDim2.new(-0.088897705078125, 0, 0, 0)
    SearchIcon.Size = UDim2.new(0, 24, 0, 24)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchIcon.BorderSizePixel = 0
    SearchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchIcon.Image = "rbxassetid://6031154871"
    SearchIcon.ImageColor3 = Color3.fromRGB(83, 116, 0)
    SearchIcon.Parent = SearchOption

    OptionsFrameFolder.Name = "OptionsFrameFolder"
    OptionsFrameFolder.Parent = OptionsFrame

    OptionsSearch.Name = "OptionsSearch"
    OptionsSearch.ClipsDescendants = true
    OptionsSearch.Position = UDim2.new(-0.011389552615582943, 0, 0.10000000149011612, 0)
    OptionsSearch.Size = UDim2.new(0.789849042892456, 0, 0, 31)
    OptionsSearch.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    OptionsSearch.BorderSizePixel = 0
    OptionsSearch.BorderColor3 = Color3.fromRGB(0, 0, 0)
    OptionsSearch.Text = ""
    OptionsSearch.PlaceholderText = "Search Here!"
    OptionsSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionsSearch.TextSize = 19
    OptionsSearch.Font = Enum.Font.Gotham
    OptionsSearch.Parent = OptionsFrameFolder
    OptionsSearch.BackgroundTransparency = 0.8
    OptionsSearch.Visible = false

    Library:RegisterTheme(OptionsSearch, "BackgroundColor3", "Background")

    UICorner_36.CornerRadius = UDim.new(0, 3)
    UICorner_36.Parent = OptionsSearch

    UITextSizeConstraint_30.MaxTextSize = 18
    UITextSizeConstraint_30.Parent = OptionsSearch

    UIStroke_33.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke_33.Color = Library.Colors["Stroke"]
    UIStroke_33.Parent = OptionsSearch












    Library:RegisterTheme(UIStroke_35, "Color", "Stroke")
    Library:RegisterTheme(UIStroke_36, "Color", "Stroke")
    Library:RegisterTheme(UIStroke_37, "Color", "Stroke")
    Library:RegisterTheme(UIStroke_38, "Color", "Stroke")


    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SettingsFrame.Position = UDim2.new(0.6691318154335022, 0, 0.5990349650382996, 0)
    SettingsFrame.Size = UDim2.new(0, 283, 0, 298)
    SettingsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SettingsFrame.Parent = SupGang
    -- SettingsFrame.Visible = false

    function Library:ChangeParent(newparent, item)
        if newparent then
            if newparent == "Settings" then
                item.Parent = SettingsFrame
                return
            end
            item.Parent = newparent
        end
    end

    


    local SettingsFrameScaler = AutoScaleGui(SettingsFrame, {
        BaseResolution = Vector2.new(1920, 1080),
        MinScale = 0.65,
        MaxScale = 1,
        Center = false,
        KeepOnScreen = true
    })

    MakeDraggable(SettingsFrame, SettingsFrame)

    UICorner_43.CornerRadius = UDim.new(0, 3)
    UICorner_43.Parent = SettingsFrame

    SettingsHolder.Name = "SettingsHolder"
    SettingsHolder.Parent = SettingsFrame

    LibraryTitle_2.Name = "LibraryTitle"
    LibraryTitle_2.Size = UDim2.new(0, 283, 0, 32)
    LibraryTitle_2.BackgroundTransparency = 1
    LibraryTitle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LibraryTitle_2.BorderSizePixel = 0
    LibraryTitle_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LibraryTitle_2.Text = "Settings"
    LibraryTitle_2.TextColor3 = Color3.fromRGB(255, 255, 255)
    LibraryTitle_2.TextSize = 23
    LibraryTitle_2.TextScaled = true
    LibraryTitle_2.TextWrapped = true
    LibraryTitle_2.Font = Enum.Font.Gotham
    LibraryTitle_2.Parent = SettingsHolder

    UITextSizeConstraint_33.MaxTextSize = 25
    UITextSizeConstraint_33.Parent = LibraryTitle_2

    line1_4.Name = "line1"
    line1_4.Position = UDim2.new(0, 0, 0.10532087087631226, 0)
    line1_4.Size = UDim2.new(0, 283, 0, 1)
    line1_4.BackgroundColor3 = Library.Colors["Stroke"]
    line1_4.BorderSizePixel = 0
    line1_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    line1_4.Parent = SettingsHolder

    Library:RegisterTheme(line1_4, "BackgroundColor3", "Stroke")

    UIListLayout_11.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_11.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_11.Padding = UDim.new(0, 10)
    UIListLayout_11.Parent = SettingsFrame

    _0NoItemHere.Name = "0NoItemHere"
    _0NoItemHere.Position = UDim2.new(0.32332155108451843, 0, 0, 0)
    _0NoItemHere.Size = UDim2.new(0, 100, 0, 43)
    _0NoItemHere.BackgroundTransparency = 1
    _0NoItemHere.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _0NoItemHere.BorderSizePixel = 0
    _0NoItemHere.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _0NoItemHere.Parent = SettingsFrame





    local ToolTip = Instance.new("TextLabel")
    local UICorner_42 = Instance.new("UICorner")
    local UIPadding_11 = Instance.new("UIPadding")
    local UITextSizeConstraint_32 = Instance.new("UITextSizeConstraint")


    ToolTip.Name = "ToolTip"
    ToolTip.ClipsDescendants = true
    ToolTip.Position = UDim2.new(0.12551990151405334, 0, 0.059036143124103546, 0)
    ToolTip.Size = UDim2.new(0, 0, 0, 20)
    ToolTip.BackgroundTransparency = 0.25
    ToolTip.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
    ToolTip.BorderSizePixel = 0
    ToolTip.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ToolTip.Text = "Enable Autofarm for Brain Rots"
    ToolTip.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToolTip.TextSize = 16
    ToolTip.TextXAlignment = Enum.TextXAlignment.Left
    ToolTip.Font = Enum.Font.Gotham
    ToolTip.Parent = SupGang
    ToolTip.Visible = true

    UICorner_42.CornerRadius = UDim.new(0, 3)
    UICorner_42.Parent = ToolTip

    UIPadding_11.PaddingLeft = UDim.new(0, 4)
    UIPadding_11.Parent = ToolTip

    UITextSizeConstraint_32.MaxTextSize = 12
    UITextSizeConstraint_32.Parent = ToolTip



    local Colorpickers = Instance.new("Folder")

    Colorpickers.Name = "Colorpickers"
    Colorpickers.Parent = MainFrame




    local LeftFrame = Instance.new("Frame")
    local TabsHolder = Instance.new("ScrollingFrame")
    local UIListLayout_10 = Instance.new("UIListLayout")
    local UIPadding_10 = Instance.new("UIPadding")
    local LeftFrameLine = Instance.new("Frame")
    local PlayerInfo = Instance.new("Frame")
    local PlayerImage = Instance.new("ImageLabel")
    local UICorner_39 = Instance.new("UICorner")
    local GameName = Instance.new("TextButton")
    local UICorner_40 = Instance.new("UICorner")


    LeftFrame.Name = "LeftFrame"
    LeftFrame.Position = UDim2.new(5.722285223441759e-08, 0, 0.09300854802131653, 0)
    LeftFrame.Size = UDim2.new(0.23624595999717712, 0, 1.0750519408020409e-07, 497)
    LeftFrame.BackgroundTransparency = 1
    LeftFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LeftFrame.BorderSizePixel = 0
    LeftFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LeftFrame.Parent = MainFrame

    TabsHolder.Name = "TabsHolder"
    TabsHolder.Active = true
    TabsHolder.Position = UDim2.new(-4.844345653509663e-07, 0, 0, 0)
    TabsHolder.Size = UDim2.new(0.9524370431900024, 0, 0, 488)
    TabsHolder.BackgroundTransparency = 1
    TabsHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabsHolder.BorderSizePixel = 0
    TabsHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabsHolder.ScrollBarThickness = 6
    TabsHolder.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    TabsHolder.Parent = LeftFrame
    

    UIListLayout_10.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_10.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_10.Padding = UDim.new(0, 6)
    UIListLayout_10.Parent = TabsHolder

    UIPadding_10.PaddingTop = UDim.new(0, 5)
    UIPadding_10.Parent = TabsHolder

    LeftFrameLine.Name = "LeftFrameLine"
    LeftFrameLine.Position = UDim2.new(0.007768942043185234, 0, 0.8752515912055969, 0)
    LeftFrameLine.Size = UDim2.new(1, 0, 0, 1)
    LeftFrameLine.BackgroundColor3 = Library.Colors["Stroke"]
    LeftFrameLine.BorderSizePixel = 0
    LeftFrameLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LeftFrameLine.Parent = LeftFrame

    Library:RegisterTheme(LeftFrameLine, "BackgroundColor3", "Stroke")

    PlayerInfo.Name = "PlayerInfo"
    PlayerInfo.Position = UDim2.new(7.150026704039192e-07, 0, 0.877263605594635, 0)
    PlayerInfo.Size = UDim2.new(1.0074559450149536, 0, 0.15694163739681244, 0)
    PlayerInfo.BackgroundTransparency = 1
    PlayerInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerInfo.BorderSizePixel = 0
    PlayerInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerInfo.Parent = LeftFrame

    PlayerImage.Name = "PlayerImage"
    PlayerImage.Position = UDim2.new(0.2870492935180664, 0, 0.1, 0)

    PlayerImage.Size = UDim2.new(0.36, 0, 0.63, 0)
    PlayerImage.BackgroundTransparency = 1
    PlayerImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerImage.BorderSizePixel = 0
    PlayerImage.BorderColor3 = Color3.fromRGB(0, 0, 0)

    local function HoverTween(Object, Property, EnterValue, LeaveValue, Options)
        Options = Options or {}

        local Time = Options.Time or 0.25
        local Style = Options.Style or Enum.EasingStyle.Quad
        local Direction = Options.Direction or "Out"

        local CurrentTween

        local function TweenTo(Value)
            if CurrentTween then
                CurrentTween:Cancel()
            end

            CurrentTween = TweenItem({
                Inst = Object,
                Property = Property,
                Value = Value,
                Time = Time,
                Style = Style,
                Direction = Direction
            })

            CurrentTween:Play()

            return CurrentTween
        end

        Object.MouseEnter:Connect(function()
            TweenTo(EnterValue)
        end)

        Object.MouseLeave:Connect(function()
            TweenTo(LeaveValue)
        end)

        return {
            SetEnter = function(Value)
                EnterValue = Value
            end,

            SetLeave = function(Value)
                LeaveValue = Value
            end,

            TweenTo = TweenTo
        }
    end



    local function Hover_Object(Object, EnterText, LeaveText, Options)
        Options = Options or {}

        local Time = Options.Time or 0.25
        local Type = Options.Type or "TextTransparency"
        local Busy = false
        local Hovering = false

        local function ChangeValue(NewValue)
            if Busy then
                return
            end

            Busy = true

            local FadeOut = TweenItem({
                Inst = Object,
                Property = {
                    [Type] = 1
                },
                Time = Time
            })

            FadeOut:Play()

            local ObjectIsA
            FadeOut:Completed(function()
                if string.find(Type, "Text") then
                    Object.Text = NewValue
                    ObjectIsA = "Text"
                elseif string.find(Type, "Image") then
                    Object.Image = NewValue
                    ObjectIsA = "Image"
                end

                local FadeIn = TweenItem({
                    Inst = Object,
                    Property = {[Type]=0},
                    Time = Time
                })

                FadeIn:Play()

                FadeIn:Completed(function()
                    Busy = false

                    local WantedText = Hovering and EnterText or LeaveText

                    if Object[ObjectIsA] ~= WantedText then
                        ChangeValue(WantedText)
                    end
                end)
            end)
        end

        Object.MouseEnter:Connect(function()
            Hovering = true
            ChangeValue(EnterText)
        end)

        Object.MouseLeave:Connect(function()
            Hovering = false
            ChangeValue(LeaveText)
        end)

        return {
            SetEnter = function(Text)
                EnterText = Text
            end,

            SetLeave = function(Text)
                LeaveText = Text
            end
        }
    end


    task.spawn(function()
        PlayerImage.ImageTransparency = 1
        PlayerImage.Image = "rbxassetid://108751890179023"

        task.wait(0.5)

        TweenItem({
            Inst = PlayerImage,
            Property = {["ImageTransparency"]=0},
            Time = 0.5
        }):Play()

        task.wait(1.5)

        local content, isReady = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420
        )

        TweenItem({
            Inst = PlayerImage,
            Property = {["ImageTransparency"]=1},
            Time = 0.5,
        }):Play():Completed(function()
            PlayerImage.Image = isReady and content or "rbxassetid://108751890179023"
            TweenItem({
                Inst = PlayerImage,
                Property = {["ImageTransparency"]=0},
                Time = 0.5,
                Value = 0
            }):Play():Completed(function()
                Hover_Object(PlayerImage, "rbxassetid://108751890179023", content, {
                    Time = 0.5,
                    Type = "ImageTransparency"
                })
            end)
        end)
    end)

    PlayerImage.Parent = PlayerInfo


    UICorner_39.CornerRadius = UDim.new(1, 0)
    UICorner_39.Parent = PlayerImage

    GameName.Name = "GameName"
    GameName.Position = UDim2.new(0.08941177278757095, 0, 0.7107692360877991, 0)
    GameName.Size = UDim2.new(0.824999988079071, 0, 0.20000000298023224, 0)
    GameName.AutoButtonColor = false
    GameName.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    GameName.BorderSizePixel = 0
    GameName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GameName.Text = _GameName
    GameName.TextColor3 = Color3.fromRGB(255, 255, 255)
    GameName.TextSize = 14
    GameName.Font = Enum.Font.Gotham
    GameName.Parent = PlayerInfo
    GameName.BackgroundTransparency = 1

    Hover_Object(GameName, "Free", _GameName, {
        Time = 0.5,
        Type = "TextTransparency"
    })


    UICorner_40.CornerRadius = UDim.new(0, 3)
    UICorner_40.Parent = GameName

    local ColorpickerFrame = Instance.new("Frame")
    local UICorner_47 = Instance.new("UICorner")
    local UIStroke_39 = Instance.new("UIStroke")
    Library:RegisterTheme(UIStroke_39, "Color", "Stroke")
    local ColorBox = Instance.new("TextBox")
    local UITextSizeConstraint_37 = Instance.new("UITextSizeConstraint")
    local Colorpickerline = Instance.new("Frame")
    local Color = Instance.new("ImageLabel")
    local UICorner_48 = Instance.new("UICorner")
    local ColorSelection = Instance.new("ImageLabel")
    local Hue = Instance.new("ImageLabel")
    local HueCorner_3 = Instance.new("UICorner")
    local HueGradient = Instance.new("UIGradient")
    local HueSelection = Instance.new("ImageLabel")


    ColorpickerFrame.Name = "ColorpickerFrame"
    ColorpickerFrame.ClipsDescendants = true
    ColorpickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorpickerFrame.Position = UDim2.new(1.25, 0, 0.35, 0)


    ColorpickerFrame.Size = UDim2.new(0, 282, 0, 203)
    ColorpickerFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    ColorpickerFrame.BorderSizePixel = 0
    ColorpickerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ColorpickerFrame.Parent = Colorpickers

    ColorpickerFrame.Size = UDim2.new(0, 282, 0, 0)
    ColorpickerFrame.BackgroundTransparency = 1

    UICorner_47.CornerRadius = UDim.new(0, 3)
    UICorner_47.Parent = ColorpickerFrame

    UIStroke_39.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke_39.Color = Library.Colors["Stroke"]
    UIStroke_39.Parent = ColorpickerFrame

    ColorBox.Name = "ColorBox"
    ColorBox.Position = UDim2.new(0, 0, 0.853154182434082, 0)
    ColorBox.Size = UDim2.new(0, 282, 0, 29)
    ColorBox.BackgroundTransparency = 1
    ColorBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ColorBox.BorderSizePixel = 0
    ColorBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ColorBox.Text = ""
    ColorBox.PlaceholderText = "ColorCode (127, 127, 127)"
    ColorBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorBox.PlaceholderColor3 = Color3.fromRGB(127, 127, 127)
    ColorBox.TextSize = 14
    ColorBox.TextScaled = true
    ColorBox.TextWrapped = true
    ColorBox.Font = Enum.Font.Gotham
    ColorBox.Parent = ColorpickerFrame
    ColorBox.ClearTextOnFocus = false

    UITextSizeConstraint_37.MaxTextSize = 17
    UITextSizeConstraint_37.Parent = ColorBox

    Colorpickerline.Name = "Colorpickerline"
    Colorpickerline.Position = UDim2.new(0, 0, 0.8399251699447632, 0)
    Colorpickerline.Size = UDim2.new(0, 282, 0, 1)
    Colorpickerline.BackgroundColor3 = Library.Colors["Stroke"]
    Colorpickerline.BorderSizePixel = 0
    Colorpickerline.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Colorpickerline.Parent = ColorpickerFrame

    Library:RegisterTheme(Colorpickerline, "BackgroundColor3", "Stroke")

    Color.Name = "Color"
    Color.Visible = true
    Color.Position = UDim2.new(-0.0000011057093161070952, 0, -1.617227951555833e-07, 0)
    Color.Size = UDim2.new(0, 247, 0, 169)
    Color.BackgroundTransparency = 0
    Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Color.BorderSizePixel = 0
    Color.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Color.Image = "rbxassetid://4155801252"
    Color.Parent = ColorpickerFrame

    UICorner_48.CornerRadius = UDim.new(0, 3)
    UICorner_48.Parent = Color

    ColorSelection.Name = "ColorSelection"
    ColorSelection.ZIndex = 50
    ColorSelection.AnchorPoint = Vector2.new(0.5, 0.5)
    ColorSelection.Position = UDim2.new(0.1538461595773697, 0, 0.2151898741722107, 0)
    ColorSelection.Size = UDim2.new(0, 18, 0, 18)
    ColorSelection.BackgroundTransparency = 1
    ColorSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ColorSelection.Image = "http://www.roblox.com/asset/?id=4805639000"
    ColorSelection.ScaleType = Enum.ScaleType.Fit
    ColorSelection.Parent = Color

    Hue.Name = "Hue"
    Hue.Position = UDim2.new(0, 250, 0, 0)
    Hue.Size = UDim2.new(0, 28, 0, 170)
    Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Hue.Parent = ColorpickerFrame

    HueCorner_3.Name = "HueCorner"
    HueCorner_3.CornerRadius = UDim.new(0, 3)
    HueCorner_3.Parent = Hue

    HueGradient.Name = "HueGradient"
    -- HueGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20000000298023224, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.4000000059604645, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.6000000238418579, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.800000011920929, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.8999999761581421, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))})
    HueGradient.Rotation = 270
    HueGradient.Parent = Hue

    HueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),     -- Red
        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),   -- Yellow
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),     -- Green
        ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),   -- Cyan
        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),     -- Blue
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),   -- Magenta
        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))      -- Red
    })

    HueSelection.Name = "HueSelection"
    HueSelection.AnchorPoint = Vector2.new(0.5, 0.5)
    HueSelection.Position = UDim2.new(0.5, 0, 0, 0)
    HueSelection.Size = UDim2.new(0, 18, 0, 18)
    HueSelection.BackgroundTransparency = 1
    HueSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HueSelection.Image = "http://www.roblox.com/asset/?id=4805639000"
    HueSelection.Parent = Hue

    local ActiveColorpicker = nil
    local ColorDragging = false
    local HueDragging = false

    ColorpickerFrame.Visible = false

    local function Color3ToRGBText(ColorValue)
        local R = math.floor(ColorValue.R * 255 + 0.5)
        local G = math.floor(ColorValue.G * 255 + 0.5)
        local B = math.floor(ColorValue.B * 255 + 0.5)

        return tostring(R) .. ", " .. tostring(G) .. ", " .. tostring(B)
    end

    local function ParseColorText(Text)
        Text = tostring(Text or ""):gsub("%s+", "")

        -- HEX formats:
        -- #ff0000
        -- FF0000
        -- 0xFF0000
        local Hex = Text:match("^#?([%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F])$")
            or Text:match("^0x([%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F][%da-fA-F])$")

        if Hex then
            local R = tonumber(Hex:sub(1, 2), 16)
            local G = tonumber(Hex:sub(3, 4), 16)
            local B = tonumber(Hex:sub(5, 6), 16)

            return Color3.fromRGB(R, G, B)
        end

        -- Short HEX format:
        -- #F00
        -- F00
        local ShortHex = Text:match("^#?([%da-fA-F][%da-fA-F][%da-fA-F])$")

        if ShortHex then
            local R = tonumber(ShortHex:sub(1, 1) .. ShortHex:sub(1, 1), 16)
            local G = tonumber(ShortHex:sub(2, 2) .. ShortHex:sub(2, 2), 16)
            local B = tonumber(ShortHex:sub(3, 3) .. ShortHex:sub(3, 3), 16)

            return Color3.fromRGB(R, G, B)
        end

        -- RGB formats:
        -- rgb(255, 0, 0)
        -- 255, 0, 0
        local R, G, B = Text:match("rgb%((%d+),(%d+),(%d+)%)")

        if not R then
            R, G, B = Text:match("(%d+),(%d+),(%d+)")
        end

        if R and G and B then
            R = math.clamp(tonumber(R), 0, 255)
            G = math.clamp(tonumber(G), 0, 255)
            B = math.clamp(tonumber(B), 0, 255)

            return Color3.fromRGB(R, G, B)
        end

        return nil
    end

    local function UpdateActiveColor(ColorValue, NoCallback)
        if not ActiveColorpicker then
            return
        end

        local H, S, V = ColorValue:ToHSV()

        if S <= 0 then
            H = ActiveColorpicker.Hue or 0
        end

        ActiveColorpicker.Hue = H

        ActiveColorpicker:Set(ColorValue, NoCallback)

        Color.BackgroundTransparency = 0
        Color.BackgroundColor3 = Color3.fromHSV(H, 1, 1)

        ColorSelection.Position = UDim2.new(
            math.clamp(S, 0, 1),
            0,
            math.clamp(1 - V, 0, 1),
            0
        )

        HueSelection.Position = UDim2.new(
            0.5,
            0,
            math.clamp(1 - H, 0, 1),
            0
        )

        ColorBox.Text = Color3ToRGBText(ColorValue)
    end

    local function UpdateColorFromPicker()
        if not ActiveColorpicker then
            return
        end

        local ColorAbsPos = Color.AbsolutePosition
        local ColorAbsSize = Color.AbsoluteSize
        local Mouse = GetFixedMouseLocation()

        local ColorX = math.clamp((Mouse.X - ColorAbsPos.X) / ColorAbsSize.X, 0, 1)
        local ColorY = math.clamp((Mouse.Y - ColorAbsPos.Y) / ColorAbsSize.Y, 0, 1)

        ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)

        local H = ActiveColorpicker.Hue or 0
        local S = ColorX
        local V = 1 - ColorY

        UpdateActiveColor(Color3.fromHSV(H, S, V))
    end

    local function UpdateHueFromPicker()
        if not ActiveColorpicker then
            return
        end

        local HueAbsPos = Hue.AbsolutePosition
        local HueAbsSize = Hue.AbsoluteSize
        local Mouse = GetFixedMouseLocation()

        local HueY = math.clamp((Mouse.Y - HueAbsPos.Y) / HueAbsSize.Y, 0, 1)
        local H = 1 - HueY

        HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)

        ActiveColorpicker.Hue = H

        local _, S, V = ActiveColorpicker.Flag:ToHSV()
        local NewColor = Color3.fromHSV(H, S, V)

        Color.BackgroundColor3 = Color3.fromHSV(H, 1, 1)

        UpdateActiveColor(NewColor)
    end

    Color.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            ColorDragging = true
            UpdateColorFromPicker()
        end
    end)

    Hue.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            HueDragging = true
            UpdateHueFromPicker()
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if ColorDragging then
                UpdateColorFromPicker()
            elseif HueDragging then
                UpdateHueFromPicker()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            ColorDragging = false
            HueDragging = false
        end
    end)

    local ColorpickerOpenSize = UDim2.new(0, 282, 0, 203)
    local ColorpickerClosedSize = UDim2.new(0, 282, 0, 0)

    local function SetColorpickerChildrenTransparency(Transparency)
        for _, Object in ipairs(ColorpickerFrame:GetDescendants()) do
            if Object:IsA("TextLabel") or Object:IsA("TextBox") or Object:IsA("TextButton") then
                TweenService:Create(Object, TweenInfo.new(0.25), {
                    TextTransparency = Transparency
                }):Play()
            elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
                TweenService:Create(Object, TweenInfo.new(0.25), {
                    ImageTransparency = Transparency
                }):Play()
            elseif Object:IsA("UIStroke") then
                TweenService:Create(Object, TweenInfo.new(0.25), {
                    Transparency = Transparency
                }):Play()
            end
        end
    end

    local ColorpickerFrameTween

    function Library:TweenColorpickerFrame(Open)
        if ColorpickerFrameTween then
            ColorpickerFrameTween:Cancel()
        end

        if Open then
            ColorpickerFrame.Visible = true
            SetColorpickerChildrenTransparency(0)
        else
            SetColorpickerChildrenTransparency(1)
        end

        ColorpickerFrameTween = TweenService:Create(
            ColorpickerFrame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = Open and ColorpickerOpenSize or ColorpickerClosedSize,
                BackgroundTransparency = Open and 0 or 1
            }
        )

        ColorpickerFrameTween.Completed:Once(function()
            if not Open then
                ColorpickerFrame.Visible = false
                MainFrame.ClipsDescendants = true
            end
        end)

        ColorpickerFrameTween:Play()
    end

    local PickerTweenId = 0

    local function TweenPickerVisuals(ColorValue)
        if not ActiveColorpicker then
            return
        end

        PickerTweenId += 1
        local ThisTweenId = PickerTweenId

        local H, S, V = ColorValue:ToHSV()

        if S <= 0 then
            H = ActiveColorpicker.Hue or 0
        end

        ActiveColorpicker.Hue = H

        ColorBox.Text = Color3ToRGBText(ColorValue)

        local Finished = 0

        local function Done()
            Finished += 1

            if Finished < 3 then
                return
            end

            if ThisTweenId ~= PickerTweenId then
                return
            end

            if not ActiveColorpicker then
                return
            end

            -- Apply the actual value after the visual tween is done
            ActiveColorpicker:Set(ColorValue)
        end

        TweenItem({
            Inst = Color,
            Property = {["BackgroundColor3"]=Color3.fromHSV(H, 1, 1)},
            Time = 0.25
        }):Play():Completed(Done)

        TweenItem({
            Inst = ColorSelection,
            Property = {["Position"]=UDim2.new(
                math.clamp(S, 0, 1),
                0,
                math.clamp(1 - V, 0, 1),
                0
            )},
            Time = 0.25
        }):Play():Completed(Done)

        TweenItem({
            Inst = HueSelection,
            Property = {["Position"]=UDim2.new(
                0.5,
                0,
                math.clamp(1 - H, 0, 1),
                0
            )},
            Time = 0.25
        }):Play():Completed(Done)
    end

    ColorBox.FocusLost:Connect(function()
        local ParsedColor = ParseColorText(ColorBox.Text)

        if ParsedColor then
            TweenPickerVisuals(ParsedColor)
        else
            if ActiveColorpicker then
                ColorBox.Text = Color3ToRGBText(ActiveColorpicker.Flag)
            end
        end
    end)



    -------------------------------------------------
    ---                  Configs                  ---
    -------------------------------------------------


    local function GetFileName(Path)
        local Name = tostring(Path):match("([^/\\]+)$") or Path
        return Name:match("(.+)%.[^%.]+$") or Name
    end

    local function CheckFolder()
        if not isfolder(Library.Folders.Main) then
            makefolder(Library.Folders.Main)
        end

        if not isfolder(Library.Folders.Configs) then
            makefolder(Library.Folders.Configs)
        end

        if not isfolder(Library.Folders.Utility) then
            makefolder(Library.Folders.Utility)
        end

        return true
    end

    if not isfile(Library.Files.Version) then
        if isfolder(Library.Folders.Main) then
            delfolder(Library.Folders.Main)
            CheckFolder()
        end
        writefile(Library.Files.Version, Library.UtilityModule.Version)
    end

    local function SerializeValue(Value)
        if typeof(Value) == "Color3" then
            return {
                __type = "Color3",
                R = math.floor(Value.R * 255 + 0.5),
                G = math.floor(Value.G * 255 + 0.5),
                B = math.floor(Value.B * 255 + 0.5)
            }
        end

        if typeof(Value) == "EnumItem" then
            return {
                __type = "EnumItem",
                EnumType = tostring(Value.EnumType),
                Name = Value.Name
            }
        end
        
        if typeof(Value) == "table" then
            local NewTable = {}

            for i, v in pairs(Value) do
                local Serialized = SerializeValue(v)

                if Serialized ~= nil then
                    NewTable[i] = Serialized
                end
            end

            return NewTable
        end

        if typeof(Value) == "string" or typeof(Value) == "number" or typeof(Value) == "boolean" then
            return Value
        end

        return nil
    end

    local function DeserializeValue(Value)
        if typeof(Value) == "table" then
            if Value.__type == "Color3" then
                return Color3.fromRGB(Value.R or 255, Value.G or 255, Value.B or 255)
            end

            if Value.__type == "EnumItem" then
                local EnumTypeName = tostring(Value.EnumType or ""):gsub("^Enum%.", "")
                local EnumType = Enum[EnumTypeName]

                if EnumType and Value.Name then
                    local Success, EnumValue = pcall(function()
                        return EnumType[Value.Name]
                    end)

                    if Success and EnumValue then
                        return EnumValue
                    end
                end

                return Enum.KeyCode.Unknown
            end

            local NewTable = {}

            for i, v in pairs(Value) do
                NewTable[i] = DeserializeValue(v)
            end

            return NewTable
        end

        return Value
    end

    function Library:GetConfigs(OnlyNames)
        OnlyNames = OnlyNames or false

        local Configs = {}

        if not CheckFolder() then
            return Configs
        end

        for _, Path in pairs(listfiles(Library.Folders.Configs)) do
            if tostring(Path):match("%.cfg$") then
                table.insert(Configs, OnlyNames and GetFileName(Path) or Path)
            end
        end

        return Configs
    end

    function Library:GetConfigValue(Item)
        if not Item then
            return nil
        end

        if Item.Get then
            return Item:Get()
        end

        if Item.Value ~= nil then
            return Item.Value
        end

        if Item.Values ~= nil then
            return Item.Values
        end

        if Item.Flag ~= nil then
            return Item.Flag
        end

        if Item.Toggled ~= nil then
            return Item.Toggled
        end

        return nil
    end

    function Library:GetLibraryFlags()
        local Data = {}

        for Flag, Item in pairs(Library.Flags) do
            local ShouldSave = true

            if Item and Item.data then
                if Item.data.IgnoreConfig == true or Item.data.Save == false then
                    ShouldSave = false
                end
            end

            if ShouldSave then
                local Value = Library:GetConfigValue(Item)
                local Serialized = SerializeValue(Value)

                if Serialized ~= nil then
                    Data[Flag] = Serialized
                end
            end
        end

        return Data
    end

    function Library:Save(Name)
        if Name == nil or Name == "" then
            warn("Select a Config!")
            return
        end

        if not CheckFolder() then
            return
        end

        Name = GetFileName(Name)

        local Data = Library:GetLibraryFlags()
        local Encoded = HttpService:JSONEncode(Data)

        writefile(Library.Folders.Configs .. "/" .. Name .. ".cfg", Encoded)
        return true
    end

    function Library:Create(Name)
        if Name == nil or Name == "" then
            warn("Enter a Config Name!")
            return
        end

        if not CheckFolder() then
            return
        end

        Name = GetFileName(Name)

        local Path = Library.Folders.Configs .. "/" .. Name .. ".cfg"

        if isfile(Path) then
            warn("Config already exists:", Name)
            return false
        end

        writefile(Path, HttpService:JSONEncode({}))
        return Name
    end

    function Library:Load(Name)
        if Name == nil or Name == "" then
            warn("Select a Config!")
            return
        end

        if not CheckFolder() then
            return
        end

        Name = GetFileName(Name)

        local Path = Library.Folders.Configs .. "/" .. Name .. ".cfg"

        if not isfile(Path) then
            warn("Config does not exist:", Name)
            return
        end

        local Success, Data = pcall(function()
            return HttpService:JSONDecode(readfile(Path))
        end)

        if not Success then
            warn("Failed to decode config:", Data)
            return
        end

        for Flag, Value in pairs(Data) do
            local Item = Library.Flags[Flag]
            Value = DeserializeValue(Value)

            if Item then
                task.spawn(function()
                    local success, err = pcall(function()
                        if Item.Set then
                            Item:Set(Value)
                        else
                            warn("Flag has no Set method:", Flag)
                        end
                    end)

                    if not success then
                        warn("Failed to load flag:", Flag, err)
                    end
                end)
            else
                warn("Unknown flag in config:", Flag)
            end
        end

        return true
    end

    function Library:DeleteConfig(Name)
        if Name == nil or Name == "" then
            warn("Select a Config!")
            return
        end

        Name = GetFileName(Name)

        local Path = Library.Folders.Configs .. "/" .. Name .. ".cfg"

        if isfile(Path) then
            delfile(Path)
            return true
        end

        return false
    end







    local IsDefaulted = false
    function Window_Table:Tab(Data)
        local Tabs = {
            IsDefaultTab = IsDefaultTab
        }

        if IsDefaulted == false then
            Tabs.IsDefaultTab = true
            IsDefaulted = true
        end

        local Name = Data.Name

        local Tab = Instance.new("TextButton")
        local UICorner_38 = Instance.new("UICorner")
        local UIStroke_34 = Instance.new("UIStroke")
        local UITextSizeConstraint_31 = Instance.new("UITextSizeConstraint")

        Library:RegisterTheme(UIStroke_34, "Color", "Stroke")

        Tab.Name = "Tab"
        Tab.AnchorPoint = Vector2.new(0.5, 0.5)
        Tab.Position = UDim2.new(0.43333321809768677, 0, 0.01769467070698738, 0)
        Tab.Size = UDim2.new(0, 102, 0, 35)
        Tab.BackgroundTransparency = 0.800000011920929
        Tab.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
        Tab.BorderSizePixel = 0
        Tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Tab.Text = Name or ""
        Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        Tab.TextSize = 18
        Tab.TextScaled = false
        Tab.TextWrapped = true
        Tab.RichText = true
        Tab.Font = Enum.Font.Gotham
        Tab.AutoButtonColor = false
        Tab.Parent = TabsHolder
        Tab.TextTransparency = 0.8

        Library:RegisterTheme(Tab, "TextColor3", "Text")

        UICorner_38.CornerRadius = UDim.new(0, 3)
        UICorner_38.Parent = Tab

        UIStroke_34.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        UIStroke_34.Color = Library.Colors["Stroke"]
        UIStroke_34.Parent = Tab
        UIStroke_34.Transparency = 0.8

        UITextSizeConstraint_31.MaxTextSize = 14
        UITextSizeConstraint_31.Parent = Tab


        local Container = Instance.new("ScrollingFrame")
        local Holder1 = Instance.new("Frame")
        local UIListLayout = Instance.new("UIListLayout")
        local UIPadding = Instance.new("UIPadding")


        Container.Name = "Container"
        Container.Active = true
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
        Container.BorderSizePixel = 0
        Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Container.ScrollBarThickness = 5
        Container.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        Container.Parent = ContainerHolder
        Container.Visible = false
        Container:SetAttribute("Name", Name)

        Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Container.CanvasSize = UDim2.new(0, 0, 0, 0)

        Holder1.Name = "Holder1"
        Holder1.Position = UDim2.new(0.004999999888241291, 0, 0, 0)
        Holder1.Size = UDim2.new(0.47600001096725464, 0, 1, 0)
        Holder1.BackgroundTransparency = 1
        Holder1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Holder1.BorderSizePixel = 0
        Holder1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Holder1.Parent = Container

        -- Holder1.AutomaticCanvasSize = Enum.AutomaticSize.Y

        UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout.Padding = UDim.new(0, 10)
        UIListLayout.Parent = Holder1

        UIPadding.PaddingTop = UDim.new(0, 5)
        UIPadding.PaddingBottom = UDim.new(0, 5)
        UIPadding.Parent = Holder1

        --Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 5)

        local Holder2 = Instance.new("Frame")
        local UIListLayout_5 = Instance.new("UIListLayout")
        local UIPadding_5 = Instance.new("UIPadding")


        Holder2.Name = "Holder2"
        Holder2.Position = UDim2.new(0.5, 0, 0, 0)
        Holder2.Size = UDim2.new(0.47600001096725464, 0, 1, 0)
        Holder2.BackgroundTransparency = 1
        Holder2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Holder2.BorderSizePixel = 0
        Holder2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Holder2.Parent = Container

        -- Holder2.AutomaticCanvasSize = Enum.AutomaticSize.Y

        UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_5.Padding = UDim.new(0, 10)
        UIListLayout_5.Parent = Holder2

        UIPadding_5.PaddingTop = UDim.new(0, 5)
        UIPadding_5.PaddingBottom = UDim.new(0, 5)
        UIPadding_5.Parent = Holder2

        function ChangeTab(instance, bool)
            TweenService:Create(
                instance.UIStroke,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                {Transparency = bool and 0 or 0.8}
            ):Play()

            TweenService:Create(
                instance,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                {TextTransparency = bool and 0 or 0.8}
            ):Play()
        end

        function DisableOtherContainers()
            for i,v in pairs(ContainerHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            for i,v in pairs(TabsHolder:GetChildren()) do
                if v:IsA("TextButton") and v:FindFirstChildOfClass("UIStroke") then
                    ChangeTab(v, false)
                end
            end
        end

        if Tab_Toggled == false then
            Container.Visible = true
            Tab_Toggled = true
            ChangeTab(Tab, true)
        end
        
        Tab.MouseButton1Click:Connect(function()
            DisableOtherContainers()
            Container.Visible = true
            ChangeTab(Tab, true)
        end)

        function Tabs:Section(Data)

            local Section_Table = {
                SectionToggled = false,
                Value = false,
                Default = Tabs.IsDefaultTab
            }

            local Name = Data.Name or "Remember A Title!"
            local Side = Data.Side
            local SectionFlag = Name

            local Section = Instance.new("Frame")
            local UIStroke = Instance.new("UIStroke")
            Library:RegisterTheme(UIStroke, "Color", "Stroke")
            local UICorner = Instance.new("UICorner")
            local UIListLayout_2 = Instance.new("UIListLayout")
            local _0SectionFront = Instance.new("Frame")
            local UIListLayout_3 = Instance.new("UIListLayout")
            local UIPadding_2 = Instance.new("UIPadding")
            local line1 = Instance.new("Frame")
            local SectionHolder = Instance.new("Folder")
            local SectionTitle = Instance.new("TextLabel")
            local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
            local UIPadding_3 = Instance.new("UIPadding")
            local ToggleSection = Instance.new("TextButton")
            local SectionArrow = Instance.new("ImageLabel")

            Library:RegisterTheme(SectionArrow, "ImageColor3", "Accent")


            Section.Name = "Section"
            Section.ClipsDescendants = true
            Section.Position = UDim2.new(0.039499953389167786, 0, -0.0002455072244629264, 0)
            Section.Size = UDim2.new(1, 0, 0, 0)
            Section.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Section.BorderSizePixel = 0
            Section.BorderColor3 = Color3.fromRGB(0, 0, 0)

            Library:RegisterTheme(Section, "BackgroundColor3", "Section Background")

            -- task.defer(UpdateContainerSize)

            function Section_Table:Destroy(time)
                time = time or 1
                task.spawn(function()
                    task.wait(time)
                    Section:Destroy()
                end)
            end

            if Side == 1 then
                Section.Parent = Holder1
            elseif Side == 2 then
                Section.Parent = Holder2
            else
                Section.Parent = Holder1
                print("No side chosen for "..Name)
            end

            UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            UIStroke.Color = Library.Colors["Stroke"]
            UIStroke.Parent = Section

            UICorner.CornerRadius = UDim.new(0, 3)
            UICorner.Parent = Section

            UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_2.Padding = UDim.new(0, 7)
            UIListLayout_2.Parent = Section

            _0SectionFront.Name = "0SectionFront"
            _0SectionFront.ZIndex = 30
            _0SectionFront.Size = UDim2.new(0, 221, 0, 39)
            _0SectionFront.BackgroundTransparency = 1
            _0SectionFront.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            _0SectionFront.BorderSizePixel = 0
            _0SectionFront.BorderColor3 = Color3.fromRGB(0, 0, 0)
            _0SectionFront.Parent = Section

            UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_3.Padding = UDim.new(0, 7)
            UIListLayout_3.Parent = _0SectionFront

            UIPadding_2.PaddingTop = UDim.new(0, 37)
            UIPadding_2.Parent = _0SectionFront

            line1.Name = "line1"
            line1.Position = UDim2.new(0, 0, 0.1, 0)


            line1.Size = UDim2.new(0, 222, 0, 1)
            line1.BackgroundColor3 = Library.Colors["Stroke"]
            line1.BorderSizePixel = 0
            line1.BorderColor3 = Color3.fromRGB(0, 0, 0)
            line1.Parent = _0SectionFront

            Library:RegisterTheme(line1, "BackgroundColor3", "Stroke")

            SectionHolder.Name = "SectionHolder"
            SectionHolder.Parent = Section

            SectionTitle.Name = "SectionTitle"
            SectionTitle.Position = UDim2.new(1.374665714592993e-07, 0, 0, 0)
            SectionTitle.Size = UDim2.new(1, 0, 0, 35)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BorderSizePixel = 0
            SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.Text = Name
            SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.TextSize = 19
            SectionTitle.TextScaled = false
            SectionTitle.TextWrapped = true
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Font = Enum.Font.Gotham
            SectionTitle.Parent = SectionHolder

            UITextSizeConstraint.MaxTextSize = 15
            UITextSizeConstraint.Parent = SectionTitle

            UIPadding_3.PaddingLeft = UDim.new(0, 6)
            UIPadding_3.Parent = SectionTitle

            ToggleSection.Name = "ToggleSection"
            ToggleSection.Size = UDim2.new(1, 0, 0, 35)
            ToggleSection.BackgroundTransparency = 1
            ToggleSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleSection.BorderSizePixel = 0
            ToggleSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ToggleSection.Text = ""
            ToggleSection.TextColor3 = Color3.fromRGB(0, 0, 0)
            ToggleSection.TextSize = 14
            ToggleSection.Font = Enum.Font.Gotham
            ToggleSection.Parent = SectionHolder

            SectionArrow.Name = "SectionArrow"
            SectionArrow.Position = UDim2.new(0.8410000205039978, 0, 0.17000000178813934, 0)
            SectionArrow.Size = UDim2.new(0.12999999523162842, 0, 0.753227710723877, 0)
            SectionArrow.BackgroundTransparency = 1
            SectionArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionArrow.BorderSizePixel = 0
            SectionArrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionArrow.Image = "http://www.roblox.com/asset/?id=6034818372"
            SectionArrow.ImageColor3 = Color3.fromRGB(83, 116, 0)
            SectionArrow.Parent = ToggleSection
            SectionArrow.Rotation = 0


            
            local SectionScaler = AutoScaleListLayout(UIListLayout_2, {
                Axis = "Y",
                UseScale = false,
                ExtraY = 7,
                MinY = 37,
                ClosedY = 37,
                DefaultOpen = true
            })

            Section_Table.SectionScaler = SectionScaler
            Section_Table.SectionToggled = true
            Section_Table.Value = true

            SectionScaler.SetOpen(true)
            SectionArrow.Rotation = 180

            Section_Table.UpdateSize = function()
                if Section_Table.SectionScaler then
                    Section_Table.SectionScaler.Update()
                end
            end

            Section_Table.ForceUpdateSize = function()
                if Section_Table.SectionScaler then
                    if Section_Table.SectionToggled then
                        Section_Table.SectionScaler.ForceUpdate()
                    else
                        Section_Table.SectionScaler.SetOpen(false)
                    end
                end
            end

            function Section_Table:Set(value, NoCallback)
                value = value == true

                Section_Table.Value = value
                Section_Table.SectionToggled = value
                SectionScaler.SetOpen(value)

                -- task.defer(UpdateContainerSize)

                TweenItem({
                    Inst = SectionArrow,
                    Property = {["Rotation"]=value and 180 or 0}
                }):Play()

                return value
            end

            Section_Table:Set(Section_Table.Default)

            function Section_Table:Get()
                return Section_Table.SectionToggled == true
            end
            
            ToggleSection.MouseButton1Click:Connect(function()
                Section_Table.SectionToggled = not Section_Table.SectionToggled

                Section_Table:Set(Section_Table.SectionToggled)

            end)

            function Section_Table:Button(Data)
                local Button_Table = {
                    data = {}
                }
                local Name = Data.Name
                local Callback = Data.Callback

                local Button = Instance.new("TextButton")
                local UICorner_2 = Instance.new("UICorner")
                local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
                local UIStroke_2 = Instance.new("UIStroke")
                local UIStroke_3 = Instance.new("UIStroke")
                -- Library:RegisterTheme(UIStroke_2, "Color", "Stroke")
                Library:RegisterTheme(UIStroke_3, "Color", "Stroke")
                local UIScale = Instance.new("UIScale")

                UIScale.Parent = Button
                UIScale.Scale = 1
                
                Button_Table.Instance = Button

                Button.Name = "Button"
                Button.AnchorPoint = Vector2.new(0.5, 0.5)
                Button.Position = UDim2.new(0.5000001192092896, 0, 0.18620619177818298, 0)
                Button.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                Button.BackgroundColor3 = Color3.fromRGB(83, 116, 0)
                Button.BorderSizePixel = 0
                Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.TextSize = 14
                Button.TextScaled = true
                Button.TextWrapped = true
                Button.Font = Enum.Font.Gotham
                Button.AutoButtonColor = false
                Button.Parent = Section
                Button.Text = Name
                Button.BackgroundTransparency = 1
                Button:SetAttribute("Button", true)

                Library:RegisterTheme(Button, "TextColor3", "Text")
                -- Library:RegisterTheme(Button, "BackgroundColor3", "Accent")

                UICorner_2.CornerRadius = UDim.new(0, 3)
                UICorner_2.Parent = Button

                UITextSizeConstraint_2.MaxTextSize = 12
                UITextSizeConstraint_2.Parent = Button

                UIStroke_2.Parent = Button

                UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_3.Color = Library.Colors["Stroke"]
                UIStroke_3.Parent = Button
                local Button_Pressed = false
                Button.MouseButton1Click:Connect(function()
                    spawn(function()
                        Button_Pressed = true
                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundTransparency"]=0},
                        }):Play()

                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundColor3"]=Button_Table.data.CustomColor or Library.Colors.Accent},
                        }):Play()

                        TweenItem({
                            Inst = UIScale,
                            Property = {["Scale"]=0.9},
                        }):Play()
                        task.wait(0.1)
                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundTransparency"]=0.8},
                        }):Play()
                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundColor3"]=Library.Colors.Background},
                        }):Play()
                        TweenItem({
                            Inst = UIScale,
                            Property = {["Scale"]=1},
                        }):Play()
                        Button_Pressed = false
                    end)
                    local success, err = pcall(function()
                        return Callback()
                    end)
                    
                    if not success and Button_Table.data.ErrorHandling then
                        warn(Name.." | "..err)
                    end
                end)

                Button.MouseEnter:Connect(function()
                    if not Button_Pressed then
                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundTransparency"]=0.5},
                        }):Play()

                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundColor3"]=Button_Table.data.CustomColor or Library.Colors.Accent},
                        }):Play()
                    end
                end)

                Button.MouseLeave:Connect(function()
                    if not Button_Pressed then
                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundTransparency"]=0.8},
                        }):Play()

                        TweenItem({
                            Inst = Button,
                            Property = {["BackgroundColor3"]=Library.Colors.Background},
                        }):Play()
                    end
                end)

                spawn(function()
                    task.wait(0.2)
                    if Button_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = Button,
                            ToolTip = ToolTip,
                            Text = Button_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end

                    Library:ChangeParent(Button_Table.data.Parent, Button)

                end)

                
                return Button_Table
            end

            function Section_Table:Toggle(Data)
                local Toggle_Table = {
                    data = {},
                    Flag = false,
                    Toggled = false,
                    Value = false,
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local Default = Data.Default or false
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end
                
                local Toggle = Instance.new("TextButton")
                local UICorner_15 = Instance.new("UICorner")
                local ToggleTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_13 = Instance.new("UITextSizeConstraint")
                local ToggleFrame = Instance.new("Frame")
                local UICorner_16 = Instance.new("UICorner")
                local UIStroke_15 = Instance.new("UIStroke")
                Library:RegisterTheme(UIStroke_15, "Color", "Stroke")

                Toggle_Table.Instance = Toggle

                Toggle.Name = "Toggle"
                Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
                Toggle.Position = UDim2.new(0.5000001192092896, 0, 0.9234643578529358, 0)
                Toggle.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                Toggle.BackgroundTransparency = 0.800000011920929
                Toggle.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Toggle.BorderSizePixel = 0
                Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Toggle.Text = ""
                Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
                Toggle.TextSize = 14
                Toggle.Font = Enum.Font.Gotham
                Toggle.AutoButtonColor = false
                Toggle.Parent = Section

                UICorner_15.CornerRadius = UDim.new(0, 3)
                UICorner_15.Parent = Toggle

                ToggleTitle.Name = "ToggleTitle"
                ToggleTitle.Position = UDim2.new(0.02707098238170147, 0, 0, 0)
                ToggleTitle.Size = UDim2.new(0.9729290008544922, 0, 0.9999999403953552, 0)
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleTitle.BorderSizePixel = 0
                ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ToggleTitle.Text = Name
                ToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleTitle.TextSize = 14
                ToggleTitle.TextScaled = true
                ToggleTitle.TextWrapped = true
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.Font = Enum.Font.Gotham
                ToggleTitle.Parent = Toggle

                UITextSizeConstraint_13.MaxTextSize = 12
                UITextSizeConstraint_13.Parent = ToggleTitle

                ToggleFrame.Name = "ToggleFrame"
                ToggleFrame.Position = UDim2.new(0.8533824682235718, 0, 0.285, 0)
                ToggleFrame.Size = UDim2.new(0.0720, 0, 0.450, 0)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(83, 116, 0)
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ToggleFrame.Parent = Toggle

                Library:RegisterTheme(ToggleFrame, "BackgroundColor3", "Accent")

                UICorner_16.CornerRadius = UDim.new(0, 2)
                UICorner_16.Parent = ToggleFrame

                UIStroke_15.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_15.Color = Library.Colors["Stroke"]
                UIStroke_15.Parent = Toggle

                local ToggleFrameUIStroke = Instance.new("UIStroke")
                Library:RegisterTheme(ToggleFrameUIStroke, "Color", "Stroke")
                ToggleFrameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ToggleFrameUIStroke.Color = Library.Colors["Stroke"]
                ToggleFrameUIStroke.Parent = ToggleFrame
                ToggleFrameUIStroke.Transparency = 0.5

                function Toggle_Table:Set(value, NoCallback)
                    value = value == true

                    Toggle_Table.Toggled = value
                    Toggle_Table.Value = value
                    Toggle_Table.Flag = value

                    TweenItem({
                        Inst = ToggleFrame,
                        Property = {["BackgroundTransparency"]=value and 0 or 1},
                    }):Play()

                    TweenItem({
                        Inst = ToggleFrameUIStroke,
                        Property = {["Transparency"]=value and 1 or 0.5},
                    }):Play()

                    if not NoCallback then
                        local success, err = pcall(function()
                            return Callback(value)
                        end)

                        if not success and Toggle_Table.data.ErrorHandling then
                            warn(Name.." | "..err)
                        end
                    end

                    return value
                end

                function Toggle_Table:Get()
                    return Toggle_Table.Toggled == true
                end
                
                Toggle.MouseButton1Click:Connect(function()
                    Toggle_Table.Toggled = not Toggle_Table.Toggled
                    Toggle_Table:Set(Toggle_Table.Toggled)
                end)

                Toggle.MouseEnter:Connect(function()
                    TweenItem({
                        Inst = ToggleFrame,
                        Property = {["BackgroundTransparency"]=0.5},
                    }):Play()
                end)

                Toggle.MouseLeave:Connect(function()
                    TweenItem({
                        Inst = ToggleFrame,
                        Property = {["BackgroundTransparency"]=Toggle_Table.Toggled and 0 or 1},
                    }):Play()
                end)

                spawn(function()
                    task.wait(0.5)
                    if Toggle_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = Toggle,
                            ToolTip = ToolTip,
                            Text = Toggle_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end
                    Library:ChangeParent(Toggle_Table.data.Parent, Toggle)
                end)

                Toggle_Table:Set(Default)

                Library.Flags[Flag] = Toggle_Table
                return Toggle_Table
            end

            function Section_Table:Dropdown(Data)
                local Dropdown_Table = {
                    data = {},
                    Flag = false,
                    Toggled = false,
                    Values = {},
                    Value = nil,
                    Items = {}
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local List = Data.List or {}
                local Multi = Data.Multi or false
                local Default = Data.Default
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end

                local ClosedHeight = Dropdown_Table.data.ClosedHeight or 28
                local ItemHeight = Dropdown_Table.data.ItemHeight or 24
                local ItemPadding = Dropdown_Table.data.ItemPadding or 4
                local SearchHeight = Dropdown_Table.data.SearchHeight or 34
                local MaxDropdownHeight = Dropdown_Table.data.MaxDropdownHeight or 170
                local ExtraDropdownPadding = Dropdown_Table.data.ExtraDropdownPadding or 8

                local SectionDropdownHolder = Instance.new("Frame")
                local Dropdown = Instance.new("TextButton")
                local UICorner = Instance.new("UICorner")
                local DropdownTitle = Instance.new("TextLabel")
                local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
                local Arrow = Instance.new("ImageLabel")
                local UIStroke = Instance.new("UIStroke")
                local DropdownFrame = Instance.new("Frame")
                local UICorner_2 = Instance.new("UICorner")
                local UIStroke_2 = Instance.new("UIStroke")
                local DropdownHolder = Instance.new("ScrollingFrame")
                local UIListLayout = Instance.new("UIListLayout")

                Library:RegisterTheme(UIStroke, "Color", "Stroke")
                Library:RegisterTheme(UIStroke_2, "Color", "Stroke")

                Dropdown_Table.Instance = SectionDropdownHolder

                local DropdownFrameFolder = Instance.new("Folder")
                local SearchBox = Instance.new("TextBox")
                local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
                local DropdownFrameline = Instance.new("Frame")
                local UIListLayout_2 = Instance.new("UIListLayout")

                SectionDropdownHolder.Name = "SectionDropdownHolder"
                SectionDropdownHolder.Position = UDim2.new(0, 0, 0, 0)
                SectionDropdownHolder.Size = UDim2.new(1, 0, 0, ClosedHeight + 3)
                SectionDropdownHolder.BackgroundTransparency = 1
                SectionDropdownHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SectionDropdownHolder.BorderSizePixel = 0
                SectionDropdownHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SectionDropdownHolder.Parent = Section
                SectionDropdownHolder.ClipsDescendants = true

                Dropdown.Name = "Dropdown"
                Dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
                Dropdown.Position = UDim2.new(0.5000001192092896, 0, 0.37682804465293884, 0)
                Dropdown.Size = UDim2.new(0.9, 0, 0, 28)
                Dropdown.BackgroundTransparency = 0.800000011920929
                Dropdown.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Dropdown.BorderSizePixel = 0
                Dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Dropdown.Text = ""
                Dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
                Dropdown.TextSize = 14
                Dropdown.Font = Enum.Font.Gotham
                Dropdown.AutoButtonColor = false
                Dropdown.Parent = SectionDropdownHolder

                UICorner.CornerRadius = UDim.new(0, 3)
                UICorner.Parent = Dropdown

                DropdownTitle.Name = "DropdownTitle"
                DropdownTitle.Position = UDim2.new(0.02707098238170147, 0, 0, 0)
                DropdownTitle.Size = UDim2.new(0.9, 0, 0.9999999403953552, 0)
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownTitle.BorderSizePixel = 0
                DropdownTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                DropdownTitle.Text = "Dropdown"
                DropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                DropdownTitle.TextSize = 14
                DropdownTitle.TextScaled = true
                DropdownTitle.TextWrapped = true
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.Font = Enum.Font.Gotham
                DropdownTitle.Parent = Dropdown
                DropdownTitle.TextTruncate = Enum.TextTruncate.AtEnd

                UITextSizeConstraint.MaxTextSize = 12
                UITextSizeConstraint.Parent = DropdownTitle

                Arrow.Name = "Arrow"
                Arrow.Position = UDim2.new(0.8558599352836609, 0, 0.1923079788684845, 0)
                Arrow.Size = UDim2.new(0, 18, 0, 17)
                Arrow.BackgroundTransparency = 1
                Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Arrow.BorderSizePixel = 0
                Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Arrow.Image = "http://www.roblox.com/asset/?id=6034818372"
                Arrow.ImageColor3 = Color3.fromRGB(83, 116, 0)
                Arrow.Parent = Dropdown

                Library:RegisterTheme(Arrow, "ImageColor3", "Accent")

                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke.Color = Library.Colors["Stroke"]
                UIStroke.Parent = Dropdown

                DropdownFrame.Name = "DropdownFrame"
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                DropdownFrame.Position = UDim2.new(0.5, 0, 4.354587554931641, 0)
                DropdownFrame.Size = UDim2.new(1, 0, 6.20917272567749, 0)
                DropdownFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                DropdownFrame.Parent = Dropdown

                UICorner_2.CornerRadius = UDim.new(0, 3)
                UICorner_2.Parent = DropdownFrame

                UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_2.Color = Library.Colors["Stroke"]
                UIStroke_2.Parent = DropdownFrame

                DropdownHolder.Name = "DropdownHolder"
                DropdownHolder.Active = true
                DropdownHolder.Position = UDim2.new(0, 0, 0.17593073844909668, 0)
                DropdownHolder.Size = UDim2.new(1, 0, 0.8241788148880005, 0)
                DropdownHolder.BackgroundTransparency = 1
                DropdownHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownHolder.BorderSizePixel = 0
                DropdownHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
                DropdownHolder.ScrollBarThickness = 6
                DropdownHolder.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
                DropdownHolder.Parent = DropdownFrame

                DropdownHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
                DropdownHolder.CanvasSize = UDim2.new(0, 0, 0, 0)

                local UIPadding = Instance.new("UIPadding")
                UIPadding.PaddingTop = UDim.new(0, 2)
                UIPadding.PaddingBottom = UDim.new(0, 20)
                UIPadding.Parent = DropdownHolder

                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.Padding = UDim.new(0, 4)
                UIListLayout.Parent = DropdownHolder

                DropdownFrameFolder.Name = "DropdownFrameFolder"
                DropdownFrameFolder.Parent = DropdownFrame

                SearchBox.Name = "SearchBox"
                SearchBox.Size = UDim2.new(0, 171, 0, 27)
                SearchBox.BackgroundTransparency = 1
                SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.BorderSizePixel = 0
                SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SearchBox.Text = ""
                SearchBox.PlaceholderText = "Search"
                SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SearchBox.TextSize = 14
                SearchBox.TextScaled = true
                SearchBox.TextWrapped = true
                SearchBox.Font = Enum.Font.Gotham
                SearchBox.CursorPosition = -1
                SearchBox.Parent = DropdownFrameFolder

                UITextSizeConstraint_2.MaxTextSize = 17
                UITextSizeConstraint_2.Parent = SearchBox

                DropdownFrameline.Name = "DropdownFrameline"
                DropdownFrameline.Position = UDim2.new(0, 0, 0.14574386179447174, 0)
                DropdownFrameline.Size = UDim2.new(1, 0, 0, 1)
                DropdownFrameline.BackgroundColor3 = Library.Colors["Stroke"]
                DropdownFrameline.BorderSizePixel = 0
                DropdownFrameline.BorderColor3 = Color3.fromRGB(0, 0, 0)
                DropdownFrameline.Parent = DropdownFrameFolder

                Library:RegisterTheme(DropdownFrameline, "BackgroundColor3", "Stroke")

                UIListLayout_2.Parent = SectionDropdownHolder
                UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
                UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

                local UIPadding = Instance.new("UIPadding")
                UIPadding.PaddingTop = UDim.new(0, 2)
                UIPadding.PaddingRight = UDim.new(0, 1)
                UIPadding.PaddingBottom = UDim.new(0, 10)
                UIPadding.Parent = SectionDropdownHolder

                function Dropdown_Table:SearchFunction(key)
                    local SkipAnimation = false
                    local TotalItems = DropdownHolder:GetChildren()
                    if #TotalItems > 200 then
                        SkipAnimation = true
                    end
                    for i,v in pairs(TotalItems) do
                        if v:IsA("TextButton") then
                            local Text = v.Text:lower()
                            if string.find(Text, string.lower(key)) then
                                v.Visible = true
                                if not SkipAnimation then
                                    TweenItem({
                                        Inst = v.UIStroke,
                                        Property = {["Transparency"]=0},
                                    }):Play()

                                    if v:FindFirstChild("ToggleItemFrame") then
                                        TweenItem({
                                            Inst = v.ToggleItemFrame.UIStroke,
                                            Property = {["Transparency"]=0},
                                        }):Play()

                                        TweenItem({
                                            Inst = v.ToggleItemFrame,
                                            Property = {["BackgroundTransparency"]=v:GetAttribute("Enabled") and 0 or 1},
                                        }):Play()
                                    end

                                    TweenItem({
                                        Inst = v,
                                        Property = {["TextTransparency"]=0},
                                    }):Play()

                                    TweenItem({
                                        Inst = v,
                                        Property = {["Size"]=UDim2.new(0.920, 0, 0, 24)},
                                    }):Play()
                                end
                                task.wait(0.005)
                                -- spawn(function()
                                --     repeat task.wait() until v.Size == UDim2.new(0.920, 0, 0, 24)
                                --     task.wait(0.1)
                                -- end)
                            else
                                if not SkipAnimation then
                                    TweenItem({
                                        Inst = v.UIStroke,
                                        Property = {["Transparency"]=1},
                                        Time = 0.1,
                                    }):Play()

                                    if v:FindFirstChild("ToggleItemFrame") then
                                        TweenItem({
                                            Inst = v.ToggleItemFrame.UIStroke,
                                            Property = {["Transparency"]=1},
                                            Time = 0.1,
                                        }):Play()

                                        TweenItem({
                                            Inst = v.ToggleItemFrame,
                                            Property = {["BackgroundTransparency"]=1},
                                            Time = 0.1,
                                        }):Play()
                                    end
                                    
                                    TweenItem({
                                        Inst = v,
                                        Property = {["TextTransparency"]=1},
                                        Time = 0.1,
                                    }):Play()

                                    TweenItem({
                                        Inst = v,
                                        Property = {["Size"]=UDim2.new(0.920, 0, 0, -4)},
                                    }):Play()
                                    
                                    task.wait(0.005)
                                    spawn(function()
                                        repeat task.wait() until v.Size == UDim2.new(0.920, 0, 0, -4)
                                        v.Visible = false
                                    end)
                                else
                                    task.wait(0.005)
                                    v.Visible = false
                                end
                            end
                        end
                    end
                end
                
                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    Dropdown_Table:SearchFunction(SearchBox.Text)
                end)

                local function GetDropdownOpenHeight()
                    local ContentHeight = UIListLayout.AbsoluteContentSize.Y + 12
                    local HolderHeight = math.clamp(ContentHeight, 0, MaxDropdownHeight)
                    local FrameHeight = SearchHeight + 1 + HolderHeight

                    return FrameHeight, HolderHeight, ContentHeight
                end

                local function GetArrayFromMap(Map)
                    local Array = {}

                    for Value, Enabled in pairs(Map) do
                        if Enabled then
                            table.insert(Array, Value)
                        end
                    end

                    return Array
                end

                local function UpdateTitle()
                    local FullTitle

                    if Multi then
                        local Selected = GetArrayFromMap(Dropdown_Table.Values)

                        if #Selected == 0 then
                            FullTitle = Name
                        else
                            FullTitle = Name .. " - " .. table.concat(Selected, ", ")
                        end
                    else
                        if Dropdown_Table.Value then
                            FullTitle = Name .. " - " .. tostring(Dropdown_Table.Value)
                        else
                            FullTitle = Name
                        end
                    end

                    local MaxWidth = DropdownTitle.AbsoluteSize.X
                    local TextHeight = DropdownTitle.AbsoluteSize.Y

                    local TextSize = TextService:GetTextSize(
                        FullTitle,
                        DropdownTitle.TextSize,
                        DropdownTitle.Font,
                        Vector2.new(math.huge, TextHeight)
                    )

                    DropdownTitle.Text = FullTitle
                    DropdownTitle.TextWrapped = false

                    if TextSize.X > MaxWidth then
                        DropdownTitle.TextTruncate = Enum.TextTruncate.AtEnd
                        Dropdown_Table.data.ValueToolTip = FullTitle
                    else
                        DropdownTitle.TextTruncate = Enum.TextTruncate.None
                        Dropdown_Table.data.ValueToolTip = nil
                    end
                end

                local function FireCallback(Value)
                    local success, err = pcall(function()
                        Callback(Value)
                    end)

                    if not success then
                        warn(Name .. " | " .. err)
                    end
                end

                local function SetItemVisual(ItemData, Enabled)
                    if not ItemData then
                        return
                    end

                    if ItemData.Type == "Multi" then
                        TweenItem({
                            Inst = ItemData.CheckFrame,
                            Property = {["BackgroundTransparency"]=Enabled and 0 or 1},
                        }):Play()

                        TweenItem({
                            Inst = ItemData.CheckStroke,
                            Property = {["Transparency"]=Enabled and 1 or 0.5},
                        }):Play()
                    else
                        TweenItem({
                            Inst = ItemData.Button,
                            Property = {["BackgroundTransparency"]=Enabled and 0.4 or 1},
                        }):Play()
                    end
                end

                Dropdown.MouseButton1Click:Connect(function()
                    local FrameHeight, HolderHeight, ContentHeight = GetDropdownOpenHeight()
                    Dropdown_Table.Toggled = not Dropdown_Table.Toggled
                    -- DropdownHolder.CanvasSize = UDim2.new(0, 0, 0, ContentHeight + 10)

                    TweenItem({
                        Inst = SectionDropdownHolder,
                        Property = {
                                ["Size"]=Dropdown_Table.Toggled and UDim2.new(
                                1,
                                0,
                                0,
                                215
                            ) or UDim2.new(
                                1,
                                0,
                                0,
                                ClosedHeight + 3
                            )
                        },
                        Time = 0.3,
                    }):Play()

                    TweenItem({
                        Inst = Arrow,
                        Property = {["Rotation"]=Dropdown_Table.Toggled and 180 or 0},
                        Time = 0.3,
                    }):Play()

                    Section_Table.ForceUpdateSize()

                end)


                task.spawn(function()
                    task.wait(0.5)

                    local OriginalToolTip = Dropdown_Table.data.ToolTip or ""

                    Dropdown_Table.data.OriginalToolTip = OriginalToolTip
                    Dropdown_Table.data.ValueToolTip = nil

                    CreateToolTip({
                        HoverObject = Dropdown,
                        ToolTip = ToolTip,
                        Text = function()
                            local Original = Dropdown_Table.data.OriginalToolTip
                            local Values = Dropdown_Table.data.ValueToolTip

                            if Original and Original ~= "" and Values and Values ~= "" then
                                local Final = Original .. "  |" .. Values
                                return Final:gsub(Name, ""):gsub("-", "")
                            end

                            if Original and Original ~= "" then
                                return Original
                            end

                            if Values and Values ~= "" then
                                return Values:gsub(Name, "")
                            end

                            return nil
                        end,
                        PaddingX = 10,
                        Height = 20,
                        OffsetX = 5,
                        OffsetY = 15
                    })

                    Library:ChangeParent(Dropdown_Table.data.Parent, SectionDropdownHolder)
                end)


                function Dropdown_Table:Get()
                    if Multi then
                        return GetArrayFromMap(Dropdown_Table.Values)
                    else
                        return Dropdown_Table.Value
                    end
                end

                function Dropdown_Table:Set(Value, NoCallback)
                    if Multi then
                        table.clear(Dropdown_Table.Values)

                        if typeof(Value) == "table" then
                            for _, ItemValue in ipairs(Value) do
                                Dropdown_Table.Values[ItemValue] = true
                            end
                        else
                            Dropdown_Table.Values[Value] = true
                        end

                        for ItemValue, ItemData in pairs(Dropdown_Table.Items) do
                            SetItemVisual(ItemData, Dropdown_Table.Values[ItemValue] == true)
                        end

                        UpdateTitle()

                        if not NoCallback then
                            FireCallback(Dropdown_Table:Get())
                        end
                    else
                        Dropdown_Table.Value = Value

                        for ItemValue, ItemData in pairs(Dropdown_Table.Items) do
                            SetItemVisual(ItemData, ItemValue == Value)
                        end

                        UpdateTitle()

                        if not NoCallback then
                            FireCallback(Value)
                        end
                    end
                end

                function Dropdown_Table:Clear(NoCallback)
                    if Multi then
                        table.clear(Dropdown_Table.Values)
                    else
                        Dropdown_Table.Value = nil
                    end

                    for _, ItemData in pairs(Dropdown_Table.Items) do
                        SetItemVisual(ItemData, false)
                    end

                    UpdateTitle()

                    if not NoCallback then
                        FireCallback(Dropdown_Table:Get())
                    end
                end
                
                function Dropdown_Table:MakeItem(text)
                    if Multi then
                        local ItemToggled = false
                        local ToggleItem = Instance.new("TextButton")
                        local UICorner_4 = Instance.new("UICorner")
                        local ToggleItemFrame = Instance.new("Frame")
                        local UICorner_5 = Instance.new("UICorner")
                        local UIStroke_4 = Instance.new("UIStroke")
                        Library:RegisterTheme(UIStroke_4, "Color", "Stroke")


                        ToggleItem.Name = "ToggleItem"
                        ToggleItem.Position = UDim2.new(0.05000000074505806, 0, 0.0829104632139206, 0)
                        ToggleItem.Size = UDim2.new(0.9200000166893005, 0, 0, 24)
                        ToggleItem.BackgroundTransparency = 1
                        ToggleItem.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
                        ToggleItem.BorderSizePixel = 0
                        ToggleItem.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        ToggleItem.Text = text
                        ToggleItem.TextColor3 = Color3.fromRGB(255, 255, 255)
                        ToggleItem.TextSize = 12
                        ToggleItem.Font = Enum.Font.Gotham
                        ToggleItem.AutoButtonColor = false
                        ToggleItem.Parent = DropdownHolder
                        ToggleItem.ClipsDescendants = true

                        UICorner_4.CornerRadius = UDim.new(0, 3)
                        UICorner_4.Parent = ToggleItem

                        ToggleItemFrame.Name = "ToggleItemFrame"
                        ToggleItemFrame.Position = UDim2.new(0.9062783122062683, 0, 0.307692289352417, 0)
                        ToggleItemFrame.Size = UDim2.new(0.058, 0, 0.38461536169052124, 0)
                        ToggleItemFrame.BackgroundColor3 = Color3.fromRGB(83, 116, 0)
                        ToggleItemFrame.BorderSizePixel = 0
                        ToggleItemFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        ToggleItemFrame.Parent = ToggleItem
                        ToggleItemFrame.BackgroundTransparency = 1

                        Library:RegisterTheme(ToggleItemFrame, "BackgroundColor3", "Accent")

                        UICorner_5.CornerRadius = UDim.new(0, 2)
                        UICorner_5.Parent = ToggleItemFrame

                        UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        UIStroke_4.Color = Library.Colors["Stroke"]
                        UIStroke_4.Parent = ToggleItem

                        local ToggleFrameUIStroke = Instance.new("UIStroke")
                        Library:RegisterTheme(ToggleFrameUIStroke, "Color", "Stroke")
                        ToggleFrameUIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        ToggleFrameUIStroke.Color = Library.Colors["Stroke"]
                        ToggleFrameUIStroke.Parent = ToggleItemFrame
                        ToggleFrameUIStroke.Transparency = 0.5

                        ToggleItem.MouseButton1Click:Connect(function()
                            Dropdown_Table.Values[text] = not Dropdown_Table.Values[text]
                            ItemToggled = Dropdown_Table.Values[text] == true

                            Dropdown_Table.Items[text].Button:SetAttribute("Enabled", ItemToggled)

                            SetItemVisual(Dropdown_Table.Items[text], ItemToggled)
                            UpdateTitle()
                            FireCallback(Dropdown_Table:Get())
                        end)

                        ToggleItem.MouseEnter:Connect(function()
                            TweenItem({
                                Inst = ToggleItemFrame,
                                Property = {["BackgroundTransparency"]=0.5},
                            }):Play()
                        end)

                        ToggleItem.MouseLeave:Connect(function()
                            TweenItem({
                                Inst = ToggleItemFrame,
                                Property = {["BackgroundTransparency"]=ItemToggled and 0 or 1},
                            }):Play()
                        end)


                        Dropdown_Table.Items[text] = {
                            Type = "Multi",
                            Button = ToggleItem,
                            CheckFrame = ToggleItemFrame,
                            CheckStroke = ToggleFrameUIStroke
                        }
                    else
                        local NormalItem = Instance.new("TextButton")
                        local UICorner_3 = Instance.new("UICorner")
                        local UIStroke_3 = Instance.new("UIStroke")
                        Library:RegisterTheme(UIStroke_3, "Color", "Stroke")

                        NormalItem.Name = "NormalItem"
                        NormalItem.Position = UDim2.new(0.05000000074505806, 0, 0, 0)
                        NormalItem.Size = UDim2.new(0.9200000166893005, 0, 0, 24)
                        NormalItem.BackgroundTransparency = 1
                        NormalItem.BackgroundColor3 = Color3.fromRGB(83, 116, 0)
                        NormalItem.BorderSizePixel = 0
                        NormalItem.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        NormalItem.Text = text
                        NormalItem.TextColor3 = Color3.fromRGB(255, 255, 255)
                        NormalItem.TextSize = 12
                        NormalItem.Font = Enum.Font.Gotham
                        NormalItem.AutoButtonColor = false
                        NormalItem.Parent = DropdownHolder
                        NormalItem.BackgroundTransparency = 1
                        NormalItem.ClipsDescendants = true

                        UICorner_3.CornerRadius = UDim.new(0, 3)
                        UICorner_3.Parent = NormalItem

                        UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        UIStroke_3.Color = Library.Colors["Stroke"]
                        UIStroke_3.Parent = NormalItem

                        local UIPadding = Instance.new("UIPadding")
                        UIPadding.PaddingTop = UDim.new(0, 5)
                        UIPadding.PaddingBottom = UDim.new(0, 5)
                        UIPadding.Parent = DropdownHolder

                        local UIScale = Instance.new("UIScale")
                        UIScale.Parent = NormalItem
                        UIScale.Scale = 1

                        Dropdown_Table.Items[text] = {
                            Type = "Single",
                            Button = NormalItem
                        }

                        local NormalItem_Pressed = false
                        NormalItem.MouseButton1Click:Connect(function()
                            Dropdown_Table:Set(text)

                            Dropdown_Table.Toggled = false

                            TweenItem({
                                Inst = SectionDropdownHolder,
                                Property = {["Size"]=UDim2.new(1, 0, 0, ClosedHeight + 3)},
                                Time = 0.3,
                            }):Play()

                            TweenItem({
                                Inst = Arrow,
                                Property = {["Rotation"]=0},
                                Time = 0.3,
                            }):Play()

                            if Section_Table.ForceUpdateSize then
                                Section_Table.ForceUpdateSize()
                            end

                            spawn(function()
                                NormalItem_Pressed = true

                                TweenItem({
                                    Inst = NormalItem,
                                    Property = {["BackgroundTransparency"]=0},
                                }):Play()

                                TweenItem({
                                    Inst = UIScale,
                                    Property = {["Scale"]=0.9},
                                }):Play()

                                task.wait(0.1)

                                TweenItem({
                                    Inst = NormalItem,
                                    Property = {["BackgroundTransparency"]=Dropdown_Table.Value == text and 0.4 or 1},
                                }):Play()

                                TweenItem({
                                    Inst = UIScale,
                                    Property = {["Scale"]=1},
                                }):Play()

                                NormalItem_Pressed = false
                            end)
                        end)

                        NormalItem.MouseEnter:Connect(function()
                            if not NormalItem_Pressed then
                                TweenItem({
                                    Inst = NormalItem,
                                    Property = {["BackgroundTransparency"]=0.5},
                                    Value = 0.5
                                }):Play()
                            end
                        end)

                        NormalItem.MouseLeave:Connect(function()
                            if not NormalItem_Pressed then
                                TweenItem({
                                    Inst = NormalItem,
                                    Property = {["BackgroundTransparency"]=1},
                                }):Play()
                            end
                        end)

                    end
                end

                function Dropdown_Table:Refresh(NewList)

                    for i, v in next, DropdownHolder:GetChildren() do
                        if v:IsA("TextButton") then
                            v:Destroy()
                        end
                    end

                    -- Dropdown_Table.Items = {}
                    -- Dropdown_Table.Values = {}
                    -- Dropdown_Table.Value = nil
                    -- Dropdown_Table.Toggled = false

                    SearchBox.Text = ""
                    
                    task.spawn(function()
                        for i, v in pairs(NewList) do
                            Dropdown_Table:MakeItem(v)
                            task.wait(0.005)
                        end
                    end)
                    
                    -- UpdateTitle()

                    if Section_Table.ForceUpdateSize then
                        task.defer(Section_Table.ForceUpdateSize)
                    end
                end

                task.spawn(function()
                    for i, v in pairs(List) do
                        Dropdown_Table:MakeItem(v)
                        task.wait(0.005)
                    end
                end)

                if Default ~= nil then
                    Dropdown_Table:Set(Default, true)
                else
                    UpdateTitle()
                end

                Library.Flags[Flag] = Dropdown_Table
                return Dropdown_Table
            end


            function Section_Table:Slider(Data)
                local Slider_Table = {
                    data = {},
                    Flag = 0,
                    Value = 0,
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local Min = Data.Min or 1
                local Max = Data.Max or 100
                local Start = Data.Start or 10
                local Suffix = Data.Suffix or ""
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end

                local Slider = Instance.new("TextButton")
                local UICorner_12 = Instance.new("UICorner")
                local SliderTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_10 = Instance.new("UITextSizeConstraint")
                local SliderFrame = Instance.new("Frame")
                local SliderFrameIndicator = Instance.new("Frame")
                local UICorner_13 = Instance.new("UICorner")
                local UIStroke_12 = Instance.new("UIStroke")
                local UICorner_14 = Instance.new("UICorner")
                local ValueVisual = Instance.new("TextLabel")
                local UITextSizeConstraint_11 = Instance.new("UITextSizeConstraint")
                local UIStroke_13 = Instance.new("UIStroke")
                local UIStroke_14 = Instance.new("UIStroke")
                local SliderInputBox = Instance.new("TextBox")
                local UITextSizeConstraint_12 = Instance.new("UITextSizeConstraint")
                Library:RegisterTheme(UIStroke_12, "Color", "Stroke")
                -- Library:RegisterTheme(UIStroke_13, "Color", "Stroke")
                Library:RegisterTheme(UIStroke_14, "Color", "Stroke")

                Library:RegisterTheme(SliderInputBox, "TextColor3", "Text")

                Slider_Table.Instance = Slider

                Slider.Name = "Slider"
                Slider.AnchorPoint = Vector2.new(0.5, 0.5)
                Slider.Position = UDim2.new(0.5000001192092896, 0, 0.6978017091751099, 0)
                Slider.Size = UDim2.new(0.8999999761581421, 0, 0, 53)
                Slider.BackgroundTransparency = 0.800000011920929
                Slider.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Slider.BorderSizePixel = 0
                Slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Slider.Text = ""
                Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
                Slider.TextSize = 14
                Slider.Font = Enum.Font.Gotham
                Slider.AutoButtonColor = false
                Slider.Parent = Section

                UICorner_12.CornerRadius = UDim.new(0, 3)
                UICorner_12.Parent = Slider

                SliderTitle.Name = "SliderTitle"
                SliderTitle.Position = UDim2.new(0.027070926502346992, 0, 0, 0)
                SliderTitle.Size = UDim2.new(1, 0, 0.5, 0)
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderTitle.BorderSizePixel = 0
                SliderTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderTitle.Text = "Walk Speed"
                SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderTitle.TextSize = 14
                SliderTitle.TextScaled = true
                SliderTitle.TextWrapped = true
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Font = Enum.Font.Gotham
                SliderTitle.Parent = Slider

                UITextSizeConstraint_10.MaxTextSize = 12
                UITextSizeConstraint_10.Parent = SliderTitle

                SliderFrame.Name = "SliderFrame"
                SliderFrame.Position = UDim2.new(0.01899874396622181, 0, 0.5500003695487976, 0)
                SliderFrame.Size = UDim2.new(0.9447440505027771, 0, -0.0419287234544754, 20)
                SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                SliderFrame.BorderSizePixel = 0
                SliderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderFrame.Parent = Slider

                SliderFrameIndicator.Name = "SliderFrameIndicator"
                SliderFrameIndicator.Size = UDim2.new(0.5849999785423279, 0, 0, 20)
                SliderFrameIndicator.BackgroundColor3 = Color3.fromRGB(83, 116, 0)
                SliderFrameIndicator.BorderSizePixel = 0
                SliderFrameIndicator.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderFrameIndicator.Parent = SliderFrame

                Library:RegisterTheme(SliderFrameIndicator, "BackgroundColor3", "Accent")

                UICorner_13.CornerRadius = UDim.new(0, 3)
                UICorner_13.Parent = SliderFrameIndicator

                UIStroke_12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_12.Parent = SliderFrame

                UICorner_14.CornerRadius = UDim.new(0, 3)
                UICorner_14.Parent = SliderFrame

                ValueVisual.Name = "ValueVisual"
                ValueVisual.Position = UDim2.new(0.022500529885292053, 0, 0.5306124091148376, 0)
                ValueVisual.Size = UDim2.new(0.9409999847412109, 0, 0, 20)
                ValueVisual.BackgroundTransparency = 1
                ValueVisual.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ValueVisual.BorderSizePixel = 0
                ValueVisual.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ValueVisual.Text = "7/10"
                ValueVisual.TextColor3 = Color3.fromRGB(255, 255, 255)
                ValueVisual.TextSize = 14
                ValueVisual.Font = Enum.Font.Gotham
                ValueVisual.Parent = Slider

                UITextSizeConstraint_11.MaxTextSize = 12
                UITextSizeConstraint_11.Parent = ValueVisual

                UIStroke_13.Parent = ValueVisual

                UIStroke_14.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_14.Color = Library.Colors["Stroke"]
                UIStroke_14.Parent = Slider

                SliderInputBox.Name = "SliderInputBox"
                SliderInputBox.Position = UDim2.new(0.7842338681221008, 0, 0, 0)
                SliderInputBox.Size = UDim2.new(0, 28, 0, 22)
                SliderInputBox.BackgroundTransparency = 1
                SliderInputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderInputBox.BorderSizePixel = 0
                SliderInputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                SliderInputBox.Text = ""
                SliderInputBox.PlaceholderText = "7"
                SliderInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderInputBox.TextSize = 14
                SliderInputBox.TextScaled = true
                SliderInputBox.TextWrapped = true
                SliderInputBox.TextXAlignment = Enum.TextXAlignment.Right
                SliderInputBox.Font = Enum.Font.Gotham
                SliderInputBox.Parent = Slider

                UITextSizeConstraint_12.MaxTextSize = 12
                UITextSizeConstraint_12.Parent = SliderInputBox

                spawn(function()
                    task.wait(0.5)
                    if Slider_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = Slider,
                            ToolTip = ToolTip,
                            Text = Slider_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end
                    Library:ChangeParent(Slider_Table.data.Parent, Slider)
                end)

                -- Slider_Table.data.ToolTip = Data.ToolTip

                SliderTitle.Text = Name

                local Increment = Data.Increment or Data.Step or 1
                local Decimals = Data.Decimals or 0
                local Dragging = false

                local function Clamp(Value)
                    return math.clamp(Value, Min, Max)
                end

                local function RoundToIncrement(Value)
                    if Increment <= 0 then
                        return Value
                    end

                    return math.floor((Value / Increment) + 0.5) * Increment
                end

                local function FormatNumber(Value)
                    if Decimals > 0 then
                        return string.format("%." .. Decimals .. "f", Value)
                    end

                    return tostring(math.floor(Value + 0.5))
                end

                local function FormatValue(Value)
                    return FormatNumber(Value) .. tostring(Suffix)
                end

                local function ParseInput(Text)
                    Text = tostring(Text or "")
                    Text = Text:gsub("%s+", "")

                    -- Supports %, °, deg, degree, degrees
                    Text = Text:gsub("%%", "")
                    Text = Text:gsub("°", "")
                    Text = Text:gsub("[dD][eE][gG][rR][eE][eE][sS]", "")
                    Text = Text:gsub("[dD][eE][gG][rR][eE][eE]", "")
                    Text = Text:gsub("[dD][eE][gG]", "")

                    -- Also remove your custom suffix if it exists
                    if Suffix and Suffix ~= "" then
                        Text = Text:gsub(Suffix, "")
                    end

                    local Number = tonumber(Text)

                    if not Number then
                        return nil
                    end

                    return Number
                end

                local function FireCallback(Value)
                    local success, err = pcall(function()
                        Callback(Value, Slider_Table)
                    end)

                    if not success then
                        warn(Name .. " | " .. err)
                    end
                end

                local function UpdateVisual(Value)
                    local Alpha = 0

                    if Max ~= Min then
                        Alpha = (Value - Min) / (Max - Min)
                    end

                    Alpha = math.clamp(Alpha, 0, 1)

                    TweenItem({
                        Inst = SliderFrameIndicator,
                        Property = {["Size"]=UDim2.new(Alpha, 0, 1, 0)},
                        Time = 0.15,
                    }):Play()

                    ValueVisual.Text = FormatValue(Value)
                    SliderInputBox.Text = FormatValue(Value)
                    SliderInputBox.PlaceholderText = FormatValue(Value)
                end

                function Slider_Table:Set(Value, NoCallback)
                    Value = tonumber(Value)

                    if not Value then
                        Value = Min
                    end

                    Value = Clamp(Value)
                    Value = RoundToIncrement(Value)
                    Value = Clamp(Value)

                    Slider_Table.Flag = Value
                    Slider_Table.Value = Value

                    UpdateVisual(Value)

                    if not NoCallback then
                        FireCallback(Value)
                    end

                    return Value
                end

                function Slider_Table:Get()
                    return Slider_Table.Value
                end

                local function SetFromMouse()
                    local MouseLocation = UserInputService:GetMouseLocation()
                    local FramePosition = SliderFrame.AbsolutePosition
                    local FrameSize = SliderFrame.AbsoluteSize

                    local Alpha = (MouseLocation.X - FramePosition.X) / FrameSize.X
                    Alpha = math.clamp(Alpha, 0, 1)

                    local Value = Min + ((Max - Min) * Alpha)

                    Slider_Table:Set(Value)
                end

                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        SetFromMouse()
                    end
                end)

                Slider.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        SetFromMouse()
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        SetFromMouse()
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                SliderInputBox.FocusLost:Connect(function(EnterPressed)
                    local ParsedValue = ParseInput(SliderInputBox.Text)

                    if ParsedValue then
                        Slider_Table:Set(ParsedValue)
                    else
                        SliderInputBox.Text = FormatValue(Slider_Table.Value or Start)
                    end
                end)

                Slider_Table:Set(Start)

                Library.Flags[Flag] = Slider_Table
                return Slider_Table
            end

            function Section_Table:Colorpicker(Data)
                local Colorpicker_Table = {
                    data = {},
                    Flag = Color3.fromRGB(0, 0, 0),
                    Toggled = false,
                    Hue = 0,
                    Value = Color3.fromRGB(0, 0, 0),
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local Default = Data.Default or Color3.fromRGB(0, 0, 0)
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end

                local Colorpicker = Instance.new("TextButton")
                local UICorner_8 = Instance.new("UICorner")
                local ColorpickerTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_5 = Instance.new("UITextSizeConstraint")
                local UIStroke_8 = Instance.new("UIStroke")
                local PreviewColor = Instance.new("Frame")
                local HueCorner = Instance.new("UICorner")

                Library:RegisterTheme(UIStroke_8, "Color", "Stroke")

                Colorpicker_Table.Instance = Colorpicker

                Colorpicker.Name = "Colorpicker"
                Colorpicker.AnchorPoint = Vector2.new(0.5, 0.5)
                Colorpicker.Position = UDim2.new(0.5000001192092896, 0, 0.2815171480178833, 0)
                Colorpicker.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                Colorpicker.BackgroundTransparency = 0
                Colorpicker.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Colorpicker.BorderSizePixel = 0
                Colorpicker.Text = ""
                Colorpicker.TextColor3 = Color3.fromRGB(0, 0, 0)
                Colorpicker.TextSize = 14
                Colorpicker.Font = Enum.Font.Gotham
                Colorpicker.AutoButtonColor = false
                Colorpicker.Parent = Section
                Colorpicker:SetAttribute("Colorpicker", true)

                UICorner_8.CornerRadius = UDim.new(0, 3)
                UICorner_8.Parent = Colorpicker

                ColorpickerTitle.Name = "ColorpickerTitle"
                ColorpickerTitle.Position = UDim2.new(0.02707098238170147, 0, 0, 0)
                ColorpickerTitle.Size = UDim2.new(0.78, 0, 0.9999999403953552, 0)
                ColorpickerTitle.BackgroundTransparency = 1
                ColorpickerTitle.BorderSizePixel = 0
                ColorpickerTitle.Text = Name
                ColorpickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                ColorpickerTitle.TextSize = 14
                ColorpickerTitle.TextScaled = true
                ColorpickerTitle.TextWrapped = true
                ColorpickerTitle.TextXAlignment = Enum.TextXAlignment.Left
                ColorpickerTitle.Font = Enum.Font.Gotham
                ColorpickerTitle.Parent = Colorpicker

                UITextSizeConstraint_5.MaxTextSize = 12
                UITextSizeConstraint_5.Parent = ColorpickerTitle

                UIStroke_8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_8.Color = Library.Colors["Stroke"]
                UIStroke_8.Parent = Colorpicker

                PreviewColor.Name = "PreviewColor"
                PreviewColor.Position = UDim2.new(1, -32, 0.1034485399723053, 0)
                PreviewColor.Size = UDim2.new(0, 23, 0, 22)
                PreviewColor.BackgroundColor3 = Default
                PreviewColor.BorderSizePixel = 0
                PreviewColor.Parent = Colorpicker

                HueCorner.Name = "HueCorner"
                HueCorner.CornerRadius = UDim.new(0, 3)
                HueCorner.Parent = PreviewColor

                spawn(function()
                    task.wait(0.5)
                    if Colorpicker_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = Colorpicker,
                            ToolTip = ToolTip,
                            Text = Colorpicker_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end
                    Library:ChangeParent(Colorpicker_Table.data.Parent, Colorpicker)
                end)

                local function FireCallback(ColorValue)
                    local success, err = pcall(function()
                        Callback(ColorValue, Colorpicker_Table)
                    end)

                    if not success then
                        warn(Name .. " | " .. err)
                    end
                end

                local function UpdatePickerVisuals(ColorValue)
                    if not ActiveColorpicker then
                        return
                    end

                    local H, S, V = ColorValue:ToHSV()

                    if S <= 0 then
                        H = ActiveColorpicker.Hue or 0
                    end

                    ActiveColorpicker.Hue = H
                    ActiveColorpicker.Flag = ColorValue

                    PreviewColor.BackgroundColor3 = ColorValue
                    ColorBox.Text = Color3ToRGBText(ColorValue)

                    Color.BackgroundTransparency = 0
                    Color.BackgroundColor3 = Color3.fromHSV(H, 1, 1)

                    ColorSelection.Position = UDim2.new(
                        math.clamp(S, 0, 1),
                        0,
                        math.clamp(1 - V, 0, 1),
                        0
                    )

                    HueSelection.Position = UDim2.new(
                        0.5,
                        0,
                        math.clamp(1 - H, 0, 1),
                        0
                    )
                end

                function Colorpicker_Table:Set(ColorValue, NoCallback)
                    if typeof(ColorValue) ~= "Color3" then
                        ColorValue = Default
                    end

                    local H, S, V = ColorValue:ToHSV()

                    if S > 0 then
                        Colorpicker_Table.Hue = H
                    else
                        H = Colorpicker_Table.Hue or 0
                    end

                    Colorpicker_Table.Flag = ColorValue
                    Colorpicker_Table.Value = ColorValue

                    TweenItem({
                        Inst = PreviewColor,
                        Property = {["BackgroundColor3"]=ColorValue},
                        Time = 0.25
                    }):Play()

                    if ActiveColorpicker == Colorpicker_Table then
                        UpdatePickerVisuals(ColorValue)
                    end

                    if not NoCallback then
                        FireCallback(ColorValue)
                    end

                    return ColorValue
                end

                function Colorpicker_Table:Get()
                    return Colorpicker_Table.Flag
                end

                function Colorpicker_Table:Open()
                    MainFrame.ClipsDescendants = false
                    ColorpickerFrame.Visible = true
                    local WasAlreadyOpen = ColorpickerFrame.Visible and ActiveColorpicker ~= nil

                    ActiveColorpicker = Colorpicker_Table
                    Colorpicker_Table.Toggled = true

                    if WasAlreadyOpen then
                        TweenPickerVisuals(Colorpicker_Table.Flag)
                    else
                        UpdatePickerVisuals(Colorpicker_Table.Flag)
                        Library:TweenColorpickerFrame(true)
                    end
                end

                function Colorpicker_Table:Close()
                    if ActiveColorpicker == Colorpicker_Table then
                        ActiveColorpicker = nil
                    end

                    Colorpicker_Table.Toggled = false

                    Library:TweenColorpickerFrame(false)
                end

                Colorpicker.MouseButton1Click:Connect(function()
                    if ActiveColorpicker == Colorpicker_Table and ColorpickerFrame.Visible then
                        Colorpicker_Table:Close()
                    else
                        if ActiveColorpicker then
                            ActiveColorpicker.Toggled = false
                        end

                        Colorpicker_Table:Open()
                    end
                end)

                Colorpicker.MouseEnter:Connect(function()
                    TweenItem({
                        Inst = Colorpicker,
                        Property = {["BackgroundColor3"]=PreviewColor.BackgroundColor3},
                    }):Play()

                    TweenItem({
                        Inst = Colorpicker,
                        Property = {["BackgroundTransparency"]=0.5},
                    }):Play()
                end)
                
                Colorpicker.MouseLeave:Connect(function()
                    TweenItem({
                        Inst = Colorpicker,
                        Property = {["BackgroundColor3"]=Color3.fromRGB(13, 13, 13)},
                    }):Play()

                    TweenItem({
                        Inst = Colorpicker,
                        Property = {["BackgroundTransparency"]=1},
                    }):Play()
                end)

                Colorpicker_Table:Set(Default, true)

                Library.Flags[Flag] = Colorpicker_Table
                return Colorpicker_Table
            end


            function Section_Table:Input(Data)
                local Input_Table = {
                    data = {},
                    Value = "",
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local Default = Data.Default or "Input"
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end

                local Input = Instance.new("TextButton")
                local UICorner_9 = Instance.new("UICorner")
                local InputTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_6 = Instance.new("UITextSizeConstraint")
                local UIStroke_9 = Instance.new("UIStroke")
                local InputBox = Instance.new("TextBox")
                local UITextSizeConstraint_7 = Instance.new("UITextSizeConstraint")

                Library:RegisterTheme(UIStroke_9, "Color", "Stroke")

                local function FireCallback(Value)
                    local success, err = pcall(function()
                        Callback(Value, Input_Table)
                    end)

                    if not success then
                        warn(Name .. " | " .. err)
                    end
                end

                function Input_Table:Set(TextValue, NoCallback)
                    TextValue = tostring(TextValue or "")

                    InputBox.Text = TextValue
                    Input_Table.Value = TextValue
                    Input_Table.Flag = TextValue

                    if not NoCallback then
                        FireCallback(TextValue)
                    end
                    
                    return TextValue
                end

                function Input_Table:Get()
                    return Input_Table.Value or ""
                end

                Input_Table.Instance = Input

                Input.Name = "Input"
                Input.Position = UDim2.new(0.02008502557873726, 0, 0.4342949688434601, 0)
                Input.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                Input.BackgroundTransparency = 0.800000011920929
                Input.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Input.BorderSizePixel = 0
                Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Input.Text = ""
                Input.TextColor3 = Color3.fromRGB(0, 0, 0)
                Input.TextSize = 14
                Input.Font = Enum.Font.Gotham
                Input.AutoButtonColor = false
                Input.Parent = Section

                UICorner_9.CornerRadius = UDim.new(0, 3)
                UICorner_9.Parent = Input

                InputTitle.Name = "InputTitle"
                InputTitle.Position = UDim2.new(0.027070874348282814, 0, 0, 0)
                InputTitle.Size = UDim2.new(1, 0, 1, 0)
                InputTitle.BackgroundTransparency = 1
                InputTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputTitle.BorderSizePixel = 0
                InputTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputTitle.Text = Name
                InputTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputTitle.TextSize = 14
                InputTitle.TextScaled = true
                InputTitle.TextWrapped = true
                InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                InputTitle.Font = Enum.Font.Gotham
                InputTitle.Parent = Input

                UITextSizeConstraint_6.MaxTextSize = 12
                UITextSizeConstraint_6.Parent = InputTitle

                UIStroke_9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_9.Color = Library.Colors["Stroke"]
                UIStroke_9.Parent = Input

                InputBox.Name = "InputBox"
                InputBox.Position = UDim2.new(0.48, 0, 0, 3)
                InputBox.Size = UDim2.new(0.5, 0, 0, 23)
                InputBox.BackgroundTransparency = 1
                InputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.BorderSizePixel = 0
                InputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
                InputBox.Text = ""
                InputBox.PlaceholderText = Default
                InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                InputBox.TextSize = 14
                InputBox.TextScaled = true
                InputBox.TextWrapped = true
                InputBox.Font = Enum.Font.Gotham
                InputBox.Parent = Input

                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(0, 3)
                UICorner.Parent = InputBox

                local UIStroke = Instance.new("UIStroke")
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke.Color = Library.Colors["Stroke"]
                UIStroke.Parent = InputBox

                Library:RegisterTheme(UIStroke, "Color", "Stroke")

                UITextSizeConstraint_7.MaxTextSize = 12
                UITextSizeConstraint_7.Parent = InputBox

                spawn(function()
                    task.wait(0.5)
                    if Input_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = Input,
                            ToolTip = ToolTip,
                            Text = Input_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end
                    Library:ChangeParent(Input_Table.data.Parent, Input)
                end)

                InputBox.FocusLost:Connect(function(ep)
                    Input_Table:Set(InputBox.Text)
                end)

                Input_Table:Set(Default, true)

                Library.Flags[Flag] = Input_Table
                return Input_Table
            end


            function Section_Table:Keybind(Data)
                local Keybind_Table = {
                    data = {},
                    Flag = Enum.KeyCode.A,
                    Value = false,
                    Toggled = false,
                    Hue = 0
                }

                local Name = Data.Name or "Remember A Name!"
                local Flag = Data.Flag or Name
                local Default = Data.Default or "Input"
                local Callback = Data.Callback or function()
                    print("Remember a function!")
                end

                local KeyBind = Instance.new("TextButton")
                local UICorner_10 = Instance.new("UICorner")
                local KeybindTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_8 = Instance.new("UITextSizeConstraint")
                local UIStroke_10 = Instance.new("UIStroke")
                local KeyText = Instance.new("TextLabel")
                local UITextSizeConstraint_9 = Instance.new("UITextSizeConstraint")
                local UIStroke_11 = Instance.new("UIStroke")
                local UICorner_11 = Instance.new("UICorner")

                Library:RegisterTheme(UIStroke_10, "Color", "Stroke")
                Library:RegisterTheme(UIStroke_11, "Color", "Stroke")

                Keybind_Table.Instance = KeyBind

                KeyBind.Name = "KeyBind"
                KeyBind.AnchorPoint = Vector2.new(0.5, 0.5)
                KeyBind.Position = UDim2.new(0.5000001192092896, 0, 0.5674500465393066, 0)
                KeyBind.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                KeyBind.BackgroundTransparency = 0.800000011920929
                KeyBind.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                KeyBind.BorderSizePixel = 0
                KeyBind.BorderColor3 = Color3.fromRGB(0, 0, 0)
                KeyBind.Text = ""
                KeyBind.TextColor3 = Color3.fromRGB(0, 0, 0)
                KeyBind.TextSize = 14
                KeyBind.Font = Enum.Font.Gotham
                KeyBind.AutoButtonColor = false
                KeyBind.Parent = Section

                UICorner_10.CornerRadius = UDim.new(0, 3)
                UICorner_10.Parent = KeyBind

                KeybindTitle.Name = "KeybindTitle"
                KeybindTitle.Position = UDim2.new(0.02707098238170147, 0, 0, 0)
                KeybindTitle.Size = UDim2.new(0.9729290008544922, 0, 0.9999999403953552, 0)
                KeybindTitle.BackgroundTransparency = 1
                KeybindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                KeybindTitle.BorderSizePixel = 0
                KeybindTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                KeybindTitle.Text = Name
                KeybindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeybindTitle.TextSize = 14
                KeybindTitle.TextScaled = true
                KeybindTitle.TextWrapped = true
                KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
                KeybindTitle.Font = Enum.Font.Gotham
                KeybindTitle.Parent = KeyBind

                UITextSizeConstraint_8.MaxTextSize = 12
                UITextSizeConstraint_8.Parent = KeybindTitle

                UIStroke_10.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_10.Color = Library.Colors["Stroke"]
                UIStroke_10.Parent = KeyBind

                KeyText.Name = "KeyText"
                KeyText.Position = UDim2.new(0.5307619571685791, 0, 0.1034485399723053, 0)
                KeyText.Size = UDim2.new(0.4320000112056732, 0, 0.800000011920929, 0)
                KeyText.BackgroundTransparency = 1
                KeyText.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                KeyText.BorderSizePixel = 0
                KeyText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                KeyText.Text = "LeftControl"
                KeyText.TextColor3 = Color3.fromRGB(255, 255, 255)
                KeyText.TextSize = 14
                KeyText.TextScaled = true
                KeyText.TextWrapped = true
                KeyText.Font = Enum.Font.Gotham
                KeyText.Parent = KeyBind

                UITextSizeConstraint_9.MaxTextSize = 12
                UITextSizeConstraint_9.Parent = KeyText

                UIStroke_11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_11.Color = Library.Colors["Stroke"]
                UIStroke_11.Parent = KeyText

                UICorner_11.CornerRadius = UDim.new(0, 3)
                UICorner_11.Parent = KeyText

                task.spawn(function()
                    task.wait(0.5)

                    if Keybind_Table.data.ToolTip then
                        CreateToolTip({
                            HoverObject = KeyBind,
                            ToolTip = ToolTip,
                            Text = Keybind_Table.data.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end
                    Library:ChangeParent(Keybind_Table.data.Parent, KeyBind)
                end)

                local Listening = false
                local CurrentKey = nil
                local State = false

                local Mode = Data.Mode or Data.Type or "Toggle"
                Mode = tostring(Mode):lower()

                local function KeyToText(Key)
                    if typeof(Key) == "EnumItem" then
                        return Key.Name
                    end

                    return tostring(Key)
                end

                local function FireCallback(Value)
                    State = Value
                    Keybind_Table.Value = Value
                    Keybind_Table.Toggled = Value

                    local success, err = pcall(function()
                        Callback(Value, Keybind_Table)
                    end)

                    if not success and Keybind_Table.data.ErrorHandling then
                        warn(Name .. " | " .. err)
                    end
                end

                function Keybind_Table:Set(Key, NoCallback)
                    if typeof(Key) == "string" then
                        local FoundKey = Enum.KeyCode[Key]

                        if FoundKey then
                            Key = FoundKey
                        else
                            Key = Enum.KeyCode.Unknown
                        end
                    end

                    if typeof(Key) ~= "EnumItem" then
                        Key = Enum.KeyCode.Unknown
                    end

                    CurrentKey = Key
                    Keybind_Table.Flag = Key

                    if Key == Enum.KeyCode.Unknown then
                        KeyText.Text = "Press to bind"
                    else
                        KeyText.Text = KeyToText(Key)
                    end

                    return Key
                end

                function Keybind_Table:Get()
                    return CurrentKey
                end

                function Keybind_Table:GetValue()
                    return State
                end

                function Keybind_Table:SetValue(Value, NoCallback)
                    Value = Value == true

                    if State == Value then
                        return Value
                    end

                    if NoCallback then
                        State = Value
                        Keybind_Table.Value = Value
                        Keybind_Table.Toggled = Value
                    else
                        FireCallback(Value)
                    end

                    return Value
                end

                function Keybind_Table:SetMode(NewMode)
                    NewMode = tostring(NewMode or "Toggle"):lower()

                    if NewMode ~= "toggle" and NewMode ~= "hold" then
                        NewMode = "toggle"
                    end

                    Mode = NewMode
                end

                function Keybind_Table:GetMode()
                    return Mode
                end

                function Keybind_Table:Listen()
                    Listening = true
                    KeyText.Text = "Listening..."
                end

                function Keybind_Table:Cancel()
                    Listening = false

                    if CurrentKey and CurrentKey ~= Enum.KeyCode.Unknown then
                        KeyText.Text = KeyToText(CurrentKey)
                    else
                        KeyText.Text = "Press to bind"
                    end
                end

                KeyBind.MouseButton1Click:Connect(function()
                    Keybind_Table:Listen()
                end)

                UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                    if GameProcessed then
                        return
                    end

                    if Listening then
                        if Input.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        if Input.KeyCode == Enum.KeyCode.Escape then
                            Listening = false
                            CurrentKey = Enum.KeyCode.Unknown
                            Keybind_Table.Flag = Enum.KeyCode.Unknown
                            KeyText.Text = "Press to bind"
                            return
                        end

                        Listening = false
                        Keybind_Table:Set(Input.KeyCode, true)
                        return
                    end

                    if not CurrentKey or CurrentKey == Enum.KeyCode.Unknown then
                        return
                    end

                    if Input.KeyCode ~= CurrentKey then
                        return
                    end

                    if Mode == "hold" then
                        if not State then
                            FireCallback(true)
                        end
                    else
                        FireCallback(not State)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input, GameProcessed)
                    if not CurrentKey or CurrentKey == Enum.KeyCode.Unknown then
                        return
                    end

                    if Input.KeyCode ~= CurrentKey then
                        return
                    end

                    if Mode == "hold" then
                        if State then
                            FireCallback(false)
                        end
                    end
                end)


                Keybind_Table:Set(Default, true)

                Library.Flags[Flag] = Keybind_Table

                return Keybind_Table
            end

            function Section_Table:Text(Data)
                local Text_Table = {}

                local InternalData = {
                    Properties = {},
                    AutoSize = Data.AutoSize or false,
                    ToolTip = Data.ToolTip,

                    PaddingTop = Data.PaddingTop or 5,
                    PaddingBottom = Data.PaddingBottom or 5,
                    PaddingLeft = Data.PaddingLeft or 5,
                    PaddingRight = Data.PaddingRight or 5,
                }

                local Name = Data.Name or "Remember A Name!"

                local Text = Instance.new("TextButton")
                local UICorner_17 = Instance.new("UICorner")
                local TextTitle = Instance.new("TextLabel")
                local UITextSizeConstraint_14 = Instance.new("UITextSizeConstraint")
                local UIStroke_16 = Instance.new("UIStroke")
                Library:RegisterTheme(UIStroke_16, "Color", "Stroke")

                Text_Table.Instance = Text
                
                Text.Name = "Text"
                Text.AnchorPoint = Vector2.new(0.5, 0.5)
                Text.Position = UDim2.new(0.5000001192092896, 0, 0.8281535506248474, 0)
                Text.Size = UDim2.new(0.8999999761581421, 0, 0, 28)
                Text.BackgroundTransparency = 0.800000011920929
                Text.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
                Text.BorderSizePixel = 0
                Text.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Text.Text = ""
                Text.TextColor3 = Color3.fromRGB(0, 0, 0)
                Text.TextSize = 14
                Text.Font = Enum.Font.Gotham
                Text.AutoButtonColor = false
                Text.Parent = Section

                UICorner_17.CornerRadius = UDim.new(0, 3)
                UICorner_17.Parent = Text

                TextTitle.Name = "TextTitle"
                TextTitle.Size = UDim2.new(1, 0, 1, 0)
                TextTitle.BackgroundTransparency = 1
                TextTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextTitle.BorderSizePixel = 0
                TextTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextTitle.Text = Name
                TextTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextTitle.TextSize = 14
                TextTitle.TextScaled = not InternalData.AutoSize
                TextTitle.TextWrapped = true
                TextTitle.RichText = true
                TextTitle.Font = Enum.Font.Gotham
                TextTitle.Parent = Text

                UITextSizeConstraint_14.MaxTextSize = 12
                UITextSizeConstraint_14.Parent = TextTitle

                UIStroke_16.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                UIStroke_16.Color = Library.Colors["Stroke"]
                UIStroke_16.Parent = Text


                local UIPadding = Instance.new("UIPadding")
                UIPadding.Parent = TextTitle

                InternalData.AutoSize = Data.AutoSize or false
                InternalData.PaddingTop = Data.PaddingTop or 5
                InternalData.PaddingBottom = Data.PaddingBottom or 5
                InternalData.PaddingLeft = Data.PaddingLeft or 5
                InternalData.PaddingRight = Data.PaddingRight or 5

                local MinHeight = Data.MinHeight or 28
                local MaxHeight = Data.MaxHeight or math.huge
                local AutoSizeTweenTime = Data.AutoSizeTweenTime or 0.35

                local function GetPaddingHeight()
                    return InternalData.PaddingTop + InternalData.PaddingBottom
                end

                local function GetPaddingWidth()
                    return InternalData.PaddingLeft + InternalData.PaddingRight
                end

                local AutoSizeQueued = false
                local CurrentSizeTween

                local function AutoSizeText(Instant)
                    if not InternalData.AutoSize then
                        return
                    end

                    if AutoSizeQueued then
                        return
                    end

                    AutoSizeQueued = true

                    task.defer(function()
                        AutoSizeQueued = false

                        RunService.RenderStepped:Wait()

                        local AvailableWidth = Text.AbsoluteSize.X - GetPaddingWidth()

                        if AvailableWidth <= 0 then
                            return
                        end

                        TextTitle.TextScaled = false
                        TextTitle.TextWrapped = true

                        local TextBounds = TextService:GetTextSize(
                            TextTitle.Text,
                            TextTitle.TextSize,
                            TextTitle.Font,
                            Vector2.new(AvailableWidth, math.huge)
                        )

                        local WantedHeight = math.clamp(
                            TextBounds.Y + GetPaddingHeight(),
                            MinHeight,
                            MaxHeight
                        )

                        local TargetSize = UDim2.new(
                            Text.Size.X.Scale,
                            Text.Size.X.Offset,
                            0,
                            WantedHeight
                        )

                        if CurrentSizeTween then
                            CurrentSizeTween:Cancel()
                        end

                        if Instant then
                            Text.Size = TargetSize
                        else
                            CurrentSizeTween = TweenService:Create(
                                Text,
                                TweenInfo.new(AutoSizeTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                {
                                    Size = TargetSize
                                }
                            )

                            CurrentSizeTween:Play()
                        end

                        if Section_Table.ForceUpdateSize then
                            task.delay(AutoSizeTweenTime + 0.05, function()
                                Section_Table.ForceUpdateSize()
                            end)
                        end
                    end)
                end

                function Text_Table:Refresh(text)
                    TextTitle.Text = text
                    AutoSizeText(false)
                end

                function Text_Table:UpdateProperties(options)
                    options = options or {}

                    local ShouldAutoSize = false

                    for i, v in pairs(options) do
                        if i == "Size" then
                            if not InternalData.AutoSize then
                                TweenItem({
                                    Inst = Text,
                                    Property = {["Size"]=UDim2.new(0.8999999761581421, 0, 0, v > 28 and v or 28)},
                                }):Play()
                            end

                        elseif i == "AutoSize" then
                            InternalData.AutoSize = v
                            TextTitle.TextScaled = not v
                            TextTitle.TextWrapped = true
                            ShouldAutoSize = true

                        elseif i == "PaddingTop" then
                            InternalData.PaddingTop = v
                            UIPadding.PaddingTop = UDim.new(0, v)
                            ShouldAutoSize = true

                        elseif i == "PaddingBottom" then
                            InternalData.PaddingBottom = v
                            UIPadding.PaddingBottom = UDim.new(0, v)
                            ShouldAutoSize = true

                        elseif i == "PaddingLeft" then
                            InternalData.PaddingLeft = v
                            UIPadding.PaddingLeft = UDim.new(0, v)
                            ShouldAutoSize = true

                        elseif i == "PaddingRight" then
                            InternalData.PaddingRight = v
                            UIPadding.PaddingRight = UDim.new(0, v)
                            ShouldAutoSize = true

                        else
                            TextTitle[i] = v
                            ShouldAutoSize = true
                        end
                    end

                    if ShouldAutoSize then
                        AutoSizeText(false)
                    end
                end

                local function ApplyData(NewData)
                    NewData = NewData or {}

                    for Index, Value in pairs(NewData) do
                        if Index == "Properties" then
                            InternalData.Properties = Value or {}
                        else
                            InternalData[Index] = Value
                        end
                    end

                    Text_Table:UpdateProperties(InternalData.Properties)

                    if InternalData.AutoSize then
                        TextTitle.TextScaled = false
                        TextTitle.TextWrapped = true
                        AutoSizeText()
                    end
                end

                setmetatable(Text_Table, {
                    __index = function(_, Index)
                        if Index == "data" then
                            return InternalData
                        end
                    end,

                    __newindex = function(_, Index, Value)
                        if Index == "data" then
                            ApplyData(Value)
                        else
                            rawset(Text_Table, Index, Value)
                        end
                    end
                })

                ApplyData(Data)
                AutoSizeText(true)

                
                UIPadding.PaddingTop = UDim.new(0, InternalData.PaddingTop)
                UIPadding.PaddingBottom = UDim.new(0, InternalData.PaddingBottom)
                UIPadding.PaddingRight = UDim.new(0, InternalData.PaddingRight)
                UIPadding.PaddingLeft = UDim.new(0, InternalData.PaddingLeft)

                task.defer(function()
                    Text_Table:UpdateProperties(InternalData.Properties)
                    AutoSizeText(true)
                end)

                spawn(function()
                    task.wait(0.5)
                    if InternalData.ToolTip then
                        CreateToolTip({
                            HoverObject = Text,
                            ToolTip = ToolTip,
                            Text = InternalData.ToolTip,
                            PaddingX = 10,
                            Height = 20,
                            OffsetX = 5,
                            OffsetY = 15
                        })
                    end

                    Library:ChangeParent(Text_Table.data.Parent, Text)
                end)


                return Text_Table
            end

            Library.Flags[SectionFlag] = Section_Table

            return Section_Table
        end

        return Tabs
    end

    task.spawn(function() -- Load TextColor3 Theme
        task.wait(0.4)
        for i,v in pairs(MainFrame:GetDescendants()) do
            if v:IsA("TextLabel") then
                Library:RegisterTheme(v, "TextColor3", "Text")
            end
        end
    end)

    task.spawn(function() -- Load Section Items Theme
        task.wait(0.5)
        for i,v in pairs(ContainerHolder:GetDescendants()) do
            if v:IsA("TextButton") and not v:GetAttribute("Colorpicker") then -- and not v:GetAttribute("Button")
                Library:RegisterTheme(v, "BackgroundColor3", "Background")
            end
        end
    end)

    function Library:MakeSettings(Tab)

        local ThemeSection = Tab:Section({
            Name = "Theme",
            Side = 2
        })

        for i,v in pairs(Library.Colors) do
            ThemeSection:Colorpicker({
                Name = i,
                Flag = "Theme"..i,
                Default = v,
                Callback = function(Color)
                    Library:SetColor(i, Color)
                end
            }).data = {
                ToolTip = "Change the "..i.." Color"
            }
        end

        local SettingsSection = Tab:Section({
            Name = "Settings",
            Side = 2
        })
        
        SettingsSection:Keybind({
            Name = "Toggle UI",
            Flag = "Key bind for GUI",
            Default = Enum.KeyCode.RightControl,
            Callback = function(Key)
                -- Library:SetOpen(not Key) -- Make A smoother opening sequence
                Globals["UITOGGLED"] = not Globals["UITOGGLED"]
                Library:ToggleUI(Globals["UITOGGLED"])
            end
        }).data = {
            ToolTip = "Bind a key to open the GUI",
            Parent = "Settings"
        }

        SettingsSection:Button({
            Name = "Discord",
            Callback = function()
                setclipboard("https://discord.gg/2r3jVkhHMk")
                Library.UtilityModule:Discord("2r3jVkhHMk")
            end
        }).data = {
            ToolTip = "Coppies Discord Server invite!",
            CustomColor = Color3.fromRGB(114,137,218),
            Parent = "Settings"
        }

        SettingsSection:Toggle({
            Name = "UI Button",
            Flag = "UI Button",
            Default = true,
            Callback = function(t)
                Library:ToggleButton(t)
            end
        }).data = {
            ToolTip = "Toggles a GUI Button",
            CustomColor = Color3.fromRGB(114,137,218),
            Parent = "Settings"
        }

        SettingsSection:Text({
            Name = "Credits: Mana"
        }).data = {
            ToolTip = "Creator of the Script & GUI",
            Parent = "Settings"
        }

        SettingsSection:Destroy(5)

        local ConfigsSection = Tab:Section({
            Name = "Configs",
            Side = 1
        })

        local ConfigDropdown = ConfigsSection:Dropdown({
            Name = "Select Config",
            Flag = "Config Select Dropdown",
            List = Library:GetConfigs(true),
            Multi = false,
            Callback = function(t)
                SelectedConfig = t
            end
        })
        ConfigDropdown.data.IgnoreConfig = true

        ConfigsSection:Button({
            Name = "Load Config",
            Callback = function()
                Library:Load(SelectedConfig)
            end
        }).data = {
            IgnoreConfig = true
        }

        ConfigsSection:Button({
            Name = "Save Config",
            Callback = function()
                if Library:Save(SelectedConfig) then
                    ConfigDropdown:Refresh(Library:GetConfigs(true))
                end
            end
        }).data = {
            IgnoreConfig = true
        }

        local CreateConfigSection = Tab:Section({
            Name = "Create Config",
            Side = 1
        })

        local ConfigNameInput = CreateConfigSection:Input({
            Name = "Config Name",
            Flag = "Config Name Input",
            Default = "",
            Callback = function(Text)
                if Text and Text ~= "" then
                    NewConfigName = Text
                end
            end
        })
        ConfigNameInput.data.IgnoreConfig = true

        CreateConfigSection:Button({
            Name = "Create Config",
            Callback = function()
                local CreatedName = Library:Create(NewConfigName)

                if CreatedName then

                    if ConfigDropdown and ConfigDropdown.Set then
                        ConfigDropdown:Set(CreatedName, false)
                    end

                    ConfigDropdown:Refresh(Library:GetConfigs(true))

                    SelectedConfig = CreatedName
                    ConfigNameInput:Set("", true)
                    NewConfigName = nil
                end
            end
        }).data = {
            IgnoreConfig = true
        }


        local DeleteConfigsSection = Tab:Section({
            Name = "Delete Config",
            Side = 1
        })

        DeleteConfigDropdown = DeleteConfigsSection:Dropdown({
            Name = "Select Config",
            Flag = "Delete Config",
            List = Library:GetConfigs(true),
            Multi = false,
            Callback = function(t)
                SelectedDeleteConfig = t
            end
        })

        DeleteConfigDropdown.data.IgnoreConfig = true

        DeleteConfigsSection:Button({
            Name = "Delete Config",
            Callback = function()
                if Library:DeleteConfig(SelectedDeleteConfig) then
                    if SelectedDeleteConfig == SelectedConfig then
                        ConfigDropdown:Set("", false)
                    end
                    SelectedDeleteConfig = nil
                    ConfigDropdown:Refresh(Library:GetConfigs(true))
                    DeleteConfigDropdown:Refresh(Library:GetConfigs(true))
                    DeleteConfigDropdown:Set("", false)
                end
            end
        }).data = {
            IgnoreConfig = true
        }




    end

    return Window_Table
end




function Example()

    local Window = Library:Window({
        Name = "Qyrix",
        GameName = "Kick A Lucky Block"
    })

    local Autofarm = Window:Tab({
        Name = "Autofarm"
    })

    local Misc = Window:Tab({
        Name = "Misc"
    })

    local Settings = Window:Tab({
        Name = "Settings"
    })

    Library:MakeSettings(Settings)

    local Farming_Section = Autofarm:Section({
        Name = "Autofarm",
        Side = 1
    })

    local Farming2_Section = Autofarm:Section({
        Name = "Misc",
        Side = 2
    })

    local Giant_Table = {"Hi", "Apple", "Orange", "d", "HALSDSLA", "NahBro","Hi", "Apple", "Orange", "d", "HALSDSLA", "NahBro","Hi", "Apple", "Orange", "d", "HALSDSLA", "NahBro","Hi", "Apple", "Orange", "d", "HALSDSLA", "NahBro","Hi", "Apple", "Orange", "d", "HALSDSLA", "NahBro",}
    for i,v in pairs(game.CoreGui:GetChildren()) do
        table.insert(Giant_Table, v.Name)
    end

    Farming_Section:Dropdown({
        Name = "Ping",
        Flag = "Hi",
        List = Giant_Table,
        Multi = true,
        Callback = function(test)
            print("Hai | "..tostring(test))
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Select An Item!"
    }

    Farming_Section:Button({
        Name = "Ping",
        Callback = function()
            print("Pong")
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Prints Pong inside the console"
    }

    Farming_Section:Input({
        Name = "Key",
        Flag = "Key", 
        Default = "Paste Key Here!",
        Callback = function(key)
            print(key)
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Prints Pong inside the console"
    }

    Farming_Section:Slider({
        Name = "Angle",
        Flag = "Angle",
        Min = 0,
        Max = 360,
        Start = 90,
        Suffix = "%",
        Increment = 1,
        Callback = function(Value)
            print("Angle:", Value)
        end
    }).data = {
        ToolTip = "Select the Angel you want your character to face."
    }

    Farming_Section:Toggle({
        Name = "Ping",
        Flag = "Hi",
        Default = false,
        Callback = function(test)
            print("Pong | "..tostring(test))
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Enable Autofarm Brainrots"
    }

    Farming2_Section:Button({
        Name = "Pong",
        Callback = function()
            print("Ping")
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Prints Ping inside the console"
    }

    Farming2_Section:Button({
        Name = "splat",
        Callback = function()
            print("split")
        end
    }).data = {
        ErrorHandling = true,
        ToolTip = "Prints split inside the console"
    }

    Farming2_Section:Keybind({
        Name = "Toggle UI",
        Flag = "ToggleUI",
        Default = Enum.KeyCode.LeftControl,
        Callback = function(Key)
            print("Pressed or changed:", Key.Name)
        end
    }).data = {
        ToolTip = "Bind a key to open the GUI"
    }



    Farming2_Section:Text({
        Name = "Hello world!"
    }).data = {
        Properties = {
            TextXAlignment = Enum.TextXAlignment.Left, -- "Left", "Right", "Center"
            TextYAlignment = Enum.TextYAlignment.Top, -- "Top", "Center", "Bottom
        },
        AutoSize = true,
        PaddingTop = 5,
        PaddingRight = 5,
        PaddingLeft = 5,
        PaddingBottom = 5,
    }

    local Nah_Section = Misc:Section({
        Name = "Nah",
        Side = 1
    })

    local MyText = Nah_Section:Text({
        Name = "This is a long text that should automatically make the text box taller when it wraps onto multiple lines.",
    })


    MyText.data = {
        AutoSize = true,
        PaddingLeft = 8,
        PaddingRight = 8,

        Properties = {
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        }
    }


    local Hallo = Nah_Section:Toggle({
        Name = "Change Text",
        Default = false,
        Callback = function(t)
            if t then
                MyText:Refresh("This is a long text that \n should automatically \n\n\n\n make the text box \n taller when it wraps onto \n multiple lines.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nHello world!")
            else
                MyText:Refresh("This is a long text that should automatically make the text box taller when it wraps onto multiple lines.")
            end
        end
    })

end

--Example()

return Library
