-- Generated with Readable GUI Dumper V11

--local MainParent = game.CoreGui
local MainParent = game.Players.LocalPlayer.PlayerGui


--// Locals \\--
local Potassium_Internal = Instance.new("ScreenGui")
local Intro = Instance.new("ImageLabel")
local UICorner = Instance.new("UICorner")
local InfoText = Instance.new("TextLabel")
local MainFrame = Instance.new("ImageButton")
local UICorner_2 = Instance.new("UICorner")
local CodingHolder = Instance.new("Frame")
local Settings = Instance.new("Frame")
local SaveFile = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local UIListLayout = Instance.new("UIListLayout")
local Execute = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")
local UIStroke_2 = Instance.new("UIStroke")
local Clear = Instance.new("TextButton")
local UICorner_5 = Instance.new("UICorner")
local UIStroke_3 = Instance.new("UIStroke")
local OpenFile = Instance.new("TextButton")
local UICorner_6 = Instance.new("UICorner")
local UIStroke_4 = Instance.new("UIStroke")
local Settings_2 = Instance.new("ImageButton")
local UICorner_7 = Instance.new("UICorner")
local Console = Instance.new("ImageButton")
local UICorner_8 = Instance.new("UICorner")
local EditorScroll = Instance.new("ScrollingFrame")
local EditorContent = Instance.new("Frame")
local Gutter = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local HighlightBar = Instance.new("Frame")
local Display = Instance.new("TextLabel")
local UIPadding = Instance.new("UIPadding")
local Input = Instance.new("TextBox")
local UICorner_9 = Instance.new("UICorner")
local UIPadding_2 = Instance.new("UIPadding")
local Pynt = Instance.new("Frame")
local UIStroke_5 = Instance.new("UIStroke")
local UICorner_10 = Instance.new("UICorner")
local Settings_3 = Instance.new("Frame")
local Holder = Instance.new("Frame")
local UIPadding_3 = Instance.new("UIPadding")
local UIListLayout_3 = Instance.new("UIListLayout")
local Close = Instance.new("ImageButton")
local Templates = Instance.new("Folder")
local Template = Instance.new("TextButton")
local UICorner_11 = Instance.new("UICorner")
local UIStroke_6 = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")
local UICorner_12 = Instance.new("UICorner")
local WaterDrop = Instance.new("ImageLabel")
local UICorner_13 = Instance.new("UICorner")
local UIScale = Instance.new("UIScale")
local Console_2 = Instance.new("ImageButton")
local UICorner_14 = Instance.new("UICorner")
local ConsoleHolder = Instance.new("Frame")
local Display_2 = Instance.new("TextLabel")
local UIPadding_4 = Instance.new("UIPadding")
local Settings_4 = Instance.new("Frame")
local Clear_2 = Instance.new("TextButton")
local UICorner_15 = Instance.new("UICorner")
local UIStroke_7 = Instance.new("UIStroke")
local UIListLayout_4 = Instance.new("UIListLayout")
local AutoScroll = Instance.new("TextButton")
local UICorner_16 = Instance.new("UICorner")
local UIStroke_8 = Instance.new("UIStroke")
local TextLabel = Instance.new("TextLabel")
local ImageLabel_2 = Instance.new("ImageLabel")
local UICorner_17 = Instance.new("UICorner")
local LogCount = Instance.new("TextButton")
local UICorner_18 = Instance.new("UICorner")
local UIStroke_9 = Instance.new("UIStroke")
local Close_2 = Instance.new("TextButton")
local UICorner_19 = Instance.new("UICorner")
local UIStroke_10 = Instance.new("UIStroke")
local LogsFrame = Instance.new("Frame")
local UICorner_20 = Instance.new("UICorner")
local UIStroke_11 = Instance.new("UIStroke")
local Holder_2 = Instance.new("ScrollingFrame")
local UIListLayout_5 = Instance.new("UIListLayout")
local UIPadding_5 = Instance.new("UIPadding")
local Templates_2 = Instance.new("Folder")
local Log = Instance.new("TextButton")

--// Properties and Parents \\--
-- StarterGui.Potassium_Internal
Potassium_Internal.Name = "Potassium_Internal"
Potassium_Internal.AutoLocalize = false
Potassium_Internal.IgnoreGuiInset = true
Potassium_Internal.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Potassium_Internal.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
Potassium_Internal.ScreenInsets = Enum.ScreenInsets.None
Potassium_Internal.Parent = MainParent

-- StarterGui.Potassium_Internal.Intro
Intro.Name = "Intro"
Intro.Visible = false
Intro.ZIndex = 500
Intro.AnchorPoint = Vector2.new(0.5, 0.5)
Intro.Position = UDim2.new(0.5, 0, 0.4000000059604645, 0)
Intro.Size = UDim2.new(0.10877881944179535, 0, 0.219419926404953, 0)
Intro.BackgroundTransparency = 0.75
Intro.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Intro.BorderSizePixel = 0
Intro.BorderColor3 = Color3.fromRGB(0, 0, 0)
Intro.Image = "rbxassetid://88583720555565"
Intro.ImageTransparency = 0.550000011920929
Intro.Parent = Potassium_Internal

-- StarterGui.Potassium_Internal.Intro.UICorner
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = Intro

-- StarterGui.Potassium_Internal.Intro.InfoText
InfoText.Name = "InfoText"
InfoText.Position = UDim2.new(0.324021577835083, 0, 0.7572356462478638, 0)
InfoText.Size = UDim2.new(0, 60, 0, 36)
InfoText.BackgroundTransparency = 1
InfoText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InfoText.BorderSizePixel = 0
InfoText.BorderColor3 = Color3.fromRGB(0, 0, 0)
InfoText.Text = "Insert"
InfoText.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoText.TextSize = 14
InfoText.TextScaled = true
InfoText.TextWrapped = true
InfoText.Font = Enum.Font.SourceSans
InfoText.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
InfoText.Parent = Intro

-- StarterGui.Potassium_Internal.MainFrame
MainFrame.Name = "MainFrame"
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 0
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.34001901745796204, 0, 0.3751668930053711, 0)
MainFrame.Size = UDim2.new(0, 587, 0, 352)
MainFrame.BackgroundTransparency = 1
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.Image = "rbxassetid://79420553037586"
MainFrame.Parent = Potassium_Internal

-- StarterGui.Potassium_Internal.MainFrame.UICorner
UICorner_2.Parent = MainFrame

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder
CodingHolder.Name = "CodingHolder"
CodingHolder.ClipsDescendants = true
CodingHolder.Size = UDim2.new(1, 0, 1, 0)
CodingHolder.BackgroundTransparency = 1
CodingHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CodingHolder.BorderSizePixel = 0
CodingHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
CodingHolder.Parent = MainFrame

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings
Settings.Name = "Settings"
Settings.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
Settings.Size = UDim2.new(0, 465, 0, 26)
Settings.BackgroundTransparency = 1
Settings.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Settings.BorderSizePixel = 0
Settings.BorderColor3 = Color3.fromRGB(0, 0, 0)
Settings.Parent = CodingHolder

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.SaveFile
SaveFile.Name = "SaveFile"
SaveFile.LayoutOrder = 3
SaveFile.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
SaveFile.Size = UDim2.new(0, 87, 0, 26)
SaveFile.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
SaveFile.BorderSizePixel = 0
SaveFile.BorderColor3 = Color3.fromRGB(0, 0, 0)
SaveFile.Text = "Save File"
SaveFile.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveFile.TextSize = 14
SaveFile.Font = Enum.Font.SourceSans
SaveFile.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
SaveFile.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.SaveFile.UICorner
UICorner_3.CornerRadius = UDim.new(0, 3)
UICorner_3.Parent = SaveFile

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.SaveFile.UIStroke
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(38, 38, 38)
UIStroke.Parent = SaveFile

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.UIListLayout
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Execute
Execute.Name = "Execute"
Execute.LayoutOrder = 1
Execute.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
Execute.Size = UDim2.new(0, 87, 0, 26)
Execute.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Execute.BorderSizePixel = 0
Execute.BorderColor3 = Color3.fromRGB(0, 0, 0)
Execute.Text = "Execute"
Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
Execute.TextSize = 14
Execute.Font = Enum.Font.SourceSans
Execute.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Execute.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Execute.UICorner
UICorner_4.CornerRadius = UDim.new(0, 3)
UICorner_4.Parent = Execute

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Execute.UIStroke
UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_2.Color = Color3.fromRGB(38, 38, 38)
UIStroke_2.Parent = Execute

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Clear
Clear.Name = "Clear"
Clear.LayoutOrder = 2
Clear.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
Clear.Size = UDim2.new(0, 87, 0, 26)
Clear.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Clear.BorderSizePixel = 0
Clear.BorderColor3 = Color3.fromRGB(0, 0, 0)
Clear.Text = "Clear"
Clear.TextColor3 = Color3.fromRGB(255, 255, 255)
Clear.TextSize = 14
Clear.Font = Enum.Font.SourceSans
Clear.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Clear.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Clear.UICorner
UICorner_5.CornerRadius = UDim.new(0, 3)
UICorner_5.Parent = Clear

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Clear.UIStroke
UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_3.Color = Color3.fromRGB(38, 38, 38)
UIStroke_3.Parent = Clear

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.OpenFile
OpenFile.Name = "OpenFile"
OpenFile.LayoutOrder = 4
OpenFile.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
OpenFile.Size = UDim2.new(0, 87, 0, 26)
OpenFile.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
OpenFile.BorderSizePixel = 0
OpenFile.BorderColor3 = Color3.fromRGB(0, 0, 0)
OpenFile.Text = "Open File"
OpenFile.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenFile.TextSize = 14
OpenFile.Font = Enum.Font.SourceSans
OpenFile.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
OpenFile.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.OpenFile.UICorner
UICorner_6.CornerRadius = UDim.new(0, 3)
UICorner_6.Parent = OpenFile

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.OpenFile.UIStroke
UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_4.Color = Color3.fromRGB(38, 38, 38)
UIStroke_4.Parent = OpenFile

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Settings
Settings_2.Name = "Settings"
Settings_2.LayoutOrder = 5
Settings_2.Position = UDim2.new(0.8172042965888977, 0, 0, 0)
Settings_2.Size = UDim2.new(0, 30, 0, 26)
Settings_2.BackgroundTransparency = 1
Settings_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Settings_2.BorderSizePixel = 0
Settings_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Settings_2.Image = "rbxassetid://96833048707493"
Settings_2.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Settings.UICorner
UICorner_7.CornerRadius = UDim.new(0, 3)
UICorner_7.Parent = Settings_2

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Console
Console.Name = "Console"
Console.LayoutOrder = 5
Console.Position = UDim2.new(0.898924708366394, 0, 0, 0)
Console.Size = UDim2.new(0, 27, 0, 26)
Console.BackgroundTransparency = 1
Console.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Console.BorderSizePixel = 0
Console.BorderColor3 = Color3.fromRGB(0, 0, 0)
Console.Image = "http://www.roblox.com/asset/?id=6022668955"
Console.Parent = Settings

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Settings.Console.UICorner
UICorner_8.CornerRadius = UDim.new(0, 3)
UICorner_8.Parent = Console

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll
EditorScroll.Name = "EditorScroll"
EditorScroll.Active = true
EditorScroll.Position = UDim2.new(5.198905839165491e-08, 0, 0.019886363297700882, 0)
EditorScroll.Size = UDim2.new(0.8415671586990356, 0, 0.7982954382896423, 0)
EditorScroll.BackgroundTransparency = 1
EditorScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
EditorScroll.BorderSizePixel = 0
EditorScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
EditorScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
EditorScroll.Parent = CodingHolder

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent
EditorContent.Name = "EditorContent"
EditorContent.Position = UDim2.new(0.04517453908920288, 0, 0, 0)
EditorContent.Size = UDim2.new(0, 466, 0, 281)
EditorContent.BackgroundTransparency = 1
EditorContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
EditorContent.BorderSizePixel = 0
EditorContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
EditorContent.Parent = EditorScroll

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Gutter
Gutter.Name = "Gutter"
Gutter.Position = UDim2.new(-0.047889020293951035, 0, 0, 0)
Gutter.Size = UDim2.new(0.04935622215270996, 0, 0.41637009382247925, 0)
Gutter.BackgroundTransparency = 1
Gutter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Gutter.BorderSizePixel = 0
Gutter.BorderColor3 = Color3.fromRGB(0, 0, 0)
Gutter.Parent = EditorContent

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Gutter.UIListLayout
UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.Parent = Gutter

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.HighlightBar
HighlightBar.Name = "HighlightBar"
HighlightBar.Visible = false
HighlightBar.ZIndex = 2
HighlightBar.Size = UDim2.new(0, 95, 0, 6)
HighlightBar.BackgroundTransparency = 0.8500000238418579
HighlightBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HighlightBar.BorderSizePixel = 0
HighlightBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
HighlightBar.Parent = EditorContent

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Display
Display.Name = "Display"
Display.ZIndex = 2
Display.Position = UDim2.new(0.014342737384140491, 0, 0, 0)
Display.Size = UDim2.new(0.985657274723053, 0, 1, 0)
Display.BackgroundTransparency = 1
Display.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Display.BorderSizePixel = 0
Display.BorderColor3 = Color3.fromRGB(0, 0, 0)
Display.Text = ""
Display.TextColor3 = Color3.fromRGB(255, 255, 255)
Display.TextSize = 14
Display.TextWrapped = true
Display.RichText = true
Display.TextXAlignment = Enum.TextXAlignment.Left
Display.TextYAlignment = Enum.TextYAlignment.Top
Display.Font = Enum.Font.SourceSans
Display.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Display.Parent = EditorContent

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Display.UIPadding
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.Parent = Display

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Input
Input.Name = "Input"
Input.ZIndex = 3
Input.Position = UDim2.new(0.014342737384140491, 0, 0, 0)
Input.Size = UDim2.new(0.985657274723053, 0, 1, 0)
Input.BackgroundTransparency = 0.8999999761581421
Input.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
Input.BorderSizePixel = 0
Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(27, 25, 25)
Input.TextSize = 14
Input.TextWrapped = true
Input.TextXAlignment = Enum.TextXAlignment.Left
Input.TextYAlignment = Enum.TextYAlignment.Top
Input.Font = Enum.Font.SourceSans
Input.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Input.ClearTextOnFocus = false
Input.MultiLine = true
Input.Parent = EditorContent

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Input.UICorner
UICorner_9.Parent = Input

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.EditorScroll.EditorContent.Input.UIPadding
UIPadding_2.PaddingLeft = UDim.new(0, 5)
UIPadding_2.Parent = Input

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Pynt
Pynt.Name = "Pynt"
Pynt.Position = UDim2.new(0.04940374940633774, 0, 0.020000023767352104, 0)
Pynt.Size = UDim2.new(0.7938671112060547, 0, 0.7979999780654907, 0)
Pynt.BackgroundTransparency = 1
Pynt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Pynt.BorderSizePixel = 0
Pynt.BorderColor3 = Color3.fromRGB(0, 0, 0)
Pynt.Parent = CodingHolder

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Pynt.UIStroke
UIStroke_5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_5.Color = Color3.fromRGB(38, 38, 38)
UIStroke_5.Parent = Pynt

-- StarterGui.Potassium_Internal.MainFrame.CodingHolder.Pynt.UICorner
UICorner_10.Parent = Pynt

-- StarterGui.Potassium_Internal.MainFrame.Settings
Settings_3.Name = "Settings"
Settings_3.Visible = false
Settings_3.ClipsDescendants = true
Settings_3.Size = UDim2.new(1, 0, 1, 0)
Settings_3.BackgroundTransparency = 1
Settings_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Settings_3.BorderSizePixel = 0
Settings_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Settings_3.Parent = MainFrame

-- StarterGui.Potassium_Internal.MainFrame.Settings.Holder
Holder.Name = "Holder"
Holder.Size = UDim2.new(1, 0, 1, 0)
Holder.BackgroundTransparency = 1
Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Holder.BorderSizePixel = 0
Holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
Holder.Parent = Settings_3

-- StarterGui.Potassium_Internal.MainFrame.Settings.Holder.UIPadding
UIPadding_3.PaddingTop = UDim.new(0, 10)
UIPadding_3.PaddingBottom = UDim.new(0, 10)
UIPadding_3.PaddingLeft = UDim.new(0, 5)
UIPadding_3.PaddingRight = UDim.new(0, 5)
UIPadding_3.Parent = Holder

-- StarterGui.Potassium_Internal.MainFrame.Settings.Holder.UIListLayout
UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_3.Padding = UDim.new(0, 5)
UIListLayout_3.Parent = Holder

-- StarterGui.Potassium_Internal.MainFrame.Settings.Close
Close.Name = "Close"
Close.Position = UDim2.new(0.9608176350593567, 0, 0, 0)
Close.Size = UDim2.new(0, 22, 0, 21)
Close.BackgroundTransparency = 1
Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Close.BorderSizePixel = 0
Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close.Image = "http://www.roblox.com/asset/?id=6031094678"
Close.ImageColor3 = Color3.fromRGB(111, 111, 111)
Close.Parent = Settings_3

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates
Templates.Name = "Templates"
Templates.Parent = Settings_3

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template
Template.Name = "Template"
Template.Visible = false
Template.Position = UDim2.new(0.1889081448316574, 0, 0, 0)
Template.Size = UDim2.new(0, 359, 0, 34)
Template.BackgroundTransparency = 1
Template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Template.BorderSizePixel = 0
Template.BorderColor3 = Color3.fromRGB(0, 0, 0)
Template.Text = ""
Template.TextColor3 = Color3.fromRGB(255, 255, 255)
Template.TextSize = 14
Template.Font = Enum.Font.SourceSans
Template.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Template.Parent = Templates

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template.UICorner
UICorner_11.CornerRadius = UDim.new(0, 3)
UICorner_11.Parent = Template

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template.UIStroke
UIStroke_6.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_6.Color = Color3.fromRGB(38, 38, 38)
UIStroke_6.Parent = Template

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template.Title
Title.Name = "Title"
Title.Position = UDim2.new(0.027855154126882553, 0, 0, 0)
Title.Size = UDim2.new(0.9721449613571167, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 0
Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = "Smart Enter"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSans
Title.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Title.Parent = Template

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template.ImageLabel
ImageLabel.Position = UDim2.new(0.9359331727027893, 0, 0.29411765933036804, 0)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 88, 91)
ImageLabel.BorderSizePixel = 0
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
ImageLabel.ImageTransparency = 1
ImageLabel.Parent = Template

-- StarterGui.Potassium_Internal.MainFrame.Settings.Templates.Template.ImageLabel.UICorner
UICorner_12.CornerRadius = UDim.new(1, 0)
UICorner_12.Parent = ImageLabel

-- StarterGui.Potassium_Internal.WaterDrop
WaterDrop.Name = "WaterDrop"
WaterDrop.AnchorPoint = Vector2.new(0.5, 0.5)
WaterDrop.Position = UDim2.new(0.49900001287460327, 0, -0.019999999552965164, 0)
WaterDrop.Size = UDim2.new(0, 23, 0, 23)
WaterDrop.BackgroundTransparency = 1
WaterDrop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WaterDrop.BorderSizePixel = 0
WaterDrop.BorderColor3 = Color3.fromRGB(0, 0, 0)
WaterDrop.Image = "rbxassetid://79420553037586"
WaterDrop.Parent = Potassium_Internal

-- StarterGui.Potassium_Internal.WaterDrop.UICorner
UICorner_13.CornerRadius = UDim.new(1, 0)
UICorner_13.Parent = WaterDrop

-- StarterGui.Potassium_Internal.WaterDrop.UIScale
UIScale.Parent = WaterDrop

-- StarterGui.Potassium_Internal.Console
Console_2.Name = "Console"
Console_2.Visible = false
Console_2.ZIndex = 0
Console_2.Position = UDim2.new(0.5822601318359375, 0, 0.3227442800998688, 0)
Console_2.Size = UDim2.new(0, 480, 0, 279)
Console_2.BackgroundTransparency = 1
Console_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Console_2.BorderSizePixel = 0
Console_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Console_2.Image = "rbxassetid://79420553037586"
Console_2.Parent = Potassium_Internal

-- StarterGui.Potassium_Internal.Console.UICorner
UICorner_14.Parent = Console_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder
ConsoleHolder.Name = "ConsoleHolder"
ConsoleHolder.ClipsDescendants = true
ConsoleHolder.Size = UDim2.new(1, 0, 1, 0)
ConsoleHolder.BackgroundTransparency = 1
ConsoleHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ConsoleHolder.BorderSizePixel = 0
ConsoleHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
ConsoleHolder.Parent = Console_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Display
Display_2.Name = "Display"
Display_2.ZIndex = 2
Display_2.Position = UDim2.new(0.04899989813566208, 0, 0.036999963223934174, 0)
Display_2.Size = UDim2.new(0, 558, 0, 281)
Display_2.BackgroundTransparency = 1
Display_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Display_2.BorderSizePixel = 0
Display_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Display_2.Text = ""
Display_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Display_2.TextSize = 14
Display_2.RichText = true
Display_2.TextXAlignment = Enum.TextXAlignment.Left
Display_2.TextYAlignment = Enum.TextYAlignment.Top
Display_2.Font = Enum.Font.SourceSans
Display_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Display_2.Parent = ConsoleHolder

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Display.UIPadding
UIPadding_4.PaddingLeft = UDim.new(0, 5)
UIPadding_4.Parent = Display_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings
Settings_4.Name = "Settings"
Settings_4.Position = UDim2.new(0.04883931577205658, 0, 0.8937975168228149, 0)
Settings_4.Size = UDim2.new(0, 432, 0, 29)
Settings_4.BackgroundTransparency = 1
Settings_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Settings_4.BorderSizePixel = 0
Settings_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
Settings_4.Parent = ConsoleHolder

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Clear
Clear_2.Name = "Clear"
Clear_2.LayoutOrder = 2
Clear_2.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
Clear_2.Size = UDim2.new(0, 87, 0, 26)
Clear_2.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Clear_2.BorderSizePixel = 0
Clear_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Clear_2.TextSize = 14
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Clear_2.Parent = Settings_4

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Clear.UICorner
UICorner_15.CornerRadius = UDim.new(0, 3)
UICorner_15.Parent = Clear_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Clear.UIStroke
UIStroke_7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_7.Color = Color3.fromRGB(38, 38, 38)
UIStroke_7.Parent = Clear_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.UIListLayout
UIListLayout_4.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_4.Padding = UDim.new(0, 8)
UIListLayout_4.Parent = Settings_4

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll
AutoScroll.Name = "AutoScroll"
AutoScroll.LayoutOrder = 2
AutoScroll.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
AutoScroll.Size = UDim2.new(0, 87, 0, 26)
AutoScroll.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
AutoScroll.BorderSizePixel = 0
AutoScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
AutoScroll.Text = ""
AutoScroll.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoScroll.TextSize = 14
AutoScroll.Font = Enum.Font.SourceSans
AutoScroll.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
AutoScroll.AutoButtonColor = false
AutoScroll.Parent = Settings_4

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll.UICorner
UICorner_16.CornerRadius = UDim.new(0, 3)
UICorner_16.Parent = AutoScroll

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll.UIStroke
UIStroke_8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_8.Color = Color3.fromRGB(38, 38, 38)
UIStroke_8.Parent = AutoScroll

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll.TextLabel
TextLabel.Size = UDim2.new(0.7011494040489197, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BorderSizePixel = 0
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.Text = "AutoScroll"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 14
TextLabel.Font = Enum.Font.SourceSans
TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
TextLabel.Parent = AutoScroll

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll.ImageLabel
ImageLabel_2.Position = UDim2.new(0.798003077507019, 0, 0.29411667585372925, 0)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 88, 91)
ImageLabel_2.BorderSizePixel = 0
ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_2.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
ImageLabel_2.ImageTransparency = 1
ImageLabel_2.Parent = AutoScroll

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.AutoScroll.ImageLabel.UICorner
UICorner_17.CornerRadius = UDim.new(1, 0)
UICorner_17.Parent = ImageLabel_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.LogCount
LogCount.Name = "LogCount"
LogCount.LayoutOrder = 2
LogCount.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
LogCount.Size = UDim2.new(0, 87, 0, 26)
LogCount.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
LogCount.BorderSizePixel = 0
LogCount.BorderColor3 = Color3.fromRGB(0, 0, 0)
LogCount.Text = "Logs: 500"
LogCount.TextColor3 = Color3.fromRGB(255, 255, 255)
LogCount.TextSize = 14
LogCount.Font = Enum.Font.SourceSans
LogCount.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
LogCount.AutoButtonColor = false
LogCount.Parent = Settings_4

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.LogCount.UICorner
UICorner_18.CornerRadius = UDim.new(0, 3)
UICorner_18.Parent = LogCount

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.LogCount.UIStroke
UIStroke_9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_9.Color = Color3.fromRGB(38, 38, 38)
UIStroke_9.Parent = LogCount

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Close
Close_2.Name = "Close"
Close_2.LayoutOrder = 2
Close_2.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
Close_2.Size = UDim2.new(0, 87, 0, 26)
Close_2.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
Close_2.BorderSizePixel = 0
Close_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Close_2.TextSize = 14
Close_2.Font = Enum.Font.SourceSans
Close_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Close_2.Parent = Settings_4

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Close.UICorner
UICorner_19.CornerRadius = UDim.new(0, 3)
UICorner_19.Parent = Close_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Settings.Close.UIStroke
UIStroke_10.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_10.Color = Color3.fromRGB(38, 38, 38)
UIStroke_10.Parent = Close_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame
LogsFrame.Name = "LogsFrame"
LogsFrame.Position = UDim2.new(0.01875000074505806, 0, 0.02867383509874344, 0)
LogsFrame.Size = UDim2.new(0.9620000123977661, 0, 0.8401434421539307, 0)
LogsFrame.BackgroundTransparency = 1
LogsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LogsFrame.BorderSizePixel = 0
LogsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
LogsFrame.Parent = ConsoleHolder

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame.UICorner
UICorner_20.Parent = LogsFrame

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame.UIStroke
UIStroke_11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke_11.Color = Color3.fromRGB(38, 38, 38)
UIStroke_11.Parent = LogsFrame

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame.Holder
Holder_2.Name = "Holder"
Holder_2.Active = true
Holder_2.Size = UDim2.new(0.9935064911842346, 0, 1, 0)
Holder_2.BackgroundTransparency = 1
Holder_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Holder_2.BorderSizePixel = 0
Holder_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Holder_2.AutomaticCanvasSize = Enum.AutomaticSize.Y
Holder_2.ScrollBarThickness = 7
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
Holder_2.Parent = LogsFrame

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame.Holder.UIListLayout
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_5.Parent = Holder_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.LogsFrame.Holder.UIPadding
UIPadding_5.PaddingTop = UDim.new(0, 5)
UIPadding_5.PaddingBottom = UDim.new(0, 5)
UIPadding_5.PaddingLeft = UDim.new(0, 5)
UIPadding_5.PaddingRight = UDim.new(0, 5)
UIPadding_5.Parent = Holder_2

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Templates
Templates_2.Name = "Templates"
Templates_2.Parent = ConsoleHolder

-- StarterGui.Potassium_Internal.Console.ConsoleHolder.Templates.Log
Log.Name = "Log"
Log.Position = UDim2.new(0.0022271715570241213, 0, 0, 0)
Log.Size = UDim2.new(1, 0, 0, 0)
Log.AutomaticSize = Enum.AutomaticSize.Y
Log.BackgroundTransparency = 1
Log.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Log.BorderSizePixel = 0
Log.BorderColor3 = Color3.fromRGB(0, 0, 0)
Log.Text = "There was an error while trying to make the new spider man"
Log.TextColor3 = Color3.fromRGB(255, 255, 255)
Log.TextSize = 14
Log.TextWrapped = true
Log.TextXAlignment = Enum.TextXAlignment.Left
Log.TextYAlignment = Enum.TextYAlignment.Top
Log.Font = Enum.Font.SourceSans
Log.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Log.Parent = Templates_2

	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/Modules/IDE.lua"))(MainFrame, Console_2)

	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/Modules/Console.lua"))(Console_2)

	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/Modules/Intro.lua"))(Potassium_Internal)

