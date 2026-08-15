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
		Normal Roblox code cannot read arbitrary Script.Source at runtime.

		This viewer now integrates with the Potassium executor script API:
		    1) registered source strings,
		    2) registered source provider,
		    3) optional executor decompile(...) when available,
		    4) Potassium getscriptbytecode(...) API,
		    5) direct Source access when the environment permits it,
		    6) PotassiumSource attribute/StringValue fallbacks.

		The documented Potassium API exposes raw Luau bytecode, not a
		documented source decompiler. When no decompile function exists,
		the viewer shows a readable bytecode/metadata view instead.
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
		Instance.new("ImageButton")

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
	ViewerWindow.ImageTransparency = 1
	ViewerWindow.AutoButtonColor = false

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
		UDim2.new(1, -190, 1, 0)
	title.TextSize = 14

	local readableNamesButton =
		newButton(
			titleBar,
			"ReadableNames",
			"Names: ON"
		)

	readableNamesButton.AnchorPoint =
		Vector2.new(1, 0.5)
	readableNamesButton.Position =
		UDim2.new(1, -80, 0.5, 0)
	readableNamesButton.Size =
		UDim2.fromOffset(78, 26)

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

	-- Transparent plain-text layer used only for mouse selection/copying.
	-- The syntax-colored TextLabel stays visible underneath it.
	local selectionBox =
		Instance.new("TextBox")

	selectionBox.Name = "SelectableCode"
	selectionBox.BackgroundTransparency = 1
	selectionBox.BorderSizePixel = 0
	selectionBox.Position = codeLabel.Position
	selectionBox.Size = codeLabel.Size
	selectionBox.Font = codeLabel.Font
	selectionBox.TextSize = codeLabel.TextSize
	selectionBox.TextXAlignment =
		Enum.TextXAlignment.Left
	selectionBox.TextYAlignment =
		Enum.TextYAlignment.Top
	selectionBox.TextWrapped = false
	selectionBox.MultiLine = true
	selectionBox.ClearTextOnFocus = false
	selectionBox.TextEditable = false
	selectionBox.ShowNativeInput = false
	selectionBox.TextTransparency = 1
	selectionBox.BackgroundColor3 =
		Color3.fromRGB(30, 30, 30)
	selectionBox.RichText = false
	selectionBox.ZIndex = 10
	selectionBox.Parent = codeContent

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
	local rawCurrentSource = ""
	local currentSource = ""
	local currentLines = {""}
	local currentSourceMode = "None"
	local readableNamesEnabled = true

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

	-- ============================================================
	-- POTASSIUM EXECUTOR SCRIPT API
	-- ============================================================

	local function getExecutorEnvironment()
		local ok, environment =
			pcall(function()
				if type(getgenv) == "function" then
					return getgenv()
				end

				return _G
			end)

		if ok
			and type(environment) == "table"
		then
			return environment
		end

		return _G
	end

	local function getExecutorFunction(name)
		local environment =
			getExecutorEnvironment()

		local candidate =
			environment
			and environment[name]

		if type(candidate) == "function" then
			return candidate
		end

		local ok, globalCandidate =
			pcall(function()
				return _G[name]
			end)

		if ok
			and type(globalCandidate) == "function"
		then
			return globalCandidate
		end

		return nil
	end

	local function buildBytecodeView(
		instance,
		bytecode
	)
		local output = {
			"-- Potassium Script Viewer",
			"-- ================================================",
			"-- Source mode: raw Luau bytecode",
			"-- Script: " .. tostring(instance.Name),
			"-- Class: " .. tostring(instance.ClassName),
			"-- Bytecode size: " .. tostring(#bytecode) .. " bytes",
		}

		local getHash =
			getExecutorFunction(
				"getscripthash"
			)

		if getHash then
			local ok, hash =
				pcall(
					getHash,
					instance
				)

			if ok
				and type(hash) == "string"
			then
				table.insert(
					output,
					"-- SHA384: " .. hash
				)
			end
		end

		table.insert(output, "--")
		table.insert(
			output,
			"-- Potassium documents getscriptbytecode(script), which returns"
		)
		table.insert(
			output,
			"-- compiled Luau bytecode rather than original Luau source."
		)
		table.insert(
			output,
			"-- If this executor build exposes decompile(script), ScriptViewer"
		)
		table.insert(
			output,
			"-- will use it automatically and show reconstructed Luau instead."
		)
		table.insert(output, "")
		table.insert(
			output,
			"-- HEX / ASCII BYTECODE DUMP"
		)
		table.insert(
			output,
			"-- -----------------------------------------------"
		)

		local bytesPerLine = 16

		for offset = 1, #bytecode, bytesPerLine do
			local chunk =
				bytecode:sub(
					offset,
					math.min(
						#bytecode,
						offset + bytesPerLine - 1
					)
				)

			local hexParts = {}
			local asciiParts = {}

			for index = 1, #chunk do
				local character =
					chunk:sub(index, index)

				local byte =
					string.byte(character)

				table.insert(
					hexParts,
					string.format(
						"%02X",
						byte
					)
				)

				if byte >= 32
					and byte <= 126
				then
					table.insert(
						asciiParts,
						character
					)
				else
					table.insert(
						asciiParts,
						"."
					)
				end
			end

			local hexText =
				table.concat(
					hexParts,
					" "
				)

			local targetHexLength =
				bytesPerLine * 3 - 1

			if #hexText < targetHexLength then
				hexText =
					hexText
					.. string.rep(
						" ",
						targetHexLength - #hexText
					)
			end

			table.insert(
				output,
				string.format(
					"%08X  %s  |%s|",
					offset - 1,
					hexText,
					table.concat(asciiParts)
				)
			)
		end

		return table.concat(
			output,
			"\n"
		)
	end

	local function tryPotassiumScriptApi(instance)
		if not (
			instance:IsA("LocalScript")
				or instance:IsA("ModuleScript")
			)
		then
			return nil,
				nil,
				"Potassium getscriptbytecode() supports LocalScript and ModuleScript."
		end

		local decompileFunction =
			getExecutorFunction(
				"decompile"
			)

		if decompileFunction then
			local ok, decompiled =
				pcall(
					decompileFunction,
					instance
				)

			if ok
				and type(decompiled) == "string"
				and decompiled ~= ""
			then
				return decompiled,
					"Decompiled",
					nil
			end
		end

		local getBytecode =
			getExecutorFunction(
				"getscriptbytecode"
			)

		if not getBytecode then
			return nil,
				nil,
				"Potassium getscriptbytecode() is unavailable in this environment."
		end

		local okBytecode, bytecode =
			pcall(
				getBytecode,
				instance
			)

		if not okBytecode then
			return nil,
				nil,
				"getscriptbytecode() failed: "
				.. tostring(bytecode)
		end

		if type(bytecode) ~= "string"
			or bytecode == ""
		then
			return nil,
				nil,
				"getscriptbytecode() returned no bytecode."
		end

		return buildBytecodeView(
			instance,
			bytecode
		),
			"Bytecode",
			nil
	end

	local function tryReadSource(instance)
		if not isScriptContainer(instance) then
			return nil,
				nil,
				"Selected instance is not a script."
		end

		local registered =
			registeredSources[instance]

		if type(registered) == "string" then
			return registered,
				"Registered Source",
				nil
		end

		if sourceProvider then
			local ok, provided =
				pcall(
					sourceProvider,
					instance
				)

			if ok
				and type(provided) == "string"
				and provided ~= ""
			then
				return provided,
					"Source Provider",
					nil
			end
		end

		local potassiumSource,
			potassiumMode,
			potassiumError =
			tryPotassiumScriptApi(
				instance
			)

		if potassiumSource then
			return potassiumSource,
				potassiumMode,
				nil
		end

		local okSource, source =
			pcall(function()
				return instance.Source
			end)

		if okSource
			and type(source) == "string"
			and source ~= ""
		then
			return source,
				"Direct Source",
				nil
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
			return attribute,
				"PotassiumSource Attribute",
				nil
		end

		local sourceValue =
			instance:FindFirstChild(
				"PotassiumSource"
			)

		if sourceValue
			and sourceValue:IsA("StringValue")
		then
			return sourceValue.Value,
				"PotassiumSource StringValue",
				nil
		end

		return nil,
			nil,
			potassiumError
			or (
				"Source unavailable. Potassium could not read or "
				.. "decompile this script."
			)
	end

	-- ============================================================
	-- READABLE DECOMPILED LOCAL NAMES
	-- ============================================================
	--
	-- This is deliberately heuristic. Decompilers often produce names such
	-- as u4/v12. Original variable names are not present in bytecode, so they
	-- cannot be recovered perfectly. Instead, infer useful names from the
	-- assignment context and replace only identifier tokens outside strings
	-- and comments.

	local function looksObfuscatedLocal(name)
		return name:match("^[uv]%d+$") ~= nil
			or name:match("^v%d+$") ~= nil
			or name:match("^u%d+$") ~= nil
			or name:match("^var%d+$") ~= nil
			or name:match("^l__%d+__$") ~= nil
	end

	local function sanitizeIdentifier(name)
		if type(name) ~= "string"
			or name == ""
		then
			return nil
		end

		name =
			name:gsub(
				"[^%w_]",
				""
			)

		if name == ""
			or not name:sub(1, 1):match("[%a_]")
		then
			return nil
		end

		return name
	end

	local function inferLocalName(rhs)
		-- Use double-quoted Luau strings here so the single-quote
		-- character inside the pattern does not terminate the string.
		local service =
			rhs:match(
				"game%s*:%s*GetService%s*%(%s*[\"']([^\"']+)[\"']"
			)

		if service then
			return sanitizeIdentifier(service)
		end

		local className =
			rhs:match(
				"Instance%s*%.%s*new%s*%(%s*[\"']([^\"']+)[\"']"
			)

		if className then
			return sanitizeIdentifier(className)
		end

		if rhs:match("^%s*{%s*}%s*[,;]?%s*$")
			or rhs:match("^%s*{%s*$")
		then
			return "Module"
		end

		if rhs:match("^%s*require%s*%(") then
			local requireBody =
				rhs:match(
					"^%s*require%s*%((.*)%)"
				)
				or rhs

			local lastName = nil

			for identifier in requireBody:gmatch(
				"[%a_][%w_]*"
				) do
				if identifier ~= "require"
					and identifier ~= "game"
					and identifier ~= "GetService"
				then
					lastName = identifier
				end
			end

			if lastName then
				if lastName:lower():find(
					"config",
					1,
					true
					) then
					return sanitizeIdentifier(
						lastName
					)
				end

				if lastName:lower():find(
					"handler",
					1,
					true
					) then
					return sanitizeIdentifier(
						lastName
					)
				end

				return sanitizeIdentifier(
					lastName
				)
					or "Module"
			end

			return "Module"
		end

		if rhs:find(
			"LocalPlayer",
			1,
			true
			) then
			return "Player"
		end

		if rhs:find(
			"HumanoidRootPart",
			1,
			true
			) then
			return "RootPart"
		end

		if rhs:find(
			"Humanoid",
			1,
			true
			) then
			return "Humanoid"
		end

		if rhs:find(
			".Character",
			1,
			true
			) then
			return "Character"
		end

		if rhs:match("^%s*workspace[%s%.%[]")
			or rhs:match("^%s*workspace%s*$")
		then
			return "Workspace"
		end

		if rhs:match("^%s*function%s*%(") then
			return "Callback"
		end

		if rhs:match("^%s*tonumber%s*%(") then
			return "Number"
		end

		if rhs:match("^%s*tostring%s*%(") then
			return "Text"
		end

		if rhs:match("^%s*[\"\\']") then
			return "Text"
		end

		if rhs:match("^%s*[%d%-]") then
			return "Number"
		end

		if rhs:match("^%s*true")
			or rhs:match("^%s*false")
		then
			return "Flag"
		end

		-- Property-chain fallback:
		--     local v15 = v14.Tower.Frame
		-- becomes approximately:
		--     local Frame = ...
		local lastProperty = nil

		for property in rhs:gmatch(
			"%.%s*([%a_][%w_]*)"
			) do
			lastProperty = property
		end

		if lastProperty then
			return sanitizeIdentifier(
				lastProperty
			)
		end

		return "Value"
	end

	local function collectExistingIdentifiers(source)
		local used = {}

		for identifier in source:gmatch(
			"[%a_][%w_]*"
			) do
			used[identifier] = true
		end

		return used
	end

	local function makeUniqueName(
		baseName,
		used,
		renamed
	)
		baseName =
			sanitizeIdentifier(baseName)
			or "Value"

		if not used[baseName]
			and not renamed[baseName]
		then
			return baseName
		end

		local index = 2

		while used[
			baseName .. tostring(index)
			]
				or renamed[
			baseName .. tostring(index)
			]
		do
			index += 1
		end

		return baseName
			.. tostring(index)
	end

	local function buildReadableNameMap(source)
		local mapping = {}
		local reverseNames = {}
		local used =
			collectExistingIdentifiers(
				source
			)

		for line in (
			source .. "\n"
			):gmatch("(.-)\n") do
			local localName,
				rhs =
				line:match(
					"^%s*local%s+([%a_][%w_]*)%s*=%s*(.-)%s*$"
				)

			if localName
				and looksObfuscatedLocal(
					localName
				)
					and not mapping[localName]
			then
				local inferred =
					inferLocalName(
						rhs
					)

				local readable =
					makeUniqueName(
						inferred,
						used,
						reverseNames
					)

				mapping[localName] =
					readable

				reverseNames[readable] =
					true
			end
		end

		return mapping
	end

	local function replaceIdentifiersSafely(
		source,
		mapping
	)
		if not next(mapping) then
			return source
		end

		local output = {}
		local i = 1
		local length = #source

		while i <= length do
			local character =
				source:sub(i, i)

			if source:sub(i, i + 1) == "--" then
				local newline =
					source:find(
						"\n",
						i,
						true
					)
					or length + 1

				table.insert(
					output,
					source:sub(
						i,
						newline - 1
					)
				)

				i = newline

			elseif character == "\""
				or character == "'"
				or character == "`"
			then
				local quote = character
				local start = i
				i += 1

				while i <= length do
					local current =
						source:sub(i, i)

					if current == "\\" then
						i += 2
					elseif current == quote then
						i += 1
						break
					else
						i += 1
					end
				end

				table.insert(
					output,
					source:sub(
						start,
						i - 1
					)
				)

			elseif character:match("[%a_]") then
				local start = i
				i += 1

				while i <= length
					and source:sub(
						i,
						i
					):match("[%w_]")
				do
					i += 1
				end

				local identifier =
					source:sub(
						start,
						i - 1
					)

				local previousNonSpace = start - 1

				while previousNonSpace >= 1
					and source:sub(
						previousNonSpace,
						previousNonSpace
					):match("%s")
				do
					previousNonSpace -= 1
				end

				local previousCharacter =
					previousNonSpace >= 1
					and source:sub(
						previousNonSpace,
						previousNonSpace
					)
					or ""

				-- Do not rename property/member names:
				-- object.v4 / object:v4()
				if previousCharacter == "."
					or previousCharacter == ":"
				then
					table.insert(
						output,
						identifier
					)
				else
					table.insert(
						output,
						mapping[identifier]
							or identifier
					)
				end
			else
				table.insert(
					output,
					character
				)
				i += 1
			end
		end

		return table.concat(output)
	end

	local function makeSourceReadable(source)
		if not readableNamesEnabled
			or type(source) ~= "string"
			or source == ""
		then
			return source
		end

		local mapping =
			buildReadableNameMap(
				source
			)

		return replaceIdentifiersSafely(
			source,
			mapping
		)
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

		selectionBox.Position =
			codeLabel.Position

		selectionBox.Size =
			codeLabel.Size

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

		local plainChunk =
			table.concat(
				codeChunk,
				"\n"
			)

		codeLabel.Text =
			highlight(
				plainChunk
			)

		-- This hidden plain-text TextBox sits above the RichText label.
		-- Dragging with the mouse creates a native TextBox selection, and
		-- Ctrl+C copies the selected source without RichText tags.
		if not selectionBox:IsFocused() then
			selectionBox.Text =
				plainChunk
		end

		gutterText.Text =
			table.concat(
				numbers,
				"\n"
			)
	end

	local function setDisplayedSource(
		instance,
		source,
		errorMessage,
		sourceMode
	)
		selectedScript = instance
		currentSourceMode =
			sourceMode
			or (
				source
				and "Source"
				or "Unavailable"
			)

		if instance then
			scriptName.Text =
				instance.Name
				.. "  <"
				.. instance.ClassName
				.. ">"

			scriptPath.Text =
				getInstancePath(instance)
				.. "  •  "
				.. currentSourceMode

			title.Text =
				"Script Viewer  •  "
				.. instance.Name
				.. "  ["
				.. currentSourceMode
				.. "]"
		else
			scriptName.Text =
				"No script selected"

			scriptPath.Text =
				"Select a Script, LocalScript, or ModuleScript in Explorer."

			title.Text = "Script Viewer"
		end

		if source then
			rawCurrentSource = source

			if sourceMode ~= "Bytecode" then
				currentSource =
					makeSourceReadable(
						rawCurrentSource
					)

				if readableNamesEnabled
					and currentSource
					~= rawCurrentSource
				then
					currentSourceMode =
						currentSourceMode
						.. " + Readable Names"
				end
			else
				currentSource =
					rawCurrentSource
			end
		else
			rawCurrentSource = ""

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

		if instance then
			scriptPath.Text =
				getInstancePath(instance)
				.. "  •  "
				.. currentSourceMode

			title.Text =
				"Script Viewer  •  "
				.. instance.Name
				.. "  ["
				.. currentSourceMode
				.. "]"
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

		local source,
			sourceMode,
			sourceError =
			tryReadSource(instance)

		setDisplayedSource(
			instance,
			source,
			sourceError,
			sourceMode
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
					source,
					nil,
					"Registered Source"
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
					source,
					nil,
					"Registered Source"
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

	readableNamesButton.MouseButton1Click:Connect(function()
		readableNamesEnabled =
			not readableNamesEnabled

		readableNamesButton.Text =
			readableNamesEnabled
			and "Names: ON"
			or "Names: OFF"

		if selectedScript
			and rawCurrentSource ~= ""
		then
			-- Re-render the already-read source. This avoids calling the
			-- decompiler/bytecode API again just to toggle display names.
			local baseMode =
				currentSourceMode:gsub(
					"%s*%+%s*Readable Names$",
					""
				)

			setDisplayedSource(
				selectedScript,
				rawCurrentSource,
				nil,
				baseMode
			)
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
		if selectionBox:IsFocused() then
			selectionBox:ReleaseFocus()
		end

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
	setDisplayedSource(
		nil,
		"",
		nil,
		"None"
	)

	return controller
end
