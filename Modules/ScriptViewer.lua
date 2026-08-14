return function(MainFrame, Console_2)
	--[[
		POTASSIUM SCRIPT VIEWER
		============================================================

		Read-only Luau source viewer.

		- Separate draggable/resizable window.
		- Same Font.Code / VS-style syntax colors as Potassium IDE.
		- Line numbers.
		- Horizontal + vertical scrolling.
		- Virtualized syntax-highlighted viewport for large scripts.
		- Opens only from Explorer's right-click "View Script" action.
		- Does not add a Script Viewer button to MainFrame.

		IMPORTANT:
		Normal Script/LocalScript code cannot read Script.Source at runtime.
		This viewer therefore supports:
		    1) direct Source access when the environment permits it,
		    2) a registered source provider,
		    3) registered source strings,
		    4) PotassiumSource attribute/StringValue fallbacks.
	]]

	-- ============================================================
	-- SERVICES
	-- ============================================================

	local UserInputService =
		game:GetService("UserInputService")

	local TextService =
		game:GetService("TextService")

	-- ============================================================
	-- ROOT
	-- ============================================================

	if not MainFrame then
		error(
			"[Potassium ScriptViewer] MainFrame is missing."
		)
	end

	local frame = MainFrame
	local windowParent = frame.Parent

	-- No MainFrame toolbar entry is created for ScriptViewer.
	-- Explorer's right-click "View Script" action is the only opener.

	-- ============================================================
	-- SINGLETON / EXISTING WINDOW
	-- ============================================================

	local existing =
		windowParent:FindFirstChild(
			"PotassiumScriptViewer"
		)

	if existing then
		local existingRequest =
			existing:FindFirstChild(
				"OpenScriptRequest"
			)

		local registerRequest =
			existing:FindFirstChild(
				"RegisterSourceRequest"
			)

		local unregisterRequest =
			existing:FindFirstChild(
				"UnregisterSourceRequest"
			)

		local providerRequest =
			existing:FindFirstChild(
				"SetSourceProviderRequest"
			)

		local controller = {}
		controller.Window = existing

		function controller:Open(instance)
			if existingRequest
				and existingRequest:IsA("BindableEvent")
			then
				existingRequest:Fire(instance)
			end
		end

		function controller:RegisterSource(
			instance,
			source
		)
			if registerRequest
				and registerRequest:IsA("BindableEvent")
			then
				registerRequest:Fire(
					instance,
					source
				)
			end
		end

		function controller:UnregisterSource(instance)
			if unregisterRequest
				and unregisterRequest:IsA("BindableEvent")
			then
				unregisterRequest:Fire(
					instance
				)
			end
		end

		function controller:SetSourceProvider(provider)
			if providerRequest
				and providerRequest:IsA("BindableEvent")
			then
				providerRequest:Fire(
					provider
				)
			end
		end

		return controller
	end

	-- ============================================================
	-- THEME
	-- ============================================================

	local WINDOW_BG =
		Color3.fromRGB(30, 30, 30)

	local PANEL_BG =
		Color3.fromRGB(34, 34, 34)

	local TOP_BG =
		Color3.fromRGB(38, 38, 38)

	local INPUT_BG =
		Color3.fromRGB(45, 45, 45)

	local BORDER =
		Color3.fromRGB(62, 62, 62)

	local TEXT =
		Color3.fromRGB(212, 212, 212)

	local MUTED =
		Color3.fromRGB(145, 145, 145)

	local ACCENT =
		Color3.fromRGB(110, 173, 255)

	local COLORS = {
		keyword = "#569CD6",
		string = "#CE9178",
		comment = "#6A9955",
		number = "#B5CEA8",
		functionName = "#DCDCAA",
		normal = "#D4D4D4",
		func = "rgb(110, 173, 255)",
		rblx = "rgb(198, 174, 57)",
	}

	-- ============================================================
	-- KEYWORDS - same visual categories as Potassium IDE
	-- ============================================================

	local KEYWORDS = {
		"if", "then", "else", "elseif", "end",
		"function", "local", "return", "for",
		"while", "do", "repeat", "until",
		"break", "continue", "and", "or", "not",
		"true", "false", "nil", "in",
	}

	local FUNCTIONS = {
		"print", "warn", "error", "assert",
		"pairs", "ipairs", "next", "select",
		"type", "typeof", "tostring", "tonumber",
		"require", "pcall", "xpcall",
		"setmetatable", "getmetatable", "rawget",
		"rawset", "rawequal",
		"math", "string", "table", "task", "coroutine",
	}

	local ROBLOXKEYWORDS = {
		"game", "workspace", "script", "Instance",
		"GetService", "Vector2", "Vector3", "CFrame",
		"Color3", "BrickColor", "UDim", "UDim2",
		"Enum", "RaycastParams", "TweenInfo",
	}

	local keywordSet = {}
	local functionSet = {}
	local robloxSet = {}

	for _, word in ipairs(KEYWORDS) do
		keywordSet[word] = true
	end

	for _, word in ipairs(FUNCTIONS) do
		functionSet[word] = true
	end

	for _, word in ipairs(ROBLOXKEYWORDS) do
		robloxSet[word] = true
	end

	-- ============================================================
	-- SMALL UI HELPERS
	-- ============================================================

	local function newLabel(
		parent,
		name,
		textValue
	)
		local label =
			Instance.new("TextLabel")

		label.Name = name
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Text = textValue or ""
		label.TextColor3 = TEXT
		label.Font = Enum.Font.Code
		label.TextSize = 13
		label.TextXAlignment =
			Enum.TextXAlignment.Left
		label.TextYAlignment =
			Enum.TextYAlignment.Center
		label.ZIndex = 7
		label.Parent = parent

		return label
	end

	local function newButton(
		parent,
		name,
		textValue
	)
		local button =
			Instance.new("TextButton")

		button.Name = name
		button.BackgroundColor3 = INPUT_BG
		button.BorderSizePixel = 0
		button.AutoButtonColor = true
		button.Text = textValue or ""
		button.TextColor3 = TEXT
		button.Font = Enum.Font.Code
		button.TextSize = 13
		button.ZIndex = 8
		button.Parent = parent

		local corner =
			Instance.new("UICorner")
		corner.CornerRadius =
			UDim.new(0, 4)
		corner.Parent = button

		return button
	end

	-- ============================================================
	-- WINDOW
	-- ============================================================

	local ViewerWindow =
		Instance.new("Frame")

	ViewerWindow.Name =
		"PotassiumScriptViewer"
	ViewerWindow.AnchorPoint =
		Vector2.new(0.5, 0.5)
	ViewerWindow.Position =
		UDim2.new(0.58, 0, 0.54, 0)
	ViewerWindow.Size =
		UDim2.fromOffset(800, 560)
	ViewerWindow.BackgroundColor3 =
		WINDOW_BG
	ViewerWindow.BorderSizePixel = 0
	ViewerWindow.Visible = false
	ViewerWindow.Active = true
	ViewerWindow.ZIndex = 4
	ViewerWindow.Parent = windowParent

	local windowCorner =
		Instance.new("UICorner")
	windowCorner.CornerRadius =
		UDim.new(0, 7)
	windowCorner.Parent = ViewerWindow

	local windowStroke =
		Instance.new("UIStroke")
	windowStroke.Color = BORDER
	windowStroke.Transparency = 0.1
	windowStroke.Parent = ViewerWindow

	local openRequest =
		Instance.new("BindableEvent")
	openRequest.Name = "OpenScriptRequest"
	openRequest.Parent = ViewerWindow

	local registerSourceRequest =
		Instance.new("BindableEvent")
	registerSourceRequest.Name =
		"RegisterSourceRequest"
	registerSourceRequest.Parent =
		ViewerWindow

	local unregisterSourceRequest =
		Instance.new("BindableEvent")
	unregisterSourceRequest.Name =
		"UnregisterSourceRequest"
	unregisterSourceRequest.Parent =
		ViewerWindow

	local setSourceProviderRequest =
		Instance.new("BindableEvent")
	setSourceProviderRequest.Name =
		"SetSourceProviderRequest"
	setSourceProviderRequest.Parent =
		ViewerWindow

	-- ============================================================
	-- TITLE BAR
	-- ============================================================

	local titleBar =
		Instance.new("Frame")

	titleBar.Name = "TitleBar"
	titleBar.Position =
		UDim2.fromOffset(0, 0)
	titleBar.Size =
		UDim2.new(1, 0, 0, 36)
	titleBar.BackgroundColor3 = TOP_BG
	titleBar.BorderSizePixel = 0
	titleBar.Active = true
	titleBar.ZIndex = 6
	titleBar.Parent = ViewerWindow

	local title =
		newLabel(
			titleBar,
			"Title",
			"Script Viewer"
		)

	title.Position =
		UDim2.fromOffset(12, 0)
	title.Size =
		UDim2.new(1, -100, 1, 0)
	title.TextSize = 14

	local refreshButton =
		newButton(
			titleBar,
			"Refresh",
			"↻"
		)

	refreshButton.AnchorPoint =
		Vector2.new(1, 0.5)
	refreshButton.Position =
		UDim2.new(1, -42, 0.5, 0)
	refreshButton.Size =
		UDim2.fromOffset(28, 26)

	local closeButton =
		newButton(
			titleBar,
			"Close",
			"×"
		)

	closeButton.AnchorPoint =
		Vector2.new(1, 0.5)
	closeButton.Position =
		UDim2.new(1, -8, 0.5, 0)
	closeButton.Size =
		UDim2.fromOffset(28, 26)
	closeButton.TextSize = 17

	-- ============================================================
	-- SCRIPT INFO
	-- ============================================================

	local infoBar =
		Instance.new("Frame")

	infoBar.Name = "InfoBar"
	infoBar.Position =
		UDim2.fromOffset(8, 44)
	infoBar.Size =
		UDim2.new(1, -16, 0, 44)
	infoBar.BackgroundColor3 = PANEL_BG
	infoBar.BorderSizePixel = 0
	infoBar.ZIndex = 5
	infoBar.Parent = ViewerWindow

	local infoCorner =
		Instance.new("UICorner")
	infoCorner.CornerRadius =
		UDim.new(0, 5)
	infoCorner.Parent = infoBar

	local scriptName =
		newLabel(
			infoBar,
			"ScriptName",
			"No script selected"
		)
	scriptName.Position =
		UDim2.fromOffset(10, 2)
	scriptName.Size =
		UDim2.new(1, -20, 0, 20)
	scriptName.TextColor3 = ACCENT

	local scriptPath =
		newLabel(
			infoBar,
			"ScriptPath",
			"Select a Script, LocalScript, or ModuleScript in Explorer."
		)
	scriptPath.Position =
		UDim2.fromOffset(10, 21)
	scriptPath.Size =
		UDim2.new(1, -20, 0, 20)
	scriptPath.TextColor3 = MUTED
	scriptPath.TextTruncate =
		Enum.TextTruncate.AtEnd

	-- ============================================================
	-- READ-ONLY CODE VIEW
	-- ============================================================

	local codeScroll =
		Instance.new("ScrollingFrame")

	codeScroll.Name = "CodeScroll"
	codeScroll.Position =
		UDim2.fromOffset(8, 96)
	codeScroll.Size =
		UDim2.new(1, -16, 1, -104)
	codeScroll.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)
	codeScroll.BorderSizePixel = 0
	codeScroll.ScrollBarThickness = 8
	codeScroll.ScrollBarImageTransparency =
		0.15
	codeScroll.CanvasSize =
		UDim2.fromOffset(0, 0)
	codeScroll.AutomaticCanvasSize =
		Enum.AutomaticSize.None
	codeScroll.ScrollingDirection =
		Enum.ScrollingDirection.XY
	codeScroll.ClipsDescendants = true
	codeScroll.ZIndex = 5
	codeScroll.Parent = ViewerWindow

	local codeCorner =
		Instance.new("UICorner")
	codeCorner.CornerRadius =
		UDim.new(0, 5)
	codeCorner.Parent = codeScroll

	local codeContent =
		Instance.new("Frame")

	codeContent.Name = "CodeContent"
	codeContent.Position =
		UDim2.fromOffset(0, 0)
	codeContent.Size =
		UDim2.fromOffset(1, 1)
	codeContent.BackgroundTransparency = 1
	codeContent.BorderSizePixel = 0
	codeContent.ZIndex = 5
	codeContent.Parent = codeScroll

	local gutter =
		Instance.new("Frame")

	gutter.Name = "Gutter"
	gutter.Position =
		UDim2.fromOffset(0, 0)
	gutter.Size =
		UDim2.fromOffset(55, 1)
	gutter.BackgroundColor3 =
		Color3.fromRGB(27, 27, 27)
	gutter.BorderSizePixel = 0
	gutter.ZIndex = 7
	gutter.Parent = codeContent

	local gutterBorder =
		Instance.new("Frame")
	gutterBorder.Name = "Border"
	gutterBorder.AnchorPoint =
		Vector2.new(1, 0)
	gutterBorder.Position =
		UDim2.new(1, 0, 0, 0)
	gutterBorder.Size =
		UDim2.new(0, 1, 1, 0)
	gutterBorder.BackgroundColor3 = BORDER
	gutterBorder.BorderSizePixel = 0
	gutterBorder.ZIndex = 8
	gutterBorder.Parent = gutter

	local gutterText =
		Instance.new("TextLabel")

	gutterText.Name = "LineNumbers"
	gutterText.BackgroundTransparency = 1
	gutterText.BorderSizePixel = 0
	gutterText.Position =
		UDim2.fromOffset(0, 0)
	gutterText.Size =
		UDim2.fromOffset(54, 20)
	gutterText.Font = Enum.Font.Code
	gutterText.TextSize = 14
	gutterText.TextColor3 = MUTED
	gutterText.TextXAlignment =
		Enum.TextXAlignment.Right
	gutterText.TextYAlignment =
		Enum.TextYAlignment.Top
	gutterText.TextWrapped = false
	gutterText.RichText = false
	gutterText.ZIndex = 9
	gutterText.Parent = gutter

	local codeLabel =
		Instance.new("TextLabel")

	codeLabel.Name = "Code"
	codeLabel.BackgroundTransparency = 1
	codeLabel.BorderSizePixel = 0
	codeLabel.Position =
		UDim2.fromOffset(63, 0)
	codeLabel.Size =
		UDim2.fromOffset(100, 20)
	codeLabel.Font = Enum.Font.Code
	codeLabel.TextSize = 14
	codeLabel.TextColor3 = TEXT
	codeLabel.TextXAlignment =
		Enum.TextXAlignment.Left
	codeLabel.TextYAlignment =
		Enum.TextYAlignment.Top
	codeLabel.TextWrapped = false
	codeLabel.RichText = true
	codeLabel.ZIndex = 6
	codeLabel.Parent = codeContent

	local resizeHandle =
		newButton(
			ViewerWindow,
			"ScriptViewerResizeHandle",
			""
		)

	resizeHandle.AnchorPoint =
		Vector2.new(1, 1)
	resizeHandle.Position =
		UDim2.new(1, -2, 1, -2)
	resizeHandle.Size =
		UDim2.fromOffset(16, 16)
	resizeHandle.BackgroundTransparency = 0.45
	resizeHandle.ZIndex = 30

	-- ============================================================
	-- SOURCE / SYNTAX STATE
	-- ============================================================

	local registeredSources =
		setmetatable(
			{},
			{__mode = "k"}
		)

	local sourceProvider = nil
	local selectedScript = nil
	local currentSource = ""
	local currentLines = {""}

	local lineHeight =
		math.max(
			1,
			TextService:GetTextSize(
				"Ay",
				codeLabel.TextSize,
				codeLabel.Font,
				Vector2.new(
					10000,
					10000
				)
			).Y
		)

	local VIEW_BUFFER_LINES = 20

	local function escapeRichText(value)
		value = value:gsub("&", "&amp;")
		value = value:gsub("<", "&lt;")
		value = value:gsub(">", "&gt;")
		value = value:gsub('"', "&quot;")
		return value
	end

	local function highlight(code)
		local result = {}
		local i = 1
		local length = #code

		while i <= length do
			local character =
				code:sub(i, i)

			if code:sub(i, i + 1) == "--" then
				local newline =
					code:find(
						"\n",
						i,
						true
					)
					or length + 1

				table.insert(
					result,
					('<font color="%s">%s</font>'):format(
						COLORS.comment,
						escapeRichText(
							code:sub(
								i,
								newline - 1
							)
						)
					)
				)

				i = newline

			elseif character == '"'
				or character == "'"
			then
				local quote = character
				local j = i + 1

				while j <= length do
					local current =
						code:sub(j, j)

					if current == "\\" then
						j += 2
					elseif current == quote then
						j += 1
						break
					else
						j += 1
					end
				end

				table.insert(
					result,
					('<font color="%s">%s</font>'):format(
						COLORS.string,
						escapeRichText(
							code:sub(
								i,
								j - 1
							)
						)
					)
				)

				i = j

			elseif character:match("[%a_]") then
				local j = i

				while j <= length
					and code:sub(j, j):match(
						"[%w_]"
					)
				do
					j += 1
				end

				local word =
					code:sub(i, j - 1)

				if keywordSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.keyword,
							escapeRichText(word)
						)
					)
				elseif functionSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.func,
							escapeRichText(word)
						)
					)
				elseif robloxSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.rblx,
							escapeRichText(word)
						)
					)
				else
					table.insert(
						result,
						escapeRichText(word)
					)
				end

				i = j

			elseif character:match("%d") then
				local j = i

				while j <= length
					and code:sub(j, j):match(
						"[%d%.]"
					)
				do
					j += 1
				end

				table.insert(
					result,
					('<font color="%s">%s</font>'):format(
						COLORS.number,
						escapeRichText(
							code:sub(
								i,
								j - 1
							)
						)
					)
				)

				i = j

			else
				table.insert(
					result,
					escapeRichText(character)
				)
				i += 1
			end
		end

		return table.concat(result)
	end

	local function splitLines(source)
		local lines = {}
		local startPosition = 1

		while true do
			local newline =
				source:find(
					"\n",
					startPosition,
					true
				)

			if not newline then
				table.insert(
					lines,
					source:sub(
						startPosition
					)
				)
				break
			end

			table.insert(
				lines,
				source:sub(
					startPosition,
					newline - 1
				)
			)

			startPosition =
				newline + 1
		end

		if #lines == 0 then
			lines = {""}
		end

		return lines
	end

	local function getInstancePath(instance)
		if not instance then
			return ""
		end

		local parts = {}
		local current = instance

		while current
			and current ~= game
		do
			table.insert(
				parts,
				1,
				current.Name
			)
			current = current.Parent
		end

		return "game."
			.. table.concat(
				parts,
				"."
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

	local function tryReadSource(instance)
		if not isScriptContainer(instance) then
			return nil,
				"Selected instance is not a script."
		end

		local registered =
			registeredSources[instance]

		if type(registered) == "string" then
			return registered
		end

		if sourceProvider then
			local ok, provided =
				pcall(
					sourceProvider,
					instance
				)

			if ok
				and type(provided) == "string"
			then
				return provided
			end
		end

		-- Works only in environments where Roblox allows Source access.
		local okSource, source =
			pcall(function()
				return instance.Source
			end)

		if okSource
			and type(source) == "string"
		then
			return source
		end

		local okAttribute, attribute =
			pcall(function()
				return instance:GetAttribute(
					"PotassiumSource"
				)
			end)

		if okAttribute
			and type(attribute) == "string"
		then
			return attribute
		end

		local sourceValue =
			instance:FindFirstChild(
				"PotassiumSource"
			)

		if sourceValue
			and sourceValue:IsA("StringValue")
		then
			return sourceValue.Value
		end

		return nil,
			"Roblox blocked access to this script's Source. "
			.. "Register the source with ScriptViewer:RegisterSource(...) "
			.. "or provide a source provider."
	end

	local function calculateContentWidth()
		local longest = ""

		for _, line in ipairs(currentLines) do
			local expanded =
				line:gsub("\t", "    ")

			if #expanded > #longest then
				longest = expanded
			end
		end

		local width = 0

		if longest ~= "" then
			width =
				TextService:GetTextSize(
					longest,
					codeLabel.TextSize,
					codeLabel.Font,
					Vector2.new(
						1000000,
						lineHeight
					)
				).X
		end

		return math.max(
			codeScroll.AbsoluteSize.X,
			math.ceil(
				width + 110
			)
		)
	end

	local function updateCanvas()
		local contentWidth =
			calculateContentWidth()

		local contentHeight =
			math.max(
				codeScroll.AbsoluteSize.Y,
				#currentLines
				* lineHeight
				+ 12
			)

		codeContent.Size =
			UDim2.fromOffset(
				contentWidth,
				contentHeight
			)

		codeScroll.CanvasSize =
			UDim2.fromOffset(
				contentWidth,
				contentHeight
			)

		gutter.Size =
			UDim2.fromOffset(
				55,
				contentHeight
			)
	end

	local lastFirstVisible = -1
	local lastLastVisible = -1

	local function updateVisibleCode(force)
		if #currentLines == 0 then
			currentLines = {""}
		end

		local viewportHeight =
			math.max(
				1,
				codeScroll.AbsoluteSize.Y
			)

		local firstVisible =
			math.floor(
				codeScroll.CanvasPosition.Y
				/ lineHeight
			)
			+ 1
		- VIEW_BUFFER_LINES

		local lastVisible =
			math.ceil(
				(
					codeScroll.CanvasPosition.Y
					+ viewportHeight
				) / lineHeight
			)
			+ VIEW_BUFFER_LINES

		firstVisible =
			math.clamp(
				firstVisible,
				1,
				#currentLines
			)

		lastVisible =
			math.clamp(
				lastVisible,
				firstVisible,
				#currentLines
			)

		-- Keep the gutter fixed horizontally while the code scrolls.
		gutter.Position =
			UDim2.fromOffset(
				codeScroll.CanvasPosition.X,
				0
			)

		if not force
			and firstVisible == lastFirstVisible
			and lastVisible == lastLastVisible
		then
			return
		end

		lastFirstVisible = firstVisible
		lastLastVisible = lastVisible

		local codeChunk = {}
		local numbers = {}

		for lineNumber =
			firstVisible,
			lastVisible
		do
			table.insert(
				codeChunk,
				currentLines[lineNumber]
			)

			table.insert(
				numbers,
				tostring(lineNumber)
			)
		end

		local y =
			(firstVisible - 1)
			* lineHeight

		local height =
			math.max(
				lineHeight,
				(
					lastVisible
					- firstVisible
					+ 1
				)
				* lineHeight
			)

		codeLabel.Position =
			UDim2.fromOffset(
				63,
				y
			)

		codeLabel.Size =
			UDim2.new(
				1,
				-70,
				0,
				height
			)

		gutterText.Position =
			UDim2.fromOffset(
				0,
				y
			)

		gutterText.Size =
			UDim2.fromOffset(
				48,
				height
			)

		codeLabel.Text =
			highlight(
				table.concat(
					codeChunk,
					"\n"
				)
			)

		gutterText.Text =
			table.concat(
				numbers,
				"\n"
			)
	end

	local function setDisplayedSource(
		instance,
		source,
		errorMessage
	)
		selectedScript = instance

		if instance then
			scriptName.Text =
				instance.Name
				.. "  <"
				.. instance.ClassName
				.. ">"

			scriptPath.Text =
				getInstancePath(instance)

			title.Text =
				"Script Viewer  •  "
				.. instance.Name
		else
			scriptName.Text =
				"No script selected"

			scriptPath.Text =
				"Select a Script, LocalScript, or ModuleScript in Explorer."

			title.Text = "Script Viewer"
		end

		if source then
			currentSource = source
		else
			currentSource =
				"-- Potassium Script Viewer\n"
				.. "-- Work is still in progress...\n"
				.. "-- Source unavailable\n\n"
				.. "-- "
				.. tostring(
					errorMessage
					or "Unknown source error."
				)
		end

		currentLines =
			splitLines(
				currentSource
			)

		lastFirstVisible = -1
		lastLastVisible = -1

		codeScroll.CanvasPosition =
			Vector2.new(0, 0)

		updateCanvas()
		updateVisibleCode(true)
	end

	local function openScript(instance)
		if not isScriptContainer(instance) then
			setDisplayedSource(
				nil,
				nil,
				"Selected Explorer item is not a script."
			)
			return false
		end

		local source, sourceError =
			tryReadSource(instance)

		setDisplayedSource(
			instance,
			source,
			sourceError
		)

		ViewerWindow.Visible = true

		-- Bring viewer above the other Potassium windows.
		MainFrame.ZIndex = 4

		if Console_2 then
			Console_2.ZIndex = 4
		end

		local explorer =
			windowParent:FindFirstChild(
				"PotassiumExplorer"
			)

		if explorer
			and explorer:IsA("GuiObject")
		then
			explorer.ZIndex = 4
		end

		ViewerWindow.ZIndex = 6

		return source ~= nil
	end

	local function getExplorerSelection()
		local explorer =
			windowParent:FindFirstChild(
				"PotassiumExplorer"
			)

		if not explorer then
			return nil
		end

		local selection =
			explorer:FindFirstChild(
				"ExplorerSelection"
			)

		if selection
			and selection:IsA("ObjectValue")
		then
			return selection.Value
		end

		return nil
	end

	-- ============================================================
	-- CONTROLLER API
	-- ============================================================

	local controller = {}
	controller.Window = ViewerWindow

	function controller:Open(instance)
		return openScript(instance)
	end

	function controller:RegisterSource(
		instance,
		source
	)
		if instance
			and type(source) == "string"
		then
			registeredSources[instance] =
				source

			if selectedScript == instance then
				setDisplayedSource(
					instance,
					source
				)
			end
		end
	end

	function controller:UnregisterSource(instance)
		registeredSources[instance] = nil
	end

	function controller:SetSourceProvider(provider)
		if provider ~= nil
			and type(provider) ~= "function"
		then
			error(
				"Source provider must be a function or nil."
			)
		end

		sourceProvider = provider
	end

	-- ============================================================
	-- OPEN / REFRESH EVENTS
	-- ============================================================

	openRequest.Event:Connect(function(instance)
		openScript(instance)
	end)

	registerSourceRequest.Event:Connect(function(
		instance,
		source
	)
		if instance
			and type(source) == "string"
		then
			registeredSources[instance] =
				source

			if selectedScript == instance then
				setDisplayedSource(
					instance,
					source
				)
			end
		end
	end)

	unregisterSourceRequest.Event:Connect(function(instance)
		registeredSources[instance] = nil
	end)

	setSourceProviderRequest.Event:Connect(function(provider)
		if provider == nil
			or type(provider) == "function"
		then
			sourceProvider = provider
		end
	end)

	refreshButton.MouseButton1Click:Connect(function()
		if selectedScript then
			openScript(selectedScript)
		else
			local selected =
				getExplorerSelection()

			if selected then
				openScript(selected)
			end
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		ViewerWindow.Visible = false
	end)

	-- ============================================================
	-- SCROLL / RESIZE
	-- ============================================================

	codeScroll:GetPropertyChangedSignal(
		"CanvasPosition"
	):Connect(function()
		updateVisibleCode(false)
	end)

	codeScroll:GetPropertyChangedSignal(
		"AbsoluteSize"
	):Connect(function()
		updateCanvas()
		updateVisibleCode(true)
	end)

	local draggingWindow = false
	local dragStart = nil
	local dragWindowStart = nil

	titleBar.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1
		then
			draggingWindow = true
			dragStart = inputObject.Position
			dragWindowStart =
				ViewerWindow.Position
		end
	end)

	local resizingWindow = false
	local resizeStartMouse = nil
	local resizeStartSize = nil

	resizeHandle.MouseButton1Down:Connect(function()
		resizingWindow = true
		resizeStartMouse =
			UserInputService:GetMouseLocation()
		resizeStartSize =
			ViewerWindow.AbsoluteSize
	end)

	UserInputService.InputChanged:Connect(function(inputObject)
		if inputObject.UserInputType
			~= Enum.UserInputType.MouseMovement
		then
			return
		end

		if draggingWindow
			and dragStart
			and dragWindowStart
		then
			local delta =
				inputObject.Position
			- dragStart

			ViewerWindow.Position =
				UDim2.new(
					dragWindowStart.X.Scale,
					dragWindowStart.X.Offset
					+ delta.X,
					dragWindowStart.Y.Scale,
					dragWindowStart.Y.Offset
					+ delta.Y
				)
		end

		if resizingWindow
			and resizeStartMouse
			and resizeStartSize
		then
			local delta =
				UserInputService:GetMouseLocation()
			- resizeStartMouse

			local width =
				math.clamp(
					resizeStartSize.X
					+ delta.X,
					520,
					1400
				)

			local height =
				math.clamp(
					resizeStartSize.Y
					+ delta.Y,
					320,
					900
				)

			ViewerWindow.Size =
				UDim2.fromOffset(
					width,
					height
				)

			updateCanvas()
			updateVisibleCode(true)
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1
		then
			draggingWindow = false
			resizingWindow = false
		end
	end)

	local function viewerInFocus()
		MainFrame.ZIndex = 4

		if Console_2 then
			Console_2.ZIndex = 4
		end

		local explorer =
			windowParent:FindFirstChild(
				"PotassiumExplorer"
			)

		if explorer
			and explorer:IsA("GuiObject")
		then
			explorer.ZIndex = 4
		end

		ViewerWindow.ZIndex = 6
	end

	ViewerWindow.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType
			== Enum.UserInputType.MouseButton1
		then
			viewerInFocus()
		end
	end)

	MainFrame.MouseButton1Down:Connect(function()
		if ViewerWindow.Visible then
			ViewerWindow.ZIndex = 4
		end
	end)

	if Console_2 then
		Console_2.MouseButton1Down:Connect(function()
			if ViewerWindow.Visible then
				ViewerWindow.ZIndex = 4
			end
		end)
	end

	-- Initial empty view.
	setDisplayedSource(nil, "")

	return controller
end
