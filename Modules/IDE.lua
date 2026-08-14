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

	-- ============================================================
	-- SERVICES
	-- ============================================================

	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local TextService = game:GetService("TextService")
	local ContextActionService = game:GetService("ContextActionService")

	-- ============================================================
	-- ROOT
	-- ============================================================

	local frame = MainFrame

	if not frame then
		error("[Potassium IDE] script.Parent is missing.")
	end

	local CodingHolder = frame:WaitForChild("CodingHolder")

	-- ============================================================
	-- CONFIGURATION
	-- ============================================================

	local MIN_WIDTH = 400
	local MIN_HEIGHT = 250

	local MAX_WIDTH = 1400
	local MAX_HEIGHT = 900

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
	-- OVERLAPPING
	-- ============================================================

	local function IDEINFOCUS()
		if Console_2.ZIndex == 5 then
			Console_2.ZIndex = 4
		end
		MainFrame.ZIndex = 5
	end

	local function CONSOLEINFOCUS()
		if MainFrame.ZIndex == 5 then
			MainFrame.ZIndex = 4
		end
		Console_2.ZIndex = 5
	end

	MainFrame.MouseButton1Down:Connect(function()
		IDEINFOCUS()
	end)

	Console_2.MouseButton1Down:Connect(function()
		CONSOLEINFOCUS()
	end)

	-- ============================================================
	-- EDITOR HIERARCHY
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
	-- EDITOR ELEMENTS
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
	-- Z INDEX
	-- ============================================================

	EditorScroll.ZIndex = 1
	EditorContent.ZIndex = 1

	gutter.ZIndex = 2
	hlBar.ZIndex = 3
	display.ZIndex = 4
	input.ZIndex = 5

	-- ============================================================
	-- UI SETUP
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
	-- MOUSE CAPTURE LAYER
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
	-- GUTTER LAYOUT
	-- ============================================================

	-- Gutter is manually positioned/virtualized. A UIListLayout would
	-- collapse virtualized line buttons toward the top of the gutter.
	local gutterLayout = gutter:FindFirstChildOfClass("UIListLayout")
	if gutterLayout then
		gutterLayout:Destroy()
	end

	-- ============================================================
	-- COLORS
	-- ============================================================

	local COLORS = {
		keyword = "#569CD6",
		string = "#CE9178",
		comment = "#6A9955",
		number = "#B5CEA8",
		functionName = "#DCDCAA",
		normal = "#D4D4D4",
		func = "rgb(110, 173, 255)",
		rblx = "rgb(198, 174, 57)"
	}

	--Color3.fromRGB(198, 174, 57)
	-- ============================================================
	-- KEYWORDS
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
	-- AUTOCOMPLETE
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
	-- STATE
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

	local selectedCompletion = 1

	local highlightedLine = 1
	local cursorNeedsUpdate = false

	local MAX_COMPLETIONS = 8
	local COMPLETION_HEIGHT = 22
	local COMPLETION_WIDTH = 220

	-- ============================================================
	-- UTILITY
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
	-- FOLDING
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
	-- FAST FOLDING CACHE
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
	-- KEEP INPUT AND DISPLAY PERFECTLY ALIGNED
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
	-- CUSTOM EDITOR CURSOR
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
	-- KEEP THE CARET INSIDE THE SCROLLING VIEWPORT
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
	-- SYNTAX HIGHLIGHTING
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
	-- FORWARD DECLARATIONS
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
	-- HORIZONTAL CONTENT WIDTH
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
	-- EDITOR LAYOUT
	-- ============================================================

	updateEditorLayout = function()
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
	-- CHUNKED DISPLAY
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
	-- ERROR DETECTION
	-- ============================================================

	local function findErrors(code)
		local errors = {}

		local bracketStack = {}

		local brackets = {
			["("] = ")",
			["["] = "]",
			["{"] = "}",
		}

		local closing = {
			[")"] = true,
			["]"] = true,
			["}"] = true,
		}

		local lineNumber = 1
		local position = 1

		while position <= #code do
			local character = code:sub(position, position)

			if character == "\n" then
				lineNumber += 1
				position += 1

			elseif code:sub(position, position + 1) == "--" then
				local newline = code:find(
					"\n",
					position,
					true
				)

				if newline then
					position = newline
				else
					break
				end

			elseif character == "\"" or character == "'" then
				local quote = character
				local startLine = lineNumber
				local closed = false

				position += 1

				while position <= #code do
					local current = code:sub(position, position)

					if current == "\\" then
						position += 2

					elseif current == quote then
						closed = true
						position += 1
						break

					elseif current == "\n" then
						break

					else
						position += 1
					end
				end

				if not closed then
					table.insert(errors, {
						line = startLine,
						message = "Unclosed string",
					})
				end

			elseif brackets[character] then
				table.insert(
					bracketStack,
					{
						char = character,
						expected = brackets[character],
						line = lineNumber,
					}
				)

				position += 1

			elseif closing[character] then
				local top = bracketStack[#bracketStack]

				if not top then
					table.insert(errors, {
						line = lineNumber,
						message =
							"Unexpected '"
							.. character
							.. "'",
					})

				elseif top.expected ~= character then
					table.insert(errors, {
						line = lineNumber,
						message =
							"Expected '"
							.. top.expected
							.. "'",
					})

					table.remove(bracketStack)

				else
					table.remove(bracketStack)
				end

				position += 1

			else
				position += 1
			end
		end

		for index = #bracketStack, 1, -1 do
			local item = bracketStack[index]

			table.insert(errors, {
				line = item.line,
				message =
					"Expected '"
					.. item.expected
					.. "'",
			})
		end

		-- ========================================================
		-- BLOCK CHECK
		-- ========================================================

		local blockStack = {}
		local lines = getLines(code)

		for index, rawLine in ipairs(lines) do
			local line = trim(stripComment(rawLine))

			if line == "" then
				continue
			end

			if line == "repeat" then
				table.insert(
					blockStack,
					{
						type = "repeat",
						line = index,
					}
				)

			elseif line:match(
				"^if%s+.+%s+then%s*$"
				) then
				table.insert(
					blockStack,
					{
						type = "if",
						line = index,
					}
				)

			elseif line:match(
				"^for%s+.+%s+do%s*$"
				) then
				table.insert(
					blockStack,
					{
						type = "for",
						line = index,
					}
				)

			elseif line:match(
				"^while%s+.+%s+do%s*$"
				) then
				table.insert(
					blockStack,
					{
						type = "while",
						line = index,
					}
				)

			elseif line:match("^function%s+")
				or line:match("^local%s+function%s+")
				or line:match("^function%s*%(")
			then
				table.insert(
					blockStack,
					{
						type = "function",
						line = index,
					}
				)

			elseif line == "do" then
				table.insert(
					blockStack,
					{
						type = "do",
						line = index,
					}
				)

			elseif line:match("^until%s+") then
				local top = blockStack[#blockStack]

				if not top
					or top.type ~= "repeat"
				then
					table.insert(errors, {
						line = index,
						message = "Unexpected 'until'",
					})
				else
					table.remove(blockStack)
				end

			elseif line == "end" then
				local top = blockStack[#blockStack]

				if not top then
					table.insert(errors, {
						line = index,
						message = "Unexpected 'end'",
					})
				else
					table.remove(blockStack)
				end
			end
		end

		for index = #blockStack, 1, -1 do
			local block = blockStack[index]

			if block.type ~= "repeat" then
				table.insert(errors, {
					line = block.line,
					message = "Expected 'end'",
				})
			end
		end

		return errors
	end

	-- ============================================================
	-- ERROR UNDERLINES
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
	-- BRACKET MATCHING
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
	-- GUTTER
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
	-- SMART ENTER
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
	-- AUTOCOMPLETE
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

	local function getCurrentWord()
		local line = getLineAtCursor()

		return line:match(
			"([%a_][%w_]*)$"
		) or ""
	end

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

				button.TextColor3 =
					Color3.fromRGB(
						255,
						255,
						255
					)
			else
				button.BackgroundTransparency = 1

				button.TextColor3 =
					Color3.fromRGB(
						220,
						220,
						220
					)
			end
		end
	end

	local AUTOCOMPLETE_X_OFFSET = 4
	local AUTOCOMPLETE_Y_OFFSET = 8

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

	local function insertCompletion()
		if not completionPopup.Visible then
			return false
		end

		local word =
			completionWords[selectedCompletion]

		if not word then
			return false
		end

		local cursor = input.CursorPosition
		local current = getCurrentWord()

		local wordStart =
			cursor - #current

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

	showAutocomplete = function()
		if not Features.Autocomplete then
			clearAutocomplete()
			return
		end

		if not input:IsFocused() then
			clearAutocomplete()
			return
		end

		local prefix = getCurrentWord()

		if prefix == "" then
			clearAutocomplete()
			return
		end

		clearAutocomplete()

		for _, word in ipairs(COMPLETIONS) do
			if word:sub(
				1,
				#prefix
				):lower()
					== prefix:lower()
					and word:lower()
					~= prefix:lower()
			then
				table.insert(
					completionWords,
					word
				)

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

		for index, word in ipairs(completionWords) do
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

			button.TextColor3 =
				Color3.fromRGB(
					220,
					220,
					220
				)

			button.TextSize = 14
			button.Font = Enum.Font.Code

			button.TextXAlignment =
				Enum.TextXAlignment.Left

			button.LayoutOrder = index

			button.AutoButtonColor = false
			button.ZIndex = 21

			local padding =
				Instance.new("UIPadding")

			padding.PaddingLeft =
				UDim.new(0, 8)

			padding.Parent = button
			button.Parent = completionPopup

			button.MouseEnter:Connect(
				function()
					selectedCompletion = index
					updateCompletionSelection()
				end
			)

			button.MouseButton1Click:Connect(
				function()
					selectedCompletion = index
					insertCompletion()
				end
			)

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

		task.defer(positionAutocomplete)
	end

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
	-- STABLE CURSOR / VERTICAL NAVIGATION
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
	-- BRACKET AUTO CLOSE
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

	MakeDraggable(frame, frame)

	-- ============================================================
	-- RESIZING
	-- ============================================================

	local resizing = false
	local resizeStartMouse = nil
	local resizeStartSize = nil

	local resizeHandle =
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

	resizeHandle.BackgroundTransparency = 0.7
	resizeHandle.BorderSizePixel = 0

	resizeHandle.Text = ""
	resizeHandle.AutoButtonColor = false

	resizeHandle.ZIndex = 100
	resizeHandle.Parent = frame

	resizeHandle.MouseButton1Down:Connect(
		function()
			resizing = true

			resizeStartMouse =
				UserInputService:GetMouseLocation()

			resizeStartSize =
				Vector2.new(
					frame.AbsoluteSize.X,
					frame.AbsoluteSize.Y
				)
		end
	)

	UserInputService.InputChanged:Connect(
		function(inputObject)
			if not resizing then
				return
			end

			if inputObject.UserInputType
				~= Enum.UserInputType.MouseMovement
			then
				return
			end

			local currentMouse =
				UserInputService:GetMouseLocation()

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

			task.defer(
				function()
					if not frame.Parent then
						return
					end

					updateEditorLayout()
					rebuildGutter()
					updateErrorUnderlines()
					updateBracketMatching()
					positionAutocomplete()
				end
			)
		end
	)

	UserInputService.InputEnded:Connect(
		function(inputObject)
			if inputObject.UserInputType
				== Enum.UserInputType.MouseButton1
			then
				resizing = false
			end
		end
	)

	-- ============================================================
	-- SETTINGS / BUTTONS
	-- ============================================================

	local ButtonsFrame =
		CodingHolder:FindFirstChild(
			"Settings"
		)

	local SettingsButton = nil
	local SaveFile = nil
	local OpenFile = nil
	local Clear = nil
	local Execute = nil
	local Console = nil

	if ButtonsFrame then
		SettingsButton =
			ButtonsFrame:FindFirstChild("Settings")

		SaveFile =
			ButtonsFrame:FindFirstChild("SaveFile")

		OpenFile =
			ButtonsFrame:FindFirstChild("OpenFile")

		Clear =
			ButtonsFrame:FindFirstChild("Clear")

		Execute =
			ButtonsFrame:FindFirstChild("Execute")

		Console =
			ButtonsFrame:FindFirstChild("Console")
	end

	-- ============================================================
	-- EXECUTE
	-- ============================================================

	if Execute then
		Execute.MouseButton1Click:Connect(
			function()

				local success, result =
					pcall(
						function()
							return loadstring(
								input.Text
							)()
						end
					)

				if not success then
					warn(
						"[Potassium IDE] Execution error:",
						result
					)
				else
					print(
						"[Potassium IDE] Execution result:",
						result
					)
				end
			end
		)
	end

	-- ============================================================
	-- CLEAR
	-- ============================================================

	if Clear then
		Clear.MouseButton1Click:Connect(
			function()
				input.Text = ""
			end
		)
	end

	-- ============================================================
	-- CONSOLE
	-- ============================================================

	if Console then
		Console.MouseButton1Click:Connect(
			function()

				if Console_2 then
					Console_2.Visible = true
				else
					warn(
						"[Potassium IDE] Console UI not found."
					)
				end
			end
		)
	end

	-- ============================================================
	-- SETTINGS
	-- ============================================================

	local SettingsFrame =
		frame:FindFirstChild("Settings")

	if SettingsFrame then
		SettingsFrame.Visible = false
	end

	if SettingsButton
		and SettingsFrame
	then
		SettingsButton.MouseButton1Click:Connect(
			function()
				local settingsContainer =
					ButtonsFrame.Parent

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

				SettingsFrame.Visible = true

				TweenService:Create(
					SettingsFrame,
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
		)
	end

	-- ============================================================
	-- FEATURE SETTINGS
	-- ============================================================

	local featureNames = {
		{
			key = "SmartEnter",
			name = "Smart Enter",
			default = false,
		},

		{
			key = "BracketMatching",
			name = "Brackets",
			default = true,
		},

		{
			key = "ErrorUnderline",
			name = "Errors",
			default = true,
		},

		{
			key = "CodeFolding",
			name = "Folding",
			default = true,
		},

		{
			key = "Autocomplete",
			name = "Autocomplete",
			default = true,
		},

		{
			key = "BracketAutoClose",
			name = "Auto Close",
			default = true,
		},
	}

	if SettingsFrame then
		local Templates =
			SettingsFrame:FindFirstChild(
				"Templates"
			)

		local Template = nil

		if Templates then
			Template =
				Templates:FindFirstChild(
					"Template"
				)
		end

		local Holder =
			SettingsFrame:FindFirstChild(
				"Holder"
			)

		if Template
			and Holder
		then
			for _, feature in ipairs(featureNames) do
				Features[feature.key] =
					feature.default == true

				local Button =
					Template:Clone()

				Button.Name =
					feature.key

				local title =
					Button:FindFirstChild(
						"Title"
					)

				if title
					and title:IsA("TextLabel")
				then
					title.Text =
						feature.name
				end

				Button.Parent = Holder
				Button.Visible = true

				Button:SetAttribute(
					"Key",
					feature.key
				)

				Button:SetAttribute(
					"Enabled",
					Features[feature.key]
				)

				local imageLabel =
					Button:FindFirstChild(
						"ImageLabel"
					)

				local function updateButton()
					if not imageLabel then
						return
					end

					imageLabel.BackgroundColor3 =
						Features[feature.key]
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

				if Button:IsA("GuiButton") then
					Button.MouseButton1Click:Connect(
						function()
							Features[feature.key] =
								not Features[
							feature.key
							]

							local enabled =
								Features[
							feature.key
							]

							Button:SetAttribute(
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

							updateDisplay()
							rebuildGutter()

							currentErrors =
								findErrors(
									input.Text
								)

							updateErrorUnderlines()
							updateBracketMatching()

							if enabled
								and feature.key
								== "Autocomplete"
							then
								showAutocomplete()

							elseif feature.key
								== "Autocomplete"
							then
								clearAutocomplete()
							end
						end
					)
				end
			end
		end
	end

	-- ============================================================
	-- CLOSE SETTINGS
	-- ============================================================

	if SettingsFrame then
		local close =
			SettingsFrame:FindFirstChild(
				"Close"
			)

		if close
			and close:IsA("GuiButton")
		then
			close.MouseButton1Click:Connect(
				function()
					TweenService:Create(
						SettingsFrame,
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
							SettingsFrame.Visible =
								false
						end
					)

					if ButtonsFrame then
						ButtonsFrame.Parent.Visible =
							true

						TweenService:Create(
							ButtonsFrame.Parent,
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
			)
		end
	end

	-- ============================================================
	-- TEXT CHANGED
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

	input:GetPropertyChangedSignal("Text"):Connect(function()
		invalidateFoldingCache()
		invalidateHorizontalWidthCache()

		if updatingText then
			return
		end

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
	-- KEYBOARD
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
	-- CURSOR
	-- ============================================================

	local function getCursorPositionFromMouse(screenPosition)
		rebuildFoldingCache()

		local lineHeight = getLineHeight()

		-- Convert the screen click into DOCUMENT coordinates explicitly.
		--
		-- CanvasPosition is the amount by which the scrolling canvas has
		-- moved. Using it directly avoids depending on the AbsolutePosition
		-- behaviour of a huge TextBox inside a ScrollingFrame.
		local viewportX =
			screenPosition.X
		- EditorScroll.AbsolutePosition.X

		local viewportY =
			screenPosition.Y
		- EditorScroll.AbsolutePosition.Y

		local documentX =
			EditorScroll.CanvasPosition.X
			+ viewportX

		local documentY =
			EditorScroll.CanvasPosition.Y
			+ viewportY

		local renderedLine =
			math.floor(
				math.max(0, documentY)
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

		-- Gutter occupies the first 55 document pixels.
		local localX =
			math.max(
				0,
				documentX - 55
			)

		-- Binary-search the nearest insertion point.
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
				> (leftWidth + rightWidth)
				* 0.5
			then
				bestCharacter += 1
			end
		end

		return math.clamp(
			lineStart + bestCharacter,
			1,
			#input.Text + 1
		)
	end

	-- The transparent MouseCapture sits above Input, so Roblox never gets
	-- a native TextBox mouse hit-test. Every click is translated manually.
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

		-- Block any CursorPosition changes caused by CaptureFocus until our
		-- manually calculated caret has been installed.
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

		logicalCursorPosition =
			cursorPosition

		guardCursor(
			cursorPosition,
			0.20
		)

		manualMousePlacementPending = false

		resetCursorBlink()
		updateEditorCursor()
		updateBracketMatching()

		task.defer(function()
			if input:IsFocused() then
				updateEditorCursor()

				if completionPopup.Visible then
					positionAutocomplete()
				end
			end
		end)
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
	-- FOCUS
	-- ============================================================

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
	-- FONT / SIZE CHANGES
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

	-- ============================================================
	-- SCROLL / RESIZE - OPTIMIZED
	-- ============================================================

	local scrollRefreshPending = false

	local lastDisplayFirstLine = -1
	local lastDisplayLastLine = -1

	local lastGutterFirstLine = -1
	local lastGutterLastLine = -1

	local lastErrorFirstLine = -1
	local lastErrorLastLine = -1

	local function refreshViewportIfNeeded()
		if not frame.Parent then
			return
		end

		rebuildFoldingCache()

		-- ========================================================
		-- DISPLAY
		-- ========================================================

		local displayFirst, displayLast =
			getViewportVisibleRange(
				DISPLAY_BUFFER_LINES
			)

		if displayFirst ~= lastDisplayFirstLine
			or displayLast ~= lastDisplayLastLine
		then
			lastDisplayFirstLine =
				displayFirst

			lastDisplayLastLine =
				displayLast

			updateDisplay()
		end

		-- ========================================================
		-- GUTTER
		-- ========================================================

		local gutterFirst, gutterLast =
			getViewportVisibleRange(
				GUTTER_BUFFER_LINES
			)

		if gutterFirst ~= lastGutterFirstLine
			or gutterLast ~= lastGutterLastLine
		then
			lastGutterFirstLine =
				gutterFirst

			lastGutterLastLine =
				gutterLast

			rebuildGutter()
		end

		-- ========================================================
		-- ERRORS
		-- ========================================================

		local errorFirst, errorLast =
			getViewportVisibleRange(5)

		if errorFirst ~= lastErrorFirstLine
			or errorLast ~= lastErrorLastLine
		then
			lastErrorFirstLine =
				errorFirst

			lastErrorLastLine =
				errorLast

			updateErrorUnderlines()
		end

		-- These are very cheap and should follow smoothly.
		if completionPopup.Visible then
			positionAutocomplete()
		end

		if input:IsFocused() then
			updateEditorCursor()
		end
	end

	local function queueViewportRefresh()
		if scrollRefreshPending then
			return
		end

		scrollRefreshPending = true

		-- Run once on the next rendered frame.
		RunService.RenderStepped:Once(function()
			scrollRefreshPending = false

			refreshViewportIfNeeded()
		end)
	end

	EditorScroll:GetPropertyChangedSignal(
		"AbsoluteSize"
	):Connect(function()

		updateEditorLayout()

		-- Force all viewport systems to refresh.
		lastDisplayFirstLine = -1
		lastDisplayLastLine = -1

		lastGutterFirstLine = -1
		lastGutterLastLine = -1

		lastErrorFirstLine = -1
		lastErrorLastLine = -1

		queueViewportRefresh()
	end)

	EditorScroll:GetPropertyChangedSignal(
		"CanvasPosition"
	):Connect(function()

		queueViewportRefresh()

	end)

	-- ============================================================
	-- INITIALIZATION
	-- ============================================================

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

	print(
		"[Potassium IDE] Initialized successfully."
	)
end
