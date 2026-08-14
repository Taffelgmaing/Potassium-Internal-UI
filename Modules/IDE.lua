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
	
	MainFrame.MouseButton1Down:Connect(function()
		if Console_2.ZIndex == 5 then
			Console_2.ZIndex = 4
		end
		MainFrame.ZIndex = 5
	end)
	
	Console_2.MouseButton1Down:Connect(function()
		if MainFrame.ZIndex == 5 then
			MainFrame.ZIndex = 4
		end
		Console_2.ZIndex = 5
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

		EditorScroll.ScrollBarThickness = 6
		EditorScroll.ScrollBarImageTransparency = 0.35

		EditorScroll.ScrollingDirection = Enum.ScrollingDirection.Y
		EditorScroll.AutomaticCanvasSize = Enum.AutomaticSize.None

		EditorScroll.ClipsDescendants = true
		EditorScroll.ZIndex = 1

		EditorScroll.Parent = CodingHolder
	end

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

	hlBar.Visible = false

	-- ============================================================
	-- GUTTER LAYOUT
	-- ============================================================

	local gutterLayout = gutter:FindFirstChildOfClass("UIListLayout")

	if not gutterLayout then
		gutterLayout = Instance.new("UIListLayout")

		gutterLayout.SortOrder = Enum.SortOrder.LayoutOrder
		gutterLayout.Padding = UDim.new(0, 0)

		gutterLayout.Parent = gutter
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

	local function getLineHeight()
		local lineHeight = input.LineHeight

		if typeof(lineHeight) ~= "number" then
			lineHeight = 1
		end

		local textSize = input.TextSize

		if typeof(textSize) ~= "number" then
			textSize = 14
		end

		return math.max(1, textSize * lineHeight)
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

	local function getBlockEnd(lines, startLine)
		if not lines[startLine] then
			return nil
		end

		if not isBlockStart(lines[startLine]) then
			return nil
		end

		local depth = 0

		for i = startLine, #lines do
			local line = trim(stripComment(lines[i]))

			if isBlockStart(line) then
				depth += 1
			end

			local ending = isBlockEnd(line)

			if ending then
				depth -= 1

				if depth == 0 then
					return i
				end
			end
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

	local function getFoldedRanges()
		local lines = getLines(input.Text)
		local ranges = {}

		for startLine = 1, #lines do
			if isBlockStart(lines[startLine]) then
				local endLine = getBlockEnd(lines, startLine)

				if endLine and endLine > startLine then
					local key = getFoldKey(startLine, endLine, lines)

					if foldedBlocks[key] then
						table.insert(ranges, {
							startLine = startLine,
							endLine = endLine,
							key = key,
						})
					end
				end
			end
		end

		return ranges
	end

	local function isLineHidden(lineNumber)
		if not Features.CodeFolding then
			return false
		end

		for _, range in ipairs(getFoldedRanges()) do
			if lineNumber > range.startLine
				and lineNumber <= range.endLine
			then
				return true
			end
		end

		return false
	end

	local function isLineFolded(lineNumber)
		local lines = getLines(input.Text)

		local endLine = getBlockEnd(lines, lineNumber)

		if not endLine or endLine <= lineNumber then
			return false
		end

		local key = getFoldKey(lineNumber, endLine, lines)

		return foldedBlocks[key] == true
	end
	
	-- ============================================================
	-- KEEP INPUT AND DISPLAY PERFECTLY ALIGNED
	-- ============================================================

	local function syncInputAndDisplay()
		-- Same exact geometry
		input.Position = display.Position
		input.Size = display.Size

		-- Same exact text rendering
		input.Font = display.Font
		input.TextSize = display.TextSize
		input.LineHeight = display.LineHeight

		input.TextXAlignment = display.TextXAlignment
		input.TextYAlignment = display.TextYAlignment

		input.TextWrapped = display.TextWrapped

		-- Input remains invisible
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

		editorCursor.BackgroundColor3 =
			Color3.fromRGB(220, 220, 220)

		editorCursor.BorderSizePixel = 0

		editorCursor.Size = UDim2.fromOffset(
			4,
			getLineHeight()
		)

		editorCursor.Visible = false

		-- Above the text.
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

		local text = input.Text

		-- Find current line.
		local lineNumber = 1

		for i = 1, cursorPosition - 1 do
			if text:sub(i, i) == "\n" then
				lineNumber += 1
			end
		end

		-- Start of current line.
		local lineStart = getLineStart(
			text,
			lineNumber
		)

		-- Text before cursor on this line.
		local textBeforeCursor = ""

		if cursorPosition > lineStart then
			textBeforeCursor = text:sub(
				lineStart,
				cursorPosition - 1
			)
		end

		-- IMPORTANT:
		-- Use the exact same font/text size as Display.
		local textWidth = TextService:GetTextSize(
			textBeforeCursor,
			display.TextSize,
			display.Font,
			Vector2.new(
				100000,
				getLineHeight()
			)
		).X

		-- Find which rendered line this is.
		local visibleLine = 0

		for i = 1, lineNumber do
			if not isLineHidden(i) then
				visibleLine += 1
			end
		end

		local lineHeight = getLineHeight()

		-- ========================================================
		-- USE DISPLAY'S REAL POSITION
		-- ========================================================

		local displayAbsoluteX =
			display.AbsolutePosition.X

		local displayAbsoluteY =
			display.AbsolutePosition.Y

		local contentAbsoluteX =
			EditorContent.AbsolutePosition.X

		local contentAbsoluteY =
			EditorContent.AbsolutePosition.Y

		local x =
			(displayAbsoluteX - contentAbsoluteX)
			+ textWidth

		local y =
			(displayAbsoluteY - contentAbsoluteY)
			+ ((visibleLine - 1) * lineHeight)

		return x, y, lineHeight
	end

	local function updateEditorCursor()
		if not input:IsFocused() then
			editorCursor.Visible = false
			return
		end

		-- Wait until Display has finished rebuilding.
		if cursorNeedsUpdate then
			return
		end

		local x, y, lineHeight =
			getCursorDisplayPosition()

		if not x then
			editorCursor.Visible = false
			return
		end

		editorCursor.Visible = true

		editorCursor.Size = UDim2.fromOffset(
			2,
			lineHeight
		)

		editorCursor.Position =
			UDim2.fromOffset(
				math.round(x + CURSOR_OFFSET_X),
				math.round(y + CURSOR_OFFSET_Y)
			)
	end

	local function resetCursorBlink()
		cursorBlinkTimer = 0
		cursorBlinkVisible = true

		editorCursor.BackgroundTransparency = 0

		updateEditorCursor()
	end

	-- ============================================================
	-- CURSOR RENDER
	-- ============================================================
	
	RunService.RenderStepped:Connect(
		function(deltaTime)

			if not input:IsFocused() then
				editorCursor.Visible = false
				return
			end

			-- Only update position when the editor is stable.
			if not cursorNeedsUpdate then
				updateEditorCursor()
			end

			cursorBlinkTimer += deltaTime

			if cursorBlinkTimer >= CURSOR_BLINK_TIME then
				cursorBlinkTimer = 0

				cursorBlinkVisible =
					not cursorBlinkVisible

				editorCursor.BackgroundTransparency =
					cursorBlinkVisible and 0 or 1
			end
		end
	)
	
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
	-- EDITOR LAYOUT
	-- ============================================================

	updateEditorLayout = function()
		-- IMPORTANT:
		-- Do NOT create an AbsoluteSize connection here.
		--
		-- The original script created a new connection every time
		-- updateEditorLayout() ran.
		--
		-- Also, editorWidth/editorHeight were never defined.
		--
		-- We get the dimensions directly from EditorScroll.

		local absoluteSize = EditorScroll.AbsoluteSize

		local editorWidth = math.max(
			1,
			absoluteSize.X
		)

		local editorHeight = math.max(
			1,
			absoluteSize.Y
		)

		local lines = getLines(input.Text)
		local lineHeight = getLineHeight()

		local contentHeight = math.max(
			editorHeight,
			#lines * lineHeight + 10
		)

		EditorContent.Size = UDim2.fromOffset(
			editorWidth,
			contentHeight
		)

		EditorScroll.CanvasSize = UDim2.fromOffset(
			editorWidth,
			contentHeight
		)

		local codeWidth = math.max(
			editorWidth - 55,
			1
		)

		--input.Position = UDim2.fromOffset(55, 0)

		--input.Size = UDim2.fromOffset(
		--	codeWidth,
		--	contentHeight
		--)

		--display.Position = UDim2.fromOffset(55, 0)

		--display.Size = UDim2.fromOffset(
		--	codeWidth,
		--	contentHeight
		--)

		--gutter.Position = UDim2.fromOffset(0, 0)

		--gutter.Size = UDim2.fromOffset(
		--	55,
		--	contentHeight
		--)

		hlBar.Size = UDim2.fromOffset(
			codeWidth,
			lineHeight
		)

		for _, bar in ipairs(errorBars) do
			if bar and bar.Parent then
				bar.Size = UDim2.fromOffset(
					codeWidth,
					2
				)
			end
		end
	end

	-- ============================================================
	-- DISPLAY
	-- ============================================================

	updateDisplay = function()
		local lines = getLines(input.Text)
		local visibleLines = {}

		for lineNumber, line in ipairs(lines) do
			if not isLineHidden(lineNumber) then
				table.insert(visibleLines, line)
			end
		end

		display.Text = highlight(
			table.concat(
				visibleLines,
				"\n"
			)
		)

		updateEditorLayout()
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
				bar:Destroy()
			end
		end

		table.clear(errorBars)
	end

	updateErrorUnderlines = function()
		clearErrorBars()

		if not Features.ErrorUnderline then
			return
		end

		local codeWidth = math.max(
			EditorContent.AbsoluteSize.X - 55,
			1
		)

		local lineHeight = getLineHeight()

		for _, err in ipairs(currentErrors) do
			local bar = Instance.new("Frame")

			bar.Name = "ErrorUnderline"
			bar.BorderSizePixel = 0

			bar.BackgroundColor3 = Color3.fromRGB(
				244,
				71,
				71
			)

			bar.Size = UDim2.fromOffset(
				codeWidth,
				2
			)

			bar.Position = UDim2.fromOffset(
				55,
				(err.line - 1)
					* lineHeight
					+ lineHeight
				- 2
			)

			bar.ZIndex = 6
			bar.Parent = EditorContent

			table.insert(
				errorBars,
				bar
			)
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

	local function isInsideStringOrComment(text, position)
		local quote = nil
		local i = 1

		while i < position do
			local character = text:sub(i, i)

			if not quote
				and text:sub(i, i + 1) == "--"
			then
				local newline = text:find(
					"\n",
					i,
					true
				)

				if not newline
					or newline >= position
				then
					return true
				end

				i = newline + 1
				continue
			end

			if quote then
				if character == "\\" then
					i += 2

				elseif character == quote then
					quote = nil
					i += 1

				else
					i += 1
				end

			else
				if character == "\""
					or character == "'"
				then
					quote = character
				end

				i += 1
			end
		end

		return quote ~= nil
	end

	local function findMatchingBracket(text, position)
		local pairs = {
			["("] = ")",
			["["] = "]",
			["{"] = "}",
		}

		local reversePairs = {
			[")"] = "(",
			["]"] = "[",
			["}"] = "{",
		}

		local character = text:sub(
			position,
			position
		)

		if isInsideStringOrComment(
			text,
			position
			) then
			return nil
		end

		if pairs[character] then
			local stack = 0
			local target = pairs[character]

			for i = position, #text do
				local current = text:sub(i, i)

				if isInsideStringOrComment(
					text,
					i
					) then
					continue
				end

				if current == character then
					stack += 1

				elseif current == target then
					stack -= 1

					if stack == 0 then
						return i
					end
				end
			end

		elseif reversePairs[character] then
			local stack = 0
			local target = reversePairs[character]

			for i = position, 1, -1 do
				local current = text:sub(i, i)

				if isInsideStringOrComment(
					text,
					i
					) then
					continue
				end

				if current == character then
					stack += 1

				elseif current == target then
					stack -= 1

					if stack == 0 then
						return i
					end
				end
			end
		end

		return nil
	end

	local function getCurrentBracketPosition()
		local cursor = input.CursorPosition

		if cursor < 1 then
			return nil
		end

		local position = cursor - 1

		if position >= 1 then
			local character = input.Text:sub(
				position,
				position
			)

			if character:match(
				"[%(%)%[%]{}]"
				) then
				return position
			end
		end

		if cursor <= #input.Text then
			local character = input.Text:sub(
				cursor,
				cursor
			)

			if character:match(
				"[%(%)%[%]{}]"
				) then
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

		local matching = findMatchingBracket(
			input.Text,
			position
		)

		if not matching then
			return
		end

		local line = 1

		for i = 1, matching - 1 do
			if input.Text:sub(i, i) == "\n" then
				line += 1
			end
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
			(line - 1) * getLineHeight()
		)

		bracketOverlay.ZIndex = 6

		bracketOverlay.Parent = EditorContent

		local stroke = Instance.new("UIStroke")

		stroke.Color = Color3.fromRGB(
			180,
			180,
			180
		)

		stroke.Transparency = 0.7
		stroke.Thickness = 1

		stroke.Parent = bracketOverlay
	end

	-- ============================================================
	-- GUTTER
	-- ============================================================

	local function clearGutter()
		for _, button in ipairs(gutterButtons) do
			if button and button.Parent then
				button:Destroy()
			end
		end

		table.clear(gutterButtons)
	end

	local function highlightLine(lineIndex)
		highlightedLine = math.max(
			1,
			lineIndex
		)

		local lineHeight = getLineHeight()

		hlBar.Visible = false

		hlBar.Position = UDim2.fromOffset(
			55,
			(highlightedLine - 1) * lineHeight
		)

		hlBar.Size = UDim2.fromOffset(
			math.max(
				EditorContent.AbsoluteSize.X - 55,
				1
			),
			lineHeight
		)

		hlBar.ZIndex = 3
	end

	rebuildGutter = function()
		clearGutter()

		local lines = getLines(input.Text)
		local lineHeight = getLineHeight()

		--gutter.Size = UDim2.fromOffset(
		--	55,
		--	math.max(
		--		EditorContent.AbsoluteSize.Y,
		--		1
		--	)
		--)

		for lineNumber = 1, #lines do
			if not isLineHidden(lineNumber) then
				local button = Instance.new("TextButton")

				button.Name = "Line" .. lineNumber

				button.Size = UDim2.fromOffset(
					55,
					lineHeight
				)

				button.BackgroundTransparency = 1
				button.BorderSizePixel = 0

				button.Font = display.Font
				button.TextSize = display.TextSize

				button.TextColor3 = Color3.fromRGB(
					133,
					133,
					133
				)

				button.TextXAlignment =
					Enum.TextXAlignment.Right

				button.TextYAlignment =
					Enum.TextYAlignment.Center

				button.LayoutOrder = lineNumber

				local foldable =
					Features.CodeFolding
					and isBlockStart(lines[lineNumber])
					and getBlockEnd(
						lines,
						lineNumber
					) ~= nil

				if foldable then
					if isLineFolded(lineNumber) then
						button.Text =
							"▶ " .. lineNumber
					else
						button.Text =
							"▼ " .. lineNumber
					end
				else
					button.Text =
						tostring(lineNumber)
				end

				button.Parent = gutter

				button.MouseButton1Click:Connect(
					function()
						if foldable then
							local endLine =
								getBlockEnd(
									lines,
									lineNumber
								)

							if endLine then
								local key =
									getFoldKey(
										lineNumber,
										endLine,
										lines
									)

								if foldedBlocks[key] then
									foldedBlocks[key] = nil
								else
									foldedBlocks[key] = true
								end

								updateDisplay()
								rebuildGutter()
							end
						else
							highlightLine(lineNumber)
						end
					end
				)

				table.insert(
					gutterButtons,
					button
				)
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

	local AUTOCOMPLETE_X_OFFSET = 0
	local AUTOCOMPLETE_Y_OFFSET = 12

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

		local lineNumber = 1

		for i = 1, cursor - 1 do
			if input.Text:sub(i, i) == "\n" then
				lineNumber += 1
			end
		end

		local lineHeight = getLineHeight()

		local localY =
			(lineNumber - 1)
			* lineHeight
			+ lineHeight
			+ AUTOCOMPLETE_Y_OFFSET

		local editorPosition =
			EditorContent.AbsolutePosition

		local framePosition =
			frame.AbsolutePosition

		local scrollY =
			EditorScroll.CanvasPosition.Y

		local x =
			editorPosition.X
		- framePosition.X
			+ AUTOCOMPLETE_X_OFFSET

		local y =
			editorPosition.Y
		- framePosition.Y
			+ localY
		- scrollY

		local popupHeight =
			completionPopup.AbsoluteSize.Y

		local frameHeight =
			frame.AbsoluteSize.Y

		if y + popupHeight > frameHeight then
			y =
				editorPosition.Y
			- framePosition.Y
				+ (lineNumber - 1)
				* lineHeight
			- popupHeight
			- AUTOCOMPLETE_Y_OFFSET
			- scrollY
		end

		y = math.max(0, y)

		completionPopup.Position =
			UDim2.fromOffset(x, y)
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

	input:GetPropertyChangedSignal("Text"):Connect(
		function()
			if updatingText then
				return
			end

			cursorNeedsUpdate = true

			local newText = input.Text
			local oldText = lastText

			-- ====================================================
			-- SMART ENTER
			-- ====================================================

			if performSmartEnter(
				oldText,
				newText
				) then
				updateDisplay()
				rebuildGutter()

				currentErrors =
					findErrors(
						input.Text
					)

				updateErrorUnderlines()
				updateBracketMatching()

				clearAutocomplete()

				return
			end
			
			-- ====================================================
			-- SKIP EXISTING AUTO-CLOSE CHARACTER
			-- ====================================================

			if skipExistingCloser(
				oldText,
				newText
				) then
				updateDisplay()
				rebuildGutter()

				currentErrors =
					findErrors(
						input.Text
					)

				updateErrorUnderlines()
				updateBracketMatching()

				cursorNeedsUpdate = false

				task.defer(function()
					if input:IsFocused() then
						updateEditorCursor()
					end
				end)

				return
			end

			-- ====================================================
			-- AUTO CLOSE
			-- ====================================================

			if autoCloseBracket(
				oldText,
				newText
				) then

				updateDisplay()
				rebuildGutter()

				currentErrors =
					findErrors(
						input.Text
					)

				updateErrorUnderlines()
				updateBracketMatching()

				cursorNeedsUpdate = false

				-- Give Roblox one frame to finish updating Display.
				task.defer(function()
					if input:IsFocused() then
						updateEditorCursor()
					end
				end)

				return
			end

			lastText = newText

			-- ====================================================
			-- UPDATE FOLDS
			-- ====================================================

			local validFolds = {}

			local lines =
				getLines(input.Text)

			for key, state in pairs(foldedBlocks) do
				if state then
					local startLine =
						tonumber(
							key:match(
								"^(%d+):"
							)
						)

					if startLine
						and lines[startLine]
						and isBlockStart(
							lines[startLine]
						)
					then
						local endLine =
							getBlockEnd(
								lines,
								startLine
							)

						if endLine then
							local newKey =
								getFoldKey(
									startLine,
									endLine,
									lines
								)

							validFolds[newKey] =
								true
						end
					end
				end
			end

			foldedBlocks = validFolds

			-- ====================================================
			-- UPDATE EVERYTHING
			-- ====================================================

			updateDisplay()
			rebuildGutter()

			currentErrors =
				findErrors(
					input.Text
				)

			updateErrorUnderlines()
			updateBracketMatching()

			cursorNeedsUpdate = false

			task.defer(function()
				if input:IsFocused() then
					updateEditorCursor()
				end
			end)

			if Features.Autocomplete then
				showAutocomplete()
			else
				clearAutocomplete()
			end
		end
	)

	-- ============================================================
	-- KEYBOARD
	-- ============================================================

	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)

		-- We ONLY care about keyboard input.
		if inputObject.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if not input:IsFocused() then
			return
		end

		-- Handle autocomplete BEFORE checking gameProcessed.
		if handleAutocompleteKey(inputObject.KeyCode) then
			return
		end

		if inputObject.KeyCode == Enum.KeyCode.Backspace then
			lastAutoClosePosition = nil
		end
	end)

	-- ============================================================
	-- CURSOR
	-- ============================================================

	input:GetPropertyChangedSignal(
		"CursorPosition"
	):Connect(
		function()

			resetCursorBlink()

			-- Let TextChanged / auto-close finish first.
			task.defer(function()
				if input:IsFocused() then
					updateEditorCursor()
				end
			end)

			updateBracketMatching()

			if Features.Autocomplete
				and input:IsFocused()
			then
				task.defer(
					function()
						if input:IsFocused() then
							showAutocomplete()
						end
					end
				)
			end
		end
	)

	-- ============================================================
	-- FOCUS
	-- ============================================================

	input.Focused:Connect(
		function()

			resetCursorBlink()

			updateBracketMatching()

			if Features.Autocomplete then
				showAutocomplete()
			end
		end
	)

	input.FocusLost:Connect(
		function()

			editorCursor.Visible = false

			clearAutocomplete()
			removeBracketOverlay()
		end
	)

	-- ============================================================
	-- FONT / SIZE CHANGES
	-- ============================================================

	input:GetPropertyChangedSignal(
		"TextSize"
	):Connect(
		function()
			updateEditorLayout()
			rebuildGutter()
			updateDisplay()
			updateErrorUnderlines()
			updateBracketMatching()
		end
	)

	input:GetPropertyChangedSignal(
		"LineHeight"
	):Connect(
		function()
			updateEditorLayout()
			rebuildGutter()
			updateDisplay()
			updateErrorUnderlines()
			updateBracketMatching()
		end
	)

	-- ============================================================
	-- SCROLL / RESIZE
	-- ============================================================

	EditorScroll:GetPropertyChangedSignal(
		"AbsoluteSize"
	):Connect(
		function()
			updateEditorLayout()

			rebuildGutter()
			updateErrorUnderlines()
			updateBracketMatching()
			positionAutocomplete()
		end
	)

	EditorScroll:GetPropertyChangedSignal(
		"CanvasPosition"
	):Connect(
		function()
			positionAutocomplete()
			updateEditorCursor(false)
		end
	)

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
