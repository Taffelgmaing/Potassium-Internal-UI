return function(Console_2)


	-- ============================================================
	-- POTASSIUM CONSOLE
	-- ============================================================

	local ConsoleFrame = Console_2
	local ConsoleHolder = ConsoleFrame.ConsoleHolder

	local ConsoleTemplate = ConsoleHolder.Templates.Log

	local ConsoleList = ConsoleHolder.LogsFrame.Holder

	local ClearButton = ConsoleHolder.Settings:FindFirstChild("Clear")
	local LogCount = ConsoleHolder.Settings:FindFirstChild("LogCount")
	local AutoScrollButton = ConsoleHolder.Settings:FindFirstChild("AutoScroll")
	local CloseConsoleButton = ConsoleHolder.Settings:FindFirstChild("Close")

	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")

	-- ============================================================
	-- DRAGGING
	-- ============================================================

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

		topbarobject.InputBegan:Connect(
			function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Dragging = true
					DragStart = input.Position
					StartPosition = object.Position

					input.Changed:Connect(
						function()
							if input.UserInputState == Enum.UserInputState.End then
								Dragging = false
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

	local MIN_WIDTH = 300
	local MIN_HEIGHT = 200

	local MAX_WIDTH = 1200
	local MAX_HEIGHT = 800

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

	local MAX_LOGS = 500
	local AUTO_SCROLL = true

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

	local SHOW_TIMESTAMP = true


	-- ============================================================
	-- STATE
	-- ============================================================

	local Logs = {}
	local ConsoleLogs = {}

	local totalLogs = 0


	-- ============================================================
	-- COLORS
	-- ============================================================

	local CONSOLE_COLORS = {

		Print =
			Color3.fromRGB(
				220,
				220,
				220
			),

		Info =
			Color3.fromRGB(
				100,
				180,
				255
			),

		Warn =
			Color3.fromRGB(
				255,
				190,
				70
			),

		Error =
			Color3.fromRGB(
				255,
				80,
				80
			),

		Success =
			Color3.fromRGB(
				110,
				220,
				130
			),

		Time =
			Color3.fromRGB(
				120,
				120,
				120
			),

	}


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

			if canvasSize <= visibleSize then
				return
			end

			for _, v in pairs(ConsoleHolder.LogsFrame.Holder:GetChildren()) do
				if v:IsA("TextButton") then
					ConsoleList.CanvasSize = UDim2.new(0, 8, 0, ConsoleHolder.LogsFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 5)
				end
			end

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
			ConsoleFrame.Visible = false
		end)
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
end
