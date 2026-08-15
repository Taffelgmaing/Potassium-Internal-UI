return function(MainFrame, Console_2)
	--[[
		POTASSIUM INTERNAL EXPLORER
		============================================================

		Standalone ModuleScript.

		Usage:

			local Explorer =
				require(ReplicatedStorage.Potassium.Explorer)

			Explorer(MainFrame, Console_2)

		The module creates/fetches its own Explorer toolbar button and
		creates the Explorer window as a sibling of MainFrame.
	]]

	-- ============================================================
	-- EASY EDIT SETTINGS
	-- ============================================================

	local SETTINGS = {
		Window = {
			DefaultWidth = 760,
			DefaultHeight = 540,
		},

		Theme = {
			WindowBackground = Color3.fromRGB(30, 30, 30),
			PanelBackground = Color3.fromRGB(34, 34, 34),
			TopBackground = Color3.fromRGB(38, 38, 38),
			RowBackground = Color3.fromRGB(40, 40, 40),
			SelectedRowBackground = Color3.fromRGB(58, 72, 92),
			InputBackground = Color3.fromRGB(45, 45, 45),
			Border = Color3.fromRGB(62, 62, 62),
			Text = Color3.fromRGB(220, 220, 220),
			Muted = Color3.fromRGB(145, 145, 145),
			Accent = Color3.fromRGB(110, 173, 255),
			Danger = Color3.fromRGB(244, 71, 71),
		},

		Tree = {
			DragThreshold = 6,
			MaxRows = 5000,
			MaxSearchResults = 250,
			MaxSearchScan = 10000,
		},
	}

	-- ============================================================
	-- SERVICES
	-- ============================================================

	local UserInputService =
		game:GetService("UserInputService")

	local Players =
		game:GetService("Players")

	local CollectionService =
		game:GetService("CollectionService")

	local GuiService =
		game:GetService("GuiService")

	-- ============================================================
	-- ROOT
	-- ============================================================

	if not MainFrame then
		error(
			"[Potassium Explorer] MainFrame is missing."
		)
	end

	local frame = MainFrame

	local CodingHolder =
		frame:WaitForChild("CodingHolder")

	local ButtonsFrame =
		CodingHolder:FindFirstChild("Settings")

	-- ============================================================
	-- EXPLORER TOOLBAR BUTTON
	-- ============================================================

	local Explorer = nil

	if ButtonsFrame then
		Explorer =
			ButtonsFrame:FindFirstChild("Explorer")

		if not Explorer then
			Explorer = Instance.new("TextButton")
			local UICorner_5 = Instance.new("UICorner")
			local UIStroke_3 = Instance.new("UIStroke")
			Explorer.Name = "Explorer"
			Explorer.LayoutOrder = 2
			Explorer.Position = UDim2.new(0.04940374940633774, 0, 0.8551136255264282, 0)
			Explorer.Size = UDim2.new(0, 87, 0, 26)
			Explorer.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
			Explorer.BorderSizePixel = 0
			Explorer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Explorer.Text = "Explorer"
			Explorer.TextColor3 = Color3.fromRGB(255, 255, 255)
			Explorer.TextSize = 14
			Explorer.Font = Enum.Font.SourceSans
			Explorer.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			Explorer.Parent = ButtonsFrame

			UICorner_5.CornerRadius = UDim.new(0, 3)
			UICorner_5.Parent = Explorer

			UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke_3.Color = Color3.fromRGB(38, 38, 38)
			UIStroke_3.Parent = Explorer

			Explorer.Font = Enum.Font.Code
			Explorer.TextSize = 13

			Explorer.Size =
				UDim2.fromOffset(74, 28)

			local ConsoleButton =
				ButtonsFrame:FindFirstChild("Console")

			Explorer.LayoutOrder =
				(ConsoleButton
					and ConsoleButton.LayoutOrder
					or 100)
				+ 1

			local corner =
				Instance.new("UICorner")

			corner.CornerRadius =
				UDim.new(0, 4)

			corner.Parent = Explorer

			Explorer.Parent = ButtonsFrame
		end
	end

	if not Explorer then
		warn(
			"[Potassium Explorer] ButtonsFrame was not found. "
				.. "The Explorer window will still be created, "
				.. "but there is no toolbar button to open it."
		)
	end

	-- ============================================================
	-- INTERNAL EXPLORER / PROPERTIES WINDOW
	-- ============================================================

	local ExplorerWindow = nil

	do
		local WINDOW_BG = SETTINGS.Theme.WindowBackground
		local PANEL_BG = SETTINGS.Theme.PanelBackground
		local TOP_BG = SETTINGS.Theme.TopBackground
		local ROW_BG = SETTINGS.Theme.RowBackground
		local ROW_SELECTED_BG = SETTINGS.Theme.SelectedRowBackground
		local INPUT_BG = SETTINGS.Theme.InputBackground
		local BORDER = SETTINGS.Theme.Border
		local TEXT = SETTINGS.Theme.Text
		local MUTED = SETTINGS.Theme.Muted
		local ACCENT = SETTINGS.Theme.Accent
		local DANGER = SETTINGS.Theme.Danger

		local explorerParent = frame.Parent

		ExplorerWindow =
			explorerParent:FindFirstChild(
				"PotassiumExplorer"
			)

		if not ExplorerWindow then
			ExplorerWindow = Instance.new("ImageButton")
			ExplorerWindow.Name = "PotassiumExplorer"
			ExplorerWindow.AnchorPoint = Vector2.new(0.5, 0.5)
			ExplorerWindow.Position = UDim2.new(0.62, 0, 0.5, 0)
			ExplorerWindow.Size = UDim2.fromOffset(SETTINGS.Window.DefaultWidth, SETTINGS.Window.DefaultHeight)
			ExplorerWindow.BackgroundColor3 = WINDOW_BG
			ExplorerWindow.BorderSizePixel = 0
			ExplorerWindow.Visible = false
			ExplorerWindow.Active = true
			ExplorerWindow.ZIndex = 4
			ExplorerWindow.Parent = explorerParent
			ExplorerWindow.ImageTransparency = 1
			ExplorerWindow.AutoButtonColor = false

			local windowCorner = Instance.new("UICorner")
			windowCorner.CornerRadius = UDim.new(0, 7)
			windowCorner.Parent = ExplorerWindow

			local windowStroke = Instance.new("UIStroke")
			windowStroke.Color = BORDER
			windowStroke.Transparency = 0.1
			windowStroke.Thickness = 1
			windowStroke.Parent = ExplorerWindow
		end

		local function newLabel(parent, name, textValue)
			local label = Instance.new("TextLabel")
			label.Name = name
			label.BackgroundTransparency = 1
			label.BorderSizePixel = 0
			label.Text = textValue or ""
			label.TextColor3 = TEXT
			label.Font = Enum.Font.Code
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Center
			label.ZIndex = 6
			label.Parent = parent
			return label
		end

		local function newButton(parent, name, textValue)
			local button = Instance.new("TextButton")
			button.Name = name
			button.BackgroundColor3 = INPUT_BG
			button.BorderSizePixel = 0
			button.AutoButtonColor = true
			button.Text = textValue or ""
			button.TextColor3 = TEXT
			button.Font = Enum.Font.Code
			button.TextSize = 13
			button.ZIndex = 7
			button.Parent = parent

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = button
			return button
		end

		local function newTextBox(parent, name, placeholder)
			local box = Instance.new("TextBox")
			box.Name = name
			box.BackgroundColor3 = INPUT_BG
			box.BorderSizePixel = 0
			box.ClearTextOnFocus = false
			box.PlaceholderText = placeholder or ""
			box.PlaceholderColor3 = MUTED
			box.Text = ""
			box.TextColor3 = TEXT
			box.Font = Enum.Font.Code
			box.TextSize = 13
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.ZIndex = 7
			box.Parent = parent

			local padding = Instance.new("UIPadding")
			padding.PaddingLeft = UDim.new(0, 8)
			padding.PaddingRight = UDim.new(0, 8)
			padding.Parent = box

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 4)
			corner.Parent = box
			return box
		end

		local titleBar =
			ExplorerWindow:FindFirstChild("TitleBar")

		if not titleBar then
			titleBar = Instance.new("Frame")
			titleBar.Name = "TitleBar"
			titleBar.Position = UDim2.fromOffset(0, 0)
			titleBar.Size = UDim2.new(1, 0, 0, 36)
			titleBar.BackgroundColor3 = TOP_BG
			titleBar.BorderSizePixel = 0
			titleBar.Active = true
			titleBar.ZIndex = 5
			titleBar.Parent = ExplorerWindow

			local title = newLabel(titleBar, "Title", "Explorer")
			title.Position = UDim2.fromOffset(12, 0)
			title.Size = UDim2.new(1, -235, 1, 0)
			title.TextSize = 14

			local titleBarCorner = Instance.new("UICorner")
			titleBarCorner.Parent = titleBar
			titleBarCorner.BottomLeftRadius = UDim.new(0, 0)
			titleBarCorner.BottomRightRadius = UDim.new(0, 0)

			local backButton =
				newButton(
					titleBar,
					"SelectionBack",
					"←"
				)
			backButton.AnchorPoint =
				Vector2.new(1, 0.5)
			backButton.Position =
				UDim2.new(1, -178, 0.5, 0)
			backButton.Size =
				UDim2.fromOffset(28, 26)

			local forwardButton =
				newButton(
					titleBar,
					"SelectionForward",
					"→"
				)
			forwardButton.AnchorPoint =
				Vector2.new(1, 0.5)
			forwardButton.Position =
				UDim2.new(1, -144, 0.5, 0)
			forwardButton.Size =
				UDim2.fromOffset(28, 26)

			local locateButton =
				newButton(
					titleBar,
					"LocateSelection",
					"◎"
				)
			locateButton.AnchorPoint =
				Vector2.new(1, 0.5)
			locateButton.Position =
				UDim2.new(1, -110, 0.5, 0)
			locateButton.Size =
				UDim2.fromOffset(28, 26)

			local settingsButton =
				newButton(
					titleBar,
					"ExplorerSettings",
					"⚙"
				)
			settingsButton.AnchorPoint =
				Vector2.new(1, 0.5)
			settingsButton.Position =
				UDim2.new(1, -76, 0.5, 0)
			settingsButton.Size =
				UDim2.fromOffset(28, 26)

			local refreshButton = newButton(titleBar, "Refresh", "↻")
			refreshButton.AnchorPoint = Vector2.new(1, 0.5)
			refreshButton.Position = UDim2.new(1, -42, 0.5, 0)
			refreshButton.Size = UDim2.fromOffset(28, 26)

			local closeButton = newButton(titleBar, "Close", "×")
			closeButton.AnchorPoint = Vector2.new(1, 0.5)
			closeButton.Position = UDim2.new(1, -8, 0.5, 0)
			closeButton.Size = UDim2.fromOffset(28, 26)
			closeButton.TextSize = 17
		end

		local body =
			ExplorerWindow:FindFirstChild("Body")

		if not body then
			body = Instance.new("Frame")
			body.Name = "Body"
			body.Position = UDim2.fromOffset(8, 44)
			body.Size = UDim2.new(1, -16, 1, -52)
			body.BackgroundTransparency = 1
			body.BorderSizePixel = 0
			body.ZIndex = 5
			body.Parent = ExplorerWindow
		end

		local treePanel =
			body:FindFirstChild("TreePanel")

		if not treePanel then
			treePanel = Instance.new("Frame")
			treePanel.Name = "TreePanel"
			treePanel.Position = UDim2.fromOffset(0, 0)
			treePanel.Size = UDim2.new(0.48, -4, 1, 0)
			treePanel.BackgroundColor3 = PANEL_BG
			treePanel.BorderSizePixel = 0
			treePanel.ZIndex = 5
			treePanel.Parent = body

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = treePanel
		end

		local propertyPanel =
			body:FindFirstChild("PropertyPanel")

		if not propertyPanel then
			propertyPanel = Instance.new("Frame")
			propertyPanel.Name = "PropertyPanel"
			propertyPanel.AnchorPoint = Vector2.new(1, 0)
			propertyPanel.Position = UDim2.new(1, 0, 0, 0)
			propertyPanel.Size = UDim2.new(0.52, -4, 1, 0)
			propertyPanel.BackgroundColor3 = PANEL_BG
			propertyPanel.BorderSizePixel = 0
			propertyPanel.ZIndex = 5
			propertyPanel.Parent = body

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = propertyPanel
		end

		local treeSearch =
			treePanel:FindFirstChild("Search")

		if not treeSearch then
			treeSearch =
				newTextBox(
					treePanel,
					"Search",
					"Search all accessible game objects..."
				)
			treeSearch.Position = UDim2.fromOffset(8, 8)
			treeSearch.Size = UDim2.new(1, -16, 0, 30)
		end

		local treeScroll =
			treePanel:FindFirstChild("Tree")

		if not treeScroll then
			treeScroll = Instance.new("ScrollingFrame")
			treeScroll.Name = "Tree"
			treeScroll.Position = UDim2.fromOffset(4, 44)
			treeScroll.Size = UDim2.new(1, -8, 1, -48)
			treeScroll.BackgroundTransparency = 1
			treeScroll.BorderSizePixel = 0
			treeScroll.ScrollBarThickness = 6
			treeScroll.ScrollBarImageTransparency = 0.25
			treeScroll.CanvasSize = UDim2.fromOffset(0, 0)
			treeScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
			treeScroll.ZIndex = 5
			treeScroll.Parent = treePanel
		end

		local propertySearch =
			propertyPanel:FindFirstChild("Search")

		if not propertySearch then
			propertySearch =
				newTextBox(
					propertyPanel,
					"Search",
					"Filter properties..."
				)
			propertySearch.Position = UDim2.fromOffset(8, 8)
			propertySearch.Size = UDim2.new(1, -16, 0, 30)
		end

		local selectionInfo =
			propertyPanel:FindFirstChild("Selection")

		if not selectionInfo then
			selectionInfo =
				newLabel(
					propertyPanel,
					"Selection",
					"No instance selected"
				)
			selectionInfo.Position = UDim2.fromOffset(8, 42)
			selectionInfo.Size = UDim2.new(1, -16, 0, 34)
			selectionInfo.TextColor3 = ACCENT
			selectionInfo.TextWrapped = true
		end

		local propertyScroll =
			propertyPanel:FindFirstChild("Properties")

		if not propertyScroll then
			propertyScroll = Instance.new("ScrollingFrame")
			propertyScroll.Name = "Properties"
			propertyScroll.Position = UDim2.fromOffset(4, 78)
			propertyScroll.Size = UDim2.new(1, -8, 1, -82)
			propertyScroll.BackgroundTransparency = 1
			propertyScroll.BorderSizePixel = 0
			propertyScroll.ScrollBarThickness = 6
			propertyScroll.ScrollBarImageTransparency = 0.25
			propertyScroll.CanvasSize = UDim2.fromOffset(0, 0)
			propertyScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
			propertyScroll.ZIndex = 5
			propertyScroll.Parent = propertyPanel
		end

		local resizeHandle =
			ExplorerWindow:FindFirstChild("ExplorerResizeHandle")

		if not resizeHandle then
			resizeHandle = newButton(
				ExplorerWindow,
				"ExplorerResizeHandle",
				""
			)
			resizeHandle.AnchorPoint = Vector2.new(1, 1)
			resizeHandle.Position = UDim2.new(1, -2, 1, -2)
			resizeHandle.Size = UDim2.fromOffset(16, 16)
			resizeHandle.BackgroundTransparency = 0.45
			resizeHandle.ZIndex = 20
		end

		-- Nothing is expanded by default.
		-- This keeps the Explorer clean instead of dumping the entire game
		-- hierarchy as soon as the window opens.
		local expanded = {}

		local selectedInstance = nil
		local treeRows = {}
		local treeRowInstances = {}
		local propertyRows = {}
		local treeRefreshSerial = 0
		local propertyRefreshSerial = 0

		-- Shared selection reference. Other Potassium windows (for example
		-- ScriptViewer) can read this without tightly coupling the modules.
		local selectionValue =
			ExplorerWindow:FindFirstChild(
				"ExplorerSelection"
			)

		if not selectionValue then
			selectionValue =
				Instance.new("ObjectValue")
			selectionValue.Name =
				"ExplorerSelection"
			selectionValue.Parent =
				ExplorerWindow
		end

		selectionValue.Value = nil

		local showContextMenu
		local hideContextMenu

		-- Tree drag/drop state.
		local pendingTreeDragInstance = nil
		local pendingTreeDragStart = nil
		local draggingTreeInstance = nil
		local dragDropTarget = nil
		local TREE_DRAG_THRESHOLD = SETTINGS.Tree.DragThreshold

		local ExplorerSettings = {
			WorldPick = false,
			AutoExpandSelection = true,
			AutoScrollSelection = true,
			HighlightWorldSelection = true,
			ShowClassNames = true,
			LiveRefresh = true,
		}

		local selectionHistory = {}
		local selectionHistoryIndex = 0
		local applyingHistorySelection = false

		local worldSelectionHighlight =
			ExplorerWindow:FindFirstChild(
				"WorldSelectionHighlight"
			)

		if not worldSelectionHighlight then
			worldSelectionHighlight =
				Instance.new("Highlight")
			worldSelectionHighlight.Name =
				"WorldSelectionHighlight"
			worldSelectionHighlight.FillTransparency = 0.8
			worldSelectionHighlight.OutlineTransparency = 0
			worldSelectionHighlight.DepthMode =
				Enum.HighlightDepthMode.AlwaysOnTop
			worldSelectionHighlight.Enabled = false
			worldSelectionHighlight.Parent =
				ExplorerWindow
		end

		local MAX_TREE_ROWS = SETTINGS.Tree.MaxRows
		local MAX_SEARCH_RESULTS = SETTINGS.Tree.MaxSearchResults
		local MAX_SEARCH_SCAN = SETTINGS.Tree.MaxSearchScan

		local READ_ONLY_PROPERTIES = {
			ClassName = true,
			Parent = true,
			AbsolutePosition = true,
			AbsoluteSize = true,
			AbsoluteRotation = true,
			AbsoluteCanvasSize = true,
			AssemblyMass = true,
			AssemblyRootPart = true,
			Mass = true,
			ReceiveAge = true,
			CurrentCamera = true,
			Character = true,
			UserId = true,
			AccountAge = true,
			DisplayName = true,
			PlaybackLoudness = true,
			TimeLength = true,
		}

		local COMMON_PROPERTIES = {
			"Name",
			"ClassName",
			"Parent",
			"Archivable",
		}

		local BASEPART_PROPERTIES = {
			"Anchored",
			"CanCollide",
			"CanQuery",
			"CanTouch",
			"CastShadow",
			"Color",
			"Material",
			"MaterialVariant",
			"Reflectance",
			"Transparency",
			"Size",
			"Position",
			"Orientation",
			"CFrame",
			"AssemblyLinearVelocity",
			"AssemblyAngularVelocity",
			"AssemblyMass",
			"AssemblyRootPart",
			"Massless",
			"CollisionGroup",
			"Locked",
			"RootPriority",
		}

		local MODEL_PROPERTIES = {
			"PrimaryPart",
			"WorldPivot",
			"ModelStreamingMode",
			"LevelOfDetail",
		}

		local GUI_PROPERTIES = {
			"Visible",
			"Active",
			"Selectable",
			"Interactable",
			"BackgroundColor3",
			"BackgroundTransparency",
			"BorderColor3",
			"BorderMode",
			"BorderSizePixel",
			"Position",
			"Size",
			"AnchorPoint",
			"AutomaticSize",
			"ClipsDescendants",
			"LayoutOrder",
			"Rotation",
			"ZIndex",
			"AbsolutePosition",
			"AbsoluteSize",
			"AbsoluteRotation",
		}

		local TEXT_PROPERTIES = {
			"Text",
			"TextColor3",
			"TextTransparency",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextSize",
			"TextScaled",
			"TextWrapped",
			"RichText",
			"Font",
			"LineHeight",
			"MaxVisibleGraphemes",
			"TextXAlignment",
			"TextYAlignment",
		}

		local TEXTBOX_PROPERTIES = {
			"PlaceholderText",
			"PlaceholderColor3",
			"ClearTextOnFocus",
			"MultiLine",
			"ShowNativeInput",
			"TextEditable",
		}

		local IMAGE_PROPERTIES = {
			"Image",
			"ImageColor3",
			"ImageTransparency",
			"ResampleMode",
			"ScaleType",
			"SliceScale",
			"TileSize",
		}

		local SCROLL_PROPERTIES = {
			"CanvasPosition",
			"CanvasSize",
			"AutomaticCanvasSize",
			"AbsoluteCanvasSize",
			"ScrollBarThickness",
			"ScrollingDirection",
			"ScrollingEnabled",
			"ElasticBehavior",
			"VerticalScrollBarInset",
			"HorizontalScrollBarInset",
		}

		local HUMANOID_PROPERTIES = {
			"Health",
			"MaxHealth",
			"WalkSpeed",
			"JumpPower",
			"JumpHeight",
			"UseJumpPower",
			"HipHeight",
			"AutoRotate",
			"PlatformStand",
			"Sit",
			"BreakJointsOnDeath",
			"RequiresNeck",
			"DisplayDistanceType",
			"HealthDisplayType",
			"NameDisplayDistance",
		}

		local SOUND_PROPERTIES = {
			"SoundId",
			"Volume",
			"PlaybackSpeed",
			"Looped",
			"TimePosition",
			"Playing",
			"PlaybackLoudness",
			"TimeLength",
			"EmitterSize",
			"RollOffMaxDistance",
			"RollOffMinDistance",
			"RollOffMode",
		}

		local LIGHTING_PROPERTIES = {
			"ClockTime",
			"Brightness",
			"Ambient",
			"OutdoorAmbient",
			"ColorShift_Bottom",
			"ColorShift_Top",
			"EnvironmentDiffuseScale",
			"EnvironmentSpecularScale",
			"ExposureCompensation",
			"FogColor",
			"FogStart",
			"FogEnd",
			"GeographicLatitude",
			"GlobalShadows",
			"ShadowSoftness",
			"Technology",
		}

		local CAMERA_PROPERTIES = {
			"CameraType",
			"CameraSubject",
			"CFrame",
			"Focus",
			"FieldOfView",
			"FieldOfViewMode",
			"MaxAxisFieldOfView",
			"DiagonalFieldOfView",
			"HeadLocked",
			"HeadScale",
		}

		local PLAYER_PROPERTIES = {
			"UserId",
			"AccountAge",
			"DisplayName",
			"Character",
			"Team",
			"Neutral",
			"CameraMode",
			"CameraMaxZoomDistance",
			"CameraMinZoomDistance",
			"DevComputerCameraMode",
			"DevTouchCameraMode",
		}

		local ATTACHMENT_PROPERTIES = {
			"Position",
			"Orientation",
			"CFrame",
			"Axis",
			"SecondaryAxis",
			"Visible",
		}

		local DECAL_PROPERTIES = {
			"Texture",
			"Color3",
			"Transparency",
			"Face",
			"ZIndex",
		}

		local MESH_PROPERTIES = {
			"MeshId",
			"TextureId",
			"MeshType",
			"Scale",
			"Offset",
			"VertexColor",
		}

		local PARTICLE_PROPERTIES = {
			"Enabled",
			"Rate",
			"Lifetime",
			"Speed",
			"Acceleration",
			"Drag",
			"RotSpeed",
			"Rotation",
			"LightEmission",
			"LightInfluence",
			"LockedToPart",
			"Orientation",
			"Shape",
			"ShapeStyle",
			"ShapeInOut",
			"TimeScale",
			"Texture",
			"ZOffset",
		}

		local PROMPT_PROPERTIES = {
			"ActionText",
			"ObjectText",
			"Enabled",
			"HoldDuration",
			"MaxActivationDistance",
			"RequiresLineOfSight",
			"ClickablePrompt",
			"KeyboardKeyCode",
			"GamepadKeyCode",
			"Exclusivity",
			"Style",
		}

		local ATMOSPHERE_PROPERTIES = {
			"Density",
			"Offset",
			"Color",
			"Decay",
			"Glare",
			"Haze",
		}

		local function addPropertyNames(target, seen, source)
			for _, name in ipairs(source) do
				if not seen[name] then
					seen[name] = true
					table.insert(target, name)
				end
			end
		end

		local function getCandidateProperties(instance)
			local result = {}
			local seen = {}

			addPropertyNames(result, seen, COMMON_PROPERTIES)

			if instance:IsA("BasePart") then
				addPropertyNames(result, seen, BASEPART_PROPERTIES)
			end
			if instance:IsA("Model") then
				addPropertyNames(result, seen, MODEL_PROPERTIES)
			end
			if instance:IsA("GuiObject") then
				addPropertyNames(result, seen, GUI_PROPERTIES)
			end
			if instance:IsA("TextLabel")
				or instance:IsA("TextButton")
				or instance:IsA("TextBox")
			then
				addPropertyNames(result, seen, TEXT_PROPERTIES)
			end
			if instance:IsA("TextBox") then
				addPropertyNames(result, seen, TEXTBOX_PROPERTIES)
			end
			if instance:IsA("ImageLabel")
				or instance:IsA("ImageButton")
			then
				addPropertyNames(result, seen, IMAGE_PROPERTIES)
			end
			if instance:IsA("ScrollingFrame") then
				addPropertyNames(result, seen, SCROLL_PROPERTIES)
			end
			if instance:IsA("Humanoid") then
				addPropertyNames(result, seen, HUMANOID_PROPERTIES)
			end
			if instance:IsA("Sound") then
				addPropertyNames(result, seen, SOUND_PROPERTIES)
			end
			if instance:IsA("Lighting") then
				addPropertyNames(result, seen, LIGHTING_PROPERTIES)
			end
			if instance:IsA("Camera") then
				addPropertyNames(result, seen, CAMERA_PROPERTIES)
			end
			if instance:IsA("Player") then
				addPropertyNames(result, seen, PLAYER_PROPERTIES)
			end
			if instance:IsA("Attachment") then
				addPropertyNames(result, seen, ATTACHMENT_PROPERTIES)
			end
			if instance:IsA("Decal")
				or instance:IsA("Texture")
			then
				addPropertyNames(result, seen, DECAL_PROPERTIES)
			end
			if instance:IsA("SpecialMesh") then
				addPropertyNames(result, seen, MESH_PROPERTIES)
			end
			if instance:IsA("ParticleEmitter") then
				addPropertyNames(result, seen, PARTICLE_PROPERTIES)
			end
			if instance:IsA("ProximityPrompt") then
				addPropertyNames(result, seen, PROMPT_PROPERTIES)
			end
			if instance:IsA("ClickDetector") then
				addPropertyNames(result, seen, {
					"MaxActivationDistance",
					"CursorIcon",
				})
			end
			if instance:IsA("Animation") then
				addPropertyNames(result, seen, {"AnimationId"})
			end
			if instance:IsA("ValueBase") then
				addPropertyNames(result, seen, {"Value"})
			end
			if instance:IsA("Script")
				or instance:IsA("LocalScript")
			then
				addPropertyNames(result, seen, {
					"Enabled",
					"RunContext",
				})
			end
			if instance:IsA("Terrain") then
				addPropertyNames(result, seen, {
					"Decoration",
					"WaterColor",
					"WaterReflectance",
					"WaterTransparency",
					"WaterWaveSize",
					"WaterWaveSpeed",
				})
			end
			if instance:IsA("Atmosphere") then
				addPropertyNames(result, seen, ATMOSPHERE_PROPERTIES)
			end
			if instance:IsA("BloomEffect") then
				addPropertyNames(result, seen, {
					"Enabled",
					"Intensity",
					"Size",
					"Threshold",
				})
			end
			if instance:IsA("ColorCorrectionEffect") then
				addPropertyNames(result, seen, {
					"Enabled",
					"Brightness",
					"Contrast",
					"Saturation",
					"TintColor",
				})
			end
			if instance:IsA("DepthOfFieldEffect") then
				addPropertyNames(result, seen, {
					"Enabled",
					"FarIntensity",
					"FocusDistance",
					"InFocusRadius",
					"NearIntensity",
				})
			end
			if instance:IsA("SunRaysEffect") then
				addPropertyNames(result, seen, {
					"Enabled",
					"Intensity",
					"Spread",
				})
			end
			if instance:IsA("Sky") then
				addPropertyNames(result, seen, {
					"CelestialBodiesShown",
					"MoonAngularSize",
					"MoonTextureId",
					"SkyboxBk",
					"SkyboxDn",
					"SkyboxFt",
					"SkyboxLf",
					"SkyboxRt",
					"SkyboxUp",
					"StarCount",
					"SunAngularSize",
					"SunTextureId",
				})
			end
			if instance:IsA("Highlight") then
				addPropertyNames(result, seen, {
					"Enabled",
					"Adornee",
					"DepthMode",
					"FillColor",
					"FillTransparency",
					"OutlineColor",
					"OutlineTransparency",
				})
			end
			if instance:IsA("Beam")
				or instance:IsA("Trail")
			then
				addPropertyNames(result, seen, {
					"Enabled",
					"Color",
					"LightEmission",
					"LightInfluence",
					"Texture",
					"TextureLength",
					"TextureMode",
					"Transparency",
				})
			end

			table.sort(result)
			return result
		end

		local function safeRead(instance, propertyName)
			local ok, value = pcall(function()
				return instance[propertyName]
			end)

			if ok then
				return true, value
			end
			return false, nil
		end

		local function safeChildren(instance)
			local ok, children = pcall(function()
				return instance:GetChildren()
			end)
			if not ok then
				return {}
			end
			table.sort(children, function(a, b)
				local an = string.lower(a.Name)
				local bn = string.lower(b.Name)
				if an == bn then
					return a.ClassName < b.ClassName
				end
				return an < bn
			end)
			return children
		end

		-- ============================================================
		-- EXPLORER FILTERING
		-- ============================================================

		-- Only show game areas that are useful/editable from this client IDE.
		-- This deliberately hides engine/internal services so the Explorer
		-- looks much closer to a normal Studio project tree.
		-- ============================================================
		-- EXPLORER ROOTS / SERVICE ORDER
		-- ============================================================
		--
		-- Show every DataModel child/service that the current environment can
		-- access. Important gameplay/client services are pinned to the top;
		-- every remaining service is appended alphabetically.
		--
		-- CoreGui is requested explicitly because executor environments can
		-- expose it even when it was not already materialized in game:GetChildren().

		local PRIORITY_ROOT_SERVICES = {
			"Workspace",
			"Players",
			"ReplicatedStorage",
			"ReplicatedFirst",
			"Lighting",
			"CoreGui",
			"StarterGui",
			"StarterPlayer",
			"StarterPack",
			"SoundService",
			"TextChatService",
			"Teams",
		}

		local explorerRootSet = {}

		local function getExplorerRoots()
			local roots = {}
			local seen = {}

			local function addRoot(instance)
				if not instance
					or instance == game
					or seen[instance]
				then
					return
				end

				seen[instance] = true
				explorerRootSet[instance] = true

				table.insert(
					roots,
					instance
				)
			end

			-- Important roots first, in a predictable Studio-like order.
			for _, serviceName in ipairs(
				PRIORITY_ROOT_SERVICES
				) do
				local ok, service =
					pcall(function()
						return game:GetService(
							serviceName
						)
					end)

				if ok and service then
					addRoot(service)
				end
			end

			-- Then expose everything else currently parented to DataModel.
			local otherRoots = {}

			for _, child in ipairs(
				safeChildren(game)
				) do
				if not seen[child] then
					table.insert(
						otherRoots,
						child
					)
				end
			end

			table.sort(
				otherRoots,
				function(a, b)
					local aName =
						string.lower(a.Name)

					local bName =
						string.lower(b.Name)

					if aName == bName then
						return a.ClassName
							< b.ClassName
					end

					return aName < bName
				end
			)

			for _, instance in ipairs(
				otherRoots
				) do
				addRoot(instance)
			end

			return roots
		end

		local function isInsideExplorerRoot(instance)
			local current = instance

			while current
				and current ~= game
			do
				if current.Parent == game then
					-- Every accessible direct DataModel child is now an
					-- Explorer root, not only a curated whitelist.
					return true
				end

				current = current.Parent
			end

			return false
		end

		local function getVisibleChildren(instance)
			if instance == game then
				return getExplorerRoots()
			end

			return safeChildren(instance)
		end

		local function getPath(instance)
			if instance == game then
				return "game"
			end

			local parts = {}
			local current = instance
			local guard = 0

			while current
				and current ~= game
				and guard < 128
			do
				table.insert(parts, 1, current.Name)
				current = current.Parent
				guard += 1
			end

			return "game." .. table.concat(parts, ".")
		end

		local function formatNumber(number)
			if math.abs(number - math.round(number)) < 0.000001 then
				return tostring(math.round(number))
			end
			return string.format("%.4f", number):gsub("0+$", ""):gsub("%.$", "")
		end

		local function formatValue(value)
			local kind = typeof(value)

			if value == nil then
				return "nil"
			elseif kind == "string" then
				return value
			elseif kind == "number" then
				return formatNumber(value)
			elseif kind == "boolean" then
				return value and "true" or "false"
			elseif kind == "Vector2" then
				return table.concat({
					formatNumber(value.X),
					formatNumber(value.Y),
				}, ", ")
			elseif kind == "Vector3" then
				return table.concat({
					formatNumber(value.X),
					formatNumber(value.Y),
					formatNumber(value.Z),
				}, ", ")
			elseif kind == "Color3" then
				return string.format(
					"%d, %d, %d",
					math.round(value.R * 255),
					math.round(value.G * 255),
					math.round(value.B * 255)
				)
			elseif kind == "UDim" then
				return formatNumber(value.Scale)
					.. ", "
					.. formatNumber(value.Offset)
			elseif kind == "UDim2" then
				return table.concat({
					formatNumber(value.X.Scale),
					formatNumber(value.X.Offset),
					formatNumber(value.Y.Scale),
					formatNumber(value.Y.Offset),
				}, ", ")
			elseif kind == "CFrame" then
				local components = {value:GetComponents()}
				local output = {}
				for index, component in ipairs(components) do
					output[index] = formatNumber(component)
				end
				return table.concat(output, ", ")
			elseif kind == "EnumItem" then
				-- EnumType is an Enum object (for example
				-- Enum.ModelStreamingMode), not an object with a Name
				-- property. tostring(EnumItem) already returns the complete
				-- Roblox enum path safely.
				return tostring(value)
			elseif kind == "BrickColor" then
				return value.Name
			elseif kind == "Instance" then
				return getPath(value)
			elseif kind == "NumberRange" then
				return formatNumber(value.Min)
					.. ", "
					.. formatNumber(value.Max)
			end

			local ok, converted = pcall(tostring, value)
			return ok and converted or ("<" .. kind .. ">")
		end

		local function parseNumbers(textValue)
			local values = {}
			for token in textValue:gmatch("[^,%s]+") do
				local number = tonumber(token)
				if not number then
					return nil
				end
				table.insert(values, number)
			end
			return values
		end

		local function parseValue(textValue, currentValue)
			local kind = typeof(currentValue)

			if kind == "string" then
				return true, textValue
			elseif kind == "number" then
				local number = tonumber(textValue)
				return number ~= nil, number
			elseif kind == "boolean" then
				local lowered = string.lower(textValue)
				if lowered == "true" or lowered == "1" then
					return true, true
				elseif lowered == "false" or lowered == "0" then
					return true, false
				end
				return false, nil
			elseif kind == "Vector2" then
				local values = parseNumbers(textValue)
				if values and #values == 2 then
					return true, Vector2.new(values[1], values[2])
				end
			elseif kind == "Vector3" then
				local values = parseNumbers(textValue)
				if values and #values == 3 then
					return true, Vector3.new(values[1], values[2], values[3])
				end
			elseif kind == "Color3" then
				local values = parseNumbers(textValue)
				if values and #values == 3 then
					local maxValue = math.max(values[1], values[2], values[3])
					local divider = maxValue > 1 and 255 or 1
					return true, Color3.new(
						math.clamp(values[1] / divider, 0, 1),
						math.clamp(values[2] / divider, 0, 1),
						math.clamp(values[3] / divider, 0, 1)
					)
				end
			elseif kind == "UDim" then
				local values = parseNumbers(textValue)
				if values and #values == 2 then
					return true, UDim.new(values[1], values[2])
				end
			elseif kind == "UDim2" then
				local values = parseNumbers(textValue)
				if values and #values == 4 then
					return true, UDim2.new(
						values[1], values[2],
						values[3], values[4]
					)
				end
			elseif kind == "CFrame" then
				local values = parseNumbers(textValue)
				if values and #values == 3 then
					return true, CFrame.new(values[1], values[2], values[3])
				elseif values and #values == 12 then
					return true, CFrame.new(table.unpack(values))
				end
			elseif kind == "EnumItem" then
				local wanted =
					textValue:match("([%w_]+)$")
				if wanted then
					for _, enumItem in ipairs(
						currentValue.EnumType:GetEnumItems()
						) do
						if string.lower(enumItem.Name)
							== string.lower(wanted)
						then
							return true, enumItem
						end
					end
				end
			elseif kind == "BrickColor" then
				local ok, brick = pcall(BrickColor.new, textValue)
				if ok then
					return true, brick
				end
			elseif kind == "NumberRange" then
				local values = parseNumbers(textValue)
				if values and #values == 1 then
					return true, NumberRange.new(values[1])
				elseif values and #values == 2 then
					return true, NumberRange.new(values[1], values[2])
				end
			end

			return false, nil
		end

		local function canEditProperty(propertyName, currentValue)
			if READ_ONLY_PROPERTIES[propertyName] then
				return false
			end

			local kind = typeof(currentValue)
			return kind == "string"
				or kind == "number"
				or kind == "boolean"
				or kind == "Vector2"
				or kind == "Vector3"
				or kind == "Color3"
				or kind == "UDim"
				or kind == "UDim2"
				or kind == "CFrame"
				or kind == "EnumItem"
				or kind == "BrickColor"
				or kind == "NumberRange"
		end

		-- Functions used by both the tree and context-menu systems.
		local rebuildTree
		local rebuildProperties
		local refreshTreeSelectionVisuals
		local revealSelectionInTree
		local selectInstanceAdvanced

		-- ============================================================
		-- EXPLORER ICONS
		-- ============================================================

		local function getExplorerIcon(instance)
			if instance == workspace then
				return "W", Color3.fromRGB(90, 160, 255)
			elseif instance:IsA("Lighting") then
				return "L", Color3.fromRGB(255, 196, 92)
			elseif instance:IsA("ReplicatedStorage") then
				return "R", Color3.fromRGB(120, 180, 255)
			elseif instance:IsA("ReplicatedFirst") then
				return "R", Color3.fromRGB(120, 180, 255)
			elseif instance:IsA("Players") then
				return "P", Color3.fromRGB(120, 220, 170)
			elseif instance:IsA("Folder") then
				return "F", Color3.fromRGB(235, 190, 75)
			elseif instance:IsA("Model") then
				return "M", Color3.fromRGB(160, 190, 255)
			elseif instance:IsA("BasePart") then
				return "■", Color3.fromRGB(130, 190, 255)
			elseif instance:IsA("Humanoid") then
				return "H", Color3.fromRGB(110, 220, 150)
			elseif instance:IsA("Camera") then
				return "C", Color3.fromRGB(190, 150, 255)
			elseif instance:IsA("LocalScript") then
				return "L", Color3.fromRGB(110, 220, 145)
			elseif instance:IsA("ModuleScript") then
				return "M", Color3.fromRGB(110, 190, 255)
			elseif instance:IsA("Script") then
				return "S", Color3.fromRGB(255, 200, 90)
			elseif instance:IsA("RemoteEvent") then
				return "E", Color3.fromRGB(255, 125, 125)
			elseif instance:IsA("RemoteFunction") then
				return "R", Color3.fromRGB(255, 125, 125)
			elseif instance:IsA("BindableEvent") then
				return "B", Color3.fromRGB(210, 140, 255)
			elseif instance:IsA("BindableFunction") then
				return "B", Color3.fromRGB(210, 140, 255)
			elseif instance:IsA("Sound") then
				return "♪", Color3.fromRGB(190, 140, 255)
			elseif instance:IsA("Tool") then
				return "T", Color3.fromRGB(255, 175, 90)
			elseif instance:IsA("ScreenGui")
				or instance:IsA("BillboardGui")
				or instance:IsA("SurfaceGui")
			then
				return "UI", Color3.fromRGB(255, 125, 190)
			elseif instance:IsA("GuiObject") then
				return "UI", Color3.fromRGB(235, 120, 185)
			elseif instance:IsA("Attachment") then
				return "A", Color3.fromRGB(110, 220, 220)
			elseif instance:IsA("ParticleEmitter") then
				return "✦", Color3.fromRGB(255, 150, 95)
			elseif instance:IsA("Beam") then
				return "B", Color3.fromRGB(130, 220, 255)
			elseif instance:IsA("Trail") then
				return "T", Color3.fromRGB(130, 220, 255)
			elseif instance:IsA("ProximityPrompt") then
				return "!", Color3.fromRGB(255, 210, 95)
			elseif instance:IsA("ClickDetector") then
				return "+", Color3.fromRGB(255, 210, 95)
			elseif instance:IsA("Highlight") then
				return "H", Color3.fromRGB(255, 230, 100)
			elseif instance:IsA("ValueBase") then
				return "#", Color3.fromRGB(125, 210, 170)
			elseif instance:IsA("Animation") then
				return "▶", Color3.fromRGB(180, 150, 255)
			elseif instance:IsA("Player") then
				return "P", Color3.fromRGB(120, 220, 170)
			end

			return instance.ClassName:sub(1, 1),
				Color3.fromRGB(125, 135, 150)
		end

		-- ============================================================
		-- EXPLORER SETTINGS
		-- ============================================================

		local explorerSettingsPopup =
			ExplorerWindow:FindFirstChild(
				"ExplorerSettingsPopup"
			)

		if not explorerSettingsPopup then
			explorerSettingsPopup =
				Instance.new("Frame")
			explorerSettingsPopup.Name =
				"ExplorerSettingsPopup"
			explorerSettingsPopup.AnchorPoint =
				Vector2.new(1, 0)
			explorerSettingsPopup.Position =
				UDim2.new(1, -8, 0, 40)
			explorerSettingsPopup.Size =
				UDim2.fromOffset(270, 236)
			explorerSettingsPopup.BackgroundColor3 =
				TOP_BG
			explorerSettingsPopup.BorderSizePixel = 0
			explorerSettingsPopup.Visible = false
			explorerSettingsPopup.ZIndex = 70
			explorerSettingsPopup.Parent =
				ExplorerWindow

			local corner =
				Instance.new("UICorner")
			corner.CornerRadius =
				UDim.new(0, 6)
			corner.Parent =
				explorerSettingsPopup

			local stroke =
				Instance.new("UIStroke")
			stroke.Color = BORDER
			stroke.Parent =
				explorerSettingsPopup
		end

		local settingsTitle =
			explorerSettingsPopup:FindFirstChild(
				"Title"
			)

		if not settingsTitle then
			settingsTitle =
				newLabel(
					explorerSettingsPopup,
					"Title",
					"Explorer Settings"
				)
			settingsTitle.Position =
				UDim2.fromOffset(10, 5)
			settingsTitle.Size =
				UDim2.new(1, -20, 0, 24)
			settingsTitle.TextSize = 14
			settingsTitle.ZIndex = 71
		end

		local settingsToggleButtons = {}

		local function updateSettingsToggleVisual(
			button,
			enabled
		)
			button.Text =
				enabled and "ON" or "OFF"

			button.TextColor3 =
				enabled
				and Color3.fromRGB(
					120,
					220,
					160
				)
				or MUTED
		end

		local function createSettingsToggle(
			name,
			labelText,
			y,
			settingName
		)
			local label =
				explorerSettingsPopup:FindFirstChild(
					name .. "Label"
				)

			if not label then
				label =
					newLabel(
						explorerSettingsPopup,
						name .. "Label",
						labelText
					)
				label.Position =
					UDim2.fromOffset(
						10,
						y
					)
				label.Size =
					UDim2.new(
						1,
						-82,
						0,
						28
					)
				label.ZIndex = 71
			end

			local button =
				explorerSettingsPopup:FindFirstChild(
					name
				)

			if not button then
				button =
					newButton(
						explorerSettingsPopup,
						name,
						"OFF"
					)
				button.AnchorPoint =
					Vector2.new(1, 0)
				button.Position =
					UDim2.new(
						1,
						-10,
						0,
						y + 2
					)
				button.Size =
					UDim2.fromOffset(
						58,
						24
					)
				button.ZIndex = 72

				button.MouseButton1Click:Connect(function()
					ExplorerSettings[settingName] =
						not ExplorerSettings[
					settingName
					]

					updateSettingsToggleVisual(
						button,
						ExplorerSettings[
						settingName
						]
					)

					if settingName
						== "ShowClassNames"
					then
						rebuildTree()
					elseif settingName
						== "HighlightWorldSelection"
					then
						if refreshTreeSelectionVisuals then
							refreshTreeSelectionVisuals()
						end
					end
				end)
			end

			settingsToggleButtons[
			settingName
			] = button

			updateSettingsToggleVisual(
				button,
				ExplorerSettings[settingName]
			)
		end

		createSettingsToggle(
			"WorldPick",
			"Pick exact 3D part from world",
			34,
			"WorldPick"
		)

		createSettingsToggle(
			"AutoExpandSelection",
			"Auto-expand selected path",
			66,
			"AutoExpandSelection"
		)

		createSettingsToggle(
			"AutoScrollSelection",
			"Auto-scroll to selected item",
			98,
			"AutoScrollSelection"
		)

		createSettingsToggle(
			"HighlightWorldSelection",
			"Highlight selected 3D object",
			130,
			"HighlightWorldSelection"
		)

		createSettingsToggle(
			"ShowClassNames",
			"Show <ClassName> in tree",
			162,
			"ShowClassNames"
		)

		createSettingsToggle(
			"LiveRefresh",
			"Live hierarchy refresh",
			194,
			"LiveRefresh"
		)

		-- ============================================================
		-- PATH / CLIPBOARD HELPERS
		-- ============================================================

		local function quoteLuaString(value)
			return string.format("%q", value)
		end

		local function getLuaPath(instance)
			if instance == game then
				return "game"
			end

			local chain = {}
			local current = instance

			while current
				and current ~= game
			do
				table.insert(chain, 1, current)
				current = current.Parent
			end

			if #chain == 0 then
				return "nil"
			end

			local first = chain[1]
			local result

			if first.Parent == game then
				result =
					"game:GetService("
					.. quoteLuaString(
						first.ClassName
					)
					.. ")"
			else
				result = "game"
			end

			for index = 2, #chain do
				result =
					result
					.. ":WaitForChild("
					.. quoteLuaString(
						chain[index].Name
					)
					.. ")"
			end

			return result
		end

		local copyDialog =
			ExplorerWindow:FindFirstChild(
				"CopyDialog"
			)

		if not copyDialog then
			copyDialog = Instance.new("Frame")
			copyDialog.Name = "CopyDialog"
			copyDialog.AnchorPoint =
				Vector2.new(0.5, 0.5)
			copyDialog.Position =
				UDim2.fromScale(0.5, 0.5)
			copyDialog.Size =
				UDim2.fromOffset(460, 118)
			copyDialog.BackgroundColor3 = TOP_BG
			copyDialog.BorderSizePixel = 0
			copyDialog.Visible = false
			copyDialog.ZIndex = 80
			copyDialog.Parent = ExplorerWindow

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6)
			corner.Parent = copyDialog

			local stroke = Instance.new("UIStroke")
			stroke.Color = BORDER
			stroke.Parent = copyDialog

			local info =
				newLabel(
					copyDialog,
					"Info",
					"Clipboard API unavailable - press Ctrl+C"
				)
			info.Position =
				UDim2.fromOffset(10, 8)
			info.Size =
				UDim2.new(1, -20, 0, 22)
			info.ZIndex = 81

			local copyBox =
				newTextBox(
					copyDialog,
					"CopyBox",
					""
				)
			copyBox.Position =
				UDim2.fromOffset(10, 36)
			copyBox.Size =
				UDim2.new(1, -20, 0, 34)
			copyBox.ZIndex = 81

			local closeCopy =
				newButton(
					copyDialog,
					"Close",
					"Close"
				)
			closeCopy.AnchorPoint =
				Vector2.new(1, 1)
			closeCopy.Position =
				UDim2.new(1, -10, 1, -10)
			closeCopy.Size =
				UDim2.fromOffset(72, 28)
			closeCopy.ZIndex = 81

			closeCopy.MouseButton1Click:Connect(function()
				copyDialog.Visible = false
			end)
		end

		local function copyText(value)
			local copied = false

			local okEnvironment, environment =
				pcall(function()
					return getfenv()
				end)

			if okEnvironment
				and environment
			then
				local clipboardFunction =
					environment.setclipboard
					or environment.toclipboard
					or environment.writeclipboard

				if type(clipboardFunction)
					== "function"
				then
					local ok =
						pcall(
							clipboardFunction,
							value
						)

					if ok then
						copied = true
					end
				end
			end

			if copied then
				return
			end

			local copyBox =
				copyDialog:FindFirstChild(
					"CopyBox"
				)

			if copyBox
				and copyBox:IsA("TextBox")
			then
				copyBox.Text = value
				copyDialog.Visible = true
				copyBox:CaptureFocus()

				task.defer(function()
					if copyBox:IsFocused() then
						copyBox.CursorPosition =
							#copyBox.Text + 1
						copyBox.SelectionStart = 1
					end
				end)
			end
		end

		-- ============================================================
		-- CONTEXT MENU UI
		-- ============================================================

		local contextMenu =
			ExplorerWindow:FindFirstChild(
				"ExplorerContextMenu"
			)

		if not contextMenu then
			contextMenu = Instance.new("Frame")
			contextMenu.Name =
				"ExplorerContextMenu"
			contextMenu.Size =
				UDim2.fromOffset(258, 100)
			contextMenu.BackgroundColor3 =
				Color3.fromRGB(32, 32, 32)
			contextMenu.BorderSizePixel = 0
			contextMenu.Visible = false
			contextMenu.ZIndex = 60
			contextMenu.Parent = ExplorerWindow

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = contextMenu

			local stroke = Instance.new("UIStroke")
			stroke.Color = BORDER
			stroke.Transparency = 0.05
			stroke.Parent = contextMenu
		end

		local insertMenu =
			ExplorerWindow:FindFirstChild(
				"ExplorerInsertMenu"
			)

		if not insertMenu then
			insertMenu =
				Instance.new("ScrollingFrame")
			insertMenu.Name =
				"ExplorerInsertMenu"
			insertMenu.Size =
				UDim2.fromOffset(220, 360)
			insertMenu.BackgroundColor3 =
				Color3.fromRGB(32, 32, 32)
			insertMenu.BorderSizePixel = 0
			insertMenu.ScrollBarThickness = 5
			insertMenu.CanvasSize =
				UDim2.fromOffset(0, 0)
			insertMenu.AutomaticCanvasSize =
				Enum.AutomaticSize.None
			insertMenu.Visible = false
			insertMenu.ZIndex = 65
			insertMenu.Parent = ExplorerWindow

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 5)
			corner.Parent = insertMenu

			local stroke = Instance.new("UIStroke")
			stroke.Color = BORDER
			stroke.Transparency = 0.05
			stroke.Parent = insertMenu
		end

		local contextTarget = nil
		local insertTarget = nil

		local INSERT_CLASSES = {
			"Folder",
			"Model",
			"Part",
			"MeshPart",
			"Configuration",
			"Attachment",
			"StringValue",
			"BoolValue",
			"IntValue",
			"NumberValue",
			"ObjectValue",
			"Vector3Value",
			"CFrameValue",
			"Color3Value",
			"Sound",
			"ProximityPrompt",
			"ClickDetector",
			"Highlight",
			"ParticleEmitter",
			"Beam",
			"Trail",
			"BillboardGui",
			"SurfaceGui",
			"ScreenGui",
			"Frame",
			"TextLabel",
			"TextButton",
			"ImageLabel",
			"ImageButton",
			"UIListLayout",
			"UIGridLayout",
			"UIPadding",
			"UICorner",
			"UIStroke",
			"RemoteEvent",
			"RemoteFunction",
			"BindableEvent",
			"BindableFunction",
			"Animation",
		}

		local function clearMenuChildren(menu)
			for _, child in ipairs(
				menu:GetChildren()
				) do
				if child:IsA("GuiButton")
					or child.Name == "Separator"
					or child.Name == "MenuLabel"
				then
					child:Destroy()
				end
			end
		end

		local function pointInsideGui(gui, point)
			if not gui.Visible then
				return false
			end

			local position =
				gui.AbsolutePosition
			local size =
				gui.AbsoluteSize

			return point.X >= position.X
				and point.X <= position.X + size.X
				and point.Y >= position.Y
				and point.Y <= position.Y + size.Y
		end

		local function clampMenuPosition(
			gui,
			screenPosition
		)
			local localX =
				screenPosition.X
			- ExplorerWindow.AbsolutePosition.X

			local localY =
				screenPosition.Y
			- ExplorerWindow.AbsolutePosition.Y

			-- math.clamp requires max >= min.
			--
			-- The context menu can now become taller than the Explorer
			-- window because of the extra spatial/world actions. In that
			-- case the old code produced maxY = 0 while still using a
			-- minimum of 4, causing:
			--
			--     invalid argument #3 to 'clamp'
			--
			-- Keep the maximum at least equal to the edge padding.
			local edgePadding = 4

			local maxX =
				math.max(
					edgePadding,
					ExplorerWindow.AbsoluteSize.X
					- gui.AbsoluteSize.X
					- edgePadding
				)

			local maxY =
				math.max(
					edgePadding,
					ExplorerWindow.AbsoluteSize.Y
					- gui.AbsoluteSize.Y
					- edgePadding
				)

			return UDim2.fromOffset(
				math.clamp(
					localX,
					edgePadding,
					maxX
				),
				math.clamp(
					localY,
					edgePadding,
					maxY
				)
			)
		end

		hideContextMenu = function()
			contextMenu.Visible = false
			insertMenu.Visible = false
			contextTarget = nil
			insertTarget = nil
		end

		local function addContextSeparator(y)
			local separator =
				Instance.new("Frame")
			separator.Name = "Separator"
			separator.Position =
				UDim2.fromOffset(8, y + 4)
			separator.Size =
				UDim2.new(1, -16, 0, 1)
			separator.BackgroundColor3 = BORDER
			separator.BorderSizePixel = 0
			separator.ZIndex = 61
			separator.Parent = contextMenu

			return y + 10
		end

		local function addContextButton(
			y,
			textValue,
			callback,
			enabled,
			textColor
		)
			local button =
				Instance.new("TextButton")

			button.Name = "MenuAction"
			button.Position =
				UDim2.fromOffset(4, y)
			button.Size =
				UDim2.new(1, -8, 0, 26)
			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.AutoButtonColor =
				enabled ~= false
			button.Text = textValue
			button.TextXAlignment =
				Enum.TextXAlignment.Left
			button.Font = Enum.Font.Code
			button.TextSize = 13
			button.TextColor3 =
				textColor
				or (
					enabled == false
					and MUTED
					or TEXT
				)
			button.ZIndex = 62
			button.Parent = contextMenu

			local padding =
				Instance.new("UIPadding")
			padding.PaddingLeft =
				UDim.new(0, 10)
			padding.Parent = button

			if enabled ~= false then
				button.MouseEnter:Connect(function()
					button.BackgroundTransparency =
						0.25
					button.BackgroundColor3 =
						Color3.fromRGB(
							55,
							55,
							55
						)
				end)

				button.MouseLeave:Connect(function()
					button.BackgroundTransparency = 1
				end)

				button.MouseButton1Click:Connect(function()
					callback()
				end)
			end

			return y + 27
		end

		local function setSelectionDirect(instance)
			selectedInstance = instance

			if selectionValue then
				selectionValue.Value =
					instance
			end

			if instance then
				selectionInfo.Text =
					instance.ClassName
					.. "  •  "
					.. getPath(instance)
			else
				selectionInfo.Text =
					"No instance selected"
			end

			refreshTreeSelectionVisuals()
			rebuildProperties()
		end

		local function expandAll(instance)
			expanded[instance] = true

			local ok, descendants =
				pcall(function()
					return instance:GetDescendants()
				end)

			if ok then
				local limit =
					math.min(
						#descendants,
						5000
					)

				for index = 1, limit do
					local descendant =
						descendants[index]

					if #safeChildren(descendant) > 0 then
						expanded[descendant] = true
					end
				end
			end

			rebuildTree()
		end

		local function collapseAll(instance)
			expanded[instance] = nil

			local ok, descendants =
				pcall(function()
					return instance:GetDescendants()
				end)

			if ok then
				for _, descendant in ipairs(
					descendants
					) do
					expanded[descendant] = nil
				end
			end

			rebuildTree()
		end

		local function showRenameDialog(instance)
			hideContextMenu()

			local renameDialog =
				ExplorerWindow:FindFirstChild(
					"RenameDialog"
				)

			if not renameDialog then
				renameDialog =
					Instance.new("Frame")
				renameDialog.Name =
					"RenameDialog"
				renameDialog.AnchorPoint =
					Vector2.new(0.5, 0.5)
				renameDialog.Position =
					UDim2.fromScale(0.5, 0.5)
				renameDialog.Size =
					UDim2.fromOffset(340, 120)
				renameDialog.BackgroundColor3 =
					TOP_BG
				renameDialog.BorderSizePixel = 0
				renameDialog.ZIndex = 75
				renameDialog.Parent =
					ExplorerWindow

				local corner =
					Instance.new("UICorner")
				corner.CornerRadius =
					UDim.new(0, 6)
				corner.Parent = renameDialog

				local stroke =
					Instance.new("UIStroke")
				stroke.Color = BORDER
				stroke.Parent = renameDialog

				local label =
					newLabel(
						renameDialog,
						"Label",
						"Rename instance"
					)
				label.Position =
					UDim2.fromOffset(10, 8)
				label.Size =
					UDim2.new(1, -20, 0, 22)
				label.ZIndex = 76

				local inputBox =
					newTextBox(
						renameDialog,
						"Input",
						"Name"
					)
				inputBox.Position =
					UDim2.fromOffset(10, 36)
				inputBox.Size =
					UDim2.new(1, -20, 0, 32)
				inputBox.ZIndex = 76

				local cancel =
					newButton(
						renameDialog,
						"Cancel",
						"Cancel"
					)
				cancel.Position =
					UDim2.new(
						1,
						-164,
						1,
						-38
					)
				cancel.Size =
					UDim2.fromOffset(72, 28)
				cancel.ZIndex = 76

				local apply =
					newButton(
						renameDialog,
						"Apply",
						"Rename"
					)
				apply.Position =
					UDim2.new(
						1,
						-84,
						1,
						-38
					)
				apply.Size =
					UDim2.fromOffset(74, 28)
				apply.ZIndex = 76

				cancel.MouseButton1Click:Connect(function()
					renameDialog.Visible = false
				end)

				apply.MouseButton1Click:Connect(function()
					local target =
						renameDialog:GetAttribute(
							"TargetDebug"
						)

					-- TargetDebug is only a marker; the live target is
					-- stored below on the dialog itself through this closure.
				end)
			end

			local inputBox =
				renameDialog:FindFirstChild("Input")
			local apply =
				renameDialog:FindFirstChild("Apply")

			-- Disconnect/recreate Apply to avoid stacked rename callbacks.
			if apply then
				local replacement =
					apply:Clone()
				replacement.Parent =
					apply.Parent
				apply:Destroy()
				apply = replacement
			end

			if inputBox
				and inputBox:IsA("TextBox")
				and apply
				and apply:IsA("TextButton")
			then
				inputBox.Text = instance.Name
				renameDialog.Visible = true
				inputBox:CaptureFocus()
				inputBox.CursorPosition =
					#inputBox.Text + 1
				inputBox.SelectionStart = 1

				apply.MouseButton1Click:Connect(function()
					local newName =
						inputBox.Text

					if newName ~= "" then
						local ok =
							pcall(function()
								instance.Name = newName
							end)

						if ok then
							renameDialog.Visible = false
							rebuildTree()
							setSelectionDirect(instance)
						end
					end
				end)
			end
		end

		local function showInsertMenu(
			parentInstance
		)
			insertTarget = parentInstance
			clearMenuChildren(insertMenu)

			local y = 4

			for _, className in ipairs(
				INSERT_CLASSES
				) do
				local button =
					Instance.new("TextButton")

				button.Name = "MenuAction"
				button.Position =
					UDim2.fromOffset(4, y)
				button.Size =
					UDim2.new(1, -8, 0, 26)
				button.BackgroundTransparency = 1
				button.BorderSizePixel = 0
				button.AutoButtonColor = true
				button.Text = "+  " .. className
				button.TextColor3 = TEXT
				button.TextXAlignment =
					Enum.TextXAlignment.Left
				button.Font = Enum.Font.Code
				button.TextSize = 13
				button.ZIndex = 66
				button.Parent = insertMenu

				local padding =
					Instance.new("UIPadding")
				padding.PaddingLeft =
					UDim.new(0, 8)
				padding.Parent = button

				button.MouseEnter:Connect(function()
					button.BackgroundTransparency =
						0.25
					button.BackgroundColor3 =
						Color3.fromRGB(
							55,
							55,
							55
						)
				end)

				button.MouseLeave:Connect(function()
					button.BackgroundTransparency = 1
				end)

				button.MouseButton1Click:Connect(function()
					local parent =
						insertTarget

					if not parent then
						return
					end

					local ok, created =
						pcall(function()
							local object =
							Instance.new(
								className
							)
							object.Parent = parent
							return object
						end)

					if ok and created then
						expanded[parent] = true
						selectedInstance = created

						selectionInfo.Text =
							created.ClassName
							.. "  •  "
							.. getPath(created)

						hideContextMenu()
						rebuildTree()
						refreshTreeSelectionVisuals()
						rebuildProperties()
					end
				end)

				y += 27
			end

			insertMenu.CanvasSize =
				UDim2.fromOffset(
					0,
					y + 4
				)

			insertMenu.Visible = true

			local x =
				contextMenu.Position.X.Offset
				+ contextMenu.AbsoluteSize.X
				+ 4

			local yPosition =
				contextMenu.Position.Y.Offset

			if x
				+ insertMenu.AbsoluteSize.X
				> ExplorerWindow.AbsoluteSize.X
			then
				x =
					contextMenu.Position.X.Offset
				- insertMenu.AbsoluteSize.X
				- 4
			end

			insertMenu.Position =
				UDim2.fromOffset(
					math.max(4, x),
					math.clamp(
						yPosition,
						4,
						math.max(
							4,
							ExplorerWindow.AbsoluteSize.Y
							- insertMenu.AbsoluteSize.Y
							- 4
						)
					)
				)
		end

		local function isScriptContainer(instance)
			return instance
				and (
					instance:IsA("Script")
					or instance:IsA("LocalScript")
					or instance:IsA("ModuleScript")
				)
		end

		local function getScriptViewerWindow()
			local existing =
				explorerParent:FindFirstChild(
					"PotassiumScriptViewer"
				)

			if existing then
				return existing
			end

			-- Lazy-load ScriptViewer only when the user chooses
			-- "View Script" from this Explorer context menu.
			-- ScriptViewer intentionally has no MainFrame toolbar button.
			local module =
				script.Parent:FindFirstChild(
					"ScriptViewer"
				)

			if module
				and module:IsA("ModuleScript")
			then
				local okRequire, factory =
					pcall(require, module)

				if okRequire
					and type(factory) == "function"
				then
					pcall(
						factory,
						MainFrame,
						Console_2
					)

					existing =
						explorerParent:FindFirstChild(
							"PotassiumScriptViewer"
						)
				end
			end

			return existing
		end

		local function openScriptInViewer(instance)
			if not isScriptContainer(instance) then
				return
			end

			local viewer =
				getScriptViewerWindow()

			if not viewer then
				warn(
					"[Potassium Explorer] ScriptViewer module/window "
						.. "was not found."
				)
				return
			end

			local request =
				viewer:FindFirstChild(
					"OpenScriptRequest"
				)

			if request
				and request:IsA("BindableEvent")
			then
				request:Fire(instance)
			end
		end

		-- ============================================================
		-- WORLD / SPATIAL CONTEXT ACTIONS
		-- ============================================================

		local function getInstanceWorldCFrame(instance)
			if not instance then
				return nil
			end

			if instance:IsA("BasePart") then
				return instance.CFrame
			end

			if instance:IsA("Attachment") then
				return instance.WorldCFrame
			end

			if instance:IsA("Model") then
				local ok, pivot =
					pcall(function()
						return instance:GetPivot()
					end)

				if ok then
					return pivot
				end
			end

			local partAncestor =
				instance:FindFirstAncestorWhichIsA(
					"BasePart"
				)

			if partAncestor then
				return partAncestor.CFrame
			end

			local modelAncestor =
				instance:FindFirstAncestorWhichIsA(
					"Model"
				)

			if modelAncestor then
				local ok, pivot =
					pcall(function()
						return modelAncestor:GetPivot()
					end)

				if ok then
					return pivot
				end
			end

			return nil
		end

		local function getInstanceWorldSize(instance)
			if not instance then
				return Vector3.zero
			end

			if instance:IsA("BasePart") then
				return instance.Size
			end

			if instance:IsA("Model") then
				local ok, size =
					pcall(function()
						local _, modelSize =
						instance:GetBoundingBox()

						return modelSize
					end)

				if ok then
					return size
				end
			end

			return Vector3.zero
		end

		local function getLocalCharacter()
			local localPlayer =
				Players.LocalPlayer

			if not localPlayer then
				return nil
			end

			return localPlayer.Character
		end

		local function teleportCharacterToInstance(instance)
			local character =
				getLocalCharacter()

			if not character then
				return false
			end

			local targetCFrame =
				getInstanceWorldCFrame(
					instance
				)

			if not targetCFrame then
				return false
			end

			local targetSize =
				getInstanceWorldSize(
					instance
				)

			local verticalOffset =
				math.max(
					4,
					(targetSize.Y * 0.5) + 3
				)

			local destination =
				CFrame.new(
					targetCFrame.Position
					+ Vector3.new(
						0,
						verticalOffset,
						0
					)
				)

			local ok =
				pcall(function()
					character:PivotTo(
						destination
					)
				end)

			return ok
		end

		local function moveInstanceToCharacter(instance)
			local character =
				getLocalCharacter()

			if not character then
				return false
			end

			local characterPivot =
				character:GetPivot()

			local destination =
				characterPivot
				* CFrame.new(
					0,
					0,
					-6
				)

			if instance:IsA("BasePart") then
				return pcall(function()
					instance.CFrame =
						destination
				end)
			end

			if instance:IsA("Model") then
				return pcall(function()
					instance:PivotTo(
						destination
					)
				end)
			end

			return false
		end

		local function focusCameraOnInstance(instance)
			local camera =
				workspace.CurrentCamera

			local targetCFrame =
				getInstanceWorldCFrame(
					instance
				)

			if not camera
				or not targetCFrame
			then
				return false
			end

			local targetSize =
				getInstanceWorldSize(
					instance
				)

			local radius =
				math.max(
					8,
					targetSize.Magnitude
					* 1.2
				)

			local targetPosition =
				targetCFrame.Position

			local cameraPosition =
				targetPosition
				+ Vector3.new(
					radius,
					radius * 0.65,
					radius
				)

			-- This is a one-shot camera focus. Roblox's normal camera
			-- controller may continue controlling the camera afterwards.
			return pcall(function()
				camera.CFrame =
					CFrame.lookAt(
						cameraPosition,
						targetPosition
					)

				camera.Focus =
					CFrame.new(
						targetPosition
					)
			end)
		end

		local function copyWorldPosition(instance)
			local targetCFrame =
				getInstanceWorldCFrame(
					instance
				)

			if not targetCFrame then
				return
			end

			local p =
				targetCFrame.Position

			copyText(
				string.format(
					"Vector3.new(%.6f, %.6f, %.6f)",
					p.X,
					p.Y,
					p.Z
				)
			)
		end

		local function copyWorldCFrame(instance)
			local targetCFrame =
				getInstanceWorldCFrame(
					instance
				)

			if not targetCFrame then
				return
			end

			local components = {
				targetCFrame:GetComponents(),
			}

			for index, value in ipairs(
				components
				) do
				components[index] =
					string.format(
						"%.6f",
						value
					)
			end

			copyText(
				"CFrame.new("
					.. table.concat(
						components,
						", "
					)
					.. ")"
			)
		end

		local function selectContainingModel(instance)
			if not instance then
				return
			end

			local model =
				instance:IsA("Model")
				and instance
				or instance:FindFirstAncestorWhichIsA(
					"Model"
				)

			if model then
				selectInstanceAdvanced(
					model,
					true,
					true
				)
			end
		end

		showContextMenu = function(
			instance,
			screenPosition
		)
			contextTarget = instance
			insertMenu.Visible = false

			-- Right click also selects the target.
			setSelectionDirect(instance)

			clearMenuChildren(contextMenu)

			local y = 4
			local children =
				getVisibleChildren(instance)
			local hasChildren =
				#children > 0

			if isScriptContainer(instance) then
				y = addContextButton(
					y,
					"View Script",
					function()
						hideContextMenu()
						openScriptInViewer(
							instance
						)
					end,
					true,
					ACCENT
				)

				y = addContextSeparator(y)
			end

			local worldCFrame =
				getInstanceWorldCFrame(
					instance
				)

			if worldCFrame then
				y = addContextButton(
					y,
					"Teleport To",
					function()
						teleportCharacterToInstance(
							instance
						)

						hideContextMenu()
					end,
					true,
					Color3.fromRGB(
						120,
						220,
						160
					)
				)

				y = addContextButton(
					y,
					"Focus Camera",
					function()
						focusCameraOnInstance(
							instance
						)

						hideContextMenu()
					end,
					true
				)

				y = addContextButton(
					y,
					"Copy Position",
					function()
						copyWorldPosition(
							instance
						)

						hideContextMenu()
					end,
					true
				)

				y = addContextButton(
					y,
					"Copy CFrame",
					function()
						copyWorldCFrame(
							instance
						)

						hideContextMenu()
					end,
					true
				)

				if instance:IsA("BasePart")
					or instance:IsA("Model")
				then
					y = addContextButton(
						y,
						"Bring To Player",
						function()
							moveInstanceToCharacter(
								instance
							)

							hideContextMenu()
							rebuildProperties()
						end,
						true
					)
				end

				local containingModel =
					instance:IsA("Model")
					and instance
					or instance:FindFirstAncestorWhichIsA(
						"Model"
					)

				if containingModel
					and containingModel ~= instance
				then
					y = addContextButton(
						y,
						"Select Model",
						function()
							hideContextMenu()
							selectContainingModel(
								instance
							)
						end,
						true
					)
				end

				if instance:IsA("Model")
					and instance.PrimaryPart
				then
					y = addContextButton(
						y,
						"Select PrimaryPart",
						function()
							local primary =
								instance.PrimaryPart

							hideContextMenu()

							if primary then
								selectInstanceAdvanced(
									primary,
									true,
									true
								)
							end
						end,
						true
					)
				end

				y = addContextSeparator(y)
			end

			y = addContextButton(
				y,
				"Copy Path",
				function()
					copyText(
						getPath(instance)
					)
					hideContextMenu()
				end,
				true
			)

			y = addContextButton(
				y,
				"Copy Luau Reference",
				function()
					copyText(
						getLuaPath(instance)
					)
					hideContextMenu()
				end,
				true
			)

			y = addContextButton(
				y,
				"Copy Name",
				function()
					copyText(instance.Name)
					hideContextMenu()
				end,
				true
			)

			y = addContextButton(
				y,
				"Copy ClassName",
				function()
					copyText(instance.ClassName)
					hideContextMenu()
				end,
				true
			)

			y = addContextButton(
				y,
				"Copy Debug Info",
				function()
					local lines = {
						"Name: " .. instance.Name,
						"ClassName: " .. instance.ClassName,
						"Path: " .. getPath(instance),
						"Luau: " .. getLuaPath(instance),
					}

					local cf =
						getInstanceWorldCFrame(
							instance
						)

					if cf then
						local p = cf.Position

						table.insert(
							lines,
							string.format(
								"Position: %.3f, %.3f, %.3f",
								p.X,
								p.Y,
								p.Z
							)
						)
					end

					copyText(
						table.concat(
							lines,
							"\n"
						)
					)

					hideContextMenu()
				end,
				true
			)

			y = addContextSeparator(y)

			if hasChildren then
				y = addContextButton(
					y,
					expanded[instance]
						and "Collapse"
						or "Expand",
					function()
						if expanded[instance] then
							expanded[instance] = nil
						else
							expanded[instance] = true
						end

						hideContextMenu()
						rebuildTree()
					end,
					true
				)

				y = addContextButton(
					y,
					"Expand All Descendants",
					function()
						hideContextMenu()
						expandAll(instance)
					end,
					true
				)

				y = addContextButton(
					y,
					"Collapse Descendants",
					function()
						hideContextMenu()
						collapseAll(instance)
					end,
					true
				)
			end

			y = addContextButton(
				y,
				"Select Parent",
				function()
					local parent = instance.Parent

					if parent
						and parent ~= game
					then
						hideContextMenu()
						setSelectionDirect(parent)
					end
				end,
				instance.Parent ~= nil
					and instance.Parent ~= game
			)

			y = addContextSeparator(y)

			y = addContextButton(
				y,
				"Insert Object  ▶",
				function()
					showInsertMenu(instance)
				end,
				true
			)

			y = addContextButton(
				y,
				"Duplicate",
				function()
					local parent = instance.Parent

					if not parent then
						return
					end

					local ok, clone =
						pcall(function()
							local duplicate =
							instance:Clone()
							duplicate.Name =
							instance.Name .. " Copy"
							duplicate.Parent = parent
							return duplicate
						end)

					if ok and clone then
						expanded[parent] = true
						hideContextMenu()
						selectedInstance = clone
						rebuildTree()
						setSelectionDirect(clone)
					end
				end,
				instance.Parent ~= game
			)

			y = addContextButton(
				y,
				"Rename",
				function()
					showRenameDialog(instance)
				end,
				instance.Parent ~= game
			)

			local okAnchored, anchored =
				safeRead(
					instance,
					"Anchored"
				)

			if okAnchored
				and typeof(anchored)
				== "boolean"
			then
				y = addContextButton(
					y,
					anchored
						and "Unanchor"
						or "Anchor",
					function()
						pcall(function()
							instance.Anchored =
								not anchored
						end)

						hideContextMenu()
						rebuildProperties()
					end,
					true
				)
			end

			local okVisible, visible =
				safeRead(
					instance,
					"Visible"
				)

			if okVisible
				and typeof(visible)
				== "boolean"
			then
				y = addContextButton(
					y,
					visible
						and "Hide"
						or "Show",
					function()
						pcall(function()
							instance.Visible =
								not visible
						end)

						hideContextMenu()
						rebuildProperties()
					end,
					true
				)
			end

			local okEnabled, enabled =
				safeRead(
					instance,
					"Enabled"
				)

			if okEnabled
				and typeof(enabled)
				== "boolean"
			then
				y = addContextButton(
					y,
					enabled
						and "Disable"
						or "Enable",
					function()
						pcall(function()
							instance.Enabled =
								not enabled
						end)

						hideContextMenu()
						rebuildProperties()
					end,
					true
				)
			end

			y = addContextSeparator(y)

			y = addContextButton(
				y,
				"Refresh",
				function()
					hideContextMenu()
					rebuildTree()
					rebuildProperties()
				end,
				true
			)

			y = addContextButton(
				y,
				"Delete",
				function()
					if instance.Parent == game then
						return
					end

					local parent =
						instance.Parent

					local ok =
						pcall(function()
							instance:Destroy()
						end)

					if ok then
						selectedInstance = parent

						if parent
							and parent ~= game
						then
							selectionInfo.Text =
								parent.ClassName
								.. "  •  "
								.. getPath(parent)
						else
							selectionInfo.Text =
								"No instance selected"
						end

						hideContextMenu()
						rebuildTree()
						rebuildProperties()
					end
				end,
				instance.Parent ~= game,
				DANGER
			)

			contextMenu.Size =
				UDim2.fromOffset(
					244,
					y + 4
				)

			contextMenu.Position =
				clampMenuPosition(
					contextMenu,
					screenPosition
				)

			contextMenu.Visible = true
		end

		local function clearRows(rows)
			for _, row in ipairs(rows) do
				if row and row.Parent then
					row:Destroy()
				end
			end
			table.clear(rows)
		end

		refreshTreeSelectionVisuals = function()
			if selectionValue then
				selectionValue.Value =
					selectedInstance
			end

			if worldSelectionHighlight then
				local adornee = nil

				if ExplorerSettings.HighlightWorldSelection
					and selectedInstance
				then
					if selectedInstance:IsA("BasePart")
						or selectedInstance:IsA("Model")
					then
						adornee = selectedInstance
					else
						adornee =
							selectedInstance:FindFirstAncestorOfClass(
								"Model"
							)
					end
				end

				worldSelectionHighlight.Adornee =
					adornee

				worldSelectionHighlight.Enabled =
					adornee ~= nil
			end

			for _, row in ipairs(treeRows) do
				if row and row.Parent then
					local rowInstance =
						treeRowInstances[row]

					local selected =
						rowInstance == selectedInstance

					row.BackgroundColor3 =
						selected
						and ROW_SELECTED_BG
						or ROW_BG

					row.BackgroundTransparency =
						selected
						and 0.05
						or 1

					local nameLabel =
						row:FindFirstChild("Name")

					if nameLabel
						and nameLabel:IsA("TextLabel")
					then
						nameLabel.TextColor3 =
							selected
							and Color3.fromRGB(
								240,
								240,
								240
							)
							or TEXT
					end
				end
			end
		end

		local function addSelectionToHistory(instance)
			if applyingHistorySelection
				or not instance
			then
				return
			end

			if selectionHistory[
				selectionHistoryIndex
				] == instance
			then
				return
			end

			while #selectionHistory
				> selectionHistoryIndex
			do
				table.remove(
					selectionHistory
				)
			end

			table.insert(
				selectionHistory,
				instance
			)

			if #selectionHistory > 50 then
				table.remove(
					selectionHistory,
					1
				)
			end

			selectionHistoryIndex =
				#selectionHistory
		end

		local function expandAncestors(instance)
			if not instance then
				return
			end

			local current =
				instance.Parent

			while current
				and current ~= game
			do
				expanded[current] = true
				current = current.Parent
			end
		end

		selectInstanceAdvanced = function(
			instance,
			revealInTree,
			addHistory
		)
			selectedInstance = instance

			if instance then
				selectionInfo.Text =
					instance.ClassName
					.. "  •  "
					.. getPath(instance)
			else
				selectionInfo.Text =
					"No instance selected"
			end

			if addHistory ~= false then
				addSelectionToHistory(
					instance
				)
			end

			if revealInTree
				and instance
			then
				if ExplorerSettings.AutoExpandSelection then
					expandAncestors(
						instance
					)
				end

				rebuildTree()

				if revealSelectionInTree then
					task.defer(
						revealSelectionInTree
					)
				end
			else
				refreshTreeSelectionVisuals()
			end

			rebuildProperties()
		end

		local function selectInstance(instance)
			selectInstanceAdvanced(
				instance,
				false,
				true
			)
		end

		-- ============================================================
		-- TREE DRAG/DROP UI
		-- ============================================================

		local treeDragGhost =
			ExplorerWindow:FindFirstChild(
				"TreeDragGhost"
			)

		if not treeDragGhost then
			treeDragGhost =
				Instance.new("TextLabel")

			treeDragGhost.Name =
				"TreeDragGhost"
			treeDragGhost.Size =
				UDim2.fromOffset(
					230,
					26
				)

			-- Dragged item follows the cursor exactly.
			treeDragGhost.AnchorPoint =
				Vector2.new(0.5, 0.5)
			treeDragGhost.BackgroundColor3 =
				Color3.fromRGB(
					45,
					45,
					45
				)
			treeDragGhost.BackgroundTransparency =
				0.08
			treeDragGhost.BorderSizePixel = 0
			treeDragGhost.TextColor3 = TEXT
			treeDragGhost.Font = Enum.Font.Code
			treeDragGhost.TextSize = 13
			treeDragGhost.TextXAlignment =
				Enum.TextXAlignment.Left
			treeDragGhost.TextTruncate =
				Enum.TextTruncate.AtEnd
			treeDragGhost.Visible = false
			treeDragGhost.ZIndex = 90
			treeDragGhost.Parent =
				ExplorerWindow

			local padding =
				Instance.new("UIPadding")
			padding.PaddingLeft =
				UDim.new(0, 8)
			padding.Parent = treeDragGhost

			local corner =
				Instance.new("UICorner")
			corner.CornerRadius =
				UDim.new(0, 5)
			corner.Parent = treeDragGhost

			local stroke =
				Instance.new("UIStroke")
			stroke.Color = ACCENT
			stroke.Transparency = 0.15
			stroke.Parent = treeDragGhost
		end

		local treeDropHighlight =
			treeScroll:FindFirstChild(
				"TreeDropHighlight"
			)

		if not treeDropHighlight then
			treeDropHighlight =
				Instance.new("Frame")
			treeDropHighlight.Name =
				"TreeDropHighlight"
			treeDropHighlight.Size =
				UDim2.new(
					1,
					-4,
					0,
					24
				)
			treeDropHighlight.BackgroundColor3 =
				ACCENT
			treeDropHighlight.BackgroundTransparency =
				0.72
			treeDropHighlight.BorderSizePixel = 0
			treeDropHighlight.Visible = false
			treeDropHighlight.ZIndex = 20
			treeDropHighlight.Parent =
				treeScroll

			local stroke =
				Instance.new("UIStroke")
			stroke.Color = ACCENT
			stroke.Thickness = 1
			stroke.Parent = treeDropHighlight
		end

		local function canDropInstanceOn(
			moving,
			target
		)
			if not moving
				or not target
			then
				return false
			end

			-- Root services are not movable.
			if moving.Parent == game then
				return false
			end

			if moving == target then
				return false
			end

			-- Never allow an instance to become a child of one of its own
			-- descendants.
			if target:IsDescendantOf(moving) then
				return false
			end

			if moving.Parent == target then
				return false
			end

			return true
		end

		local function getTreeRowUnderPoint(
			screenPoint
		)
			local position =
				treeScroll.AbsolutePosition
			local size =
				treeScroll.AbsoluteSize

			if screenPoint.X < position.X
				or screenPoint.X
				> position.X + size.X
				or screenPoint.Y < position.Y
				or screenPoint.Y
				> position.Y + size.Y
			then
				return nil, nil
			end

			local documentY =
				treeScroll.CanvasPosition.Y
				+ (
					screenPoint.Y
					- position.Y
				)

			local index =
				math.floor(
					math.max(
						0,
						documentY
					) / 24
				)
				+ 1

			local row =
				treeRows[index]

			if not row
				or not row.Parent
			then
				return nil, nil
			end

			return row,
				treeRowInstances[row]
		end

		local function updateTreeDragTarget(
			screenPoint
		)
			local row, target =
				getTreeRowUnderPoint(
					screenPoint
				)

			if row
				and canDropInstanceOn(
					draggingTreeInstance,
					target
				)
			then
				dragDropTarget = target
				treeDropHighlight.Position =
					row.Position
				treeDropHighlight.Visible =
					true
			else
				dragDropTarget = nil
				treeDropHighlight.Visible =
					false
			end
		end

		local function cancelTreeDrag()
			pendingTreeDragInstance = nil
			pendingTreeDragStart = nil
			draggingTreeInstance = nil
			dragDropTarget = nil

			treeDragGhost.Visible = false
			treeDropHighlight.Visible = false
		end

		local function finishTreeDrag()
			local moving =
				draggingTreeInstance
			local target =
				dragDropTarget

			if moving
				and target
				and canDropInstanceOn(
					moving,
					target
				)
			then
				local ok =
					pcall(function()
						moving.Parent = target
					end)

				if ok then
					expanded[target] = true
					selectedInstance = moving

					selectionInfo.Text =
						moving.ClassName
						.. "  •  "
						.. getPath(moving)

					if selectionValue then
						selectionValue.Value =
							moving
					end

					cancelTreeDrag()
					rebuildTree()
					refreshTreeSelectionVisuals()
					rebuildProperties()
					return
				end
			end

			cancelTreeDrag()
		end

		local function addTreeRow(
			instance,
			depth,
			searchMode
		)
			if #treeRows >= MAX_TREE_ROWS then
				return nil
			end

			local children = {}

			if not searchMode then
				children =
					getVisibleChildren(
						instance
					)
			end

			local hasChildren =
				#children > 0

			local indent =
				depth * 16

			-- The row is the selection hitbox.
			-- The arrow is a separate higher-ZIndex TextButton used only
			-- for expand/collapse.
			local row =
				Instance.new("TextButton")

			row.Name = "TreeRow"
			row.Text = ""
			row.AutoButtonColor = false
			row.Active = true
			row.Selectable = false

			row.Position =
				UDim2.fromOffset(
					0,
					#treeRows * 24
				)

			row.Size =
				UDim2.new(
					1,
					-4,
					0,
					24
				)

			row.BackgroundColor3 =
				instance == selectedInstance
				and ROW_SELECTED_BG
				or ROW_BG

			row.BackgroundTransparency =
				instance == selectedInstance
				and 0.05
				or 1

			row.BorderSizePixel = 0
			row.ZIndex = 7
			row.Parent = treeScroll

			table.insert(
				treeRows,
				row
			)

			treeRowInstances[row] =
				instance

			if depth > 0 then
				local guide =
					Instance.new("Frame")

				guide.Name = "Guide"
				guide.Position =
					UDim2.fromOffset(
						indent - 7,
						0
					)

				guide.Size =
					UDim2.fromOffset(
						1,
						24
					)

				guide.BackgroundColor3 =
					Color3.fromRGB(
						58,
						58,
						58
					)

				guide.BackgroundTransparency =
					0.35

				guide.BorderSizePixel = 0
				guide.ZIndex = 8
				guide.Parent = row
			end

			-- The arrow is the ONLY expand/collapse control.
			-- A normal row click only selects the instance.
			local arrow =
				Instance.new("TextButton")

			arrow.Name = "Arrow"
			arrow.BackgroundTransparency = 1
			arrow.BorderSizePixel = 0
			arrow.AutoButtonColor = false
			arrow.Active = hasChildren
			arrow.Selectable = false

			arrow.Position =
				UDim2.fromOffset(
					indent,
					0
				)

			arrow.Size =
				UDim2.fromOffset(
					22,
					24
				)

			arrow.Font =
				Enum.Font.SourceSansBold

			arrow.TextSize = 14
			arrow.TextColor3 = MUTED
			arrow.TextXAlignment =
				Enum.TextXAlignment.Center

			arrow.TextYAlignment =
				Enum.TextYAlignment.Center

			arrow.Text =
				hasChildren
				and (
					expanded[instance]
					and "▼"
					or "▶"
				)
				or ""

			-- Keep the arrow above the row selection button so the row
			-- can never steal the arrow click.
			arrow.ZIndex = 12
			arrow.Parent = row

			if hasChildren
				and not searchMode
			then
				arrow.MouseButton1Down:Connect(function()
					if expanded[instance] then
						expanded[instance] = nil
					else
						expanded[instance] = true
					end

					rebuildTree()
				end)
			end

			-- Right-clicking directly on the arrow should still open the
			-- normal Explorer context menu for this instance.
			arrow.InputBegan:Connect(function(inputObject)
				if inputObject.UserInputType
					~= Enum.UserInputType.MouseButton2
				then
					return
				end

				showContextMenu(
					instance,
					Vector2.new(
						inputObject.Position.X,
						inputObject.Position.Y
					)
				)
			end)

			local iconText, iconColor =
				getExplorerIcon(instance)

			local icon =
				Instance.new("TextLabel")

			icon.Name = "Icon"
			icon.Position =
				UDim2.fromOffset(
					indent + 24,
					3
				)
			icon.Size =
				UDim2.fromOffset(
					18,
					18
				)
			icon.BackgroundColor3 = iconColor
			icon.BackgroundTransparency = 0.1
			icon.BorderSizePixel = 0
			icon.Text = iconText
			icon.TextColor3 =
				Color3.fromRGB(
					245,
					245,
					245
				)
			icon.Font = Enum.Font.SourceSansBold
			icon.TextSize =
				#iconText > 1 and 9 or 11
			icon.ZIndex = 8
			icon.Parent = row

			local iconCorner =
				Instance.new("UICorner")
			iconCorner.CornerRadius =
				UDim.new(0, 4)
			iconCorner.Parent = icon

			local nameLabel =
				Instance.new("TextLabel")

			nameLabel.Name = "Name"
			nameLabel.BackgroundTransparency = 1
			nameLabel.BorderSizePixel = 0

			nameLabel.Position =
				UDim2.fromOffset(
					indent + 48,
					0
				)

			nameLabel.Size =
				UDim2.new(
					1,
					-(indent + 50),
					1,
					0
				)

			nameLabel.Font = Enum.Font.Code
			nameLabel.TextSize = 13
			nameLabel.TextXAlignment =
				Enum.TextXAlignment.Left

			nameLabel.TextYAlignment =
				Enum.TextYAlignment.Center

			nameLabel.TextTruncate =
				Enum.TextTruncate.AtEnd

			nameLabel.Text =
				ExplorerSettings.ShowClassNames
				and (
					instance.Name
					.. "  <"
					.. instance.ClassName
					.. ">"
				)
				or instance.Name

			nameLabel.TextColor3 =
				instance == selectedInstance
				and Color3.fromRGB(
					240,
					240,
					240
				)
				or TEXT

			nameLabel.ZIndex = 8
			nameLabel.Parent = row

			-- Clicking the row only selects/highlights it.
			-- Expansion is handled exclusively by the arrow TextButton.
			row.MouseButton1Down:Connect(function(x, y)
				selectInstanceAdvanced(
					instance,
					false,
					true
				)

				-- Services directly under game are protected from dragging.
				if instance.Parent ~= game then
					pendingTreeDragInstance =
						instance

					pendingTreeDragStart =
						Vector2.new(
							x,
							y
						)
				end
			end)

			row.InputBegan:Connect(function(inputObject)
				if inputObject.UserInputType
					~= Enum.UserInputType.MouseButton2
				then
					return
				end

				local screenPosition =
					Vector2.new(
						inputObject.Position.X,
						inputObject.Position.Y
					)

				showContextMenu(
					instance,
					screenPosition
				)
			end)

			return children
		end

		rebuildTree = function()
			clearRows(treeRows)
			table.clear(treeRowInstances)

			-- clearRows only owns actual tree rows; keep overlays alive.
			if treeDropHighlight then
				treeDropHighlight.Visible = false
				treeDropHighlight.Parent =
					treeScroll
			end

			if not ExplorerWindow.Visible then
				return
			end

			local searchText =
				string.lower(
					treeSearch.Text
					or ""
				)

			if searchText ~= "" then
				-- Search across every accessible Explorer root.
				local queue =
					getExplorerRoots()

				local index = 1
				local scanned = 0
				local results = 0

				while index <= #queue
					and scanned < MAX_SEARCH_SCAN
					and results < MAX_SEARCH_RESULTS
				do
					local instance =
						queue[index]

					index += 1
					scanned += 1

					local nameMatch =
						string.find(
							string.lower(
								instance.Name
							),
							searchText,
							1,
							true
						)

					local classMatch =
						string.find(
							string.lower(
								instance.ClassName
							),
							searchText,
							1,
							true
						)

					if nameMatch
						or classMatch
					then
						addTreeRow(
							instance,
							0,
							true
						)

						results += 1
					end

					for _, child in ipairs(
						getVisibleChildren(
							instance
						)
						) do
						if #queue
							< MAX_SEARCH_SCAN
						then
							table.insert(
								queue,
								child
							)
						end
					end
				end

			else
				local function visit(
					instance,
					depth
				)
					if #treeRows
						>= MAX_TREE_ROWS
					then
						return
					end

					local children =
						addTreeRow(
							instance,
							depth,
							false
						)

					-- This is the actual dropdown behaviour:
					-- children do not exist visually until the parent arrow
					-- is opened.
					if expanded[instance]
						and children
					then
						for _, child in ipairs(
							children
							) do
							visit(
								child,
								depth + 1
							)

							if #treeRows
								>= MAX_TREE_ROWS
							then
								break
							end
						end
					end
				end

				-- Do not show "game" as one giant expanded root.
				-- Show all accessible services directly, with important ones first.
				for _, root in ipairs(
					getExplorerRoots()
					) do
					visit(root, 0)

					if #treeRows
						>= MAX_TREE_ROWS
					then
						break
					end
				end
			end

			treeScroll.CanvasSize =
				UDim2.fromOffset(
					0,
					#treeRows * 24 + 4
				)
		end

		local function addPropertyHeader(textValue)
			local row = Instance.new("Frame")
			row.Name = "PropertyHeader"
			row.Position = UDim2.fromOffset(0, #propertyRows * 26)
			row.Size = UDim2.new(1, -4, 0, 26)
			row.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
			row.BorderSizePixel = 0
			row.ZIndex = 6
			row.Parent = propertyScroll
			table.insert(propertyRows, row)

			local label = newLabel(row, "Text", textValue)
			label.Position = UDim2.fromOffset(8, 0)
			label.Size = UDim2.new(1, -16, 1, 0)
			label.TextColor3 = ACCENT
		end

		local function flashInvalid(widget)
			local original = widget.BackgroundColor3
			widget.BackgroundColor3 = DANGER
			task.delay(0.18, function()
				if widget and widget.Parent then
					widget.BackgroundColor3 = original
				end
			end)
		end

		local function addPropertyRow(instance, propertyName, value, attribute)
			local row = Instance.new("Frame")
			row.Name = "PropertyRow"
			row.Position = UDim2.fromOffset(0, #propertyRows * 26)
			row.Size = UDim2.new(1, -4, 0, 26)
			row.BackgroundTransparency = 1
			row.BorderSizePixel = 0
			row.ZIndex = 6
			row.Parent = propertyScroll
			table.insert(propertyRows, row)

			local nameLabel = newLabel(row, "Name", propertyName)
			nameLabel.Position = UDim2.fromOffset(8, 0)
			nameLabel.Size = UDim2.new(0.43, -10, 1, 0)
			nameLabel.TextColor3 = attribute and ACCENT or TEXT
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd

			local separator = Instance.new("Frame")
			separator.Name = "Separator"
			separator.Position = UDim2.new(0.43, 0, 0, 3)
			separator.Size = UDim2.fromOffset(1, 20)
			separator.BackgroundColor3 = BORDER
			separator.BorderSizePixel = 0
			separator.ZIndex = 6
			separator.Parent = row

			local kind = typeof(value)
			local editable =
				attribute
				or canEditProperty(propertyName, value)

			if kind == "boolean" and editable then
				local valueButton = newButton(
					row,
					"Value",
					value and "true" or "false"
				)
				valueButton.Position = UDim2.new(0.43, 6, 0, 2)
				valueButton.Size = UDim2.new(0.57, -12, 0, 22)
				valueButton.TextXAlignment = Enum.TextXAlignment.Left

				local valuePadding = Instance.new("UIPadding")
				valuePadding.PaddingLeft = UDim.new(0, 6)
				valuePadding.Parent = valueButton

				valueButton.MouseButton1Click:Connect(function()
					local newValue = not value
					local ok
					if attribute then
						ok = pcall(function()
							instance:SetAttribute(propertyName, newValue)
						end)
					else
						ok = pcall(function()
							instance[propertyName] = newValue
						end)
					end

					if ok then
						rebuildProperties()
						if propertyName == "Name" then
							rebuildTree()
						end
					else
						flashInvalid(valueButton)
					end
				end)

			elseif kind == "Instance" and value then
				local valueButton = newButton(
					row,
					"Value",
					formatValue(value)
				)
				valueButton.Position = UDim2.new(0.43, 6, 0, 2)
				valueButton.Size = UDim2.new(0.57, -12, 0, 22)
				valueButton.TextXAlignment = Enum.TextXAlignment.Left
				valueButton.TextTruncate = Enum.TextTruncate.AtEnd
				valueButton.TextColor3 = ACCENT

				local valuePadding = Instance.new("UIPadding")
				valuePadding.PaddingLeft = UDim.new(0, 6)
				valuePadding.Parent = valueButton

				valueButton.MouseButton1Click:Connect(function()
					selectInstance(value)
				end)

			else
				local valueBox = newTextBox(row, "Value", "")
				valueBox.Position = UDim2.new(0.43, 6, 0, 2)
				valueBox.Size = UDim2.new(0.57, -12, 0, 22)
				valueBox.Text = formatValue(value)
				valueBox.TextEditable = editable
				valueBox.ClearTextOnFocus = false
				valueBox.TextColor3 =
					editable and TEXT or MUTED
				valueBox.BackgroundTransparency =
					editable and 0 or 0.55

				if editable then
					valueBox.FocusLost:Connect(function()
						local currentValue
						if attribute then
							currentValue =
								instance:GetAttribute(propertyName)
						else
							local okRead, latest =
								safeRead(instance, propertyName)
							if not okRead then
								flashInvalid(valueBox)
								return
							end
							currentValue = latest
						end

						local okParse, parsed =
							parseValue(
								valueBox.Text,
								currentValue
							)

						if not okParse then
							valueBox.Text = formatValue(currentValue)
							flashInvalid(valueBox)
							return
						end

						local okWrite
						if attribute then
							okWrite = pcall(function()
								instance:SetAttribute(
									propertyName,
									parsed
								)
							end)
						else
							okWrite = pcall(function()
								instance[propertyName] = parsed
							end)
						end

						if okWrite then
							valueBox.Text = formatValue(parsed)
							if propertyName == "Name" then
								rebuildTree()
								selectionInfo.Text =
									instance.ClassName
									.. "  •  "
									.. getPath(instance)
							end
						else
							flashInvalid(valueBox)
							valueBox.Text = formatValue(currentValue)
						end
					end)
				end
			end
		end

		revealSelectionInTree = function()
			if not selectedInstance then
				return
			end

			local selectedRow = nil

			for _, row in ipairs(
				treeRows
				) do
				if treeRowInstances[row]
					== selectedInstance
				then
					selectedRow = row
					break
				end
			end

			if not selectedRow then
				return
			end

			refreshTreeSelectionVisuals()

			if not ExplorerSettings.AutoScrollSelection then
				return
			end

			local rowTop =
				selectedRow.Position.Y.Offset

			local rowBottom =
				rowTop
				+ selectedRow.AbsoluteSize.Y

			local viewportTop =
				treeScroll.CanvasPosition.Y

			local viewportBottom =
				viewportTop
				+ treeScroll.AbsoluteSize.Y

			local targetY =
				viewportTop

			if rowTop < viewportTop then
				targetY = rowTop
			elseif rowBottom > viewportBottom then
				targetY =
					rowBottom
				- treeScroll.AbsoluteSize.Y
			end

			local maxY =
				math.max(
					0,
					treeScroll.CanvasSize.Y.Offset
					- treeScroll.AbsoluteSize.Y
				)

			treeScroll.CanvasPosition =
				Vector2.new(
					treeScroll.CanvasPosition.X,
					math.clamp(
						targetY,
						0,
						maxY
					)
				)
		end

		rebuildProperties = function()
			clearRows(propertyRows)

			if not selectedInstance then
				propertyScroll.CanvasSize = UDim2.fromOffset(0, 0)
				return
			end

			local filter =
				string.lower(propertySearch.Text or "")

			local candidates =
				getCandidateProperties(selectedInstance)

			local readable = {}
			for _, propertyName in ipairs(candidates) do
				if filter == ""
					or string.find(
						string.lower(propertyName),
						filter,
						1,
						true
					)
				then
					local ok, value =
						safeRead(
							selectedInstance,
							propertyName
						)
					if ok
						and canEditProperty(
							propertyName,
							value
						)
					then
						table.insert(readable, {
							name = propertyName,
							value = value,
						})
					end
				end
			end

			addPropertyHeader(
				"Properties  (" .. tostring(#readable) .. ")"
			)

			for _, entry in ipairs(readable) do
				addPropertyRow(
					selectedInstance,
					entry.name,
					entry.value,
					false
				)
			end

			local attributes = {}
			local okAttributes, attributeTable =
				pcall(function()
					return selectedInstance:GetAttributes()
				end)

			if okAttributes then
				for name, value in pairs(attributeTable) do
					if filter == ""
						or string.find(
							string.lower(name),
							filter,
							1,
							true
						)
					then
						table.insert(attributes, {
							name = name,
							value = value,
						})
					end
				end
			end

			table.sort(attributes, function(a, b)
				return string.lower(a.name) < string.lower(b.name)
			end)

			addPropertyHeader(
				"Attributes  (" .. tostring(#attributes) .. ")"
			)

			for _, attribute in ipairs(attributes) do
				addPropertyRow(
					selectedInstance,
					attribute.name,
					attribute.value,
					true
				)
			end


			propertyScroll.CanvasSize =
				UDim2.fromOffset(
					0,
					#propertyRows * 26 + 4
				)
		end

		local function scheduleTreeRefresh(delaySeconds)
			treeRefreshSerial += 1
			local serial = treeRefreshSerial
			task.delay(delaySeconds or 0.08, function()
				if serial ~= treeRefreshSerial
					or not ExplorerWindow.Parent
					or not ExplorerWindow.Visible
				then
					return
				end
				rebuildTree()
			end)
		end

		local function schedulePropertyRefresh(delaySeconds)
			propertyRefreshSerial += 1
			local serial = propertyRefreshSerial
			task.delay(delaySeconds or 0.08, function()
				if serial ~= propertyRefreshSerial
					or not ExplorerWindow.Parent
					or not ExplorerWindow.Visible
				then
					return
				end
				rebuildProperties()
			end)
		end

		treeSearch:GetPropertyChangedSignal("Text"):Connect(function()
			scheduleTreeRefresh(0.12)
		end)

		propertySearch:GetPropertyChangedSignal("Text"):Connect(function()
			schedulePropertyRefresh(0.08)
		end)

		local function EXPLORERINFOCUS()
			MainFrame.ZIndex = 4

			if Console_2 then
				Console_2.ZIndex = 4
			end

			local scriptViewer =
				explorerParent:FindFirstChild(
					"PotassiumScriptViewer"
				)

			if scriptViewer
				and scriptViewer:IsA("GuiObject")
			then
				scriptViewer.ZIndex = 4
			end

			ExplorerWindow.ZIndex = 5
		end

		ExplorerWindow.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType
				== Enum.UserInputType.MouseButton1
			then
				EXPLORERINFOCUS()
			end
		end)

		local draggingExplorer = false
		local dragStart = nil
		local dragWindowStart = nil

		titleBar.InputBegan:Connect(function(inputObject)
			if inputObject.UserInputType
				== Enum.UserInputType.MouseButton1
			then
				draggingExplorer = true
				dragStart = inputObject.Position
				dragWindowStart = ExplorerWindow.Position
			end
		end)

		local resizingExplorer = false
		local resizeStartMouse = nil
		local resizeStartSize = nil

		resizeHandle.MouseButton1Down:Connect(function()
			resizingExplorer = true
			resizeStartMouse =
				UserInputService:GetMouseLocation()
			resizeStartSize =
				ExplorerWindow.AbsoluteSize
		end)

		UserInputService.InputChanged:Connect(function(inputObject)
			if inputObject.UserInputType
				~= Enum.UserInputType.MouseMovement
			then
				return
			end

			if draggingExplorer
				and dragStart
				and dragWindowStart
			then
				local delta =
					inputObject.Position - dragStart

				ExplorerWindow.Position =
					UDim2.new(
						dragWindowStart.X.Scale,
						dragWindowStart.X.Offset + delta.X,
						dragWindowStart.Y.Scale,
						dragWindowStart.Y.Offset + delta.Y
					)
			end

			if pendingTreeDragInstance
				and pendingTreeDragStart
				and not draggingTreeInstance
				and UserInputService:IsMouseButtonPressed(
					Enum.UserInputType.MouseButton1
				)
			then
				-- Use the current InputObject position for the entire drag
				-- operation so the ghost and the drop target use one
				-- consistent coordinate space.
				local currentMouse =
					Vector2.new(
						inputObject.Position.X,
						inputObject.Position.Y
					)

				if (
					currentMouse
					- pendingTreeDragStart
					).Magnitude >= TREE_DRAG_THRESHOLD
				then
					draggingTreeInstance =
						pendingTreeDragInstance

					treeDragGhost.Text =
						draggingTreeInstance.Name
						.. "  <"
						.. draggingTreeInstance.ClassName
						.. ">"

					treeDragGhost.Visible = true
				end
			end

			if draggingTreeInstance then
				local currentMouse =
					Vector2.new(
						inputObject.Position.X,
						inputObject.Position.Y
					)

				-- No +12/+12 offset. Because the ghost AnchorPoint is
				-- 0.5, 0.5, the cursor is directly in its center.
				treeDragGhost.Position =
					UDim2.fromOffset(
						currentMouse.X
						- ExplorerWindow.AbsolutePosition.X,
						currentMouse.Y
						- ExplorerWindow.AbsolutePosition.Y
					)

				updateTreeDragTarget(
					currentMouse
				)
			end

			if resizingExplorer
				and resizeStartMouse
				and resizeStartSize
			then
				local delta =
					UserInputService:GetMouseLocation()
				- resizeStartMouse

				local width =
					math.clamp(
						resizeStartSize.X + delta.X,
						520,
						1200
					)
				local height =
					math.clamp(
						resizeStartSize.Y + delta.Y,
						320,
						900
					)

				ExplorerWindow.Size =
					UDim2.fromOffset(width, height)
			end
		end)

		local function pointInsideGuiObject(
			guiObject,
			point
		)
			if not guiObject
				or not guiObject:IsA("GuiObject")
				or not guiObject.Visible
			then
				return false
			end

			local position =
				guiObject.AbsolutePosition

			local size =
				guiObject.AbsoluteSize

			return point.X >= position.X
				and point.X <= position.X + size.X
				and point.Y >= position.Y
				and point.Y <= position.Y + size.Y
		end

		local function pointOverPotassiumGui(point)
			-- GetGuiObjectsAtPosition is a BasePlayerGui method,
			-- so call it on PlayerGui instead of GuiService.
			local localPlayer =
				Players.LocalPlayer

			local playerGui =
				localPlayer
				and localPlayer:FindFirstChildOfClass(
					"PlayerGui"
				)

			if playerGui then
				local ok, objects =
					pcall(function()
						return playerGui:GetGuiObjectsAtPosition(
							point.X,
							point.Y
						)
					end)

				if ok and objects then
					for _, object in ipairs(objects) do
						if object:IsDescendantOf(
							ExplorerWindow
							)
								or object:IsDescendantOf(
									MainFrame
								)
								or (
									Console_2
									and object:IsDescendantOf(
										Console_2
									)
								)
						then
							return true
						end
					end

					return false
				end
			end

			-- Fallback if the Potassium UI is parented somewhere unusual:
			-- directly test the visible window rectangles.
			if pointInsideGuiObject(
				ExplorerWindow,
				point
				) then
				return true
			end

			if pointInsideGuiObject(
				MainFrame,
				point
				) then
				return true
			end

			if Console_2
				and pointInsideGuiObject(
					Console_2,
					point
				)
			then
				return true
			end

			return false
		end

		local function pickWorldInstanceFromMouse(
			screenPoint
		)
			local camera =
				workspace.CurrentCamera

			if not camera then
				return nil
			end

			-- InputObject.Position is a SCREEN coordinate. Use
			-- ScreenPointToRay so Roblox handles the top-bar / GUI inset
			-- itself. The old code subtracted GuiInset manually and then
			-- called ViewportPointToRay, which could shift the ray enough
			-- to miss a small Part and hit the Baseplate behind it.
			local ray =
				camera:ScreenPointToRay(
					screenPoint.X,
					screenPoint.Y,
					0
				)

			local params =
				RaycastParams.new()

			params.FilterType =
				Enum.RaycastFilterType.Exclude

			local excluded = {}

			local localPlayer =
				Players.LocalPlayer

			if localPlayer
				and localPlayer.Character
			then
				table.insert(
					excluded,
					localPlayer.Character
				)
			end

			-- Do not let Potassium's own 3D selection Highlight affect
			-- anything indirectly if its Adornee happens to move.
			params.FilterDescendantsInstances =
				excluded

			params.IgnoreWater = false

			local result =
				workspace:Raycast(
					ray.Origin,
					ray.Direction * 10000,
					params
				)

			if not result then
				return nil
			end

			-- Always return the exact BasePart hit by the ray. Do not walk
			-- up to its Model/ancestor; the Explorer can reveal that exact
			-- Part in the hierarchy.
			return result.Instance
		end

		UserInputService.InputBegan:Connect(function(
			inputObject,
			gameProcessed
		)
			if not ExplorerWindow.Visible
				or not ExplorerSettings.WorldPick
				or gameProcessed
				or inputObject.UserInputType
				~= Enum.UserInputType.MouseButton1
			then
				return
			end

			local point =
				Vector2.new(
					inputObject.Position.X,
					inputObject.Position.Y
				)

			if pointOverPotassiumGui(
				point
				) then
				return
			end

			local picked =
				pickWorldInstanceFromMouse(
					point
				)

			if not picked then
				return
			end

			selectInstanceAdvanced(
				picked,
				true,
				true
			)
		end)

		UserInputService.InputBegan:Connect(function(inputObject)
			if not contextMenu.Visible
				and not insertMenu.Visible
			then
				return
			end

			if inputObject.UserInputType
				~= Enum.UserInputType.MouseButton1
				and inputObject.UserInputType
				~= Enum.UserInputType.MouseButton2
			then
				return
			end

			local point =
				Vector2.new(
					inputObject.Position.X,
					inputObject.Position.Y
				)

			if pointInsideGui(contextMenu, point)
				or pointInsideGui(insertMenu, point)
			then
				return
			end

			hideContextMenu()
		end)

		UserInputService.InputBegan:Connect(function(
			inputObject,
			gameProcessed
		)
			if gameProcessed
				or not ExplorerWindow.Visible
			then
				return
			end

			local focused =
				UserInputService:GetFocusedTextBox()

			if focused then
				return
			end

			local controlDown =
				UserInputService:IsKeyDown(
					Enum.KeyCode.LeftControl
				)
				or UserInputService:IsKeyDown(
					Enum.KeyCode.RightControl
				)

			if controlDown
				and inputObject.KeyCode
				== Enum.KeyCode.F
			then
				treeSearch:CaptureFocus()
				return
			end

			if selectedInstance
				and inputObject.KeyCode
				== Enum.KeyCode.F2
			then
				showRenameDialog(
					selectedInstance
				)
				return
			end

			if controlDown
				and selectedInstance
				and inputObject.KeyCode
				== Enum.KeyCode.D
			then
				local parent =
					selectedInstance.Parent

				if parent
					and parent ~= game
				then
					local ok, clone =
						pcall(function()
							local duplicate =
							selectedInstance:Clone()

							duplicate.Name =
							selectedInstance.Name
							.. " Copy"

							duplicate.Parent =
							parent

							return duplicate
						end)

					if ok and clone then
						expanded[parent] = true

						selectInstanceAdvanced(
							clone,
							true,
							true
						)
					end
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType
				== Enum.UserInputType.MouseButton1
			then
				draggingExplorer = false
				resizingExplorer = false

				if draggingTreeInstance then
					finishTreeDrag()
				else
					pendingTreeDragInstance = nil
					pendingTreeDragStart = nil
				end
			end
		end)

		local settingsButton =
			titleBar:FindFirstChild(
				"ExplorerSettings"
			)

		if settingsButton then
			settingsButton.MouseButton1Click:Connect(function()
				explorerSettingsPopup.Visible =
					not explorerSettingsPopup.Visible

				hideContextMenu()
			end)
		end

		local locateButton =
			titleBar:FindFirstChild(
				"LocateSelection"
			)

		if locateButton then
			locateButton.MouseButton1Click:Connect(function()
				if not selectedInstance then
					return
				end

				expandAncestors(
					selectedInstance
				)

				rebuildTree()

				task.defer(
					revealSelectionInTree
				)
			end)
		end

		local backButton =
			titleBar:FindFirstChild(
				"SelectionBack"
			)

		if backButton then
			backButton.MouseButton1Click:Connect(function()
				if selectionHistoryIndex <= 1 then
					return
				end

				selectionHistoryIndex -= 1

				local target =
					selectionHistory[
				selectionHistoryIndex
				]

				if target
					and target.Parent
				then
					applyingHistorySelection = true

					selectInstanceAdvanced(
						target,
						true,
						false
					)

					applyingHistorySelection = false
				end
			end)
		end

		local forwardButton =
			titleBar:FindFirstChild(
				"SelectionForward"
			)

		if forwardButton then
			forwardButton.MouseButton1Click:Connect(function()
				if selectionHistoryIndex
					>= #selectionHistory
				then
					return
				end

				selectionHistoryIndex += 1

				local target =
					selectionHistory[
				selectionHistoryIndex
				]

				if target
					and target.Parent
				then
					applyingHistorySelection = true

					selectInstanceAdvanced(
						target,
						true,
						false
					)

					applyingHistorySelection = false
				end
			end)
		end

		local closeButton =
			titleBar:FindFirstChild("Close")

		if closeButton then
			closeButton.MouseButton1Click:Connect(function()
				hideContextMenu()
				explorerSettingsPopup.Visible = false
				ExplorerWindow.Visible = false
			end)
		end

		local refreshButton =
			titleBar:FindFirstChild("Refresh")

		if refreshButton then
			refreshButton.MouseButton1Click:Connect(function()
				rebuildTree()
				rebuildProperties()
			end)
		end

		if Explorer then
			Explorer.MouseButton1Click:Connect(function()
				ExplorerWindow.Visible =
					not ExplorerWindow.Visible

				if not ExplorerWindow.Visible then
					hideContextMenu()
				end

				if ExplorerWindow.Visible then
					EXPLORERINFOCUS()
					rebuildTree()
					rebuildProperties()
				end
			end)
		end

		game.DescendantAdded:Connect(function(descendant)
			if not ExplorerSettings.LiveRefresh
				or not ExplorerWindow.Visible
			then
				return
			end

			local parent = descendant.Parent
			if treeSearch.Text ~= ""
				or parent == game
				or expanded[parent]
			then
				scheduleTreeRefresh(0.08)
			end
		end)

		game.DescendantRemoving:Connect(function(descendant)
			if selectedInstance == descendant then
				selectedInstance = nil
				selectionInfo.Text = "No instance selected"
				schedulePropertyRefresh(0)
			end

			if ExplorerSettings.LiveRefresh
				and ExplorerWindow.Visible
			then
				scheduleTreeRefresh(0.08)
			end
		end)
	end


	return ExplorerWindow
end
