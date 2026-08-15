--[[
	POTASSIUM IDE MINOR
	============================================================

	Support-only systems extracted from Potassium.IDE.

	The main IDE ModuleScript keeps the actual editor engine:
	    • text rendering / syntax highlighting
	    • error parser / error underlines
	    • autocomplete / dynamic symbols
	    • code folding
	    • caret / selection / keyboard editing
	    • document execution callbacks

	This module owns the large but secondary systems:
	    • window dragging
	    • window resizing
	    • toolbar button plumbing
	    • settings open/close animation
	    • feature-toggle UI
	    • configurable menu key
	    • optimized viewport refresh bookkeeping

	Splitting these systems gives them separate Luau register frames and avoids
	the 200-local-register limit in the main IDE initializer.
]]

-- ============================================================
-- EASY EDIT SETTINGS
-- ============================================================

local SETTINGS = {
	Window = {
		MinWidth = 400,
		MinHeight = 250,
		MaxWidth = 1400,
		MaxHeight = 900,
		DragTweenTime = 0.2,
	},

	MenuKey = Enum.KeyCode.Delete,

	Features = {
		{key = "SmartEnter", name = "Smart Enter", default = false},
		{key = "BracketMatching", name = "Brackets", default = true},
		{key = "ErrorUnderline", name = "Errors", default = true},
		{key = "CodeFolding", name = "Folding", default = true},
		{key = "Autocomplete", name = "Autocomplete", default = true},
		{key = "BracketAutoClose", name = "Auto Close", default = true},
	},
}

local Minor = {}
Minor.__index = Minor

local UserInputService =
	game:GetService("UserInputService")

local TweenService =
	game:GetService("TweenService")

local RunService =
	game:GetService("RunService")

local MIN_WIDTH = SETTINGS.Window.MinWidth
local MIN_HEIGHT = SETTINGS.Window.MinHeight
local MAX_WIDTH = SETTINGS.Window.MaxWidth
local MAX_HEIGHT = SETTINGS.Window.MaxHeight

local FEATURE_DEFINITIONS = SETTINGS.Features

local function getKeyDisplayName(keyCode)
	if keyCode == Enum.KeyCode.Delete then
		return "DEL"
	elseif keyCode == Enum.KeyCode.Insert then
		return "INS"
	elseif keyCode == Enum.KeyCode.Backspace then
		return "BACKSPACE"
	elseif keyCode == Enum.KeyCode.Return then
		return "ENTER"
	elseif keyCode == Enum.KeyCode.LeftControl then
		return "LCTRL"
	elseif keyCode == Enum.KeyCode.RightControl then
		return "RCTRL"
	elseif keyCode == Enum.KeyCode.LeftShift then
		return "LSHIFT"
	elseif keyCode == Enum.KeyCode.RightShift then
		return "RSHIFT"
	elseif keyCode == Enum.KeyCode.LeftAlt then
		return "LALT"
	elseif keyCode == Enum.KeyCode.RightAlt then
		return "RALT"
	end

	return keyCode.Name
end

function Minor.new(context)
	assert(
		type(context) == "table",
		"[Potassium IDEMinor] context is required."
	)

	local self =
		setmetatable(
			{},
			Minor
		)

	self.MainFrame =
		assert(
			context.MainFrame,
			"[Potassium IDEMinor] MainFrame is missing."
		)

	self.ConsoleFrame =
		context.ConsoleFrame

	self.CodingHolder =
		assert(
			context.CodingHolder,
			"[Potassium IDEMinor] CodingHolder is missing."
		)

	self.EditorScroll =
		assert(
			context.EditorScroll,
			"[Potassium IDEMinor] EditorScroll is missing."
		)

	self.Input =
		assert(
			context.Input,
			"[Potassium IDEMinor] Input is missing."
		)

	self.Features =
		assert(
			context.Features,
			"[Potassium IDEMinor] Features table is missing."
		)

	self.callbacks = context

	self.MenuKey =
		SETTINGS.MenuKey

	self.waitingForMenuKey = false

	self.MainFrame:SetAttribute(
		"MenuKey",
		self.MenuKey.Name
	)

	self:_setupDragging()
	self:_setupResizing()
	self:_setupToolbar()
	self:_setupSettings()
	self:_setupViewportRefresh()

	return self
end

-- ============================================================
-- WINDOW DRAGGING
-- ============================================================

function Minor:_setupDragging()
	local frame =
		self.MainFrame

	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPosition = nil

	local function update(inputObject)
		if not dragStart
			or not startPosition
		then
			return
		end

		local delta =
			inputObject.Position
		- dragStart

		local position =
			UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset
				+ delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset
				+ delta.Y
			)

		TweenService:Create(
			frame,
			TweenInfo.new(SETTINGS.Window.DragTweenTime),
			{
				Position = position,
			}
		):Play()
	end

	frame.InputBegan:Connect(function(
		inputObject
	)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1
			or inputObject.UserInputType
			== Enum.UserInputType.Touch
		then
			dragging = true
			dragStart =
				inputObject.Position
			startPosition =
				frame.Position

			inputObject.Changed:Connect(
				function()
					if inputObject.UserInputState
						== Enum.UserInputState.End
					then
						dragging = false
					end
				end
			)
		end
	end)

	frame.InputChanged:Connect(function(
		inputObject
	)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseMovement
			or inputObject.UserInputType
			== Enum.UserInputType.Touch
		then
			dragInput = inputObject
		end
	end)

	UserInputService.InputChanged:Connect(function(
		inputObject
	)
		if inputObject == dragInput
			and dragging
		then
			update(inputObject)
		end
	end)
end

-- ============================================================
-- WINDOW RESIZING
-- ============================================================

function Minor:_setupResizing()
	local frame =
		self.MainFrame

	local resizing = false
	local resizeStartMouse = nil
	local resizeStartSize = nil

	local resizeHandle =
		frame:FindFirstChild(
			"ResizeHandle"
		)

	if not resizeHandle then
		resizeHandle =
			Instance.new("TextButton")

		resizeHandle.Name =
			"ResizeHandle"

		resizeHandle.Size =
			UDim2.fromOffset(18, 18)

		resizeHandle.Position =
			UDim2.new(
				1,
				-18,
				1,
				-18
			)

		resizeHandle.BackgroundTransparency =
			0.7

		resizeHandle.BorderSizePixel = 0
		resizeHandle.Text = ""
		resizeHandle.AutoButtonColor = false
		resizeHandle.ZIndex = 100
		resizeHandle.Parent = frame
	end

	resizeHandle.MouseButton1Down:Connect(
		function()
			resizing = true

			resizeStartMouse =
				UserInputService:
				GetMouseLocation()

			resizeStartSize =
				Vector2.new(
					frame.AbsoluteSize.X,
					frame.AbsoluteSize.Y
				)
		end
	)

	UserInputService.InputChanged:Connect(function(
		inputObject
	)
		if not resizing then
			return
		end

		if inputObject.UserInputType
			~= Enum.UserInputType.MouseMovement
		then
			return
		end

		if not resizeStartMouse
			or not resizeStartSize
		then
			return
		end

		local currentMouse =
			UserInputService:
			GetMouseLocation()

		local delta =
			currentMouse
		- resizeStartMouse

		local newWidth =
			math.clamp(
				resizeStartSize.X
				+ delta.X,
				MIN_WIDTH,
				MAX_WIDTH
			)

		local newHeight =
			math.clamp(
				resizeStartSize.Y
				+ delta.Y,
				MIN_HEIGHT,
				MAX_HEIGHT
			)

		frame.Size =
			UDim2.fromOffset(
				newWidth,
				newHeight
			)

		local callback =
			self.callbacks.onResize

		if callback then
			task.defer(callback)
		end
	end)

	UserInputService.InputEnded:Connect(function(
		inputObject
	)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1
		then
			resizing = false
		end
	end)
end

-- ============================================================
-- TOOLBAR
-- ============================================================

function Minor:_setupToolbar()
	local buttonsFrame =
		self.CodingHolder:
		FindFirstChild(
			"Settings"
		)

	self.ButtonsFrame =
		buttonsFrame

	if not buttonsFrame then
		return
	end

	self.SettingsButton =
		buttonsFrame:
		FindFirstChild(
			"Settings"
		)

	self.ClearButton =
		buttonsFrame:
		FindFirstChild(
			"Clear"
		)

	self.ExecuteButton =
		buttonsFrame:
		FindFirstChild(
			"Execute"
		)

	self.ConsoleButton =
		buttonsFrame:
		FindFirstChild(
			"Console"
		)

	if self.ExecuteButton then
		self.ExecuteButton.MouseButton1Click:
			Connect(function()
				local callback =
				self.callbacks.onExecute

				if callback then
					callback()
				end
			end)
	end

	if self.ClearButton then
		self.ClearButton.MouseButton1Click:
			Connect(function()
				local callback =
				self.callbacks.onClear

				if callback then
					callback()
				end
			end)
	end

	if self.ConsoleButton then
		self.ConsoleButton.MouseButton1Click:
			Connect(function()
				local callback =
				self.callbacks.onConsole

				if callback then
					callback()
				end
			end)
	end
end

-- ============================================================
-- SETTINGS
-- ============================================================

function Minor:_openSettings()
	local settingsFrame =
		self.SettingsFrame

	local buttonsFrame =
		self.ButtonsFrame

	if not settingsFrame
		or not buttonsFrame
	then
		return
	end

	local settingsContainer =
		buttonsFrame.Parent

	settingsContainer.Visible = true

	TweenService:Create(
		settingsContainer,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.new(
					1,
					0,
					0,
					0
				),

			Position =
				UDim2.new(
					0,
					0,
					1,
					0
				),
		}
	):Play()

	settingsFrame.Visible = true

	TweenService:Create(
		settingsFrame,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.fromScale(
					1,
					1
				),

			Position =
				UDim2.fromOffset(
					0,
					0
				),
		}
	):Play()
end

function Minor:_closeSettings()
	local settingsFrame =
		self.SettingsFrame

	if not settingsFrame then
		return
	end

	TweenService:Create(
		settingsFrame,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			Size =
				UDim2.new(
					1,
					0,
					0,
					0
				),
		}
	):Play()

	task.delay(
		0.3,
		function()
			if settingsFrame.Parent then
				settingsFrame.Visible =
					false
			end
		end
	)

	local buttonsFrame =
		self.ButtonsFrame

	if buttonsFrame then
		buttonsFrame.Parent.Visible = true

		TweenService:Create(
			buttonsFrame.Parent,
			TweenInfo.new(
				0.3,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size =
					UDim2.fromScale(
						1,
						1
					),

				Position =
					UDim2.fromOffset(
						0,
						0
					),
			}
		):Play()
	end
end

function Minor:_setupFeatureSettings()
	local settingsFrame =
		self.SettingsFrame

	if not settingsFrame then
		return
	end

	local templates =
		settingsFrame:
		FindFirstChild(
			"Templates"
		)

	local template =
		templates
		and templates:
		FindFirstChild(
			"Template"
		)

	local holder =
		settingsFrame:
		FindFirstChild(
			"Holder"
		)

	if not template
		or not holder
	then
		return
	end

	for _, feature in ipairs(
		FEATURE_DEFINITIONS
		) do
		self.Features[feature.key] =
			feature.default == true

		local button =
			holder:FindFirstChild(
				feature.key
			)

		if not button then
			button =
				template:Clone()

			button.Name =
				feature.key

			button.Parent =
				holder

			button.Visible = true
		end

		local title =
			button:FindFirstChild(
				"Title"
			)

		if title
			and title:IsA(
				"TextLabel"
			)
		then
			title.Text =
				feature.name
		end

		button:SetAttribute(
			"Key",
			feature.key
		)

		button:SetAttribute(
			"Enabled",
			self.Features[
			feature.key
			]
		)

		self:_wireFeatureButton(
			button,
			feature.key
		)
	end
end

function Minor:_wireFeatureButton(
	button,
	featureKey
)
	local imageLabel =
		button:FindFirstChild(
			"ImageLabel"
		)

	local function updateButton()
		if not imageLabel then
			return
		end

		imageLabel.BackgroundColor3 =
			self.Features[featureKey]
			and Color3.fromRGB(
				172,
				255,
				47
			)
			or Color3.fromRGB(
				255,
				88,
				91
			)
	end

	updateButton()

	if not button:IsA("GuiButton") then
		return
	end

	button.MouseButton1Click:Connect(
		function()
			self.Features[featureKey] =
				not self.Features[
			featureKey
			]

			local enabled =
				self.Features[
			featureKey
			]

			button:SetAttribute(
				"Enabled",
				enabled
			)

			if imageLabel then
				TweenService:Create(
					imageLabel,
					TweenInfo.new(
						0.3,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out
					),
					{
						BackgroundColor3 =
							enabled
							and Color3.fromRGB(
								172,
								255,
								47
							)
							or Color3.fromRGB(
								255,
								88,
								91
							),
					}
				):Play()
			end

			local callback =
				self.callbacks.onFeatureChanged

			if callback then
				callback(
					featureKey,
					enabled
				)
			end
		end
	)
end

function Minor:_setupMenuKeySetting()
	local settingsFrame =
		self.SettingsFrame

	if not settingsFrame then
		return
	end

	local holder =
		settingsFrame:
		FindFirstChild(
			"Holder"
		)

	local templates =
		settingsFrame:
		FindFirstChild(
			"Templates"
		)

	local template =
		templates
		and templates:
		FindFirstChild(
			"Template"
		)

	if not holder
		or not template
	then
		return
	end

	local menuKeyButton =
		holder:FindFirstChild(
			"MenuKey"
		)

	if not menuKeyButton then
		menuKeyButton =
			template:Clone()

		menuKeyButton.Name =
			"MenuKey"

		menuKeyButton.Parent =
			holder

		menuKeyButton.Visible = true
	end

	local title =
		menuKeyButton:
		FindFirstChild(
			"Title"
		)

	local indicator =
		menuKeyButton:
		FindFirstChild(
			"ImageLabel"
		)

	if indicator then
		indicator.Visible = false
	end

	local keyLabel =
		menuKeyButton:
		FindFirstChild(
			"KeyLabel"
		)

	if not keyLabel then
		keyLabel =
			self:_createKeyLabel(
				menuKeyButton
			)
	end

	if title
		and title:IsA(
			"TextLabel"
		)
	then
		title.Text = "Menu Key"

		title.Size =
			UDim2.new(
				1,
				-125,
				1,
				0
			)
	end

	self.MenuKeyLabel =
		keyLabel

	self:_updateMenuKeyLabel()

	if menuKeyButton:IsA(
		"GuiButton"
		) then
		menuKeyButton.MouseButton1Click:
			Connect(function()
				self.waitingForMenuKey =
				true

				self:_updateMenuKeyLabel()
			end)
	end
end

function Minor:_createKeyLabel(parent)
	local keyLabel =
		Instance.new("TextLabel")

	keyLabel.Name = "KeyLabel"
	keyLabel.AnchorPoint =
		Vector2.new(1, 0.5)

	keyLabel.Position =
		UDim2.new(
			1,
			-10,
			0.5,
			0
		)

	keyLabel.Size =
		UDim2.fromOffset(
			105,
			24
		)

	keyLabel.BackgroundColor3 =
		Color3.fromRGB(
			42,
			42,
			42
		)

	keyLabel.BorderSizePixel = 0

	keyLabel.TextColor3 =
		Color3.fromRGB(
			215,
			215,
			215
		)

	keyLabel.Font =
		Enum.Font.Code

	keyLabel.TextSize = 12

	keyLabel.TextXAlignment =
		Enum.TextXAlignment.Center

	keyLabel.ZIndex =
		parent.ZIndex + 2

	keyLabel.Parent = parent

	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, 4)

	corner.Parent =
		keyLabel

	return keyLabel
end

function Minor:_updateMenuKeyLabel()
	if not self.MenuKeyLabel then
		return
	end

	if self.waitingForMenuKey then
		self.MenuKeyLabel.Text =
			"PRESS A KEY..."
	else
		self.MenuKeyLabel.Text =
			getKeyDisplayName(
				self.MenuKey
			)
	end
end

function Minor:_handleMenuKeyInput(
	inputObject
)
	if inputObject.UserInputType
		~= Enum.UserInputType.Keyboard
	then
		return
	end

	if self.waitingForMenuKey then
		if inputObject.KeyCode
			== Enum.KeyCode.Escape
		then
			self.waitingForMenuKey =
				false

			self:_updateMenuKeyLabel()
			return
		end

		if inputObject.KeyCode
			~= Enum.KeyCode.Unknown
		then
			self.MenuKey =
				inputObject.KeyCode

			self.waitingForMenuKey =
				false

			self.MainFrame:SetAttribute(
				"MenuKey",
				self.MenuKey.Name
			)

			self:_updateMenuKeyLabel()
		end

		return
	end

	if inputObject.KeyCode
		~= self.MenuKey
	then
		return
	end

	self.MainFrame.Visible =
		not self.MainFrame.Visible

	if self.MainFrame.Visible then
		local callback =
			self.callbacks.onMenuShown

		if callback then
			callback()
		end
	else
		local callback =
			self.callbacks.onMenuHidden

		if callback then
			callback()
		end
	end
end

function Minor:_setupSettings()
	local settingsFrame =
		self.MainFrame:
		FindFirstChild(
			"Settings"
		)

	self.SettingsFrame =
		settingsFrame

	if settingsFrame then
		settingsFrame.Visible = false
	end

	if self.SettingsButton
		and settingsFrame
	then
		self.SettingsButton.MouseButton1Click:
			Connect(function()
				self:_openSettings()
			end)
	end

	self:_setupFeatureSettings()
	self:_setupMenuKeySetting()

	if settingsFrame then
		local close =
			settingsFrame:
			FindFirstChild(
				"Close"
			)

		if close
			and close:IsA(
				"GuiButton"
			)
		then
			close.MouseButton1Click:
				Connect(function()
					self:_closeSettings()
				end)
		end
	end

	UserInputService.InputBegan:
		Connect(function(
			inputObject,
			_gameProcessed
		)
		self:_handleMenuKeyInput(
			inputObject
		)
	end)
end

-- ============================================================
-- OPTIMIZED VIEWPORT REFRESH
-- ============================================================

function Minor:_setupViewportRefresh()
	self.viewport = {
		scrollRefreshPending = false,

		lastDisplayFirstLine = -1,
		lastDisplayLastLine = -1,

		lastGutterFirstLine = -1,
		lastGutterLastLine = -1,

		lastErrorFirstLine = -1,
		lastErrorLastLine = -1,
	}

	self.EditorScroll:
		GetPropertyChangedSignal(
			"AbsoluteSize"
		):Connect(function()
		local callback =
			self.callbacks.updateEditorLayout

		if callback then
			callback()
		end

		self:_resetViewportRanges()
		self:_queueViewportRefresh()
	end)

	self.EditorScroll:
		GetPropertyChangedSignal(
			"CanvasPosition"
		):Connect(function()
		self:_queueViewportRefresh()
	end)
end

function Minor:_resetViewportRanges()
	local viewport =
		self.viewport

	viewport.lastDisplayFirstLine = -1
	viewport.lastDisplayLastLine = -1
	viewport.lastGutterFirstLine = -1
	viewport.lastGutterLastLine = -1
	viewport.lastErrorFirstLine = -1
	viewport.lastErrorLastLine = -1
end

function Minor:_queueViewportRefresh()
	local viewport =
		self.viewport

	if viewport.scrollRefreshPending then
		return
	end

	viewport.scrollRefreshPending = true

	RunService.RenderStepped:Once(
		function()
			viewport.scrollRefreshPending =
				false

			self:_refreshViewportIfNeeded()
		end
	)
end

function Minor:_refreshViewportIfNeeded()
	if not self.MainFrame.Parent then
		return
	end

	local callbacks =
		self.callbacks

	if callbacks.rebuildFoldingCache then
		callbacks.rebuildFoldingCache()
	end

	self:_refreshDisplayRange()
	self:_refreshGutterRange()
	self:_refreshErrorRange()

	if callbacks.isAutocompleteVisible
		and callbacks.isAutocompleteVisible()
		and callbacks.positionAutocomplete
	then
		callbacks.positionAutocomplete()
	end

	if callbacks.isInputFocused
		and callbacks.isInputFocused()
		and callbacks.updateEditorCursor
	then
		callbacks.updateEditorCursor()
	end
end

function Minor:_refreshDisplayRange()
	local callbacks =
		self.callbacks

	if not callbacks.getViewportVisibleRange
		or not callbacks.updateDisplay
	then
		return
	end

	local buffer =
		callbacks.getDisplayBuffer
		and callbacks.getDisplayBuffer()
		or 12

	local firstLine,
		lastLine =
		callbacks.getViewportVisibleRange(
			buffer
		)

	local viewport =
		self.viewport

	if firstLine
		~= viewport.lastDisplayFirstLine
		or lastLine
		~= viewport.lastDisplayLastLine
	then
		viewport.lastDisplayFirstLine =
			firstLine

		viewport.lastDisplayLastLine =
			lastLine

		callbacks.updateDisplay()
	end
end

function Minor:_refreshGutterRange()
	local callbacks =
		self.callbacks

	if not callbacks.getViewportVisibleRange
		or not callbacks.rebuildGutter
	then
		return
	end

	local buffer =
		callbacks.getGutterBuffer
		and callbacks.getGutterBuffer()
		or 15

	local firstLine,
		lastLine =
		callbacks.getViewportVisibleRange(
			buffer
		)

	local viewport =
		self.viewport

	if firstLine
		~= viewport.lastGutterFirstLine
		or lastLine
		~= viewport.lastGutterLastLine
	then
		viewport.lastGutterFirstLine =
			firstLine

		viewport.lastGutterLastLine =
			lastLine

		callbacks.rebuildGutter()
	end
end

function Minor:_refreshErrorRange()
	local callbacks =
		self.callbacks

	if not callbacks.getViewportVisibleRange
		or not callbacks.updateErrorUnderlines
	then
		return
	end

	local firstLine,
		lastLine =
		callbacks.getViewportVisibleRange(5)

	local viewport =
		self.viewport

	if firstLine
		~= viewport.lastErrorFirstLine
		or lastLine
		~= viewport.lastErrorLastLine
	then
		viewport.lastErrorFirstLine =
			firstLine

		viewport.lastErrorLastLine =
			lastLine

		callbacks.updateErrorUnderlines()
	end
end

return Minor
