return function(MainFrame, Console_2)
	--[[
    POTASSIUM IDE
    ============================================================

    Corrected / reorganized version.

    Fixes:
        ✓ editorWidth nil error
        ✓ editorHeight nil error
        ✓ recursive AbsoluteSize connections
        ✓ getLines handling
        ✓ getLineHeight handling
        ✓ initialization order
        ✓ EditorScroll creation order
        ✓ EditorContent creation order
        ✓ autocomplete navigation
        ✓ syntax highlighting
        ✓ bracket matching
        ✓ error detection
        ✓ error underlines
        ✓ code folding
        ✓ line numbers
        ✓ smart enter
        ✓ bracket auto-close
        ✓ resize handling
        ✓ settings handling
]]

	--[[
		POTASSIUM IDE - FILE MAP
		============================================================

		Use Ctrl+F with the numbered section names below when debugging.

		01  Services / root / configuration
		02  Window focus / editor hierarchy
		03  Editor UI / input / display / gutter
		04  Theme, keywords and completion catalog
		05  Runtime state and shared utilities
		06  Folding and viewport mapping
		07  Cursor, scrolling and input/display alignment
		08  Dynamic symbol discovery and scope tracking
		09  Syntax highlighting
		10  Editor layout and chunked rendering
		11  Error detection and error underlines
		12  Bracket matching and gutter rendering
		13  Smart Enter and autocomplete engine
		14  Cursor navigation and bracket auto-close
		15  Window dragging / resizing
		16  Settings, execute, clear and console controls
		17  Text-change pipeline and keyboard handling
		18  Focus / font / optimized viewport refresh
		19  Initialization

		Debugging rule:
		- UI creation lives near the top.
		- Parsing / analysis systems live in the middle.
		- Input event wiring lives near the bottom.
		- Initialization is always the final section.

		Execution order has intentionally NOT been rearranged because many
		editor systems depend on forward declarations and state created above
		them. The organization pass labels and groups the existing flow instead
		of introducing risky dependency changes.
	]]

	-- ============================================================
	-- [01] SERVICES
	-- ============================================================

	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TextService = game:GetService("TextService")
	local ContextActionService = game:GetService("ContextActionService")

	-- ============================================================
	-- [02] ROOT / MAIN FRAME
	-- ============================================================

	local frame = MainFrame

	if not frame then
		error("[Potassium IDE] script.Parent is missing.")
	end

	local CodingHolder = frame:WaitForChild("CodingHolder")

	-- Kept in a separate ModuleScript to avoid Luau's 200-local-register
	-- limit in this already-large IDE initializer.
	local IDEWorkspace = 
		RunService:IsStudio()
		and
		require(
			script.Parent:WaitForChild(
				"IDEWorkspace"
			)
		)
		or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/Modules/IDEWorkspace.lua"))()

	-- Minor/support systems live in their own ModuleScript so the main
	-- editor function keeps register headroom for the actual code editor,
	-- parser, autocomplete, folding, highlighting and input logic.
	local IDEMinor =
		RunService:IsStudio()
		and require(
			script.Parent:WaitForChild(
				"IDEMinor"
			)
		)
		or loadstring(
			game:HttpGetAsync(
				"https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/Modules/IDEMinor.lua"
			)
		)()

	-- ============================================================
	-- [03] CONFIGURATION / FEATURE FLAGS
	-- ============================================================

	local EDITOR_BG = Color3.fromRGB(30, 30, 30)

	local Features = {
		SmartEnter = false,
		BracketMatching = true,
		ErrorUnderline = true,
		CodeFolding = true,
		Autocomplete = true,
		BracketAutoClose = true,
	}

	-- ============================================================
	-- [04] WINDOW FOCUS / Z-ORDER
	-- ============================================================

	local function IDEINFOCUS()
		if Console_2.ZIndex == 5 then
			Console_2.ZIndex = 4
		end
		MainFrame.ZIndex = 5
	end


	for i,v in pairs(MainFrame.Parent:GetChildren()) do
		if v:IsA("ImageButton") then
			v.MouseButton1Down:Connect(function()
				for i,v in pairs(MainFrame.Parent:GetChildren()) do
					if v:IsA("ImageButton") then
						v.ZIndex = 10
					end
				end
				v.ZIndex = 30
			end)
		end
	end

	-- ============================================================
	-- [05] EDITOR HIERARCHY
	-- ============================================================

	local EditorScroll = CodingHolder:FindFirstChild("EditorScroll")

	if not EditorScroll then
		EditorScroll = Instance.new("ScrollingFrame")

		EditorScroll.Name = "EditorScroll"
		--EditorScroll.Position = UDim2.fromOffset(0, 0)
		EditorScroll.Size = UDim2.new(0.792, 0, 0.798, 0)

		EditorScroll.BackgroundTransparency = 1
		EditorScroll.BorderSizePixel = 0

		--EditorScroll.CanvasSize = UDim2.fromOffset(0, 0)

		EditorScroll.ScrollBarThickness = 8
		EditorScroll.ScrollBarImageTransparency = 0.15

		-- Allow both vertical and horizontal scrolling.
		-- Roblox automatically shows the needed scrollbar when CanvasSize
		-- exceeds the visible editor area.
		EditorScroll.ScrollingDirection = Enum.ScrollingDirection.XY
		EditorScroll.AutomaticCanvasSize = Enum.AutomaticSize.None

		EditorScroll.ClipsDescendants = true
		EditorScroll.ZIndex = 1

		EditorScroll.Parent = CodingHolder
	end

	-- Enforce scrolling settings even when EditorScroll already existed.
	EditorScroll.ScrollBarThickness = 8
	EditorScroll.ScrollBarImageTransparency = 0.15
	EditorScroll.ScrollingDirection = Enum.ScrollingDirection.XY
	EditorScroll.AutomaticCanvasSize = Enum.AutomaticSize.None

	local EditorContent = EditorScroll:FindFirstChild("EditorContent")

	if not EditorContent then
		EditorContent = Instance.new("Frame")

		EditorContent.Name = "EditorContent"
		EditorContent.Position = UDim2.fromOffset(0, 0)
		EditorContent.Size = UDim2.fromOffset(1, 100)

		EditorContent.BackgroundTransparency = 1
		EditorContent.BorderSizePixel = 0

		EditorContent.Parent = EditorScroll
	end

	-- ============================================================
	-- [06] EDITOR ELEMENT REFERENCES
	-- ============================================================

	local gutter = EditorContent:FindFirstChild("Gutter")

	if not gutter then
		gutter = Instance.new("Frame")

		gutter.Name = "Gutter"
		gutter.Position = UDim2.fromOffset(0, 0)
		gutter.Size = UDim2.fromOffset(55, 100)

		gutter.BackgroundTransparency = 1
		gutter.BorderSizePixel = 0

		gutter.Parent = EditorContent
	end

	local display = EditorContent:FindFirstChild("Display")

	if not display then
		display = Instance.new("TextLabel")

		display.Name = "Display"

		display.BackgroundTransparency = 1
		display.BorderSizePixel = 0

		display.Text = ""

		display.Parent = EditorContent
	end

	local input = EditorContent:FindFirstChild("Input")

	if not input then
		input = Instance.new("TextBox")

		input.Name = "Input"

		input.BackgroundTransparency = 1
		input.BorderSizePixel = 0

		input.Text = ""

		input.Parent = EditorContent
	end

	local hlBar = EditorContent:FindFirstChild("HighlightBar")

	if not hlBar then
		hlBar = Instance.new("Frame")

		hlBar.Name = "HighlightBar"

		hlBar.Position = UDim2.fromOffset(55, 0)
		hlBar.Size = UDim2.fromOffset(1, 20)

		hlBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		hlBar.BackgroundTransparency = 0.35

		hlBar.BorderSizePixel = 0

		hlBar.Parent = EditorContent
	end

	-- ============================================================
	-- [07] EDITOR Z-INDEX
	-- ============================================================

	EditorScroll.ZIndex = 1
	EditorContent.ZIndex = 1

	gutter.ZIndex = 2
	hlBar.ZIndex = 3
	display.ZIndex = 4
	input.ZIndex = 5

	-- ============================================================
	-- [08] TEXT INPUT / DISPLAY SETUP
	-- ============================================================

	input.MultiLine = true
	input.ClearTextOnFocus = false
	input.TextWrapped = false

	input.TextXAlignment = Enum.TextXAlignment.Left
	input.TextYAlignment = Enum.TextYAlignment.Top

	input.BackgroundTransparency = 1
	input.TextTransparency = 1

	input.Font = Enum.Font.Code

	display.RichText = true
	display.BackgroundTransparency = 1

	display.TextXAlignment = Enum.TextXAlignment.Left
	display.TextYAlignment = Enum.TextYAlignment.Top

	display.TextWrapped = false
	display.Font = Enum.Font.Code

	-- Display itself is now just the container/reference.
	display.Text = ""
	display.ClipsDescendants = false

	hlBar.Visible = false

	-- ============================================================
	-- MOUSE TEXT SELECTION OVERLAY
	-- ============================================================

	local selectionOverlay =
		EditorContent:FindFirstChild(
			"SelectionOverlay"
		)

	if not selectionOverlay then
		selectionOverlay =
			Instance.new("Frame")

		selectionOverlay.Name =
			"SelectionOverlay"

		selectionOverlay.BackgroundTransparency = 1
		selectionOverlay.BorderSizePixel = 0
		selectionOverlay.Position = UDim2.fromOffset(0, 0)
		selectionOverlay.Size = UDim2.fromScale(1, 1)
		selectionOverlay.ZIndex = 3
		selectionOverlay.Parent = EditorContent
	end

	local selectionFrames = {}

	local function clearSelectionVisuals()
		for _, selectionFrame in ipairs(
			selectionFrames
			) do
			selectionFrame:Destroy()
		end

		table.clear(selectionFrames)
	end

	-- ============================================================
	-- [09] MOUSE CAPTURE / CARET HIT TEST
	-- ============================================================
	--
	-- The real TextBox must NOT receive mouse clicks directly.
	-- Roblox's native hit-testing becomes unreliable on very large
	-- multiline TextBoxes and can leave behind a bad internal vertical
	-- navigation position. We capture clicks here and place the caret
	-- ourselves.
	-- ============================================================

	local mouseCapture =
		EditorContent:FindFirstChild("MouseCapture")

	if not mouseCapture then
		mouseCapture = Instance.new("TextButton")
		mouseCapture.Name = "MouseCapture"
		mouseCapture.Text = ""
		mouseCapture.AutoButtonColor = false
		mouseCapture.BackgroundTransparency = 1
		mouseCapture.BorderSizePixel = 0
		mouseCapture.Active = true
		mouseCapture.Selectable = false
		mouseCapture.ZIndex = 7
		mouseCapture.Parent = EditorContent
	end

	mouseCapture.Text = ""
	mouseCapture.AutoButtonColor = false
	mouseCapture.BackgroundTransparency = 1
	mouseCapture.BorderSizePixel = 0
	mouseCapture.Active = true
	mouseCapture.Selectable = false
	mouseCapture.ZIndex = 7

	-- ============================================================
	-- [09.5] WORKSPACE / TABS CONTROLLER
	-- ============================================================

	local WorkspaceController =
		IDEWorkspace.new({
			MainFrame = frame,
			CodingHolder = CodingHolder,
			Input = input,
			EditorScroll = EditorScroll,
			ButtonsFrame =
			CodingHolder:FindFirstChild(
				"Settings"
			),
			SaveButton =
			CodingHolder:FindFirstChild(
				"Settings"
			)
			and CodingHolder.Settings:
			FindFirstChild(
				"SaveFile"
			),
			FilesButton =
			CodingHolder:FindFirstChild(
				"Settings"
			)
			and CodingHolder.Settings:
			FindFirstChild(
				"OpenFile"
			),
		})

	-- ============================================================
	-- [10] GUTTER BASE SETUP
	-- ============================================================

	-- Gutter is manually positioned/virtualized. A UIListLayout would
	-- collapse virtualized line buttons toward the top of the gutter.
	local gutterLayout = gutter:FindFirstChildOfClass("UIListLayout")
	if gutterLayout then
		gutterLayout:Destroy()
	end

	-- ============================================================
	-- [11] THEME / SYNTAX COLORS
	-- ============================================================

	local COLORS = {
		keyword = "#569CD6",
		string = "#CE9178",
		comment = "#6A9955",
		number = "#B5CEA8",
		functionName = "#DCDCAA",
		normal = "#D4D4D4",
		func = "rgb(110, 173, 255)",
		rblx = "rgb(198, 174, 57)",

		-- User-declared locals, parameters, loop variables and function
		-- references. Kept separate from Roblox/global keywords.
		symbol = "#4EC9B0",
	}

	--Color3.fromRGB(198, 174, 57)
	-- ============================================================
	-- [12] SYNTAX KEYWORD CATALOGS
	-- ============================================================

	local KEYWORDS = {
		"if",
		"then",
		"else",
		"elseif",
		"end",
		"function",
		"local",
		"return",
		"for",
		"while",
		"do",
		"repeat",
		"until",
		"break",
		"and",
		"or",
		"not",
		"true",
		"false",
		"nil",
		"in",
	}

	local FUNCTIONS = {
		"print",
		"warn",
		"error",
		"require",
		"wait",
		"task",
		"pairs",
		"ipairs",
		"next",
		"pcall",
		"xpcall",
		"tostring",
		"tonumber",
		"type",
		"typeof",
		"select",
	}

	local ROBLOXKEYWORDS = {
		"game",
		"GetService",
		"workspace",
		"script",
		"Instance",
		"Vector2",
		"Vector3",
		"CFrame",
		"Color3",
		"UDim2",
		"Enum",
	}

	local keywordSet = {}

	for _, keyword in ipairs(KEYWORDS) do
		keywordSet[keyword] = true
	end

	local keywordfunctionsSet = {}

	for _, keyword in ipairs(FUNCTIONS) do
		keywordfunctionsSet[keyword] = true
	end

	local ROBLOXKEYWORDSSet = {}

	for _, keyword in ipairs(ROBLOXKEYWORDS) do
		ROBLOXKEYWORDSSet[keyword] = true
	end

	-- ============================================================
	-- [13] AUTOCOMPLETE CATALOG
	-- ============================================================

	local COMPLETIONS = {
		-- Lua
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"end",
		"false",
		"for",
		"function",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while",

		-- Roblox
		"game",
		"workspace",
		"script",
		"Instance",
		"Vector2",
		"Vector3",
		"CFrame",
		"Color3",
		"UDim2",
		"Enum",
		"GetService",

		-- Services
		"Players",
		"RunService",
		"TweenService",
		"UserInputService",
		"ReplicatedStorage",
		"ServerStorage",
		"ServerScriptService",
		"StarterGui",
		"StarterPlayer",

		-- Functions
		"print",
		"warn",
		"error",
		"require",
		"wait",
		"task",
		"pairs",
		"ipairs",
		"next",
		"pcall",
		"xpcall",
		"tostring",
		"tonumber",
		"type",
		"typeof",
		"select",

		-- Libraries
		"table",
		"string",
		"math",
		"coroutine",
	}

	-- ============================================================
	-- [14] EDITOR STATE
	-- ============================================================

	local currentErrors = {}

	local gutterButtons = {}
	local errorBars = {}

	local bracketOverlay = nil

	local foldedBlocks = {}

	local updatingText = false
	local lastText = input.Text

	local completionButtons = {}
	local completionWords = {}

	-- Symbols discovered from the user's source.
	local dynamicSymbolSet = {}
	local dynamicSymbolList = {}
	local dynamicFunctionSet = {}

	local selectedCompletion = 1

	local highlightedLine = 1
	local cursorNeedsUpdate = false

	local MAX_COMPLETIONS = 8
	local COMPLETION_HEIGHT = 22
	local COMPLETION_WIDTH = 220

	-- ============================================================
	-- [15] SHARED TEXT UTILITIES
	-- ============================================================

	local function escapeRichText(text)
		text = text:gsub("&", "&amp;")
		text = text:gsub("<", "&lt;")
		text = text:gsub(">", "&gt;")
		text = text:gsub("\"", "&quot;")

		return text
	end

	local cachedMeasuredLineHeight = nil

	local function getLineHeight()
		if cachedMeasuredLineHeight then
			return cachedMeasuredLineHeight
		end

		local bounds =
			TextService:GetTextSize(
				"Ay",
				input.TextSize,
				input.Font,
				Vector2.new(
					10000,
					10000
				)
			)

		local lineHeightMultiplier =
			input.LineHeight

		if typeof(lineHeightMultiplier) ~= "number" then
			lineHeightMultiplier = 1
		end

		cachedMeasuredLineHeight =
			math.max(
				1,
				bounds.Y
				* lineHeightMultiplier
			)

		return cachedMeasuredLineHeight
	end

	local function getLines(text)
		local lines = {}

		if text == "" then
			return {""}
		end

		for line in (text .. "\n"):gmatch("(.-)\n") do
			table.insert(lines, line)
		end

		return lines
	end

	local function getLineStart(text, lineNumber)
		if lineNumber <= 1 then
			return 1
		end

		local currentLine = 1

		for position = 1, #text do
			if text:sub(position, position) == "\n" then
				currentLine += 1

				if currentLine == lineNumber then
					return position + 1
				end
			end
		end

		return #text + 1
	end

	local function getLineEnd(text, lineNumber)
		local startPosition = getLineStart(text, lineNumber)

		if startPosition > #text then
			return #text
		end

		local newline = text:find("\n", startPosition, true)

		if newline then
			return newline - 1
		end

		return #text
	end

	local function getLineText(text, lineNumber)
		local startPosition = getLineStart(text, lineNumber)
		local endPosition = getLineEnd(text, lineNumber)

		if startPosition > #text then
			return ""
		end

		return text:sub(startPosition, endPosition)
	end

	local function getIndent(line)
		return line:match("^(%s*)") or ""
	end

	local function trim(line)
		return line:match("^%s*(.-)%s*$") or ""
	end

	local function stripComment(line)
		return line:gsub("%-%-.*", "")
	end

	local function getLineAtCursor()
		local cursor = input.CursorPosition

		if cursor < 1 then
			return ""
		end

		local before = input.Text:sub(1, cursor - 1)

		return before:match("([^\n]*)$") or ""
	end



	-- ============================================================
	-- [16] FOLDING RULES
	-- ============================================================

	local function isBlockStart(line)
		line = trim(stripComment(line))

		if line == "" then
			return false
		end

		return line:match("^if%s+.+%s+then%s*$") ~= nil
			or line:match("^for%s+.+%s+do%s*$") ~= nil
			or line:match("^while%s+.+%s+do%s*$") ~= nil
			or line:match("^function%s+") ~= nil
			or line:match("^local%s+function%s+") ~= nil
			or line == "do"
			or line == "repeat"
	end

	local function isBlockEnd(line)
		line = trim(stripComment(line))

		if line == "end" then
			return "end"
		end

		if line:match("^until%s+") then
			return "until"
		end

		return nil
	end

	-- ============================================================
	-- [17] FOLDING CACHE / LINE MAPPING
	-- ============================================================

	local foldEndByStart = {}
	local hiddenLines = {}
	local visibleLineIndex = {}
	local visibleToSourceLine = {}
	local lineStartPositions = {}
	local cachedLines = {""}

	local foldingCacheText = nil

	local function getBlockType(line)
		line = trim(stripComment(line))

		if line == "" then
			return nil
		end

		if line == "repeat" then
			return "repeat"
		end

		if line:match("^if%s+.+%s+then%s*$")
			or line:match("^for%s+.+%s+do%s*$")
			or line:match("^while%s+.+%s+do%s*$")
			or line:match("^function%s+")
			or line:match("^local%s+function%s+")
			or line == "do"
		then
			return "normal"
		end

		return nil
	end

	local function getFoldKey(startLine, endLine, lines)
		return tostring(startLine)
			.. ":"
			.. tostring(endLine)
			.. ":"
			.. tostring(lines[startLine] or "")
	end

	local function rebuildFoldingCache()
		local text = input.Text

		if foldingCacheText == text then
			return
		end

		foldingCacheText = text

		table.clear(foldEndByStart)
		table.clear(hiddenLines)
		table.clear(visibleLineIndex)
		table.clear(visibleToSourceLine)
		table.clear(lineStartPositions)

		cachedLines = getLines(text)

		local stack = {}
		local characterPosition = 1

		for lineNumber, line in ipairs(cachedLines) do
			lineStartPositions[lineNumber] = characterPosition
			characterPosition += #line + 1
		end

		-- Find every fold pair in one pass.
		for lineNumber, rawLine in ipairs(cachedLines) do
			local line = trim(stripComment(rawLine))
			local blockType = getBlockType(line)

			if blockType then
				table.insert(stack, {
					line = lineNumber,
					type = blockType,
				})
			end

			if line == "end" then
				for i = #stack, 1, -1 do
					if stack[i].type ~= "repeat" then
						local block = table.remove(stack, i)
						foldEndByStart[block.line] = lineNumber
						break
					end
				end
			elseif line:match("^until%s+") then
				for i = #stack, 1, -1 do
					if stack[i].type == "repeat" then
						local block = table.remove(stack, i)
						foldEndByStart[block.line] = lineNumber
						break
					end
				end
			end
		end

		-- Build the hidden-line table once.
		if Features.CodeFolding then
			for startLine, endLine in pairs(foldEndByStart) do
				local key = getFoldKey(startLine, endLine, cachedLines)

				if foldedBlocks[key] then
					for lineNumber = startLine + 1, endLine do
						hiddenLines[lineNumber] = true
					end
				end
			end
		end

		-- Source <-> rendered visible-line lookup.
		local visible = 0
		for lineNumber = 1, #cachedLines do
			if not hiddenLines[lineNumber] then
				visible += 1
				visibleToSourceLine[visible] = lineNumber
			end

			visibleLineIndex[lineNumber] = visible
		end
	end

	local function invalidateFoldingCache()
		foldingCacheText = nil
	end

	local function getBlockEnd(_lines, startLine)
		rebuildFoldingCache()
		return foldEndByStart[startLine]
	end

	local function getFoldedRanges()
		rebuildFoldingCache()

		local ranges = {}

		for startLine, endLine in pairs(foldEndByStart) do
			local key = getFoldKey(startLine, endLine, cachedLines)

			if foldedBlocks[key] then
				table.insert(ranges, {
					startLine = startLine,
					endLine = endLine,
					key = key,
				})
			end
		end

		return ranges
	end

	local function isLineHidden(lineNumber)
		if not Features.CodeFolding then
			return false
		end

		rebuildFoldingCache()
		return hiddenLines[lineNumber] == true
	end

	local function isLineFolded(lineNumber)
		rebuildFoldingCache()

		local endLine = foldEndByStart[lineNumber]
		if not endLine then
			return false
		end

		local key = getFoldKey(lineNumber, endLine, cachedLines)
		return foldedBlocks[key] == true
	end

	local function getCursorSourceLine(cursorPosition)
		rebuildFoldingCache()

		local low = 1
		local high = #lineStartPositions
		local lineNumber = 1

		while low <= high do
			local mid = math.floor((low + high) / 2)

			if lineStartPositions[mid] <= cursorPosition then
				lineNumber = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end

		return lineNumber
	end

	local function getViewportVisibleRange(bufferLines)
		rebuildFoldingCache()

		bufferLines = bufferLines or 12

		local lineHeight = getLineHeight()
		local canvasY = EditorScroll.CanvasPosition.Y
		local viewportHeight = EditorScroll.AbsoluteSize.Y

		local firstVisible = math.max(
			1,
			math.floor(canvasY / lineHeight) + 1 - bufferLines
		)

		local lastVisible = math.min(
			#visibleToSourceLine,
			math.ceil((canvasY + viewportHeight) / lineHeight)
				+ bufferLines
		)

		return firstVisible, math.max(firstVisible, lastVisible)
	end

	-- ============================================================
	-- [18] INPUT / DISPLAY ALIGNMENT
	-- ============================================================

	local function syncInputAndDisplay()
		display.Position = input.Position
		display.Size = input.Size

		display.Font = input.Font
		display.TextSize = input.TextSize
		display.LineHeight = input.LineHeight

		display.TextXAlignment =
			input.TextXAlignment

		display.TextYAlignment =
			input.TextYAlignment

		display.TextWrapped =
			input.TextWrapped

		input.TextTransparency = 1
		input.BackgroundTransparency = 1
	end

	syncInputAndDisplay()

	-- ============================================================
	-- [19] CUSTOM EDITOR CURSOR
	-- ============================================================

	local CURSOR_OFFSET_X = 4
	local CURSOR_OFFSET_Y = 0

	local editorCursor = EditorContent:FindFirstChild("EditorCursor")

	if not editorCursor then
		editorCursor = Instance.new("Frame")
		editorCursor.Name = "EditorCursor"
		editorCursor.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
		editorCursor.BorderSizePixel = 0
		editorCursor.Visible = false
		editorCursor.ZIndex = 6
		editorCursor.Parent = EditorContent
	end

	local cursorBlinkTimer = 0
	local cursorBlinkVisible = true
	local CURSOR_BLINK_TIME = 0.55

	local function getCursorDisplayPosition()
		if not input:IsFocused() then
			return nil
		end

		local cursorPosition = input.CursorPosition
		if cursorPosition < 1 then
			return nil
		end

		rebuildFoldingCache()

		local lineNumber = getCursorSourceLine(cursorPosition)
		local lineStart = lineStartPositions[lineNumber] or 1
		local textBeforeCursor = ""

		if cursorPosition > lineStart then
			textBeforeCursor = input.Text:sub(
				lineStart,
				cursorPosition - 1
			)
		end

		local textWidth = TextService:GetTextSize(
			textBeforeCursor,
			input.TextSize,
			input.Font,
			Vector2.new(100000, getLineHeight())
		).X

		local visibleLine = visibleLineIndex[lineNumber] or lineNumber
		local lineHeight = getLineHeight()

		local x =
			(display.AbsolutePosition.X - EditorContent.AbsolutePosition.X)
			+ textWidth

		local y =
			(display.AbsolutePosition.Y - EditorContent.AbsolutePosition.Y)
			+ ((visibleLine - 1) * lineHeight)

		return x, y, lineHeight
	end

	local function updateEditorCursor()
		if not input:IsFocused() then
			editorCursor.Visible = false
			return
		end

		if cursorNeedsUpdate then
			return
		end

		local x, y, lineHeight = getCursorDisplayPosition()
		if not x then
			editorCursor.Visible = false
			return
		end

		editorCursor.Visible = true
		editorCursor.Size = UDim2.fromOffset(2, lineHeight)
		editorCursor.Position = UDim2.fromOffset(
			math.round(x + CURSOR_OFFSET_X),
			math.round(y + CURSOR_OFFSET_Y)
		)
	end

	-- ============================================================
	-- [20] CARET AUTO-SCROLL
	-- ============================================================

	local AUTO_SCROLL_PADDING_X = 36
	local AUTO_SCROLL_PADDING_Y = 4

	local function ensureCursorVisible()
		if not input:IsFocused() then
			return
		end

		local cursorX, cursorY, lineHeight =
			getCursorDisplayPosition()

		if not cursorX then
			return
		end

		local canvas = EditorScroll.CanvasPosition
		local viewportSize = EditorScroll.AbsoluteSize
		local canvasSize = EditorScroll.CanvasSize

		-- Reserve room for a scrollbar on the opposite axis when needed.
		local verticalOverflow =
			canvasSize.Y.Offset > viewportSize.Y

		local horizontalOverflow =
			canvasSize.X.Offset > viewportSize.X

		local viewportWidth =
			math.max(
				1,
				viewportSize.X
				- (verticalOverflow
					and EditorScroll.ScrollBarThickness
					or 0)
			)

		local viewportHeight =
			math.max(
				1,
				viewportSize.Y
				- (horizontalOverflow
					and EditorScroll.ScrollBarThickness
					or 0)
			)

		local targetX = canvas.X
		local targetY = canvas.Y

		-- Horizontal caret visibility.
		if cursorX < canvas.X + AUTO_SCROLL_PADDING_X then
			targetX =
				cursorX - AUTO_SCROLL_PADDING_X
		elseif cursorX + 2
			> canvas.X
			+ viewportWidth
			- AUTO_SCROLL_PADDING_X
		then
			targetX =
				cursorX
				+ 2
			- viewportWidth
				+ AUTO_SCROLL_PADDING_X
		end

		-- Vertical caret visibility.
		if cursorY < canvas.Y + AUTO_SCROLL_PADDING_Y then
			targetY =
				cursorY - AUTO_SCROLL_PADDING_Y
		elseif cursorY + lineHeight
			> canvas.Y
			+ viewportHeight
			- AUTO_SCROLL_PADDING_Y
		then
			targetY =
				cursorY
				+ lineHeight
			- viewportHeight
				+ AUTO_SCROLL_PADDING_Y
		end

		local maxX =
			math.max(
				0,
				canvasSize.X.Offset - viewportWidth
			)

		local maxY =
			math.max(
				0,
				canvasSize.Y.Offset - viewportHeight
			)

		targetX = math.clamp(targetX, 0, maxX)
		targetY = math.clamp(targetY, 0, maxY)

		if math.abs(targetX - canvas.X) > 0.5
			or math.abs(targetY - canvas.Y) > 0.5
		then
			EditorScroll.CanvasPosition =
				Vector2.new(
					math.round(targetX),
					math.round(targetY)
				)
		end
	end

	local function resetCursorBlink()
		cursorBlinkTimer = 0
		cursorBlinkVisible = true
		editorCursor.BackgroundTransparency = 0
		updateEditorCursor()
	end

	-- Only blink every frame. Do NOT recalculate the cursor position every
	-- RenderStepped; that was expensive for large scripts.
	RunService.RenderStepped:Connect(function(deltaTime)
		if not input:IsFocused() then
			editorCursor.Visible = false
			return
		end

		cursorBlinkTimer += deltaTime

		if cursorBlinkTimer >= CURSOR_BLINK_TIME then
			cursorBlinkTimer = 0
			cursorBlinkVisible = not cursorBlinkVisible
			editorCursor.BackgroundTransparency =
				cursorBlinkVisible and 0 or 1
		end
	end)

	-- ============================================================
	-- [21] DYNAMIC SYMBOL DISCOVERY / SCOPE ANALYSIS
	-- ============================================================

	-- This lexer only needs enough information to discover identifiers.
	-- It deliberately ignores comments and string contents so text such as
	-- "local fakeVariable" inside a string does not become autocomplete.
	local function tokenizeSymbols(source)
		local tokens = {}
		local i = 1
		local length = #source
		local line = 1

		local function add(value, kind)
			table.insert(tokens, {
				value = value,
				kind = kind,
				line = line,
			})
		end

		local function isIdentifierStart(character)
			return character ~= ""
				and character:match("[%a_]") ~= nil
		end

		local function isIdentifierPart(character)
			return character ~= ""
				and character:match("[%w_]") ~= nil
		end

		local function longBracketEquals(position)
			if source:sub(position, position) ~= "[" then
				return nil
			end

			local cursor = position + 1
			local equals = 0

			while source:sub(cursor, cursor) == "=" do
				equals += 1
				cursor += 1
			end

			if source:sub(cursor, cursor) == "[" then
				return equals
			end

			return nil
		end

		while i <= length do
			local character = source:sub(i, i)

			if character == "\n" then
				add("\n", "newline")
				line += 1
				i += 1

			elseif character:match("%s") then
				i += 1

			elseif source:sub(i, i + 1) == "--" then
				local longEquals =
					longBracketEquals(i + 2)

				if longEquals ~= nil then
					local closing =
						"]"
						.. string.rep("=", longEquals)
						.. "]"

					local openingLength =
						2 + longEquals + 2

					local searchFrom =
						i + openingLength

					local closeStart =
						source:find(
							closing,
							searchFrom,
							true
						)

					local finish =
						closeStart
						and (
							closeStart
							+ #closing
							- 1
						)
						or length

					local segment =
						source:sub(i, finish)

					local _, newlines =
						segment:gsub("\n", "")

					line += newlines
					i = finish + 1
				else
					local newline =
						source:find(
							"\n",
							i,
							true
						)

					if newline then
						i = newline
					else
						break
					end
				end

			elseif character == "\""
				or character == "'"
				or character == "`"
			then
				local quote = character
				i += 1

				while i <= length do
					local current =
						source:sub(i, i)

					if current == "\\" then
						i += 2

					elseif current == quote then
						i += 1
						break

					elseif current == "\n" then
						line += 1

						if quote ~= "`" then
							break
						end

						i += 1

					else
						i += 1
					end
				end

			elseif character == "[" then
				local longEquals =
					longBracketEquals(i)

				if longEquals ~= nil then
					local closing =
						"]"
						.. string.rep("=", longEquals)
						.. "]"

					local openingLength =
						longEquals + 2

					local closeStart =
						source:find(
							closing,
							i + openingLength,
							true
						)

					local finish =
						closeStart
						and (
							closeStart
							+ #closing
							- 1
						)
						or length

					local segment =
						source:sub(i, finish)

					local _, newlines =
						segment:gsub("\n", "")

					line += newlines
					i = finish + 1
				else
					add("[", "symbol")
					i += 1
				end

			elseif isIdentifierStart(character) then
				local start = i
				i += 1

				while i <= length
					and isIdentifierPart(
						source:sub(i, i)
					)
				do
					i += 1
				end

				add(
					source:sub(start, i - 1),
					"identifier"
				)

			elseif character:match("%d") then
				local start = i
				i += 1

				while i <= length
					and source:sub(i, i):match(
						"[%w_%.]"
					)
				do
					i += 1
				end

				add(
					source:sub(start, i - 1),
					"number"
				)

			else
				local two =
					source:sub(i, i + 1)

				if two == "::"
					or two == "->"
					or two == ".."
					or two == "=="
					or two == "~="
					or two == "<="
					or two == ">="
					or two == "+="
					or two == "-="
					or two == "*="
					or two == "/="
					or two == "%="
					or two == "^="
				then
					add(two, "symbol")
					i += 2
				else
					add(character, "symbol")
					i += 1
				end
			end
		end

		return tokens
	end

	local RESERVED_DECLARATION_WORDS = {
		["local"] = true,
		["function"] = true,
		["if"] = true,
		["then"] = true,
		["else"] = true,
		["elseif"] = true,
		["end"] = true,
		["for"] = true,
		["while"] = true,
		["do"] = true,
		["repeat"] = true,
		["until"] = true,
		["return"] = true,
		["break"] = true,
		["continue"] = true,
		["and"] = true,
		["or"] = true,
		["not"] = true,
		["true"] = true,
		["false"] = true,
		["nil"] = true,
		["in"] = true,
	}

	local function collectDeclaredSymbols(source)
		local tokens =
			tokenizeSymbols(source)

		local symbols = {}
		local functions = {}

		local function addSymbol(name, isFunction)
			if not name
				or name == ""
				or RESERVED_DECLARATION_WORDS[name]
			then
				return
			end

			symbols[name] = true

			if isFunction then
				functions[name] = true
			end
		end

		local function isIdentifier(token)
			return token
				and token.kind == "identifier"
		end

		local index = 1

		while index <= #tokens do
			local token = tokens[index]

			-- local variable declarations:
			-- local player = ...
			-- local a, b, c = ...
			-- local value: number = ...
			if token.value == "local" then
				local nextToken =
					tokens[index + 1]

				if nextToken
					and nextToken.value == "function"
				then
					local nameToken =
						tokens[index + 2]

					if isIdentifier(nameToken) then
						addSymbol(
							nameToken.value,
							true
						)
					end
				else
					local cursor =
						index + 1

					while cursor <= #tokens do
						local current =
							tokens[cursor]

						if current.value == "="
							or current.value == "\n"
							or current.value == ";"
						then
							break
						end

						if isIdentifier(current) then
							-- Only the first identifier in each comma
							-- separated declaration is a variable name.
							local previous =
								tokens[cursor - 1]

							if cursor == index + 1
								or (
									previous
										and previous.value == ","
								)
							then
								addSymbol(
									current.value,
									false
								)
							end
						end

						cursor += 1
					end
				end

				-- Named functions:
				-- function Test()
				-- function Module.Test()
				-- function Object:Method()
			elseif token.value == "function" then
				local cursor =
					index + 1

				local lastIdentifier = nil

				while cursor <= #tokens do
					local current =
						tokens[cursor]

					if current.value == "(" then
						break
					end

					if current.value == "\n"
						or current.value == "="
					then
						break
					end

					if isIdentifier(current) then
						lastIdentifier =
							current.value
					end

					cursor += 1
				end

				if lastIdentifier then
					addSymbol(
						lastIdentifier,
						true
					)
				end

				-- Function parameters.
				if tokens[cursor]
					and tokens[cursor].value == "("
				then
					cursor += 1
					local nesting = 1
					local expectingParameter = true

					while cursor <= #tokens
						and nesting > 0
					do
						local current =
							tokens[cursor]

						if current.value == "(" then
							nesting += 1

						elseif current.value == ")" then
							nesting -= 1

						elseif nesting == 1 then
							if current.value == "," then
								expectingParameter = true

							elseif expectingParameter
								and isIdentifier(current)
							then
								addSymbol(
									current.value,
									false
								)

								expectingParameter = false
							end
						end

						cursor += 1
					end
				end

				-- Loop variables:
				-- for i = 1, 10 do
				-- for key, value in pairs(tbl) do
			elseif token.value == "for" then
				local cursor =
					index + 1

				while cursor <= #tokens do
					local current =
						tokens[cursor]

					if current.value == "="
						or current.value == "in"
						or current.value == "do"
						or current.value == "\n"
					then
						break
					end

					if isIdentifier(current) then
						local previous =
							tokens[cursor - 1]

						if cursor == index + 1
							or (
								previous
									and previous.value == ","
							)
						then
							addSymbol(
								current.value,
								false
							)
						end
					end

					cursor += 1
				end

				-- Non-local/global assignments.
				--
				-- A lot of Roblox UI code declares state like this:
				--
				--     SomeToggle:Toggle(..., function(t)
				--         Selected_Auto_Buy_Easter = t
				--     end)
				--
				-- There is no `local`, but the identifier is still a real
				-- script-level variable and should become a dynamic suggestion.
			elseif isIdentifier(token)
				and nextToken
				and (
					nextToken.value == "="
						or nextToken.value == "+="
						or nextToken.value == "-="
						or nextToken.value == "*="
						or nextToken.value == "/="
						or nextToken.value == "%="
						or nextToken.value == "^="
				)
					and not (
						previous
						and (
							previous.value == "."
							or previous.value == ":"
							or previous.value == "::"
						)
					)
			then
				addSymbol(
					token.value,
					false
				)
			end

			index += 1
		end

		local list = {}

		for name in pairs(symbols) do
			table.insert(list, name)
		end

		table.sort(
			list,
			function(a, b)
				return a:lower()
					< b:lower()
			end
		)

		return symbols, list, functions
	end

	-- Returns only symbols that are actually in scope at the END of
	-- the supplied source. This is used by autocomplete with the source
	-- sliced at the cursor position.
	--
	-- Important difference from collectDeclaredSymbols():
	-- function parameters and locals inside a function disappear when that
	-- function's matching `end` is passed.
	local function collectAvailableSymbols(source)
		local tokens =
			tokenizeSymbols(source)

		local function isIdentifier(token)
			return token
				and token.kind == "identifier"
		end

		local scopes = {
			{
				symbols = {},
				functions = {},
			},
		}

		local blocks = {}

		local function currentScope()
			return scopes[#scopes]
		end

		local function pushScope()
			table.insert(scopes, {
				symbols = {},
				functions = {},
			})
		end

		local function popScope()
			if #scopes > 1 then
				table.remove(scopes)
			end
		end

		local function symbolExistsInOpenScopes(name)
			for scopeIndex = #scopes, 1, -1 do
				if scopes[scopeIndex].symbols[name] then
					return true
				end
			end

			return false
		end

		local function addGlobalSymbol(
			name,
			isFunction
		)
			if not name
				or name == ""
				or RESERVED_DECLARATION_WORDS[name]
			then
				return
			end

			scopes[1].symbols[name] = true

			if isFunction then
				scopes[1].functions[name] = true
			end
		end

		local function addToCurrentScope(
			name,
			isFunction
		)
			if not name
				or name == ""
				or RESERVED_DECLARATION_WORDS[name]
			then
				return
			end

			local scope =
				currentScope()

			scope.symbols[name] = true

			if isFunction then
				scope.functions[name] = true
			end
		end

		local function pushBlock(
			blockType,
			createsScope,
			expectsDo
		)
			if createsScope then
				pushScope()
			end

			table.insert(blocks, {
				type = blockType,
				createsScope =
					createsScope == true,
				expectsDo =
					expectsDo == true,
				sawDo = false,
			})
		end

		local function popBlock()
			local block =
				blocks[#blocks]

			if not block then
				return
			end

			table.remove(blocks)

			if block.createsScope then
				popScope()
			end
		end

		local function parseFunctionParameters(
			functionIndex
		)
			local cursor =
				functionIndex + 1

			-- Skip a named function path such as:
			-- function Module.Sub:Method(
			while cursor <= #tokens
				and tokens[cursor].value ~= "("
				and tokens[cursor].value ~= "\n"
			do
				cursor += 1
			end

			if not tokens[cursor]
				or tokens[cursor].value ~= "("
			then
				return
			end

			cursor += 1

			local nesting = 1
			local expectingParameter = true

			while cursor <= #tokens
				and nesting > 0
			do
				local current =
					tokens[cursor]

				if current.value == "(" then
					nesting += 1

				elseif current.value == ")" then
					nesting -= 1

				elseif nesting == 1 then
					if current.value == "," then
						expectingParameter = true

					elseif expectingParameter
						and isIdentifier(current)
					then
						addToCurrentScope(
							current.value,
							false
						)

						expectingParameter = false
					end
				end

				cursor += 1
			end
		end

		local index = 1

		while index <= #tokens do
			local token =
				tokens[index]

			local value =
				token.value

			local previous =
				tokens[index - 1]

			local nextToken =
				tokens[index + 1]

			if value == "local" then
				if nextToken
					and nextToken.value
					== "function"
				then
					local nameToken =
						tokens[index + 2]

					if isIdentifier(nameToken) then
						-- local function Foo() is declared in the OUTER
						-- scope, while its parameters belong to the new
						-- function scope.
						addToCurrentScope(
							nameToken.value,
							true
						)
					end

				else
					local cursor =
						index + 1

					local expectingName = true

					while cursor <= #tokens do
						local current =
							tokens[cursor]

						if current.value == "="
							or current.value == "\n"
							or current.value == ";"
						then
							break
						end

						if current.value == "," then
							expectingName = true

						elseif expectingName
							and isIdentifier(current)
						then
							addToCurrentScope(
								current.value,
								false
							)

							expectingName = false
						end

						cursor += 1
					end
				end

			elseif value == "function" then
				-- Non-local named functions are useful suggestions too.
				if not (
					previous
						and previous.value == "local"
					) then
					local cursor =
						index + 1

					local lastIdentifier = nil

					while cursor <= #tokens do
						local current =
							tokens[cursor]

						if current.value == "("
							or current.value == "\n"
						then
							break
						end

						if isIdentifier(current) then
							lastIdentifier =
								current.value
						end

						cursor += 1
					end

					if lastIdentifier then
						addToCurrentScope(
							lastIdentifier,
							true
						)
					end
				end

				-- Everything declared below this point belongs to the
				-- function scope until this function's matching `end`.
				pushBlock(
					"function",
					true,
					false
				)

				parseFunctionParameters(
					index
				)

			elseif value == "if" then
				pushBlock(
					"if",
					true,
					false
				)

			elseif value == "while" then
				pushBlock(
					"while",
					true,
					true
				)

			elseif value == "for" then
				pushBlock(
					"for",
					true,
					true
				)

				-- Loop variables belong only to the loop scope.
				local cursor =
					index + 1

				local expectingName = true

				while cursor <= #tokens do
					local current =
						tokens[cursor]

					if current.value == "="
						or current.value == "in"
						or current.value == "do"
						or current.value == "\n"
					then
						break
					end

					if current.value == "," then
						expectingName = true

					elseif expectingName
						and isIdentifier(current)
					then
						addToCurrentScope(
							current.value,
							false
						)

						expectingName = false
					end

					cursor += 1
				end

				-- Bare assignment without `local` creates/uses a script-global
				-- variable in normal Luau semantics.
				--
				-- If the name already belongs to an open local/parameter/loop
				-- scope, do NOT promote it to global. Otherwise remember it in
				-- the root scope so later callbacks/functions can suggest it.
			elseif isIdentifier(token)
				and nextToken
				and (
					nextToken.value == "="
						or nextToken.value == "+="
						or nextToken.value == "-="
						or nextToken.value == "*="
						or nextToken.value == "/="
						or nextToken.value == "%="
						or nextToken.value == "^="
				)
					and not (
						previous
						and (
							previous.value == "."
							or previous.value == ":"
							or previous.value == "::"
						)
					)
			then
				if not symbolExistsInOpenScopes(
					token.value
					) then
					addGlobalSymbol(
						token.value,
						false
					)
				end

			elseif value == "repeat" then
				pushBlock(
					"repeat",
					true,
					false
				)

			elseif value == "do" then
				local top =
					blocks[#blocks]

				-- while/for already opened their scope when their keyword
				-- was encountered, so their `do` must not create another
				-- block.
				if top
					and top.expectsDo
					and not top.sawDo
				then
					top.sawDo = true
				else
					pushBlock(
						"do",
						true,
						false
					)
				end

			elseif value == "until" then
				local top =
					blocks[#blocks]

				if top
					and top.type == "repeat"
				then
					popBlock()
				end

			elseif value == "end" then
				popBlock()
			end

			index += 1
		end

		-- Merge only scopes that are STILL OPEN at the cursor.
		local availableSet = {}
		local availableFunctions = {}

		for _, scope in ipairs(scopes) do
			for name in pairs(
				scope.symbols
				) do
				availableSet[name] = true
			end

			for name in pairs(
				scope.functions
				) do
				availableFunctions[name] = true
			end
		end

		local availableList = {}

		for name in pairs(
			availableSet
			) do
			table.insert(
				availableList,
				name
			)
		end

		table.sort(
			availableList,
			function(a, b)
				return a:lower()
					< b:lower()
			end
		)

		return availableSet,
			availableList,
			availableFunctions
	end

	local function rebuildDynamicSymbols(source)
		dynamicSymbolSet,
			dynamicSymbolList,
			dynamicFunctionSet =
			collectDeclaredSymbols(
				source or ""
			)
	end

	-- ============================================================
	-- [22] SYNTAX HIGHLIGHTING
	-- ============================================================

	local function highlight(code)
		local result = {}

		local i = 1
		local length = #code

		while i <= length do
			local character = code:sub(i, i)

			-- COMMENT
			if code:sub(i, i + 1) == "--" then
				local newline = code:find("\n", i, true) or length + 1

				table.insert(
					result,
					('<font color="%s">%s</font>'):format(
						COLORS.comment,
						escapeRichText(
							code:sub(i, newline - 1)
						)
					)
				)

				i = newline

				-- STRING
			elseif character == "\"" or character == "'" then
				local quote = character
				local j = i + 1

				while j <= length do
					local current = code:sub(j, j)

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
							code:sub(i, j - 1)
						)
					)
				)

				i = j

				-- IDENTIFIER
			elseif character:match("[%a_]") then
				local j = i

				while j <= length
					and code:sub(j, j):match("[%w_]")
				do
					j += 1
				end

				local word = code:sub(i, j - 1)

				if keywordSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.keyword,
							escapeRichText(word)
						)
					)

				elseif dynamicSymbolSet[word] then
					-- Any reference to a user-declared local, function,
					-- parameter or loop variable is colored green.
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.symbol,
							escapeRichText(word)
						)
					)

				elseif keywordfunctionsSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.func,
							escapeRichText(word)
						)
					)
				elseif ROBLOXKEYWORDSSet[word] then
					table.insert(
						result,
						('<font color="%s">%s</font>'):format(
							COLORS.rblx,
							escapeRichText(word)
						)
					)
				else
					table.insert(result, escapeRichText(word))
				end

				i = j

				-- NUMBER
			elseif character:match("%d") then
				local j = i

				while j <= length
					and code:sub(j, j):match("[%d%.]")
				do
					j += 1
				end

				table.insert(
					result,
					('<font color="%s">%s</font>'):format(
						COLORS.number,
						escapeRichText(
							code:sub(i, j - 1)
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

	-- ============================================================
	-- [23] FORWARD DECLARATIONS
	-- ============================================================

	local updateEditorLayout
	local updateDisplay
	local rebuildGutter
	local updateErrorUnderlines
	local updateBracketMatching
	local positionAutocomplete
	local showAutocomplete
	local clearAutocomplete

	-- ============================================================
	-- [24] HORIZONTAL CONTENT MEASUREMENT
	-- ============================================================

	local HORIZONTAL_END_PADDING = 60
	local cachedHorizontalText = nil
	local cachedHorizontalTextSize = nil
	local cachedHorizontalFont = nil
	local cachedHorizontalWidth = 0

	local function invalidateHorizontalWidthCache()
		cachedHorizontalText = nil
	end

	local function getRequiredCodeWidth()
		rebuildFoldingCache()

		if cachedHorizontalText == input.Text
			and cachedHorizontalTextSize == input.TextSize
			and cachedHorizontalFont == input.Font
		then
			return cachedHorizontalWidth
		end

		-- Font.Code is monospaced, so finding the line with the largest
		-- character count lets us perform only ONE TextService measurement.
		local longestLine = ""
		local longestVisualLength = -1

		for _, line in ipairs(cachedLines) do
			local expanded = line:gsub("\t", "    ")
			local visualLength = #expanded

			if visualLength > longestVisualLength then
				longestVisualLength = visualLength
				longestLine = expanded
			end
		end

		local measuredWidth = 0

		if longestLine ~= "" then
			measuredWidth = TextService:GetTextSize(
				longestLine,
				input.TextSize,
				input.Font,
				Vector2.new(1000000, getLineHeight())
			).X
		end

		cachedHorizontalText = input.Text
		cachedHorizontalTextSize = input.TextSize
		cachedHorizontalFont = input.Font
		cachedHorizontalWidth =
			math.ceil(measuredWidth + HORIZONTAL_END_PADDING)

		return cachedHorizontalWidth
	end

	-- ============================================================
	-- [25] EDITOR LAYOUT
	-- ============================================================

	updateEditorLayout = function()
		WorkspaceController:ApplyLayout()

		local absoluteSize = EditorScroll.AbsoluteSize
		local editorWidth = math.max(1, absoluteSize.X)
		local editorHeight = math.max(1, absoluteSize.Y)

		rebuildFoldingCache()

		local lineHeight = getLineHeight()

		local sourceHeight = math.max(
			editorHeight,
			#cachedLines * lineHeight + 10
		)

		-- Width of the visible code viewport, excluding the gutter.
		local visibleCodeWidth = math.max(editorWidth - 55, 1)

		-- Width required by the longest source line.
		local requiredCodeWidth = getRequiredCodeWidth()

		-- The code area expands only when text actually exceeds the viewport.
		local codeWidth = math.max(
			visibleCodeWidth,
			requiredCodeWidth
		)

		-- Total canvas width includes the 55px gutter.
		local contentWidth = math.max(
			editorWidth,
			55 + codeWidth
		)

		EditorContent.Position = UDim2.fromOffset(0, 0)
		EditorContent.Size = UDim2.fromOffset(
			contentWidth,
			sourceHeight
		)

		EditorScroll.CanvasSize = UDim2.fromOffset(
			contentWidth,
			sourceHeight
		)

		gutter.Position = UDim2.fromOffset(0, 0)
		gutter.Size = UDim2.fromOffset(55, sourceHeight)

		input.Position = UDim2.fromOffset(55, 0)
		input.Size = UDim2.fromOffset(codeWidth, sourceHeight)

		mouseCapture.Position = input.Position
		mouseCapture.Size = input.Size

		input.TextXAlignment = Enum.TextXAlignment.Left
		input.TextYAlignment = Enum.TextYAlignment.Top
		input.TextWrapped = false

		display.Position = input.Position
		display.Size = input.Size
		display.Font = input.Font
		display.TextSize = input.TextSize
		display.LineHeight = input.LineHeight
		display.TextXAlignment = input.TextXAlignment
		display.TextYAlignment = input.TextYAlignment
		display.TextWrapped = false

		hlBar.Size = UDim2.fromOffset(codeWidth, lineHeight)

		for _, bar in ipairs(errorBars) do
			if bar and bar.Parent then
				bar.Size = UDim2.fromOffset(codeWidth, 2)
			end
		end
	end

	-- ============================================================
	-- [26] CHUNKED / VIRTUALIZED DISPLAY
	-- ============================================================

	-- Virtualized display: only syntax-highlight the lines close to the
	-- viewport. The invisible TextBox still owns the complete source.
	local DISPLAY_BUFFER_LINES = 20

	local viewportDisplay = display:FindFirstChild("ViewportDisplay")

	if not viewportDisplay then
		viewportDisplay = Instance.new("TextLabel")
		viewportDisplay.Name = "ViewportDisplay"
		viewportDisplay.BackgroundTransparency = 1
		viewportDisplay.BorderSizePixel = 0
		viewportDisplay.RichText = true
		viewportDisplay.TextXAlignment = Enum.TextXAlignment.Left
		viewportDisplay.TextYAlignment = Enum.TextYAlignment.Top
		viewportDisplay.TextWrapped = false
		viewportDisplay.ZIndex = display.ZIndex
		viewportDisplay.Parent = display
	end

	-- Clean up old chunk objects from the previous implementation.
	for _, child in ipairs(display:GetChildren()) do
		if child.Name == "DisplayChunk" then
			child:Destroy()
		end
	end

	updateDisplay = function()
		rebuildFoldingCache()

		display.Text = ""

		viewportDisplay.Font = input.Font
		viewportDisplay.TextSize = input.TextSize
		viewportDisplay.LineHeight = input.LineHeight
		viewportDisplay.TextColor3 = display.TextColor3
		viewportDisplay.TextTransparency = display.TextTransparency

		local firstVisible, lastVisible =
			getViewportVisibleRange(DISPLAY_BUFFER_LINES)

		local sourceLines = {}
		local actualFirstVisible = nil
		local actualLastVisible = nil

		for visibleLine = firstVisible, lastVisible do
			local sourceLine = visibleToSourceLine[visibleLine]

			if sourceLine then
				actualFirstVisible = actualFirstVisible or visibleLine
				actualLastVisible = visibleLine
				table.insert(sourceLines, cachedLines[sourceLine] or "")
			end
		end

		if not actualFirstVisible then
			actualFirstVisible = 1
			actualLastVisible = 1
			sourceLines = {""}
		end

		local lineHeight = getLineHeight()

		viewportDisplay.Position = UDim2.fromOffset(
			0,
			(actualFirstVisible - 1) * lineHeight
		)

		viewportDisplay.Size = UDim2.new(
			1,
			0,
			0,
			math.max(
				(actualLastVisible - actualFirstVisible + 1) * lineHeight,
				lineHeight
			)
		)

		viewportDisplay.Text = highlight(table.concat(sourceLines, "\n"))
	end

	-- ============================================================
	-- [27] ERROR DETECTION / LIVE PARSER
	-- ============================================================

	local function findErrors(code)
		--[[
			More complete live Luau syntax checker.

			This is intentionally a lightweight parser rather than a handful
			of regex checks. It tokenizes what is currently typed, ignores
			comments/strings correctly, validates punctuation/operators, and
			tracks Luau blocks.

			It catches, among other things:
				:
				object:
				object.
				local =
				local 123
				x =
				= x
				x + *
				@
				if then
				if x
				elseif without if
				else without if
				duplicate else
				while x
				for x
				function test
				unexpected end/until
				break/continue outside loops
				unclosed strings/comments/brackets
				mismatched brackets
				missing end/until
		]]

		local errors = {}
		local errorKeys = {}

		local function addError(line, column, message)
			line = math.max(1, line or 1)
			column = math.max(1, column or 1)

			local key =
				tostring(line)
				.. ":"
				.. tostring(column)
				.. ":"
				.. message

			if errorKeys[key] then
				return
			end

			errorKeys[key] = true

			table.insert(errors, {
				line = line,
				column = column,
				message = message,
			})
		end

		-- ========================================================
		-- TOKENIZER
		-- ========================================================

		local tokens = {}

		local position = 1
		local line = 1
		local column = 1
		local length = #code

		local function peek(offset)
			offset = offset or 0

			local index =
				position + offset

			if index < 1
				or index > length
			then
				return ""
			end

			return code:sub(index, index)
		end

		local function advance()
			local character =
				peek()

			position += 1

			if character == "\n" then
				line += 1
				column = 1
			else
				column += 1
			end

			return character
		end

		local function addToken(
			kind,
			value,
			tokenLine,
			tokenColumn
		)
			table.insert(tokens, {
				kind = kind,
				value = value,
				line = tokenLine,
				column = tokenColumn,
			})
		end

		local function isIdentifierStart(character)
			return character ~= ""
				and character:match(
					"[%a_]"
				) ~= nil
		end

		local function isIdentifierPart(character)
			return character ~= ""
				and character:match(
					"[%w_]"
				) ~= nil
		end

		local function getLongBracketEquals(atPosition)
			if code:sub(
				atPosition,
				atPosition
				) ~= "["
			then
				return nil
			end

			local cursor =
				atPosition + 1

			local equalsCount = 0

			while code:sub(
				cursor,
				cursor
				) == "="
			do
				equalsCount += 1
				cursor += 1
			end

			if code:sub(
				cursor,
				cursor
				) == "["
			then
				return equalsCount
			end

			return nil
		end

		local function consumeLongBracket(
			equalsCount,
			startLine,
			startColumn,
			description
		)
			-- Consume opening [=*[.
			advance()

			for _ = 1, equalsCount do
				advance()
			end

			advance()

			local closing =
				"]"
				.. string.rep(
					"=",
					equalsCount
				)
				.. "]"

			local closed = false

			while position <= length do
				if code:sub(
					position,
					position
						+ #closing
					- 1
					) == closing
				then
					for _ = 1, #closing do
						advance()
					end

					closed = true
					break
				end

				advance()
			end

			if not closed then
				addError(
					startLine,
					startColumn,
					"Unclosed "
						.. description
				)
			end

			return closed
		end

		while position <= length do
			local character = peek()

			-- WHITESPACE
			if character == " "
				or character == "\t"
				or character == "\r"
				or character == "\n"
			then
				advance()

				-- COMMENTS
			elseif character == "-"
				and peek(1) == "-"
			then
				local commentLine = line
				local commentColumn = column

				advance()
				advance()

				local longEquals =
					getLongBracketEquals(
						position
					)

				if longEquals ~= nil then
					consumeLongBracket(
						longEquals,
						commentLine,
						commentColumn,
						"block comment"
					)
				else
					while position <= length
						and peek() ~= "\n"
					do
						advance()
					end
				end

				-- QUOTED STRINGS
			elseif character == "\""
				or character == "'"
				or character == "`"
			then
				local quote = character
				local stringLine = line
				local stringColumn = column

				advance()

				local closed = false

				while position <= length do
					local current = peek()

					if current == "\\" then
						advance()

						if position <= length then
							advance()
						end

					elseif current == quote then
						advance()
						closed = true
						break

					elseif current == "\n"
						and quote ~= "`"
					then
						break

					else
						advance()
					end
				end

				if not closed then
					addError(
						stringLine,
						stringColumn,
						"Unclosed string"
					)
				end

				addToken(
					"string",
					"<string>",
					stringLine,
					stringColumn
				)

				-- LONG STRINGS
			elseif character == "[" then
				local longEquals =
					getLongBracketEquals(
						position
					)

				if longEquals ~= nil then
					local stringLine = line
					local stringColumn = column

					consumeLongBracket(
						longEquals,
						stringLine,
						stringColumn,
						"long string"
					)

					addToken(
						"string",
						"<string>",
						stringLine,
						stringColumn
					)
				else
					addToken(
						"symbol",
						"[",
						line,
						column
					)

					advance()
				end

				-- IDENTIFIERS / KEYWORDS
			elseif isIdentifierStart(
				character
				)
			then
				local tokenLine = line
				local tokenColumn = column
				local startPosition =
					position

				advance()

				while isIdentifierPart(
					peek()
					)
				do
					advance()
				end

				local value =
					code:sub(
						startPosition,
						position - 1
					)

				addToken(
					"identifier",
					value,
					tokenLine,
					tokenColumn
				)

				-- NUMBERS
			elseif character:match("%d") then
				local tokenLine = line
				local tokenColumn = column
				local startPosition =
					position

				-- Hexadecimal.
				if character == "0"
					and (
						peek(1) == "x"
							or peek(1) == "X"
					)
				then
					advance()
					advance()

					local digits = 0

					while peek():match(
						"[%da-fA-F_]"
						)
					do
						digits += 1
						advance()
					end

					if digits == 0 then
						addError(
							tokenLine,
							tokenColumn,
							"Invalid hexadecimal number"
						)
					end

					-- Binary.
				elseif character == "0"
					and (
						peek(1) == "b"
							or peek(1) == "B"
					)
				then
					advance()
					advance()

					local digits = 0

					while peek():match(
						"[01_]"
						)
					do
						digits += 1
						advance()
					end

					if digits == 0 then
						addError(
							tokenLine,
							tokenColumn,
							"Invalid binary number"
						)
					end

				else
					while peek():match(
						"[%d_]"
						)
					do
						advance()
					end

					if peek() == "."
						and peek(1) ~= "."
					then
						advance()

						while peek():match(
							"[%d_]"
							)
						do
							advance()
						end
					end

					if peek() == "e"
						or peek() == "E"
					then
						advance()

						if peek() == "+"
							or peek() == "-"
						then
							advance()
						end

						local exponentDigits = 0

						while peek():match(
							"[%d_]"
							)
						do
							exponentDigits += 1
							advance()
						end

						if exponentDigits == 0 then
							addError(
								tokenLine,
								tokenColumn,
								"Invalid number exponent"
							)
						end
					end
				end

				addToken(
					"number",
					code:sub(
						startPosition,
						position - 1
					),
					tokenLine,
					tokenColumn
				)

			else
				local tokenLine = line
				local tokenColumn = column

				local three =
					code:sub(
						position,
						position + 2
					)

				local two =
					code:sub(
						position,
						position + 1
					)

				if three == "..." then
					addToken(
						"symbol",
						"...",
						tokenLine,
						tokenColumn
					)

					advance()
					advance()
					advance()

				elseif two == "::"
					or two == "=="
					or two == "~="
					or two == "<="
					or two == ">="
					or two == "+="
					or two == "-="
					or two == "*="
					or two == "/="
					or two == "%="
					or two == "^="
					or two == ".."
					or two == "//"
					or two == "->"
				then
					addToken(
						"symbol",
						two,
						tokenLine,
						tokenColumn
					)

					advance()
					advance()

				elseif character:match(
					"[%(%){%}%]%[%+%-%*/%%%^#=<>;,%.:%?]"
					)
				then
					addToken(
						"symbol",
						character,
						tokenLine,
						tokenColumn
					)

					advance()

				else
					addError(
						tokenLine,
						tokenColumn,
						"Unexpected character '"
							.. character
							.. "'"
					)

					advance()
				end
			end
		end

		-- ========================================================
		-- TOKEN HELPERS
		-- ========================================================

		local function tokenAt(index)
			return tokens[index]
		end

		local function previousToken(index)
			return tokenAt(index - 1)
		end

		local function nextToken(index)
			return tokenAt(index + 1)
		end

		local function isIdentifierToken(token)
			return token
				and token.kind
				== "identifier"
		end

		local function isValueEndingToken(token)
			if not token then
				return false
			end

			if token.kind == "identifier"
				or token.kind == "number"
				or token.kind == "string"
			then
				return true
			end

			return token.value == ")"
				or token.value == "]"
				or token.value == "}"
				or token.value == "..."
		end

		local function isValueStartingToken(token)
			if not token then
				return false
			end

			if token.kind == "identifier"
				or token.kind == "number"
				or token.kind == "string"
			then
				return true
			end

			return token.value == "("
				or token.value == "{"
				or token.value == "-"
				or token.value == "#"
				or token.value == "..."
				or token.value == "function"
		end

		local binaryOperators = {
			["+"] = true,
			["-"] = true,
			["*"] = true,
			["/"] = true,
			["//"] = true,
			["%"] = true,
			["^"] = true,
			[".."] = true,
			["=="] = true,
			["~="] = true,
			["<"] = true,
			["<="] = true,
			[">"] = true,
			[">="] = true,
			["and"] = true,
			["or"] = true,
		}

		local assignmentOperators = {
			["="] = true,
			["+="] = true,
			["-="] = true,
			["*="] = true,
			["/="] = true,
			["%="] = true,
			["^="] = true,
		}

		local statementBoundaryKeywords = {
			["then"] = true,
			["do"] = true,
			["else"] = true,
			["elseif"] = true,
			["end"] = true,
			["until"] = true,
		}

		local function findKeywordAhead(
			startIndex,
			keyword,
			maxLines
		)
			local startToken =
				tokenAt(startIndex)

			if not startToken then
				return nil
			end

			local startLine =
				startToken.line

			for index =
				startIndex + 1,
				#tokens
			do
				local token =
					tokenAt(index)

				if maxLines
					and token.line
					> startLine + maxLines
				then
					return nil
				end

				if token.value == keyword then
					return index
				end

				if token.value == ";"
					or (
						statementBoundaryKeywords[
						token.value
						]
							and token.value
							~= keyword
					)
				then
					-- Stop on a clearly different statement boundary.
					if token.line > startLine then
						return nil
					end
				end
			end

			return nil
		end

		-- ========================================================
		-- BRACKETS / DELIMITERS
		-- ========================================================

		local bracketStack = {}

		local openingBrackets = {
			["("] = ")",
			["["] = "]",
			["{"] = "}",
		}

		local closingBrackets = {
			[")"] = "(",
			["]"] = "[",
			["}"] = "{",
		}

		for _, token in ipairs(tokens) do
			local expected =
				openingBrackets[
			token.value
			]

			if expected then
				table.insert(
					bracketStack,
					{
						value = token.value,
						expected = expected,
						line = token.line,
						column = token.column,
					}
				)

			elseif closingBrackets[
				token.value
				]
			then
				local top =
					bracketStack[
				#bracketStack
				]

				if not top then
					addError(
						token.line,
						token.column,
						"Unexpected '"
							.. token.value
							.. "'"
					)

				elseif top.expected
					~= token.value
				then
					addError(
						token.line,
						token.column,
						"Expected '"
							.. top.expected
							.. "' before '"
							.. token.value
							.. "'"
					)

					table.remove(
						bracketStack
					)

				else
					table.remove(
						bracketStack
					)
				end
			end
		end

		for index =
			#bracketStack,
			1,
			-1
		do
			local bracket =
				bracketStack[index]

			addError(
				bracket.line,
				bracket.column,
				"Expected '"
					.. bracket.expected
					.. "'"
			)
		end

		-- ========================================================
		-- PUNCTUATION / OPERATOR CHECKS
		-- ========================================================

		for index, token in ipairs(tokens) do
			local value = token.value
			local previous =
				previousToken(index)
			local nextValue =
				nextToken(index)

			-- A colon is only useful as:
			--     object:Method()
			--     name: Type
			-- A lone ":" therefore becomes an error immediately.
			if value == ":" then
				if not previous
					or not nextValue
					or not isValueEndingToken(
						previous
					)
						or not isIdentifierToken(
							nextValue
						)
				then
					addError(
						token.line,
						token.column,
						"Unexpected ':'"
					)
				end

			elseif value == "." then
				if not previous
					or not nextValue
					or not isValueEndingToken(
						previous
					)
						or not isIdentifierToken(
							nextValue
						)
				then
					addError(
						token.line,
						token.column,
						"Unexpected '.'"
					)
				end

			elseif value == "," then
				local previousOkay =
					previous
					and previous.value ~= ","
					and previous.value ~= "("
					and previous.value ~= "["
					and previous.value ~= "{"

				local nextOkay =
					nextValue
					and nextValue.value ~= ","
					and (
						nextValue.value ~= ")"
						and nextValue.value ~= "]"
						and nextValue.value ~= "}"
						or previousOkay
					)

				if not previousOkay
					or not nextOkay
				then
					addError(
						token.line,
						token.column,
						"Unexpected ','"
					)
				end

			elseif assignmentOperators[value] then
				if not previous
					or previous.value == ","
					or previous.value == "("
					or previous.value == "{"
					or previous.value == "="
					or previous.value == "local"
				then
					addError(
						token.line,
						token.column,
						"Missing assignment target before '"
							.. value
							.. "'"
					)
				end

				if not nextValue
					or nextValue.value == ","
					or nextValue.value == ")"
					or nextValue.value == "]"
					or nextValue.value == "}"
					or nextValue.value == "end"
					or nextValue.value == "else"
					or nextValue.value == "elseif"
				then
					addError(
						token.line,
						token.column,
						"Expected value after '"
							.. value
							.. "'"
					)
				end

			elseif binaryOperators[value] then
				local unaryMinus =
					value == "-"
					and (
						not previous
						or binaryOperators[
						previous.value
						]
						or assignmentOperators[
						previous.value
						]
						or previous.value == "("
						or previous.value == "["
						or previous.value == "{"
						or previous.value == ","
						or previous.value == "return"
					)

				if not unaryMinus then
					if not previous
						or not isValueEndingToken(
							previous
						)
					then
						addError(
							token.line,
							token.column,
							"Missing value before '"
								.. value
								.. "'"
						)
					end
				end

				if not nextValue
					or (
						not isValueStartingToken(
							nextValue
						)
							and nextValue.value
							~= "not"
					)
				then
					addError(
						token.line,
						token.column,
						"Expected value after '"
							.. value
							.. "'"
					)
				end
			end
		end

		-- ========================================================
		-- STATEMENT / BLOCK CHECKS
		-- ========================================================

		local blockStack = {}

		local function pushBlock(
			blockType,
			token
		)
			table.insert(
				blockStack,
				{
					type = blockType,
					line = token.line,
					column = token.column,
					elseSeen = false,
				}
			)
		end

		local function findNearestBlock(
			blockType
		)
			for index =
				#blockStack,
				1,
				-1
			do
				if blockStack[index].type
					== blockType
				then
					return index,
						blockStack[index]
				end
			end

			return nil, nil
		end

		local function insideLoop()
			for index =
				#blockStack,
				1,
				-1
			do
				local blockType =
					blockStack[index].type

				if blockType == "for"
					or blockType == "while"
					or blockType == "repeat"
				then
					return true
				end
			end

			return false
		end

		for index, token in ipairs(tokens) do
			local value = token.value
			local previous =
				previousToken(index)
			local nextValue =
				nextToken(index)

			if value == "local" then
				if not nextValue then
					addError(
						token.line,
						token.column,
						"Expected variable or function name after 'local'"
					)

				elseif nextValue.value
					== "function"
				then
					local functionName =
						tokenAt(index + 2)

					if not isIdentifierToken(
						functionName
						)
					then
						addError(
							nextValue.line,
							nextValue.column,
							"Expected function name"
						)
					end

				elseif not isIdentifierToken(
					nextValue
					)
				then
					addError(
						nextValue.line,
						nextValue.column,
						"Expected variable name after 'local'"
					)
				end

			elseif value == "if" then
				local thenIndex =
					findKeywordAhead(
						index,
						"then",
						3
					)

				if not nextValue
					or nextValue.value == "then"
				then
					addError(
						token.line,
						token.column,
						"Expected condition after 'if'"
					)
				end

				if not thenIndex then
					addError(
						token.line,
						token.column,
						"Expected 'then'"
					)
				end

				pushBlock(
					"if",
					token
				)

			elseif value == "elseif" then
				local _, ifBlock =
					findNearestBlock("if")

				if not ifBlock then
					addError(
						token.line,
						token.column,
						"Unexpected 'elseif'"
					)
				elseif ifBlock.elseSeen then
					addError(
						token.line,
						token.column,
						"'elseif' cannot appear after 'else'"
					)
				end

				if not nextValue
					or nextValue.value == "then"
				then
					addError(
						token.line,
						token.column,
						"Expected condition after 'elseif'"
					)
				end

				if not findKeywordAhead(
					index,
					"then",
					3
					)
				then
					addError(
						token.line,
						token.column,
						"Expected 'then' after 'elseif'"
					)
				end

			elseif value == "else" then
				local _, ifBlock =
					findNearestBlock("if")

				if not ifBlock then
					addError(
						token.line,
						token.column,
						"Unexpected 'else'"
					)
				elseif ifBlock.elseSeen then
					addError(
						token.line,
						token.column,
						"Duplicate 'else'"
					)
				else
					ifBlock.elseSeen = true
				end

			elseif value == "while" then
				if not nextValue
					or nextValue.value == "do"
				then
					addError(
						token.line,
						token.column,
						"Expected condition after 'while'"
					)
				end

				if not findKeywordAhead(
					index,
					"do",
					3
					)
				then
					addError(
						token.line,
						token.column,
						"Expected 'do' after 'while'"
					)
				end

				pushBlock(
					"while",
					token
				)

			elseif value == "for" then
				if not nextValue
					or not isIdentifierToken(
						nextValue
					)
				then
					addError(
						token.line,
						token.column,
						"Expected variable after 'for'"
					)
				end

				if not findKeywordAhead(
					index,
					"do",
					4
					)
				then
					addError(
						token.line,
						token.column,
						"Expected 'do' after 'for'"
					)
				end

				pushBlock(
					"for",
					token
				)

			elseif value == "repeat" then
				pushBlock(
					"repeat",
					token
				)

			elseif value == "function" then
				-- Anonymous function() is valid. Named declarations need
				-- a name followed by a parameter list.
				if previous
					and (
						previous.value == "local"
							or (
								previous.line
								== token.line
								and previous.value
								~= "="
								and previous.value
								~= "("
								and previous.value
								~= ","
								and previous.value
								~= "return"
							)
					)
				then
					if not nextValue
						or (
							not isIdentifierToken(
								nextValue
							)
								and nextValue.value
								~= "("
						)
					then
						addError(
							token.line,
							token.column,
							"Expected function name or '('"
						)
					end
				end

				local cursor =
					index + 1

				while tokenAt(cursor)
					and tokenAt(cursor).line
					<= token.line + 2
					and tokenAt(cursor).value
					~= "("
					and tokenAt(cursor).value
					~= "end"
				do
					cursor += 1
				end

				if not tokenAt(cursor)
					or tokenAt(cursor).value
					~= "("
				then
					addError(
						token.line,
						token.column,
						"Expected '(' after function declaration"
					)
				end

				pushBlock(
					"function",
					token
				)

			elseif value == "do" then
				-- for/while already own their 'do'. A standalone do opens
				-- its own block.
				if not previous
					or (
						previous.value
							~= "while"
							and previous.value
							~= "for"
					)
				then
					local belongsToLoop =
						false

					for cursor =
						math.max(
							1,
							index - 12
						),
							index - 1
					do
						local possible =
							tokenAt(cursor)

						if possible
							and possible.line
							>= token.line - 3
							and (
								possible.value
									== "while"
									or possible.value
									== "for"
							)
						then
							belongsToLoop =
								true
						end
					end

					if not belongsToLoop then
						pushBlock(
							"do",
							token
						)
					end
				end

			elseif value == "until" then
				local top =
					blockStack[
				#blockStack
				]

				if not top
					or top.type ~= "repeat"
				then
					addError(
						token.line,
						token.column,
						"Unexpected 'until'"
					)
				else
					table.remove(
						blockStack
					)
				end

				if not nextValue
					or nextValue.value == "end"
					or nextValue.value == "else"
				then
					addError(
						token.line,
						token.column,
						"Expected condition after 'until'"
					)
				end

			elseif value == "end" then
				local top =
					blockStack[
				#blockStack
				]

				if not top then
					addError(
						token.line,
						token.column,
						"Unexpected 'end'"
					)

				elseif top.type == "repeat" then
					addError(
						token.line,
						token.column,
						"Expected 'until' for repeat block"
					)

					table.remove(
						blockStack
					)

				else
					table.remove(
						blockStack
					)
				end

			elseif value == "break"
				or value == "continue"
			then
				if not insideLoop() then
					addError(
						token.line,
						token.column,
						"'"
							.. value
							.. "' used outside of a loop"
					)
				end

			elseif value == "then" then
				if not previous then
					addError(
						token.line,
						token.column,
						"Unexpected 'then'"
					)
				end
			end
		end

		for index =
			#blockStack,
			1,
			-1
		do
			local block =
				blockStack[index]

			if block.type == "repeat" then
				addError(
					block.line,
					block.column,
					"Expected 'until'"
				)
			else
				addError(
					block.line,
					block.column,
					"Expected 'end'"
				)
			end
		end

		-- ========================================================
		-- LINE-LEVEL CHECKS
		-- ========================================================

		local lineTokens = {}

		for _, token in ipairs(tokens) do
			lineTokens[token.line] =
				lineTokens[token.line]
				or {}

			table.insert(
				lineTokens[token.line],
				token
			)
		end

		for lineNumber, tokensOnLine in pairs(
			lineTokens
			) do
			local first =
				tokensOnLine[1]

			local last =
				tokensOnLine[
			#tokensOnLine
			]

			if first
				and last
			then
				-- Do not validate syntax from physical line boundaries.
				-- Luau allows calls and expressions to span multiple lines:
				--
				--     Remote:FireServer(
				--         "Buy",
				--         value
				--     )
				--
				-- The complete token stream above already validates brackets,
				-- punctuation, operators, and missing operands. A closing
				-- parenthesis by itself on a line is therefore perfectly valid.

				-- Literals cannot be direct assignment targets.
				for index, token in ipairs(
					tokensOnLine
					) do
					if assignmentOperators[
						token.value
						]
					then
						local lhs =
							tokensOnLine[
						index - 1
						]

						if lhs
							and (
								lhs.kind == "number"
									or lhs.kind == "string"
									or lhs.value == "true"
									or lhs.value == "false"
									or lhs.value == "nil"
							)
						then
							addError(
								lhs.line,
								lhs.column,
								"Invalid assignment target"
							)
						end
					end
				end
			end
		end

		table.sort(
			errors,
			function(a, b)
				if a.line == b.line then
					return (
						a.column or 1
					) < (
						b.column or 1
					)
				end

				return a.line < b.line
			end
		)

		return errors
	end

	-- ============================================================
	-- [28] ERROR UNDERLINES
	-- ============================================================

	local function clearErrorBars()
		for _, bar in ipairs(errorBars) do
			if bar and bar.Parent then
				bar.Visible = false
			end
		end
	end

	updateErrorUnderlines = function()
		clearErrorBars()

		if not Features.ErrorUnderline then
			return
		end

		rebuildFoldingCache()

		local firstVisible, lastVisible =
			getViewportVisibleRange(5)

		local codeWidth =
			math.max(
				EditorContent.AbsoluteSize.X - 55,
				1
			)

		local lineHeight =
			getLineHeight()

		local used = 0

		for _, err in ipairs(currentErrors) do
			local visibleLine =
				visibleLineIndex[err.line]

			if visibleLine
				and not hiddenLines[err.line]
				and visibleLine >= firstVisible
				and visibleLine <= lastVisible
			then
				used += 1

				local bar =
					errorBars[used]

				if not bar then
					bar = Instance.new("Frame")

					bar.Name =
						"ErrorUnderline"

					bar.BorderSizePixel = 0

					bar.BackgroundColor3 =
						Color3.fromRGB(
							244,
							71,
							71
						)

					bar.ZIndex = 6
					bar.Parent = EditorContent

					table.insert(
						errorBars,
						bar
					)
				end

				bar.Visible = true

				bar.Size =
					UDim2.fromOffset(
						codeWidth,
						2
					)

				bar.Position =
					UDim2.fromOffset(
						55,

						(visibleLine - 1)
						* lineHeight
						+ lineHeight
						- 2
					)
			end
		end
	end

	-- ============================================================
	-- [29] BRACKET MATCHING
	-- ============================================================

	local function removeBracketOverlay()
		if bracketOverlay then
			bracketOverlay:Destroy()
			bracketOverlay = nil
		end
	end

	local bracketPairCacheText = nil
	local bracketPairs = {}

	local function rebuildBracketPairCache()
		local text = input.Text

		if bracketPairCacheText == text then
			return
		end

		bracketPairCacheText = text
		table.clear(bracketPairs)

		local stack = {}
		local pairs = {
			["("] = ")",
			["["] = "]",
			["{"] = "}",
		}
		local reverse = {
			[")"] = "(",
			["]"] = "[",
			["}"] = "{",
		}

		local quote = nil
		local i = 1

		while i <= #text do
			local ch = text:sub(i, i)

			if quote then
				if ch == "\\" then
					i += 2
				elseif ch == quote then
					quote = nil
					i += 1
				else
					i += 1
				end
			elseif text:sub(i, i + 1) == "--" then
				local newline = text:find("\n", i, true)
				i = newline and (newline + 1) or (#text + 1)
			elseif ch == "\"" or ch == "'" then
				quote = ch
				i += 1
			elseif pairs[ch] then
				table.insert(stack, {
					char = ch,
					position = i,
				})
				i += 1
			elseif reverse[ch] then
				local expectedOpen = reverse[ch]

				for s = #stack, 1, -1 do
					if stack[s].char == expectedOpen then
						local open = table.remove(stack, s)
						bracketPairs[open.position] = i
						bracketPairs[i] = open.position
						break
					end
				end

				i += 1
			else
				i += 1
			end
		end
	end

	local function findMatchingBracket(_text, position)
		rebuildBracketPairCache()
		return bracketPairs[position]
	end

	local function getCurrentBracketPosition()
		local cursor = input.CursorPosition

		if cursor < 1 then
			return nil
		end

		local before = cursor - 1
		if before >= 1 then
			local character = input.Text:sub(before, before)
			if character:match("[%(%)%[%]{}]") then
				return before
			end
		end

		if cursor <= #input.Text then
			local character = input.Text:sub(cursor, cursor)
			if character:match("[%(%)%[%]{}]") then
				return cursor
			end
		end

		return nil
	end

	updateBracketMatching = function()
		removeBracketOverlay()

		if not Features.BracketMatching then
			return
		end

		local position = getCurrentBracketPosition()
		if not position then
			return
		end

		local matching = findMatchingBracket(input.Text, position)
		if not matching then
			return
		end

		rebuildFoldingCache()

		local sourceLine = getCursorSourceLine(matching)
		local visibleLine = visibleLineIndex[sourceLine]

		if not visibleLine or hiddenLines[sourceLine] then
			return
		end

		bracketOverlay = Instance.new("Frame")
		bracketOverlay.Name = "BracketMatch"
		bracketOverlay.BackgroundTransparency = 1
		bracketOverlay.BorderSizePixel = 0
		bracketOverlay.Size = UDim2.new(
			1,
			-55,
			0,
			getLineHeight()
		)
		bracketOverlay.Position = UDim2.fromOffset(
			55,
			(visibleLine - 1) * getLineHeight()
		)
		bracketOverlay.ZIndex = 6
		bracketOverlay.Parent = EditorContent

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(180, 180, 180)
		stroke.Transparency = 0.7
		stroke.Thickness = 1
		stroke.Parent = bracketOverlay
	end

	-- ============================================================
	-- [30] GUTTER / LINE NUMBERS / FOLD BUTTONS
	-- ============================================================

	local GUTTER_BUFFER_LINES = 15

	local function clearGutter()
		for _, button in ipairs(gutterButtons) do
			if button and button.Parent then
				button.Visible = false
				button:SetAttribute("SourceLine", nil)
			end
		end
	end

	local function highlightLine(lineIndex)
		highlightedLine = math.max(1, lineIndex)

		rebuildFoldingCache()

		local visibleLine = visibleLineIndex[highlightedLine]
		if not visibleLine then
			return
		end

		local lineHeight = getLineHeight()

		hlBar.Visible = false
		hlBar.Position = UDim2.fromOffset(
			55,
			(visibleLine - 1) * lineHeight
		)

		hlBar.Size = UDim2.fromOffset(
			math.max(EditorContent.AbsoluteSize.X - 55, 1),
			lineHeight
		)

		hlBar.ZIndex = 3
	end

	local function createGutterButton()
		local button = Instance.new("TextButton")
		button.Name = "VirtualLine"
		button.BackgroundTransparency = 1
		button.BorderSizePixel = 0
		button.TextColor3 = Color3.fromRGB(133, 133, 133)
		button.TextXAlignment = Enum.TextXAlignment.Right
		button.TextYAlignment = Enum.TextYAlignment.Center
		button.ZIndex = gutter.ZIndex
		button.Parent = gutter

		button.MouseButton1Click:Connect(function()
			local sourceLine = button:GetAttribute("SourceLine")
			if not sourceLine then
				return
			end

			rebuildFoldingCache()

			local endLine = foldEndByStart[sourceLine]

			if Features.CodeFolding and endLine then
				local key = getFoldKey(
					sourceLine,
					endLine,
					cachedLines
				)

				if foldedBlocks[key] then
					foldedBlocks[key] = nil
				else
					foldedBlocks[key] = true
				end

				invalidateFoldingCache()
				updateDisplay()
				rebuildGutter()
				updateEditorCursor()
			else
				highlightLine(sourceLine)
			end
		end)

		table.insert(gutterButtons, button)
		return button
	end

	rebuildGutter = function()
		rebuildFoldingCache()

		local firstVisible, lastVisible =
			getViewportVisibleRange(GUTTER_BUFFER_LINES)

		local needed = math.max(0, lastVisible - firstVisible + 1)

		while #gutterButtons < needed do
			createGutterButton()
		end

		clearGutter()

		local lineHeight = getLineHeight()
		local poolIndex = 0

		for visibleLine = firstVisible, lastVisible do
			local sourceLine = visibleToSourceLine[visibleLine]

			if sourceLine then
				poolIndex += 1

				local button = gutterButtons[poolIndex]
				local endLine = foldEndByStart[sourceLine]
				local foldable =
					Features.CodeFolding
					and endLine ~= nil

				button.Visible = true
				button:SetAttribute("SourceLine", sourceLine)
				button.Font = input.Font
				button.TextSize = input.TextSize
				button.Size = UDim2.fromOffset(55, lineHeight)
				button.Position = UDim2.fromOffset(
					0,
					(visibleLine - 1) * lineHeight
				)

				if foldable then
					local foldKey = getFoldKey(
						sourceLine,
						endLine,
						cachedLines
					)

					button.Text =
						(foldedBlocks[foldKey] and "▶ " or "▼ ")
						.. sourceLine
				else
					button.Text = tostring(sourceLine)
				end
			end
		end
	end

	-- ============================================================
	-- [31] SMART ENTER
	-- ============================================================

	local BLOCK_PATTERNS = {
		{
			pattern = "^if%s+.+%s+then$",
			closer = "end",
		},

		{
			pattern = "^for%s+.+%s+do$",
			closer = "end",
		},

		{
			pattern = "^while%s+.+%s+do$",
			closer = "end",
		},

		{
			pattern = "^repeat$",
			closer = "until true",
		},

		{
			pattern = "^function%s+.+%)$",
			closer = "end",
		},

		{
			pattern = "^local%s+function%s+.+%)$",
			closer = "end",
		},
	}

	local function detectCloser(line)
		line = trim(line)

		for _, rule in ipairs(BLOCK_PATTERNS) do
			if line:match(rule.pattern) then
				return rule.closer
			end
		end

		return nil
	end

	local function performSmartEnter(oldText, newText)
		if not Features.SmartEnter then
			return false
		end

		if #newText ~= #oldText + 1 then
			return false
		end

		local position = 1

		while position <= #oldText
			and oldText:sub(position, position)
			== newText:sub(position, position)
		do
			position += 1
		end

		if newText:sub(position, position) ~= "\n" then
			return false
		end

		local prefix = oldText:sub(
			1,
			position - 1
		)

		local suffix = oldText:sub(position)

		local currentLine =
			prefix:match("([^\n]*)$") or ""

		local indent = getIndent(currentLine)

		local trimmed = trim(currentLine)

		local closer = detectCloser(trimmed)

		local finalText
		local cursorPosition

		if closer then
			local deeperIndent = indent .. "\t"

			finalText =
				prefix
				.. "\n"
				.. deeperIndent
				.. "\n"
				.. indent
				.. closer
				.. suffix

			cursorPosition =
				#prefix
				+ 1
				+ #deeperIndent
				+ 1
		else
			finalText =
				prefix
				.. "\n"
				.. indent
				.. suffix

			cursorPosition =
				#prefix
				+ 1
				+ #indent
				+ 1
		end

		updatingText = true

		input.Text = finalText
		input.CursorPosition = cursorPosition

		lastText = finalText

		updatingText = false

		return true
	end

	-- ============================================================
	-- [32] AUTOCOMPLETE ENGINE / POPUP
	-- ============================================================

	local completionPopup = Instance.new("Frame")

	completionPopup.Name = "CompletionPopup"

	completionPopup.BackgroundColor3 =
		Color3.fromRGB(37, 37, 38)

	completionPopup.BorderSizePixel = 0
	completionPopup.Visible = false
	completionPopup.ZIndex = 20

	completionPopup.Size = UDim2.fromOffset(
		COMPLETION_WIDTH,
		COMPLETION_HEIGHT
	)

	completionPopup.Parent = frame

	local popupCorner = Instance.new("UICorner")

	popupCorner.CornerRadius =
		UDim.new(0, 4)

	popupCorner.Parent = completionPopup

	local popupStroke = Instance.new("UIStroke")

	popupStroke.Color =
		Color3.fromRGB(70, 70, 72)

	popupStroke.Transparency = 0.35
	popupStroke.Thickness = 1

	popupStroke.Parent = completionPopup

	local completionLayout =
		Instance.new("UIListLayout")

	completionLayout.SortOrder =
		Enum.SortOrder.LayoutOrder

	completionLayout.Parent =
		completionPopup

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: POPUP RESET
	-- ------------------------------------------------------------

	clearAutocomplete = function()
		for _, button in ipairs(completionButtons) do
			if button and button.Parent then
				button:Destroy()
			end
		end

		table.clear(completionButtons)
		table.clear(completionWords)

		selectedCompletion = 1

		completionPopup.Visible = false
	end

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: CURSOR / IDENTIFIER CONTEXT
	-- ------------------------------------------------------------

	local function getAutocompleteContext()
		local cursor =
			input.CursorPosition

		if cursor < 1 then
			return {
				prefix = "",
				suffix = "",
				fullWord = "",
				wordStart = cursor,
				wordEnd = cursor,
			}
		end

		local text =
			input.Text

		local prefixEnd =
			cursor - 1

		local prefixStart =
			prefixEnd

		while prefixStart >= 1
			and text:sub(
				prefixStart,
				prefixStart
			):match("[%w_]")
		do
			prefixStart -= 1
		end

		prefixStart += 1

		local suffixStart =
			cursor

		local suffixEnd =
			suffixStart

		while suffixEnd <= #text
			and text:sub(
				suffixEnd,
				suffixEnd
			):match("[%w_]")
		do
			suffixEnd += 1
		end

		local prefix =
			text:sub(
				prefixStart,
				prefixEnd
			)

		local suffix =
			text:sub(
				suffixStart,
				suffixEnd - 1
			)

		local fullWord =
			prefix .. suffix

		-- A valid identifier must start with a letter or underscore.
		if fullWord ~= ""
			and not fullWord:sub(
				1,
				1
			):match("[%a_]")
		then
			return {
				prefix = "",
				suffix = "",
				fullWord = "",
				wordStart = cursor,
				wordEnd = cursor,
			}
		end

		return {
			prefix = prefix,
			suffix = suffix,
			fullWord = fullWord,
			wordStart = prefixStart,
			wordEnd = suffixEnd - 1,
		}
	end

	local function getCurrentWord()
		return getAutocompleteContext().prefix
	end

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: SELECTION VISUALS
	-- ------------------------------------------------------------

	local function updateCompletionSelection()
		for index, button in ipairs(completionButtons) do
			if index == selectedCompletion then
				button.BackgroundTransparency = 0

				button.BackgroundColor3 =
					Color3.fromRGB(
						62,
						62,
						64
					)

				if button:GetAttribute(
					"DynamicSymbol"
					) then
					button.TextColor3 =
						Color3.fromRGB(
							110,
							235,
							205
						)
				else
					button.TextColor3 =
						Color3.fromRGB(
							255,
							255,
							255
						)
				end
			else
				button.BackgroundTransparency = 1

				if button:GetAttribute(
					"DynamicSymbol"
					) then
					button.TextColor3 =
						Color3.fromRGB(
							78,
							201,
							176
						)
				else
					button.TextColor3 =
						Color3.fromRGB(
							220,
							220,
							220
						)
				end
			end
		end
	end

	local AUTOCOMPLETE_X_OFFSET = 4
	local AUTOCOMPLETE_Y_OFFSET = 8

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: POPUP POSITION
	-- ------------------------------------------------------------

	positionAutocomplete = function()
		if not completionPopup.Visible then
			return
		end

		if not input:IsFocused() then
			return
		end

		local cursor = input.CursorPosition

		if cursor < 1 then
			return
		end

		rebuildFoldingCache()

		-- ========================================================
		-- FIND CURRENT SOURCE / VISIBLE LINE
		-- ========================================================

		local sourceLine =
			getCursorSourceLine(cursor)

		local visibleLine =
			visibleLineIndex[sourceLine]

		if not visibleLine then
			return
		end

		local lineHeight =
			getLineHeight()

		-- ========================================================
		-- FIND TEXT BEFORE CURSOR ON CURRENT LINE
		-- ========================================================

		local lineStart =
			lineStartPositions[sourceLine]
			or 1

		local textBeforeCursor = ""

		if cursor > lineStart then
			textBeforeCursor =
				input.Text:sub(
					lineStart,
					cursor - 1
				)
		end

		-- Exact horizontal cursor position.
		local textWidth =
			TextService:GetTextSize(
				textBeforeCursor,
				input.TextSize,
				input.Font,
				Vector2.new(
					100000,
					lineHeight
				)
			).X

		-- ========================================================
		-- CURSOR ABSOLUTE SCREEN POSITION
		-- ========================================================

		-- IMPORTANT:
		--
		-- EditorContent.AbsolutePosition already accounts for
		-- ScrollingFrame.CanvasPosition.
		--
		-- DO NOT subtract CanvasPosition again.

		local cursorAbsoluteX =
			display.AbsolutePosition.X
			+ textWidth

		local cursorAbsoluteY =
			display.AbsolutePosition.Y
			+ ((visibleLine - 1) * lineHeight)

		-- Convert screen coordinates to coordinates relative
		-- to the MainFrame, because CompletionPopup.Parent = frame.

		local frameAbsolute =
			frame.AbsolutePosition

		local x =
			cursorAbsoluteX
		- frameAbsolute.X
			+ AUTOCOMPLETE_X_OFFSET

		local y =
			cursorAbsoluteY
		- frameAbsolute.Y
			+ lineHeight
			+ AUTOCOMPLETE_Y_OFFSET

		-- ========================================================
		-- KEEP POPUP INSIDE WINDOW
		-- ========================================================

		local popupWidth =
			completionPopup.AbsoluteSize.X

		local popupHeight =
			completionPopup.AbsoluteSize.Y

		-- AbsoluteSize may still be zero on the first frame.
		if popupWidth <= 0 then
			popupWidth = COMPLETION_WIDTH
		end

		if popupHeight <= 0 then
			popupHeight =
				math.max(
					COMPLETION_HEIGHT,
					#completionWords
					* COMPLETION_HEIGHT
				)
		end

		local frameWidth =
			frame.AbsoluteSize.X

		local frameHeight =
			frame.AbsoluteSize.Y

		-- If there isn't enough room underneath,
		-- put autocomplete above the current line.
		if y + popupHeight > frameHeight then
			y =
				cursorAbsoluteY
			- frameAbsolute.Y
			- popupHeight
			- AUTOCOMPLETE_Y_OFFSET
		end

		-- Keep inside left/right/bottom/top bounds.
		x =
			math.clamp(
				x,
				0,
				math.max(
					0,
					frameWidth - popupWidth
				)
			)

		y =
			math.clamp(
				y,
				0,
				math.max(
					0,
					frameHeight - popupHeight
				)
			)

		completionPopup.Position =
			UDim2.fromOffset(
				math.round(x),
				math.round(y)
			)
	end

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: INSERT SUGGESTION
	-- ------------------------------------------------------------

	local function insertCompletion()
		if not completionPopup.Visible then
			return false
		end

		local word =
			completionWords[selectedCompletion]

		if not word then
			return false
		end

		local cursor =
			input.CursorPosition

		local context =
			getAutocompleteContext()

		-- Autocomplete should never replace text while the cursor is
		-- sitting inside an already existing identifier.
		if context.suffix ~= "" then
			clearAutocomplete()
			return false
		end

		local wordStart =
			context.wordStart

		local before =
			input.Text:sub(
				1,
				wordStart - 1
			)

		local after =
			input.Text:sub(cursor)

		local newText =
			before
			.. word
			.. after

		local newCursor =
			#before
			+ #word
			+ 1

		updatingText = true

		input.Text = newText
		input.CursorPosition = newCursor

		lastText = newText

		updatingText = false

		clearAutocomplete()

		return true
	end

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: BUILD SUGGESTIONS
	-- ------------------------------------------------------------

	showAutocomplete = function()
		if not Features.Autocomplete then
			clearAutocomplete()
			return
		end

		if not input:IsFocused() then
			clearAutocomplete()
			return
		end

		local context =
			getAutocompleteContext()

		local prefix =
			context.prefix

		-- Do not show suggestions while the cursor is inside an existing
		-- identifier. Example:
		--
		--     h|umanoid
		--
		-- "umanoid" already exists to the right of the cursor, so suggesting
		-- "Humanoid" again is noisy and can accidentally duplicate text.
		if context.suffix ~= "" then
			clearAutocomplete()
			return
		end

		if prefix == "" then
			clearAutocomplete()
			return
		end

		clearAutocomplete()

		local prefixLower =
			prefix:lower()

		local added = {}

		local function tryAdd(word)
			if not word
				or added[word]
			then
				return
			end

			local lower =
				word:lower()

			if lower:sub(
				1,
				#prefixLower
				) == prefixLower
					and lower ~= prefixLower
			then
				added[word] = true

				table.insert(
					completionWords,
					word
				)
			end
		end

		-- Only symbols declared before the cursor are suggested. This makes
		-- autocomplete behave much more like a real editor instead of
		-- suggesting variables that haven't been declared yet.
		local cursor =
			math.max(
				1,
				input.CursorPosition
			)

		local sourceBeforeCursor =
			input.Text:sub(
				1,
				math.max(
					0,
					cursor - 1
				)
			)

		local availableSet,
			availableSymbols,
			availableFunctions =
			collectAvailableSymbols(
				sourceBeforeCursor
			)

		-- Do not suppress autocomplete just because the prefix exactly
		-- matches one in-scope symbol. tryAdd() already excludes the exact
		-- same word while still allowing longer useful matches.
		--
		-- This keeps h|umanoid fixed via the suffix guard above, while
		-- allowing loop code such as "for i, v in ..." to still suggest
		-- longer v-prefixed names when appropriate.

		-- Dynamic symbols come first because they are usually more useful
		-- than generic built-ins.
		for _, word in ipairs(
			availableSymbols
			) do
			tryAdd(word)

			if #completionWords >=
				MAX_COMPLETIONS
			then
				break
			end
		end

		if #completionWords
			< MAX_COMPLETIONS
		then
			for _, word in ipairs(COMPLETIONS) do
				tryAdd(word)

				if #completionWords >=
					MAX_COMPLETIONS
				then
					break
				end
			end
		end

		if #completionWords == 0 then
			return
		end

		for index, word in ipairs(
			completionWords
			) do
			local button =
				Instance.new("TextButton")

			button.Name =
				"Completion" .. index

			button.Size =
				UDim2.new(
					1,
					0,
					0,
					COMPLETION_HEIGHT
				)

			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.Text = word

			-- User symbols are green in autocomplete too.
			button.TextColor3 =
				availableSet[word]
				and Color3.fromRGB(
					78,
					201,
					176
				)
				or Color3.fromRGB(
					220,
					220,
					220
				)

			button.TextSize = 14
			button.Font = Enum.Font.Code
			button.TextXAlignment =
				Enum.TextXAlignment.Left

			button.LayoutOrder = index
			button.ZIndex = 101
			button.Parent = completionPopup

			-- Store the kind so selection styling can preserve the semantic
			-- green color after moving with Up/Down.
			button:SetAttribute(
				"DynamicSymbol",
				availableSet[word]
					== true
			)

			button:SetAttribute(
				"DynamicFunction",
				availableFunctions[word]
					== true
			)

			button.MouseButton1Click:Connect(function()
				selectedCompletion = index
				insertCompletion()
			end)

			table.insert(
				completionButtons,
				button
			)
		end

		completionPopup.Size =
			UDim2.fromOffset(
				COMPLETION_WIDTH,
				#completionWords
				* COMPLETION_HEIGHT
			)

		selectedCompletion = 1
		updateCompletionSelection()

		completionPopup.Visible = true
		positionAutocomplete()
	end

	-- ------------------------------------------------------------
	-- AUTOCOMPLETE: KEYBOARD CONTROL
	-- ------------------------------------------------------------

	local function handleAutocompleteKey(keyCode)
		if not Features.Autocomplete then
			return false
		end

		if not completionPopup.Visible then
			return false
		end

		if not input:IsFocused() then
			return false
		end

		-- DOWN
		if keyCode == Enum.KeyCode.Down then
			if #completionWords == 0 then
				return false
			end

			selectedCompletion += 1

			if selectedCompletion > #completionWords then
				selectedCompletion = 1
			end

			updateCompletionSelection()

			return true
		end

		-- UP
		if keyCode == Enum.KeyCode.Up then
			if #completionWords == 0 then
				return false
			end

			selectedCompletion -= 1

			if selectedCompletion < 1 then
				selectedCompletion = #completionWords
			end

			updateCompletionSelection()

			return true
		end

		-- TAB
		if keyCode == Enum.KeyCode.Tab then
			local accepted = insertCompletion()

			if accepted then
				task.spawn(function()
					-- Wait for Roblox's TextBox to process Tab.
					RunService.Heartbeat:Wait()

					if not input:IsFocused() then
						return
					end

					local text = input.Text
					local cursor = input.CursorPosition

					if cursor < 1 then
						return
					end

					-- Remove the native tab if Roblox added it.
					if cursor > 1
						and text:sub(
							cursor - 1,
							cursor - 1
						) == "\t"
					then
						updatingText = true

						input.Text =
							text:sub(
								1,
								cursor - 2
							)
							.. text:sub(cursor)

						input.CursorPosition =
							cursor - 1

						lastText = input.Text

						updatingText = false

						updateDisplay()
						rebuildGutter()
						updateBracketMatching()
					end
				end)

				return true
			end

			return false
		end

		-- ENTER
		if keyCode == Enum.KeyCode.Return then
			return insertCompletion()
		end

		-- ESC
		if keyCode == Enum.KeyCode.Escape then
			clearAutocomplete()
			return true
		end

		return false
	end


	-- ============================================================
	-- [33] KEYBOARD CURSOR / VERTICAL NAVIGATION
	-- ============================================================
	--
	-- IMPORTANT:
	--
	-- The visible editor is virtualized, but Roblox still owns the real
	-- TextBox caret. On very large multiline TextBoxes Roblox can apply its
	-- own mouse/Up/Down caret movement after our Lua callback. That caused
	-- the one-time ~986 -> ~483 jump and also caused mouse clicks above the
	-- current caret to snap back down.
	--
	-- Potassium now keeps ONE logical cursor position and temporarily guards
	-- it whenever we perform custom mouse or vertical navigation.
	-- ============================================================

	local preferredVerticalColumn = nil

	local logicalCursorPosition =
		math.max(
			1,
			input.CursorPosition
		)

	local guardedCursorPosition = nil
	local cursorGuardUntil = 0
	local verticalKeyDown = false
	local settingCursorInternally = false
	local manualMousePlacementPending = false

	local mouseSelectingText = false
	local mouseSelectionAnchor = nil

	local function isCursorGuardActive()
		return guardedCursorPosition ~= nil
			and (
				verticalKeyDown
				or os.clock() <= cursorGuardUntil
			)
	end

	local function setCursorInternally(cursorPosition)
		if not input.Parent then
			return
		end

		cursorPosition =
			math.clamp(
				cursorPosition,
				1,
				#input.Text + 1
			)

		settingCursorInternally = true

		input.CursorPosition = cursorPosition
		input.SelectionStart = cursorPosition

		settingCursorInternally = false

		logicalCursorPosition = cursorPosition
	end

	local function setSelectionInternally(
		anchorPosition,
		cursorPosition
	)
		if not input.Parent then
			return
		end

		anchorPosition =
			math.clamp(
				anchorPosition,
				1,
				#input.Text + 1
			)

		cursorPosition =
			math.clamp(
				cursorPosition,
				1,
				#input.Text + 1
			)

		settingCursorInternally = true

		input.CursorPosition =
			cursorPosition

		input.SelectionStart =
			anchorPosition

		settingCursorInternally = false

		logicalCursorPosition =
			cursorPosition
	end

	local function getSelectionRange()
		local cursor =
			input.CursorPosition

		local selectionStart =
			input.SelectionStart

		if cursor < 1
			or selectionStart < 1
			or cursor == selectionStart
		then
			return nil, nil
		end

		return math.min(
			cursor,
			selectionStart
		),
			math.max(
				cursor,
				selectionStart
			)
	end

	local function updateSelectionVisuals()
		clearSelectionVisuals()

		local selectionMin,
			selectionMax =
			getSelectionRange()

		if not selectionMin
			or not input:IsFocused()
		then
			return
		end

		rebuildFoldingCache()

		local lineHeight =
			getLineHeight()

		local displayOffsetX =
			input.Position.X.Offset

		local displayOffsetY =
			input.Position.Y.Offset

		local startLine =
			getCursorSourceLine(
				selectionMin
			)

		local endLine =
			getCursorSourceLine(
				math.max(
					selectionMin,
					selectionMax - 1
				)
			)

		for sourceLine =
			startLine,
			endLine
		do
			if not isLineHidden(
				sourceLine
				) then
				local lineText =
					cachedLines[
				sourceLine
				] or ""

				local lineStart =
					lineStartPositions[
				sourceLine
				] or 1

				local localStart =
					math.clamp(
						selectionMin
						- lineStart,
						0,
						#lineText
					)

				local localEnd =
					math.clamp(
						selectionMax
						- lineStart,
						0,
						#lineText
					)

				if sourceLine > startLine then
					localStart = 0
				end

				if sourceLine < endLine then
					localEnd =
						#lineText
				end

				local selectsLineBreak =
					sourceLine < endLine

				if localEnd > localStart
					or selectsLineBreak
				then
					local beforeText =
						lineText:sub(
							1,
							localStart
						)

					local selectedText =
						lineText:sub(
							localStart + 1,
							localEnd
						)

					local startWidth =
						TextService:GetTextSize(
							beforeText,
							input.TextSize,
							input.Font,
							Vector2.new(
								100000,
								lineHeight
							)
						).X

					local selectedWidth =
						TextService:GetTextSize(
							selectedText,
							input.TextSize,
							input.Font,
							Vector2.new(
								100000,
								lineHeight
							)
						).X

					local visibleLine =
						visibleLineIndex[
					sourceLine
					] or sourceLine

					local visual =
						Instance.new("Frame")

					visual.Name =
						"Selection"

					visual.BackgroundColor3 =
						Color3.fromRGB(
							70,
							110,
							170
						)

					visual.BackgroundTransparency =
						0.35

					visual.BorderSizePixel = 0
					visual.ZIndex = 3

					visual.Position =
						UDim2.fromOffset(
							math.round(
								displayOffsetX
								+ startWidth
							),
							math.round(
								displayOffsetY
								+ (
									visibleLine - 1
								)
								* lineHeight
							)
						)

					local visualWidth =
						selectedWidth

					if selectsLineBreak then
						visualWidth +=
							math.max(
								4,
								TextService:GetTextSize(
									" ",
									input.TextSize,
									input.Font,
									Vector2.new(
										1000,
										lineHeight
									)
								).X
							)
					end

					visual.Size =
						UDim2.fromOffset(
							math.max(
								2,
								math.ceil(
									visualWidth
								)
							),
							math.ceil(
								lineHeight
							)
						)

					visual.Parent =
						selectionOverlay

					table.insert(
						selectionFrames,
						visual
					)
				end
			end
		end
	end

	local function guardCursor(cursorPosition, duration)
		cursorPosition =
			math.clamp(
				cursorPosition,
				1,
				#input.Text + 1
			)

		guardedCursorPosition = cursorPosition
		cursorGuardUntil =
			math.max(
				cursorGuardUntil,
				os.clock() + (duration or 0.12)
			)

		setCursorInternally(cursorPosition)
	end

	local function clearCursorGuard()
		guardedCursorPosition = nil
		cursorGuardUntil = 0
		verticalKeyDown = false
	end

	local function moveCursorVertically(direction)
		if not input:IsFocused() then
			return false
		end

		rebuildFoldingCache()

		-- Never base custom navigation on a native TextBox jump.
		local cursor =
			guardedCursorPosition
			or logicalCursorPosition
			or input.CursorPosition

		cursor =
			math.clamp(
				cursor,
				1,
				#input.Text + 1
			)

		local sourceLine =
			getCursorSourceLine(cursor)

		-- Move exactly one SOURCE line.
		local targetSourceLine =
			math.clamp(
				sourceLine + direction,
				1,
				math.max(1, #cachedLines)
			)

		if targetSourceLine == sourceLine then
			guardCursor(cursor, 0.15)
			return true
		end

		local currentLineStart =
			lineStartPositions[sourceLine]
			or 1

		-- Preserve the horizontal column while travelling vertically.
		if preferredVerticalColumn == nil then
			preferredVerticalColumn =
				math.max(
					0,
					cursor - currentLineStart
				)
		end

		local targetText =
			cachedLines[targetSourceLine]
			or ""

		local targetLineStart =
			lineStartPositions[targetSourceLine]
			or 1

		local targetColumn =
			math.min(
				preferredVerticalColumn,
				#targetText
			)

		local newCursor =
			targetLineStart
			+ targetColumn

		-- Keep ownership of the caret for the full physical key press.
		guardCursor(newCursor, 0.18)

		resetCursorBlink()
		updateEditorCursor()

		task.defer(function()
			if input:IsFocused() then
				ensureCursorVisible()

				if completionPopup.Visible then
					positionAutocomplete()
				end
			end
		end)

		return true
	end

	-- Continuously reject any delayed native TextBox movement while a custom
	-- cursor operation is protected. This is much more reliable than only
	-- checking four frames after the key press.
	RunService.RenderStepped:Connect(function()
		if not guardedCursorPosition then
			return
		end

		if not isCursorGuardActive() then
			guardedCursorPosition = nil
			return
		end

		if input.Parent
			and input.CursorPosition ~= guardedCursorPosition
		then
			setCursorInternally(
				guardedCursorPosition
			)
		end
	end)

	-- Up/Down are handled later by UserInputService.
	-- Do NOT bind them through ContextActionService here. A focused
	-- multiline TextBox can process those bindings in an inconsistent
	-- order relative to its native caret navigation.

	-- ============================================================
	-- [34] BRACKET / QUOTE AUTO-CLOSE
	-- ============================================================

	local lastAutoClosePosition = nil

	local function skipExistingCloser(oldText, newText)
		if not Features.BracketAutoClose then
			return false
		end

		if #newText ~= #oldText + 1 then
			return false
		end

		local cursor = input.CursorPosition

		if cursor < 2 then
			return false
		end

		local insertedPosition = cursor - 1

		local inserted =
			newText:sub(
				insertedPosition,
				insertedPosition
			)

		local closers = {
			[")"] = true,
			["]"] = true,
			["}"] = true,
			['"'] = true,
			["'"] = true,
		}

		if not closers[inserted] then
			return false
		end

		-- Check what was already at this position BEFORE
		-- Roblox inserted the newly typed character.
		local existing =
			oldText:sub(
				insertedPosition,
				insertedPosition
			)

		if existing ~= inserted then
			return false
		end

		-- Remove the duplicate character Roblox just inserted,
		-- and move the real cursor past the existing closer.
		updatingText = true

		input.Text = oldText

		input.CursorPosition =
			insertedPosition + 1

		lastText = input.Text

		updatingText = false

		return true
	end

	local function autoCloseBracket(oldText, newText)
		if not Features.BracketAutoClose then
			return false
		end

		if #newText ~= #oldText + 1 then
			return false
		end

		local cursor = input.CursorPosition

		if cursor < 2 then
			return false
		end

		local inserted = newText:sub(
			cursor - 1,
			cursor - 1
		)

		local closingPairs = {
			["("] = ")",
			["["] = "]",
			["{"] = "}",
			['"'] = '"',
			["'"] = "'",
		}

		local closing =
			closingPairs[inserted]

		if not closing then
			return false
		end

		local nextCharacter =
			newText:sub(
				cursor,
				cursor
			)

		if nextCharacter == closing then
			return false
		end

		updatingText = true

		input.Text =
			newText:sub(
				1,
				cursor - 1
			)
			.. closing
			.. newText:sub(cursor)

		input.CursorPosition = cursor

		lastText = input.Text

		updatingText = false

		lastAutoClosePosition = cursor

		return true
	end

	-- ============================================================
	-- [35] MINOR / SUPPORT SYSTEMS
	-- ============================================================
	--
	-- Main IDE functionality stays in this file. Window chrome, Settings,
	-- the menu hotkey, resizing/dragging, toolbar plumbing and viewport
	-- refresh bookkeeping live in IDEMinor so they do not consume the main
	-- initializer's limited local-register budget.

	local MinorController =
		IDEMinor.new({
			MainFrame = frame,
			ConsoleFrame = Console_2,
			CodingHolder = CodingHolder,
			EditorScroll = EditorScroll,
			Input = input,
			Features = Features,

			-- ----------------------------------------------------
			-- MAIN FUNCTIONALITY CALLBACKS
			-- ----------------------------------------------------

			onExecute = function()
				local success, result =
				pcall(function()
					return loadstring(
						input.Text
					)()
				end)

				if not success then
					warn(
						"[Potassium IDE] Execution error:",
						result
					)
				end
			end,

			onClear = function()
				input.Text = ""
			end,

			onConsole = function()
				if Console_2 then
					Console_2.Visible = true
				else
					warn(
						"[Potassium IDE] Console UI not found."
					)
				end
			end,

			onFeatureChanged = function(
				featureKey,
				enabled
			)
				updateDisplay()
				rebuildGutter()

				currentErrors =
				findErrors(
					input.Text
				)

				updateErrorUnderlines()
				updateBracketMatching()

				if featureKey
					== "Autocomplete"
				then
					if enabled then
						showAutocomplete()
					else
						clearAutocomplete()
					end
				end
			end,

			onResize = function()
				updateEditorLayout()
				rebuildGutter()
				updateErrorUnderlines()
				updateBracketMatching()
				positionAutocomplete()
			end,

			onMenuShown = function()
				IDEINFOCUS()

				task.defer(function()
					if frame.Parent
						and input.Parent
					then
						input:CaptureFocus()
						updateEditorCursor()
					end
				end)
			end,

			onMenuHidden = function()
				input:ReleaseFocus()
				clearAutocomplete()
				clearSelectionVisuals()
				removeBracketOverlay()
				editorCursor.Visible = false
			end,

			-- ----------------------------------------------------
			-- VIEWPORT SUPPORT CALLBACKS
			-- ----------------------------------------------------

			rebuildFoldingCache =
			rebuildFoldingCache,

			getViewportVisibleRange =
			getViewportVisibleRange,

			getDisplayBuffer = function()
				return DISPLAY_BUFFER_LINES
			end,

			getGutterBuffer = function()
				return GUTTER_BUFFER_LINES
			end,

			updateDisplay =
			updateDisplay,

			rebuildGutter =
			rebuildGutter,

			updateErrorUnderlines =
			updateErrorUnderlines,

			positionAutocomplete =
			positionAutocomplete,

			isAutocompleteVisible =
			function()
				return completionPopup.Visible
			end,

			updateEditorCursor =
			updateEditorCursor,

			isInputFocused =
			function()
				return input:IsFocused()
			end,

			updateEditorLayout =
			updateEditorLayout,
		})

	-- ============================================================
	-- [44] TEXT-CHANGE PIPELINE
	-- ============================================================

	local refreshSerial = 0

	local function refreshEditorView(recalculateErrors)
		updateEditorLayout()
		updateDisplay()
		rebuildGutter()

		if recalculateErrors then
			currentErrors = findErrors(input.Text)
		end

		updateErrorUnderlines()
		updateBracketMatching()

		cursorNeedsUpdate = false

		if input:IsFocused() then
			updateEditorCursor()
			ensureCursorVisible()
		end
	end

	local function scheduleExpensiveRefresh(delaySeconds)
		refreshSerial += 1
		local serial = refreshSerial

		task.delay(delaySeconds or 0.10, function()
			if serial ~= refreshSerial then
				return
			end

			if not frame.Parent then
				return
			end

			currentErrors = findErrors(input.Text)
			updateErrorUnderlines()
			updateBracketMatching()
		end)
	end

	-- ============================================================
	-- [44.5] WORKSPACE CONTROLLER BINDING
	-- ============================================================

	WorkspaceController:Bind({
		getText = function()
			return input.Text
		end,

		getCursor = function()
			return math.max(
				1,
				input.CursorPosition
			)
		end,

		getSelection = function()
			return input.SelectionStart
		end,

		getCanvas = function()
			return EditorScroll.CanvasPosition
		end,

		loadDocument = function(document)
			updatingText = true

			foldedBlocks = {}
			clearAutocomplete()
			clearSelectionVisuals()
			removeBracketOverlay()

			input.Text =
				document.text or ""

			input.CursorPosition =
				math.clamp(
					document.cursor or 1,
					1,
					#input.Text + 1
				)

			input.SelectionStart =
				math.clamp(
					document.selectionStart
					or input.CursorPosition,
					1,
					#input.Text + 1
				)

			EditorScroll.CanvasPosition =
				document.canvasPosition
				or Vector2.zero

			lastText = input.Text

			invalidateFoldingCache()
			invalidateHorizontalWidthCache()
			rebuildDynamicSymbols(
				input.Text
			)

			currentErrors =
				findErrors(
					input.Text
				)

			updatingText = false

			refreshEditorView(false)
		end,

		layoutChanged = function()
			updateEditorLayout()
			refreshEditorView(false)
		end,
	})

	input:GetPropertyChangedSignal("Text"):Connect(function()
		invalidateFoldingCache()
		invalidateHorizontalWidthCache()

		-- Keep semantic highlighting/autocomplete synchronized with the
		-- source as the user types.
		rebuildDynamicSymbols(
			input.Text
		)

		if updatingText then
			return
		end

		WorkspaceController:MarkDirty(
			input.Text
		)

		cursorNeedsUpdate = true

		local newText = input.Text
		local oldText = lastText

		-- Smart Enter may rewrite Text/CursorPosition itself.
		if performSmartEnter(oldText, newText) then
			lastText = input.Text
			invalidateFoldingCache()
			refreshEditorView(false)
			scheduleExpensiveRefresh(0.08)
			clearAutocomplete()
			return
		end

		-- Skip a closer that was already inserted automatically.
		if skipExistingCloser(oldText, newText) then
			lastText = input.Text
			invalidateFoldingCache()
			refreshEditorView(false)
			scheduleExpensiveRefresh(0.08)
			return
		end

		-- Insert matching quotes/brackets.
		if autoCloseBracket(oldText, newText) then
			lastText = input.Text
			invalidateFoldingCache()
			refreshEditorView(false)
			scheduleExpensiveRefresh(0.08)
			return
		end

		lastText = newText

		-- Preserve only folds whose start line still exists. The expensive
		-- block pairing itself is cached and rebuilt once for this revision.
		rebuildFoldingCache()

		local validFolds = {}

		for key, state in pairs(foldedBlocks) do
			if state then
				local startLine =
					tonumber(key:match("^(%d+):"))

				if startLine
					and cachedLines[startLine]
					and foldEndByStart[startLine]
				then
					local newKey = getFoldKey(
						startLine,
						foldEndByStart[startLine],
						cachedLines
					)

					validFolds[newKey] = true
				end
			end
		end

		foldedBlocks = validFolds

		-- Cheap viewport work is immediate. Whole-file error checking is
		-- debounced so large pastes/typing do not freeze the client.
		invalidateFoldingCache()
		refreshEditorView(false)
		scheduleExpensiveRefresh(0.12)

		if Features.Autocomplete then
			showAutocomplete()
		else
			clearAutocomplete()
		end
	end)

	-- ============================================================
	-- [45] KEYBOARD INPUT
	-- ============================================================

	local verticalRepeatToken = 0
	local VERTICAL_REPEAT_DELAY = 0.32
	local VERTICAL_REPEAT_RATE = 0.045

	local function handleVerticalArrowKey(keyCode)
		if not input:IsFocused() then
			return
		end

		-- Autocomplete owns Up/Down while it is actually visible.
		if completionPopup.Visible
			and Features.Autocomplete
		then
			guardCursor(
				logicalCursorPosition,
				0.20
			)

			handleAutocompleteKey(
				keyCode
			)

			return
		end

		local direction =
			keyCode == Enum.KeyCode.Up
			and -1
			or 1

		verticalKeyDown = true

		moveCursorVertically(
			direction
		)
	end

	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)

		-- We ONLY care about keyboard input.
		if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if not input:IsFocused() then
			return
		end

		-- Up/Down are handled completely by Potassium.
		--
		-- The CursorPosition listener rejects Roblox's native multiline
		-- TextBox jump while the physical arrow key is down. We then move
		-- exactly one source line ourselves here.
		if inputObject.KeyCode == Enum.KeyCode.Up
			or inputObject.KeyCode == Enum.KeyCode.Down
		then
			local keyCode =
				inputObject.KeyCode

			verticalRepeatToken += 1
			local myToken =
				verticalRepeatToken

			handleVerticalArrowKey(
				keyCode
			)

			-- Recreate normal editor key-repeat without ever handing vertical
			-- navigation back to the native TextBox.
			task.spawn(function()
				task.wait(
					VERTICAL_REPEAT_DELAY
				)

				while input.Parent
					and input:IsFocused()
					and verticalRepeatToken == myToken
					and UserInputService:IsKeyDown(
						keyCode
					)
				do
					handleVerticalArrowKey(
						keyCode
					)

					task.wait(
						VERTICAL_REPEAT_RATE
					)
				end
			end)

			return
		end

		-- Any normal editing/navigation key ends the vertical guard and
		-- starts a fresh preferred column next time Up/Down is used.
		preferredVerticalColumn = nil
		clearCursorGuard()

		logicalCursorPosition =
			math.max(
				1,
				input.CursorPosition
			)

		-- Handle autocomplete BEFORE checking gameProcessed.
		if handleAutocompleteKey(inputObject.KeyCode) then
			return
		end

		if inputObject.KeyCode == Enum.KeyCode.Backspace then
			lastAutoClosePosition = nil
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType
			~= Enum.UserInputType.Keyboard
		then
			return
		end

		if inputObject.KeyCode ~= Enum.KeyCode.Up
			and inputObject.KeyCode ~= Enum.KeyCode.Down
		then
			return
		end

		verticalRepeatToken += 1
		verticalKeyDown = false

		-- Keep a short protection tail because Roblox can publish a native
		-- caret change just after the key-up event.
		cursorGuardUntil =
			os.clock() + 0.12
	end)

	-- ============================================================
	-- [46] CURSOR / SELECTION EVENTS
	-- ============================================================

	local function getCursorPositionFromMouse(screenPosition)
		rebuildFoldingCache()

		local lineHeight =
			getLineHeight()

		-- MouseCapture exactly overlays the hidden TextBox. Using its real
		-- AbsolutePosition is more accurate than reconstructing the point
		-- from CanvasPosition and a hard-coded gutter offset.
		local localX =
			screenPosition.X
		- mouseCapture.AbsolutePosition.X

		local localY =
			screenPosition.Y
		- mouseCapture.AbsolutePosition.Y

		-- Clamp while dragging beyond the visible text area.
		localX =
			math.clamp(
				localX,
				0,
				math.max(
					0,
					mouseCapture.AbsoluteSize.X
				)
			)

		localY =
			math.clamp(
				localY,
				0,
				math.max(
					0,
					mouseCapture.AbsoluteSize.Y
				)
			)

		local renderedLine =
			math.floor(
				math.max(0, localY)
				/ lineHeight
			)
			+ 1

		renderedLine =
			math.clamp(
				renderedLine,
				1,
				math.max(
					1,
					#visibleToSourceLine
				)
			)

		local sourceLine =
			visibleToSourceLine[
		renderedLine
		]
			or #cachedLines

		local lineText =
			cachedLines[sourceLine]
			or ""

		local lineStart =
			lineStartPositions[sourceLine]
			or 1

		local low = 0
		local high = #lineText
		local bestCharacter = 0

		while low <= high do
			local mid =
				math.floor(
					(low + high) / 2
				)

			local width =
				TextService:GetTextSize(
					lineText:sub(
						1,
						mid
					),
					input.TextSize,
					input.Font,
					Vector2.new(
						100000,
						lineHeight
					)
				).X

			if width <= localX then
				bestCharacter = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end

		if bestCharacter < #lineText then
			local leftWidth =
				TextService:GetTextSize(
					lineText:sub(
						1,
						bestCharacter
					),
					input.TextSize,
					input.Font,
					Vector2.new(
						100000,
						lineHeight
					)
				).X

			local rightWidth =
				TextService:GetTextSize(
					lineText:sub(
						1,
						bestCharacter + 1
					),
					input.TextSize,
					input.Font,
					Vector2.new(
						100000,
						lineHeight
					)
				).X

			if localX
				>= (
					leftWidth
						+ rightWidth
				) * 0.5
			then
				bestCharacter += 1
			end
		end

		return math.clamp(
			lineStart
				+ bestCharacter,
			1,
			#input.Text + 1
		)
	end

	-- MouseCapture sits above the transparent TextBox, so Potassium
	-- performs both caret placement and drag-selection itself.
	mouseCapture.InputBegan:Connect(function(
		inputObject
	)
		if inputObject.UserInputType
			~= Enum.UserInputType.MouseButton1
		then
			return
		end

		local clickPosition =
			Vector2.new(
				inputObject.Position.X,
				inputObject.Position.Y
			)

		manualMousePlacementPending = true
		preferredVerticalColumn = nil
		clearCursorGuard()

		local cursorPosition =
			getCursorPositionFromMouse(
				clickPosition
			)

		if not input:IsFocused() then
			input:CaptureFocus()
		end

		mouseSelectingText = true
		mouseSelectionAnchor =
			cursorPosition

		logicalCursorPosition =
			cursorPosition

		setSelectionInternally(
			cursorPosition,
			cursorPosition
		)

		manualMousePlacementPending = false

		clearSelectionVisuals()
		clearAutocomplete()

		resetCursorBlink()
		updateEditorCursor()
		updateBracketMatching()
	end)

	UserInputService.InputChanged:Connect(function(
		inputObject
	)
		if not mouseSelectingText
			or inputObject.UserInputType
			~= Enum.UserInputType.MouseMovement
		then
			return
		end

		if not input:IsFocused()
			or not mouseSelectionAnchor
		then
			return
		end

		local mousePosition =
			Vector2.new(
				inputObject.Position.X,
				inputObject.Position.Y
			)

		local cursorPosition =
			getCursorPositionFromMouse(
				mousePosition
			)

		clearCursorGuard()

		setSelectionInternally(
			mouseSelectionAnchor,
			cursorPosition
		)

		resetCursorBlink()
		updateSelectionVisuals()
		updateEditorCursor()

		task.defer(function()
			if input:IsFocused() then
				ensureCursorVisible()
			end
		end)
	end)

	UserInputService.InputEnded:Connect(function(
		inputObject
	)
		if inputObject.UserInputType
			~= Enum.UserInputType.MouseButton1
		then
			return
		end

		if not mouseSelectingText then
			return
		end

		mouseSelectingText = false
		mouseSelectionAnchor = nil

		logicalCursorPosition =
			math.max(
				1,
				input.CursorPosition
			)

		updateSelectionVisuals()
		updateEditorCursor()
		updateBracketMatching()
	end)

	input:GetPropertyChangedSignal(
		"CursorPosition"
	):Connect(function()

		if settingCursorInternally then
			return
		end

		local actualCursor =
			math.max(
				1,
				input.CursorPosition
			)

		if mouseSelectingText then
			logicalCursorPosition =
				actualCursor

			updateSelectionVisuals()
			updateEditorCursor()
			return
		end

		-- CaptureFocus may briefly try to choose its own caret. Ignore that
		-- while a custom mouse placement is being installed.
		if manualMousePlacementPending then
			if actualCursor
				~= logicalCursorPosition
			then
				setCursorInternally(
					logicalCursorPosition
				)
			end

			return
		end

		-- Roblox can move the TextBox caret before ContextActionService's
		-- Up/Down callback runs. Detect the physical key state here and
		-- reject that native movement before it can replace our logical
		-- cursor position.
		local nativeVerticalKeyDown =
			UserInputService:IsKeyDown(
				Enum.KeyCode.Up
			)
			or UserInputService:IsKeyDown(
				Enum.KeyCode.Down
			)

		if nativeVerticalKeyDown
			and not settingCursorInternally
		then
			local expected =
				guardedCursorPosition
				or logicalCursorPosition

			if expected
				and actualCursor ~= expected
			then
				setCursorInternally(
					expected
				)
			end

			return
		end

		-- During custom mouse/Up/Down movement the native TextBox is not
		-- allowed to replace the logical cursor with its own large jump.
		if isCursorGuardActive()
			and guardedCursorPosition
			and actualCursor
			~= guardedCursorPosition
		then
			setCursorInternally(
				guardedCursorPosition
			)

			return
		end

		-- This is a legitimate native cursor change such as Left/Right,
		-- Home/End, typing, deletion, etc.
		logicalCursorPosition =
			actualCursor

		resetCursorBlink()

		task.defer(function()
			if input:IsFocused() then
				updateEditorCursor()
				ensureCursorVisible()
			end
		end)

		updateBracketMatching()

		if Features.Autocomplete
			and input:IsFocused()
		then
			task.defer(function()
				if input:IsFocused() then
					showAutocomplete()
				end
			end)
		end
	end)

	-- ============================================================
	-- [47] TEXTBOX FOCUS EVENTS
	-- ============================================================

	input:GetPropertyChangedSignal(
		"SelectionStart"
	):Connect(function()
		if settingCursorInternally then
			return
		end

		updateSelectionVisuals()
	end)

	input.Focused:Connect(
		function()
			IDEINFOCUS()

			logicalCursorPosition =
				math.max(
					1,
					input.CursorPosition
				)

			resetCursorBlink()
			updateBracketMatching()

			if Features.Autocomplete then
				showAutocomplete()
			end
		end
	)

	input.FocusLost:Connect(
		function()
			verticalRepeatToken += 1
			clearCursorGuard()
			preferredVerticalColumn = nil

			editorCursor.Visible = false

			clearAutocomplete()
			removeBracketOverlay()
		end
	)

	-- ============================================================
	-- [48] FONT / TEXT SIZE WATCHERS
	-- ============================================================

	local function refreshTextMetrics()
		cachedMeasuredLineHeight = nil
		invalidateFoldingCache()
		invalidateHorizontalWidthCache()

		updateEditorLayout()
		updateDisplay()
		rebuildGutter()
		updateErrorUnderlines()
		updateBracketMatching()
		updateEditorCursor()
	end

	input:GetPropertyChangedSignal("TextSize"):Connect(
		refreshTextMetrics
	)

	input:GetPropertyChangedSignal("LineHeight"):Connect(
		refreshTextMetrics
	)

	-- Viewport refresh bookkeeping is owned by IDEMinor.

	-- ============================================================
	-- [50] INITIALIZATION
	-- ============================================================

	rebuildDynamicSymbols(
		input.Text
	)

	currentErrors =
		findErrors(
			input.Text
		)

	lastText =
		input.Text

	updateEditorLayout()
	updateDisplay()
	rebuildGutter()
	updateErrorUnderlines()
	updateBracketMatching()
	WorkspaceController:RefreshFileSidebar()

	print(
		"[Potassium IDE] Initialized successfully."
	)
end
