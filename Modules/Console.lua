return function(Console_2, FileSystem)


	-- ============================================================
	-- EASY EDIT SETTINGS
	-- ============================================================

	local SETTINGS = {
		Window = {
			MinWidth = 300,
			MinHeight = 200,
			MaxWidth = 1200,
			MaxHeight = 800,
		},

		BottomBar = {
			Height = 36,
			ControlHeight = 28,
			Gap = 6,
			EdgePadding = 8,
			ClearWidth = 92,
			AutoScrollWidth = 94,
			LogCountWidth = 88,
			CloseWidth = 94,
		},

		Logging = {
			MaxLogs = 500,
			AutoScroll = true,
			ShowTimestamp = true,
		},

		Colors = {
			Print = Color3.fromRGB(220, 220, 220),
			Info = Color3.fromRGB(100, 180, 255),
			Warn = Color3.fromRGB(255, 190, 70),
			Error = Color3.fromRGB(255, 80, 80),
			Success = Color3.fromRGB(110, 220, 130),
			Time = Color3.fromRGB(120, 120, 120),
		},
	}

	-- ============================================================
	-- POTASSIUM CONSOLE
	-- ============================================================

	local ConsoleFrame = Console_2
	local ConsoleHolder = ConsoleFrame.ConsoleHolder

	local ConsoleTemplate = ConsoleHolder.Templates.Log

	local ConsoleList = ConsoleHolder.LogsFrame.Holder

	-- Leave room for the fixed bottom toolbar.
	local LogsFrame =
		ConsoleHolder:FindFirstChild("LogsFrame")

	if LogsFrame then
		LogsFrame.Size =
			UDim2.new(
				1,
				0,
				1,
				-36
			)
	end

	local ClearButton = ConsoleHolder.Settings:FindFirstChild("Clear")
	local LogCount = ConsoleHolder.Settings:FindFirstChild("LogCount")
	local AutoScrollButton = ConsoleHolder.Settings:FindFirstChild("AutoScroll")
	local CloseConsoleButton = ConsoleHolder.Settings:FindFirstChild("Close")

	local UserInputService = game:GetService("UserInputService")

	-- ============================================================
	-- FILESYSTEM / PERSISTENT CONSOLE STATE
	-- ============================================================

	-- FileSystem can either be passed into this module:
	--     CreateConsole(ConsoleFrame, FileSystem)
	-- or placed next to this ModuleScript as "FileSystem".
	if not FileSystem and script and script.Parent then
		local FileSystemModule = script.Parent:FindFirstChild("FileSystem")

		if FileSystemModule and FileSystemModule:IsA("ModuleScript") then
			local success, result = pcall(require, FileSystemModule)

			if success then
				FileSystem = result
			end
		end
	end

	assert(
		FileSystem,
		"[Potassium Console] FileSystem module was not provided"
	)

	local ConsoleStatePath

	if FileSystem.Join then
		ConsoleStatePath = FileSystem.Join(FileSystem.DataPath, "Console.cfg")
	else
		ConsoleStatePath = FileSystem.DataPath .. "/Console.cfg"
	end

	local loadingConsoleState = false
	local consoleStateLoaded = false

	local function serializeUDim2(value)
		return {
			XScale = value.X.Scale,
			XOffset = value.X.Offset,
			YScale = value.Y.Scale,
			YOffset = value.Y.Offset,
		}
	end

	local function deserializeUDim2(data, fallback)
		if type(data) ~= "table" then
			return fallback
		end

		local xScale = tonumber(data.XScale)
		local xOffset = tonumber(data.XOffset)
		local yScale = tonumber(data.YScale)
		local yOffset = tonumber(data.YOffset)

		if xScale == nil or xOffset == nil or yScale == nil or yOffset == nil then
			return fallback
		end

		return UDim2.new(xScale, xOffset, yScale, yOffset)
	end

	local function SaveConsoleState()
		if loadingConsoleState then
			return false
		end

		local state = {
			WasOpen = ConsoleFrame.Visible,
			Position = serializeUDim2(ConsoleFrame.Position),
			Size = serializeUDim2(ConsoleFrame.Size),
		}

		local success, err = FileSystem.SaveJSON(ConsoleStatePath, state)

		if not success then
			warn(
				"[Potassium Console] Failed to save console state:",
				err
			)
		end

		return success
	end

	local function LoadConsoleState()
		loadingConsoleState = true

		local state = nil

		if FileSystem.FileExists(ConsoleStatePath) then
			local loaded, err = FileSystem.ReadJSON(ConsoleStatePath)

			if type(loaded) == "table" then
				state = loaded
			elseif err then
				warn(
					"[Potassium Console] Failed to load console state:",
					err
				)
			end
		end

		if state then
			ConsoleFrame.Position = deserializeUDim2(
				state.Position,
				ConsoleFrame.Position
			)

			ConsoleFrame.Size = deserializeUDim2(
				state.Size,
				ConsoleFrame.Size
			)

			if type(state.WasOpen) == "boolean" then
				ConsoleFrame.Visible = state.WasOpen
			end
		end

		loadingConsoleState = false
		consoleStateLoaded = true

		-- First run: create the config immediately from the default state.
		if not state then
			SaveConsoleState()
		end
	end

	LoadConsoleState()

	-- Save immediately EVERY time the console is opened or closed.
	-- This also catches Visible changes made outside this module.
	ConsoleFrame:GetPropertyChangedSignal("Visible"):Connect(function()
		if consoleStateLoaded then
			SaveConsoleState()
		end
	end)

	-- Final backup for a clean shutdown. The console does not rely on this.
	pcall(function()
		game:BindToClose(function()
			SaveConsoleState()
		end)
	end)

	-- ============================================================
	-- FIXED CONSOLE BOTTOM BAR
	-- ============================================================
	--
	-- Keep the console controls INSIDE the console at all sizes.
	-- The toolbar itself follows the bottom edge, while the controls use
	-- fixed pixel positions/sizes instead of inheriting scale-based layout.

	local SettingsBar =
		ConsoleHolder:FindFirstChild("Settings")

	local BOTTOM_BAR_HEIGHT = SETTINGS.BottomBar.Height
	local CONTROL_HEIGHT = SETTINGS.BottomBar.ControlHeight
	local CONTROL_GAP = SETTINGS.BottomBar.Gap
	local EDGE_PADDING = SETTINGS.BottomBar.EdgePadding

	local function styleBottomControl(control)
		if not control
			or not control:IsA("GuiObject")
		then
			return
		end

		control.AnchorPoint =
			Vector2.new(0, 0.5)

		control.Size =
			UDim2.fromOffset(
				math.max(
					1,
					control.AbsoluteSize.X
				),
				CONTROL_HEIGHT
			)

		control.Visible = true
	end

	local function layoutConsoleBottomBar()
		if not SettingsBar then
			return
		end

		-- Keep the full settings bar locked to the bottom INSIDE ConsoleHolder.
		SettingsBar.AnchorPoint =
			Vector2.new(0, 1)

		SettingsBar.Position =
			UDim2.new(
				0,
				0,
				1,
				0
			)

		SettingsBar.Size =
			UDim2.new(
				1,
				-16,
				0,
				BOTTOM_BAR_HEIGHT
			)

		SettingsBar.Visible = true

		-- Explicit widths so none of these controls collapse/disappear.
		if ClearButton then
			ClearButton.AnchorPoint =
				Vector2.new(0, 0.5)

			ClearButton.Position =
				UDim2.new(
					0,
					EDGE_PADDING,
					0.5,
					0
				)

			ClearButton.Size =
				UDim2.fromOffset(
					SETTINGS.BottomBar.ClearWidth,
					CONTROL_HEIGHT
				)

			ClearButton.Visible = true
		end

		if AutoScrollButton then
			AutoScrollButton.AnchorPoint =
				Vector2.new(0, 0.5)

			AutoScrollButton.Position =
				UDim2.new(
					0,
					EDGE_PADDING + SETTINGS.BottomBar.ClearWidth + CONTROL_GAP,
					0.5,
					0
				)

			AutoScrollButton.Size =
				UDim2.fromOffset(
					SETTINGS.BottomBar.AutoScrollWidth,
					CONTROL_HEIGHT
				)

			AutoScrollButton.Visible = true
		end

		if LogCount then
			LogCount.AnchorPoint =
				Vector2.new(0, 0.5)

			LogCount.Position =
				UDim2.new(
					0,
					EDGE_PADDING
					+ SETTINGS.BottomBar.ClearWidth
					+ CONTROL_GAP
					+ SETTINGS.BottomBar.AutoScrollWidth
					+ CONTROL_GAP,
					0.5,
					0
				)

			LogCount.Size =
				UDim2.fromOffset(
					SETTINGS.BottomBar.LogCountWidth,
					CONTROL_HEIGHT
				)

			LogCount.Visible = true
		end

		if CloseConsoleButton then

			CloseConsoleButton.AnchorPoint =
				Vector2.new(0, 0.5)

			CloseConsoleButton.Position =
				UDim2.new(
					0,
					EDGE_PADDING
					+ 187
					+ CONTROL_GAP
					+ 94
					+ CONTROL_GAP,
					0.5,
					0
				)

			CloseConsoleButton.Size =
				UDim2.fromOffset(
					94,
					CONTROL_HEIGHT
				)

			CloseConsoleButton.Visible = true
		end
	end

	task.defer(function()
		layoutConsoleBottomBar()
	end)
	local TweenService = game:GetService("TweenService")

	-- ============================================================
	-- DRAGGING
	-- ============================================================

	local function MakeDraggable(topbarobject, object)
		local Dragging = false
		local DragInput = nil
		local DragStart = nil
		local StartPosition = nil
		local LastTargetPosition = nil
		local ActiveTween = nil

		local function Update(input)
			local Delta = input.Position - DragStart
			local pos =
				UDim2.new(
					StartPosition.X.Scale,
					StartPosition.X.Offset + Delta.X,
					StartPosition.Y.Scale,
					StartPosition.Y.Offset + Delta.Y
				)

			LastTargetPosition = pos

			if ActiveTween then
				ActiveTween:Cancel()
			end

			ActiveTween = TweenService:Create(
				object,
				TweenInfo.new(0.2),
				{Position = pos}
			)

			ActiveTween:Play()
		end

		topbarobject.InputBegan:Connect(
			function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = input.Position
					StartPosition = object.Position
					LastTargetPosition = object.Position

					input.Changed:Connect(
						function()
							if input.UserInputState == Enum.UserInputState.End then
								Dragging = false

								if ActiveTween then
									ActiveTween:Cancel()
								end

								if LastTargetPosition then
									object.Position = LastTargetPosition
								end

								-- Save the final dragged position immediately.
								SaveConsoleState()
							end
						end
					)
				end
			end
		)

		topbarobject.InputChanged:Connect(
			function(input)
				if
					input.UserInputType == Enum.UserInputType.MouseMovement or
					input.UserInputType == Enum.UserInputType.Touch
				then
					DragInput = input
				end
			end
		)

		UserInputService.InputChanged:Connect(
			function(input)
				if input == DragInput and Dragging then
					Update(input)
				end
			end
		)
	end

	MakeDraggable(ConsoleFrame, ConsoleFrame)

	-- ============================================================
	-- CONSOLE RESIZING
	-- ============================================================


	local ResizeHandle =
		Instance.new("TextButton")

	ResizeHandle.Name =
		"ResizeHandle"

	ResizeHandle.Text =
		""

	ResizeHandle.AutoButtonColor =
		false

	ResizeHandle.BackgroundTransparency =
		0

	ResizeHandle.BackgroundColor3 =
		Color3.fromRGB(
			80,
			80,
			80
		)

	ResizeHandle.BorderSizePixel =
		0

	ResizeHandle.Size =
		UDim2.new(
			0,
			16,
			0,
			16
		)

	ResizeHandle.AnchorPoint =
		Vector2.new(
			1,
			1
		)

	ResizeHandle.Position =
		UDim2.new(
			1,
			0,
			1,
			0
		)

	ResizeHandle.ZIndex =
		100

	ResizeHandle.Parent =
		ConsoleHolder

	-- ============================================================
	-- RESIZE SETTINGS
	-- ============================================================

	local MIN_WIDTH = SETTINGS.Window.MinWidth
	local MIN_HEIGHT = SETTINGS.Window.MinHeight

	local MAX_WIDTH = SETTINGS.Window.MaxWidth
	local MAX_HEIGHT = SETTINGS.Window.MaxHeight

	local resizing = false
	local resizeStartMouse = nil
	local resizeStartSize = nil

	-- ============================================================
	-- START RESIZING
	-- ============================================================

	ResizeHandle.MouseButton1Down:Connect(
		function()

			resizing = true

			resizeStartMouse =
				UserInputService:GetMouseLocation()

			resizeStartSize =
				ConsoleFrame.AbsoluteSize

		end
	)


	-- ============================================================
	-- RESIZE
	-- ============================================================

	UserInputService.InputChanged:Connect(
		function(input)

			if not resizing then
				return
			end

			if input.UserInputType ~=
				Enum.UserInputType.MouseMovement
			then
				return
			end

			local mouse =
				UserInputService:GetMouseLocation()

			local delta =
				mouse
			- resizeStartMouse

			local newWidth =
				resizeStartSize.X
				+ delta.X

			local newHeight =
				resizeStartSize.Y
				+ delta.Y

			-- ================================================
			-- LIMIT SIZE
			-- ================================================

			newWidth =
				math.clamp(
					newWidth,
					MIN_WIDTH,
					MAX_WIDTH
				)

			newHeight =
				math.clamp(
					newHeight,
					MIN_HEIGHT,
					MAX_HEIGHT
				)

			-- ================================================
			-- APPLY SIZE
			-- ================================================

			ConsoleFrame.Size =
				UDim2.new(
					0,
					newWidth,
					0,
					newHeight
				)

			layoutConsoleBottomBar()

		end
	)


	-- ============================================================
	-- STOP RESIZING
	-- ============================================================

	UserInputService.InputEnded:Connect(
		function(input)

			if input.UserInputType ==
				Enum.UserInputType.MouseButton1
			then

				resizing = false
				layoutConsoleBottomBar()
				SaveConsoleState()

			end

		end
	)

	-- ============================================================
	-- SERVICES
	-- ============================================================

	local TweenService =
		game:GetService("TweenService")

	local TextService =
		game:GetService("TextService")


	-- ============================================================
	-- CONFIG
	-- ============================================================

	local MAX_LOGS = SETTINGS.Logging.MaxLogs
	local AUTO_SCROLL = SETTINGS.Logging.AutoScroll

	if AutoScrollButton then
		AutoScrollButton.ImageLabel.BackgroundColor3 = AUTO_SCROLL and Color3.fromRGB(172,255,47) or Color3.fromRGB(255,88,91)

		AutoScrollButton.MouseButton1Click:Connect(function()
			AUTO_SCROLL = not AUTO_SCROLL
			TweenService:Create(
				AutoScrollButton.ImageLabel,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad),
				{BackgroundColor3 = AUTO_SCROLL and Color3.fromRGB(172,255,47) or Color3.fromRGB(255,88,91)}
			):Play()
		end)
	end

	local SHOW_TIMESTAMP = SETTINGS.Logging.ShowTimestamp


	-- ============================================================
	-- STATE
	-- ============================================================

	local Logs = {}
	local ConsoleLogs = {}

	local totalLogs = 0


	-- ============================================================
	-- COLORS
	-- ============================================================

	local CONSOLE_COLORS = SETTINGS.Colors


	-- ============================================================
	-- UTILITY
	-- ============================================================

	local function getTime()

		return os.date(
			"%H:%M:%S"
		)

	end


	local function stringify(value)

		if typeof(value) == "string" then

			return value

		end

		if value == nil then

			return "nil"

		end

		local success, result =
			pcall(
				function()

					return tostring(value)

				end
			)

		if success then

			return result

		end

		return "<unable to convert value>"

	end


	local function formatArguments(...)

		local args = {
			...
		}

		local output = {}

		for _, value in ipairs(args) do

			table.insert(
				output,
				stringify(value)
			)

		end

		return table.concat(
			output,
			"\t"
		)

	end


	-- ============================================================
	-- SCROLL TO BOTTOM
	-- ============================================================

	local function scrollToBottom()

		if not AUTO_SCROLL then
			return
		end

		task.defer(function()

			if not ConsoleList then
				return
			end

			if not ConsoleList:IsA("ScrollingFrame") then
				return
			end

			local canvasSize =
				ConsoleList.AbsoluteCanvasSize.Y

			local visibleSize =
				ConsoleList.AbsoluteWindowSize.Y

			-- Don't scroll if everything fits
			-- inside the visible area.
			if canvasSize <= visibleSize then
				return
			end

			for _, v in pairs(ConsoleHolder.LogsFrame.Holder:GetChildren()) do
				if v:IsA("TextButton") then
					ConsoleList.CanvasSize = UDim2.new(0, 8, 0, ConsoleHolder.LogsFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 5)
				end
			end

			-- There are more logs than can be displayed,
			-- so scroll to the bottom.
			ConsoleList.CanvasPosition =
				Vector2.new(
					0,
					canvasSize - visibleSize
				)

		end)

	end


	-- ============================================================
	-- UPDATE COUNT
	-- ============================================================

	local function updateCount()

		if not LogCount then
			return
		end

		LogCount.Text =
			tostring(totalLogs)

	end


	-- ============================================================
	-- REMOVE OLD LOGS
	-- ============================================================

	local function enforceLimit()

		while #Logs > MAX_LOGS do

			local old =
				table.remove(
					Logs,
					1
				)

			if old then

				if old.gui
					and old.gui.Parent
				then

					old.gui:Destroy()

				end

			end

		end

	end


	-- ============================================================
	-- CONSOLE LOGS
	-- ============================================================

	local ConsoleLogger = {}

	function ConsoleLogger:Add(
		logType,
		message,
		stackTrace
	)

		message = stringify(message)

		local log = {
			type = logType,
			message = message,
			stackTrace = stackTrace,
			time = getTime(),
			gui = nil,
			expanded = false,
		}

		table.insert(Logs, log)

		totalLogs += 1

		-- ========================================================
		-- CLONE LOG TEMPLATE
		-- ========================================================

		local gui = ConsoleTemplate:Clone()

		gui.Name = "Log_" .. totalLogs
		gui.Visible = true
		gui.Parent = ConsoleList

		log.gui = gui

		-- ========================================================
		-- FORMAT LOG
		-- ========================================================

		local color = CONSOLE_COLORS[logType] or CONSOLE_COLORS.Print

		local prefix = ""

		if SHOW_TIMESTAMP then
			prefix = "[" .. log.time .. "] "
		end

		local formattedText =
			prefix
			.. "["
			.. logType
			.. "] "
			.. message

		-- Add stack trace
		if stackTrace then
			formattedText =
				formattedText
				.. "\n"
				.. stringify(stackTrace)
		end

		-- ========================================================
		-- TEXT BUTTON
		-- ========================================================

		gui.Text = formattedText

		gui.TextColor3 = color

		gui.TextWrapped = true

		gui.TextXAlignment =
			Enum.TextXAlignment.Left

		gui.TextYAlignment =
			Enum.TextYAlignment.Top

		gui.Font =
			Enum.Font.Code

		gui.TextSize = 13

		-- Automatically make the button tall enough
		gui.AutomaticSize =
			Enum.AutomaticSize.Y

		-- ========================================================
		-- OPTIONAL HOVER
		-- ========================================================

		gui.AutoButtonColor = true

		-- ========================================================
		-- CLICK TO EXPAND / COLLAPSE
		-- ========================================================

		if stackTrace then

			gui.MouseButton1Click:Connect(
				function()

					log.expanded =
						not log.expanded

					if log.expanded then

						gui.Text =
							prefix
							.. "["
							.. logType
							.. "] "
							.. message
							.. "\n\n"
							.. stringify(stackTrace)

					else

						gui.Text =
							prefix
							.. "["
							.. logType
							.. "] "
							.. message

					end

				end
			)

		end

		-- ========================================================
		-- LIMIT
		-- ========================================================

		enforceLimit()

		updateCount()

		scrollToBottom()

		return log
	end


	-- ============================================================
	-- PRINT
	-- ============================================================

	function ConsoleLogger:Print(...)

		local message =
			formatArguments(...)

		return self:Add(
			"Print",
			message
		)

	end


	-- ============================================================
	-- INFO
	-- ============================================================

	function ConsoleLogger:Info(...)

		local message =
			formatArguments(...)

		return self:Add(
			"Info",
			message
		)

	end


	-- ============================================================
	-- WARN
	-- ============================================================

	function ConsoleLogger:Warn(...)

		local message =
			formatArguments(...)

		return self:Add(
			"Warn",
			message
		)

	end


	-- ============================================================
	-- ERROR
	-- ============================================================

	function ConsoleLogger:Error(
		message,
		stackTrace
	)

		return self:Add(
			"Error",
			"\nStack Begin\nScript "..message.."\nStack End",
			stackTrace
		)

	end


	-- ============================================================
	-- SUCCESS
	-- ============================================================

	function ConsoleLogger:Success(...)

		local message =
			formatArguments(...)

		return self:Add(
			"Success",
			message
		)

	end


	-- ============================================================
	-- CLEAR
	-- ============================================================

	function ConsoleLogger:Clear()

		for _, log in ipairs(Logs) do

			if log.gui
				and log.gui.Parent
			then

				log.gui:Destroy()

			end

		end

		table.clear(
			Logs
		)

		totalLogs = 0

		updateCount()

	end


	-- ============================================================
	-- AUTO SCROLL
	-- ============================================================

	function ConsoleLogger:SetAutoScroll(
		enabled
	)

		AUTO_SCROLL =
			enabled == true

	end


	-- ============================================================
	-- GET LOGS
	-- ============================================================

	function ConsoleLogger:GetLogs()

		return Logs

	end


	-- ============================================================
	-- CLEAR BUTTON
	-- ============================================================

	if ClearButton then

		ClearButton.MouseButton1Click:Connect(
			function()

				ConsoleLogger:Clear()

			end
		)

	end


	-- ============================================================
	-- INITIALIZE
	-- ============================================================

	if ConsoleList:IsA(
		"ScrollingFrame"
		) then

		ConsoleList.AutomaticCanvasSize =
			Enum.AutomaticSize.Y

	end


	if ConsoleTemplate then

		ConsoleTemplate.Visible =
			false

	end


	updateCount()


	if CloseConsoleButton then
		CloseConsoleButton.MouseButton1Click:Connect(function()
			-- The Visible listener saves the closed state immediately.
			ConsoleFrame.Visible = false
		end)
	end

	-- ============================================================
	-- CONSOLE VISIBILITY / STATE API
	-- ============================================================

	function ConsoleLogger:Open()
		ConsoleFrame.Visible = true
	end

	function ConsoleLogger:Close()
		ConsoleFrame.Visible = false
	end

	function ConsoleLogger:Toggle()
		ConsoleFrame.Visible = not ConsoleFrame.Visible
		return ConsoleFrame.Visible
	end

	function ConsoleLogger:IsOpen()
		return ConsoleFrame.Visible
	end

	function ConsoleLogger:SaveState()
		return SaveConsoleState()
	end

	-- ============================================================
	-- ROBLOX OUTPUT HOOK
	-- ============================================================

	local LogService =
		game:GetService("LogService")

	LogService.MessageOut:Connect(
		function(
			message,
			messageType
		)

			-- ================================================
			-- PRINT
			-- ================================================

			if messageType ==
				Enum.MessageType.MessageOutput
			then

				ConsoleLogger:Print(
					message
				)

				-- ================================================
				-- WARNING
				-- ================================================

			elseif messageType ==
				Enum.MessageType.MessageWarning
			then

				ConsoleLogger:Warn(
					message
				)

				-- ================================================
				-- ERROR
				-- ================================================

			elseif messageType ==
				Enum.MessageType.MessageError
			then

				ConsoleLogger:Error(
					message
				)

			end

		end
	)

	print(
		"[Potassium Console] Initialized"
	)

	return ConsoleLogger
end
