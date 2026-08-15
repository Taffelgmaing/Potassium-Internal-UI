--[[
	POTASSIUM IDE WORKSPACE
	============================================================

	Separate workspace/tabs/files controller.

	This module intentionally owns the large collection of UI references,
	document state, file-system functions and tab/file event connections that
	previously lived in Potassium.IDE.

	Reason:
	Luau has a limit of 200 local registers per function. Keeping all of these
	locals inside the main IDE initializer eventually caused:

	    Out of local registers ... exceeded limit 200

	Keeping this subsystem in its own ModuleScript gives it its own register
	frame and keeps Potassium.IDE comfortably below that limit.
]]

local Workspace = {}
Workspace.__index = Workspace

local UserInputService =
	game:GetService("UserInputService")

local WORKSPACE_MARGIN = 8
local TAB_BAR_HEIGHT = 30
local FILE_PANEL_WIDTH = 172
local BOTTOM_TOOLBAR_HEIGHT = 42

local FILE_ROOT = "PotassiumWorkspace"

local function makeCorner(parent, radius)
	local corner =
		Instance.new("UICorner")

	corner.CornerRadius =
		UDim.new(0, radius or 4)

	corner.Parent = parent

	return corner
end

local function newButton(
	parent,
	name,
	text,
	size
)
	local button =
		Instance.new("TextButton")

	button.Name = name
	button.Text = text or ""
	button.Size =
		size
		or UDim2.fromOffset(80, 26)
	button.BackgroundColor3 =
		Color3.fromRGB(42, 42, 42)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.TextColor3 =
		Color3.fromRGB(220, 220, 220)
	button.Font = Enum.Font.Code
	button.TextSize = 13
	button.ZIndex = 24
	button.Parent = parent

	makeCorner(button, 4)

	return button
end

local function executorGlobal(name)
	local environment = _G

	pcall(function()
		if type(getgenv) == "function" then
			environment = getgenv()
		end
	end)

	if environment
		and type(environment[name]) == "function"
	then
		return environment[name]
	end

	if type(_G[name]) == "function" then
		return _G[name]
	end

	return nil
end

local function sanitizeFileName(name)
	name =
		tostring(name or "")
		:gsub("^%s+", "")
		:gsub("%s+$", "")
		:gsub("[/\\:*?\"<>|]", "_")

	if name == "" then
		name = "Untitled.lua"
	end

	if not name:match("%.[%w_]+$") then
		name ..= ".lua"
	end

	return name
end

local function baseName(path)
	path =
		tostring(path or "")
		:gsub("\\", "/")

	return path:match("([^/]+)$")
		or path
end

function Workspace.new(context)
	assert(
		type(context) == "table",
		"[Potassium IDEWorkspace] context is required."
	)

	local self =
		setmetatable(
			{},
			Workspace
		)

	self.CodingHolder =
		assert(
			context.CodingHolder,
			"[Potassium IDEWorkspace] CodingHolder is missing."
		)

	self.MainFrame =
		context.MainFrame

	self.Input =
		assert(
			context.Input,
			"[Potassium IDEWorkspace] Input is missing."
		)

	self.EditorScroll =
		assert(
			context.EditorScroll,
			"[Potassium IDEWorkspace] EditorScroll is missing."
		)

	self.ButtonsFrame =
		context.ButtonsFrame

	self.SaveButton =
		context.SaveButton

	self.FilesButton =
		context.FilesButton

	self.documents = {}
	self.documentById = {}
	self.activeDocument = nil
	self.nextDocumentId = 0
	self.sessionSavedFiles = {}
	self.tabButtons = {}
	self.promptCallback = nil
	self.callbacks = {}
	self.loadingDocument = false

	self.fs = {
		writefile = executorGlobal("writefile"),
		readfile = executorGlobal("readfile"),
		isfile = executorGlobal("isfile"),
		listfiles = executorGlobal("listfiles"),
		makefolder = executorGlobal("makefolder"),
		isfolder = executorGlobal("isfolder"),
		delfile = executorGlobal("delfile"),
	}

	self:_createUI()
	self:_ensureWorkspaceFolder()
	self:_wireBaseUI()

	return self
end

function Workspace:_createUI()
	local codingHolder =
		self.CodingHolder

	local chrome =
		codingHolder:FindFirstChild(
			"WorkspaceChrome"
		)

	if not chrome then
		chrome =
			Instance.new("Frame")

		chrome.Name =
			"WorkspaceChrome"
		chrome.BackgroundTransparency = 1
		chrome.BorderSizePixel = 0
		chrome.ZIndex = 20
		chrome.Parent = codingHolder
	end

	self.Chrome = chrome

	local tabBar =
		chrome:FindFirstChild("TabBar")

	if not tabBar then
		tabBar =
			Instance.new("ScrollingFrame")

		tabBar.Name = "TabBar"
		tabBar.BackgroundColor3 =
			Color3.fromRGB(31, 31, 31)
		tabBar.BackgroundTransparency = 0.08
		tabBar.BorderSizePixel = 0
		tabBar.ScrollBarThickness = 3
		tabBar.ScrollingDirection =
			Enum.ScrollingDirection.X
		tabBar.AutomaticCanvasSize =
			Enum.AutomaticSize.None
		tabBar.CanvasSize =
			UDim2.fromOffset(0, 0)
		tabBar.ZIndex = 21
		tabBar.Parent = chrome

		makeCorner(tabBar, 4)
	end

	self.TabBar = tabBar

	local tabsHolder =
		tabBar:FindFirstChild(
			"TabsHolder"
		)

	if not tabsHolder then
		tabsHolder =
			Instance.new("Frame")

		tabsHolder.Name = "TabsHolder"
		tabsHolder.BackgroundTransparency = 1
		tabsHolder.BorderSizePixel = 0
		tabsHolder.Position =
			UDim2.fromOffset(4, 2)
		tabsHolder.Size =
			UDim2.fromOffset(1, 26)
		tabsHolder.ZIndex = 22
		tabsHolder.Parent = tabBar

		local layout =
			Instance.new("UIListLayout")

		layout.FillDirection =
			Enum.FillDirection.Horizontal
		layout.SortOrder =
			Enum.SortOrder.LayoutOrder
		layout.Padding =
			UDim.new(0, 4)
		layout.VerticalAlignment =
			Enum.VerticalAlignment.Center
		layout.Parent = tabsHolder
	end

	self.TabsHolder = tabsHolder

	local newTab =
		chrome:FindFirstChild("NewTab")

	if not newTab then
		newTab =
			newButton(
				chrome,
				"NewTab",
				"+",
				UDim2.fromOffset(
					28,
					TAB_BAR_HEIGHT
				)
			)

		newTab.TextSize = 18
	end

	self.NewTabButton = newTab

	local filePanel =
		chrome:FindFirstChild(
			"FilePanel"
		)

	if not filePanel then
		filePanel =
			Instance.new("Frame")

		filePanel.Name = "FilePanel"
		filePanel.BackgroundColor3 =
			Color3.fromRGB(31, 31, 31)
		filePanel.BorderSizePixel = 0
		filePanel.ZIndex = 21
		filePanel.Parent = chrome

		makeCorner(filePanel, 5)
	end

	self.FilePanel = filePanel

	local panelTitle =
		filePanel:FindFirstChild("Title")

	if not panelTitle then
		panelTitle =
			Instance.new("TextLabel")

		panelTitle.Name = "Title"
		panelTitle.BackgroundTransparency = 1
		panelTitle.Position =
			UDim2.fromOffset(8, 4)
		panelTitle.Size =
			UDim2.new(1, -16, 0, 24)
		panelTitle.Text = "FILES"
		panelTitle.TextColor3 =
			Color3.fromRGB(165, 165, 165)
		panelTitle.TextXAlignment =
			Enum.TextXAlignment.Left
		panelTitle.Font = Enum.Font.Code
		panelTitle.TextSize = 12
		panelTitle.ZIndex = 22
		panelTitle.Parent = filePanel
	end

	local panelNew =
		filePanel:FindFirstChild(
			"NewFile"
		)

	if not panelNew then
		panelNew =
			newButton(
				filePanel,
				"NewFile",
				"+",
				UDim2.fromOffset(24, 22)
			)

		panelNew.AnchorPoint =
			Vector2.new(1, 0)
		panelNew.Position =
			UDim2.new(1, -6, 0, 4)
		panelNew.TextSize = 16
	end

	self.FilePanelNew = panelNew

	local fileList =
		filePanel:FindFirstChild(
			"FileList"
		)

	if not fileList then
		fileList =
			Instance.new("ScrollingFrame")

		fileList.Name = "FileList"
		fileList.Position =
			UDim2.fromOffset(5, 31)
		fileList.Size =
			UDim2.new(1, -10, 1, -36)
		fileList.BackgroundTransparency = 1
		fileList.BorderSizePixel = 0
		fileList.ScrollBarThickness = 4
		fileList.AutomaticCanvasSize =
			Enum.AutomaticSize.Y
		fileList.CanvasSize =
			UDim2.fromOffset(0, 0)
		fileList.ZIndex = 22
		fileList.Parent = filePanel

		local layout =
			Instance.new("UIListLayout")

		layout.SortOrder =
			Enum.SortOrder.LayoutOrder
		layout.Padding =
			UDim.new(0, 2)
		layout.Parent = fileList
	end

	self.FileList = fileList

	local legacyFiles =
		self.MainFrame
		and self.MainFrame:FindFirstChild(
			"Files"
		)

	if legacyFiles then
		legacyFiles.Visible = false
	end

	local prompt =
		chrome:FindFirstChild(
			"FilePrompt"
		)

	if not prompt then
		prompt =
			Instance.new("Frame")

		prompt.Name = "FilePrompt"
		prompt.Visible = false
		prompt.AnchorPoint =
			Vector2.new(0.5, 0.5)
		prompt.Position =
			UDim2.fromScale(0.5, 0.45)
		prompt.Size =
			UDim2.fromOffset(290, 112)
		prompt.BackgroundColor3 =
			Color3.fromRGB(38, 38, 38)
		prompt.BorderSizePixel = 0
		prompt.ZIndex = 80
		prompt.Parent = chrome

		makeCorner(prompt, 6)

		local stroke =
			Instance.new("UIStroke")

		stroke.Color =
			Color3.fromRGB(72, 72, 72)
		stroke.Parent = prompt
	end

	self.FilePrompt = prompt

	local promptTitle =
		prompt:FindFirstChild("Title")

	if not promptTitle then
		promptTitle =
			Instance.new("TextLabel")

		promptTitle.Name = "Title"
		promptTitle.Position =
			UDim2.fromOffset(10, 7)
		promptTitle.Size =
			UDim2.new(1, -20, 0, 22)
		promptTitle.BackgroundTransparency = 1
		promptTitle.Text = "New file"
		promptTitle.TextColor3 =
			Color3.fromRGB(220, 220, 220)
		promptTitle.TextXAlignment =
			Enum.TextXAlignment.Left
		promptTitle.Font = Enum.Font.Code
		promptTitle.TextSize = 13
		promptTitle.ZIndex = 81
		promptTitle.Parent = prompt
	end

	self.PromptTitle = promptTitle

	local promptInput =
		prompt:FindFirstChild("Input")

	if not promptInput then
		promptInput =
			Instance.new("TextBox")

		promptInput.Name = "Input"
		promptInput.Position =
			UDim2.fromOffset(10, 35)
		promptInput.Size =
			UDim2.new(1, -20, 0, 30)
		promptInput.BackgroundColor3 =
			Color3.fromRGB(48, 48, 48)
		promptInput.BorderSizePixel = 0
		promptInput.ClearTextOnFocus = false
		promptInput.Text = ""
		promptInput.PlaceholderText =
			"FileName.lua"
		promptInput.TextColor3 =
			Color3.fromRGB(225, 225, 225)
		promptInput.PlaceholderColor3 =
			Color3.fromRGB(125, 125, 125)
		promptInput.TextXAlignment =
			Enum.TextXAlignment.Left
		promptInput.Font = Enum.Font.Code
		promptInput.TextSize = 13
		promptInput.ZIndex = 81
		promptInput.Parent = prompt

		local padding =
			Instance.new("UIPadding")

		padding.PaddingLeft =
			UDim.new(0, 8)
		padding.PaddingRight =
			UDim.new(0, 8)
		padding.Parent = promptInput

		makeCorner(promptInput, 4)
	end

	self.PromptInput = promptInput

	local cancel =
		prompt:FindFirstChild("Cancel")

	if not cancel then
		cancel =
			newButton(
				prompt,
				"Cancel",
				"Cancel",
				UDim2.fromOffset(72, 28)
			)

		cancel.AnchorPoint =
			Vector2.new(1, 1)
		cancel.Position =
			UDim2.new(1, -78, 1, -8)
		cancel.ZIndex = 81
	end

	self.PromptCancel = cancel

	local confirm =
		prompt:FindFirstChild("Confirm")

	if not confirm then
		confirm =
			newButton(
				prompt,
				"Confirm",
				"Create",
				UDim2.fromOffset(64, 28)
			)

		confirm.AnchorPoint =
			Vector2.new(1, 1)
		confirm.Position =
			UDim2.new(1, -8, 1, -8)
		confirm.BackgroundColor3 =
			Color3.fromRGB(62, 93, 130)
		confirm.ZIndex = 81
	end

	self.PromptConfirm = confirm
end

function Workspace:ApplyLayout()
	local sidebarWidth =
		self.FilePanel.Visible
		and FILE_PANEL_WIDTH
		or 0

	self.Chrome.Position =
		UDim2.fromOffset(0, 0)

	self.Chrome.Size =
		UDim2.fromScale(1, 1)

	self.TabBar.Position =
		UDim2.fromOffset(
			WORKSPACE_MARGIN,
			WORKSPACE_MARGIN
		)

	self.TabBar.Size =
		UDim2.new(
			1,
			-(WORKSPACE_MARGIN * 2)
			- sidebarWidth
			- 34,
			0,
			TAB_BAR_HEIGHT
		)

	self.NewTabButton.AnchorPoint =
		Vector2.new(1, 0)

	self.NewTabButton.Position =
		UDim2.new(
			1,
			-WORKSPACE_MARGIN
			- sidebarWidth,
			0,
			WORKSPACE_MARGIN
		)

	self.NewTabButton.Size =
		UDim2.fromOffset(
			28,
			TAB_BAR_HEIGHT
		)

	self.FilePanel.Position =
		UDim2.new(
			1,
			-WORKSPACE_MARGIN
			- FILE_PANEL_WIDTH,
			0,
			WORKSPACE_MARGIN
		)

	self.FilePanel.Size =
		UDim2.new(
			0,
			FILE_PANEL_WIDTH,
			1,
			-(WORKSPACE_MARGIN * 2)
			- BOTTOM_TOOLBAR_HEIGHT
		)

	self.EditorScroll.Position =
		UDim2.fromOffset(
			WORKSPACE_MARGIN,
			WORKSPACE_MARGIN
			+ TAB_BAR_HEIGHT
			+ 6
		)

	self.EditorScroll.Size =
		UDim2.new(
			1,
			-(WORKSPACE_MARGIN * 2)
			- sidebarWidth,
			1,
			-(WORKSPACE_MARGIN * 2)
			- TAB_BAR_HEIGHT
			- BOTTOM_TOOLBAR_HEIGHT
			- 8
		)

	if self.ButtonsFrame then
		self.ButtonsFrame.Position =
			UDim2.new(
				0,
				WORKSPACE_MARGIN,
				1,
				-BOTTOM_TOOLBAR_HEIGHT + 7
			)

		self.ButtonsFrame.Size =
			UDim2.new(
				1,
				-(WORKSPACE_MARGIN * 2)
				- sidebarWidth,
				0,
				30
			)
	end
end

function Workspace:_hasPersistentFilesystem()
	return self.fs.writefile ~= nil
		and self.fs.readfile ~= nil
end

function Workspace:_ensureWorkspaceFolder()
	if not self:_hasPersistentFilesystem()
		or not self.fs.makefolder
	then
		return
	end

	local exists = false

	if self.fs.isfolder then
		pcall(function()
			exists =
				self.fs.isfolder(
					FILE_ROOT
				)
		end)
	end

	if not exists then
		pcall(
			self.fs.makefolder,
			FILE_ROOT
		)
	end
end

function Workspace:_filePath(fileName)
	return FILE_ROOT
		.. "/"
		.. sanitizeFileName(
			fileName
		)
end

function Workspace:_readSavedFile(fileName)
	fileName =
		sanitizeFileName(fileName)

	if self:_hasPersistentFilesystem() then
		local ok, result =
			pcall(
				self.fs.readfile,
				self:_filePath(
					fileName
				)
			)

		if ok
			and type(result) == "string"
		then
			return result
		end
	end

	return self.sessionSavedFiles[
	fileName
	]
end

function Workspace:_writeSavedFile(
	fileName,
	source
)
	fileName =
		sanitizeFileName(fileName)

	source =
		tostring(source or "")

	self.sessionSavedFiles[fileName] =
		source

	if self:_hasPersistentFilesystem() then
		self:_ensureWorkspaceFolder()

		local ok, err =
			pcall(
				self.fs.writefile,
				self:_filePath(fileName),
				source
			)

		if not ok then
			warn(
				"[Potassium IDE] Failed to save file:",
				err
			)

			return false
		end
	end

	return true
end

function Workspace:_deleteSavedFile(fileName)
	fileName =
		sanitizeFileName(fileName)

	self.sessionSavedFiles[fileName] = nil

	if self:_hasPersistentFilesystem()
		and self.fs.delfile
	then
		pcall(
			self.fs.delfile,
			self:_filePath(fileName)
		)
	end
end

function Workspace:_listSavedFiles()
	local names = {}
	local seen = {}

	for fileName in pairs(
		self.sessionSavedFiles
		) do
		seen[fileName] = true
		table.insert(names, fileName)
	end

	if self:_hasPersistentFilesystem()
		and self.fs.listfiles
	then
		local ok, paths =
			pcall(
				self.fs.listfiles,
				FILE_ROOT
			)

		if ok
			and type(paths) == "table"
		then
			for _, path in ipairs(paths) do
				local name =
					baseName(path)

				if name ~= ""
					and not seen[name]
				then
					seen[name] = true
					table.insert(
						names,
						name
					)
				end
			end
		end
	end

	table.sort(
		names,
		function(a, b)
			return a:lower()
				< b:lower()
		end
	)

	return names
end

function Workspace:_showPrompt(
	titleText,
	defaultText,
	confirmText,
	callback
)
	self.promptCallback = callback

	self.PromptTitle.Text =
		titleText or "File"

	self.PromptInput.Text =
		defaultText or ""

	self.PromptConfirm.Text =
		confirmText or "OK"

	self.FilePrompt.Visible = true
	self.PromptInput:CaptureFocus()

	task.defer(function()
		if self.PromptInput:IsFocused() then
			self.PromptInput.CursorPosition =
				#self.PromptInput.Text + 1

			self.PromptInput.SelectionStart = 1
		end
	end)
end

function Workspace:_closePrompt()
	self.FilePrompt.Visible = false
	self.PromptInput:ReleaseFocus()
	self.promptCallback = nil
end

function Workspace:_captureDocument(document)
	if not document
		or self.loadingDocument
	then
		return
	end

	local callbacks =
		self.callbacks

	document.text =
		callbacks.getText
		and callbacks.getText()
		or self.Input.Text

	document.cursor =
		callbacks.getCursor
		and callbacks.getCursor()
		or math.max(
			1,
			self.Input.CursorPosition
		)

	document.selectionStart =
		callbacks.getSelection
		and callbacks.getSelection()
		or self.Input.SelectionStart

	document.canvasPosition =
		callbacks.getCanvas
		and callbacks.getCanvas()
		or self.EditorScroll.CanvasPosition
end

function Workspace:_loadDocument(document)
	if not document then
		return
	end

	self.loadingDocument = true

	local callback =
		self.callbacks.loadDocument

	if callback then
		callback(document)
	else
		self.Input.Text =
			document.text or ""

		self.Input.CursorPosition =
			math.clamp(
				document.cursor or 1,
				1,
				#self.Input.Text + 1
			)

		self.Input.SelectionStart =
			math.clamp(
				document.selectionStart
				or self.Input.CursorPosition,
				1,
				#self.Input.Text + 1
			)

		self.EditorScroll.CanvasPosition =
			document.canvasPosition
			or Vector2.zero
	end

	self.loadingDocument = false
end

function Workspace:_updateTabAppearance()
	for document, holder in pairs(
		self.tabButtons
		) do
		if holder
			and holder.Parent
		then
			local selected =
				document
				== self.activeDocument

			holder.BackgroundColor3 =
				selected
				and Color3.fromRGB(
					52,
					60,
					72
				)
				or Color3.fromRGB(
					40,
					40,
					40
				)

			local label =
				holder:FindFirstChild(
					"Label"
				)

			if label then
				label.Text =
					(document.dirty
						and "● "
						or "")
					.. document.name
			end
		end
	end
end

function Workspace:_resizeTabCanvas()
	local layout =
		self.TabsHolder:
		FindFirstChildOfClass(
			"UIListLayout"
		)

	if not layout then
		return
	end

	task.defer(function()
		if not layout.Parent then
			return
		end

		local width =
			layout.AbsoluteContentSize.X
			+ 8

		self.TabsHolder.Size =
			UDim2.fromOffset(
				math.max(width, 1),
				26
			)

		self.TabBar.CanvasSize =
			UDim2.fromOffset(
				width,
				0
			)
	end)
end

function Workspace:_createTabButton(document)
	local holder =
		Instance.new("TextButton")

	holder.Name =
		"Tab_" .. document.id
	holder.Size =
		UDim2.fromOffset(142, 26)
	holder.BackgroundColor3 =
		Color3.fromRGB(40, 40, 40)
	holder.BorderSizePixel = 0
	holder.Text = ""
	holder.AutoButtonColor = true
	holder.ZIndex = 23
	holder.Parent = self.TabsHolder

	makeCorner(holder, 4)

	local label =
		Instance.new("TextLabel")

	label.Name = "Label"
	label.Position =
		UDim2.fromOffset(8, 0)
	label.Size =
		UDim2.new(1, -32, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = document.name
	label.TextColor3 =
		Color3.fromRGB(220, 220, 220)
	label.TextXAlignment =
		Enum.TextXAlignment.Left
	label.TextTruncate =
		Enum.TextTruncate.AtEnd
	label.Font = Enum.Font.Code
	label.TextSize = 12
	label.ZIndex = 24
	label.Parent = holder

	local close =
		Instance.new("TextButton")

	close.Name = "Close"
	close.AnchorPoint =
		Vector2.new(1, 0.5)
	close.Position =
		UDim2.new(1, -4, 0.5, 0)
	close.Size =
		UDim2.fromOffset(20, 20)
	close.BackgroundTransparency = 1
	close.Text = "×"
	close.TextColor3 =
		Color3.fromRGB(160, 160, 160)
	close.Font = Enum.Font.Code
	close.TextSize = 14
	close.ZIndex = 25
	close.Parent = holder

	holder.MouseButton1Click:Connect(
		function()
			self:SwitchDocument(
				document
			)
		end
	)

	close.MouseButton1Click:Connect(
		function()
			self:CloseDocument(
				document
			)
		end
	)

	self.tabButtons[document] = holder

	self:_resizeTabCanvas()
	self:_updateTabAppearance()
end

function Workspace:CreateDocument(
	name,
	source,
	fileName
)
	self.nextDocumentId += 1

	local document = {
		id = tostring(
			self.nextDocumentId
		),

		name =
			sanitizeFileName(
				name or "Untitled.lua"
			),

		fileName =
			fileName
			and sanitizeFileName(
				fileName
			)
			or nil,

		text = source or "",
		cursor = 1,
		selectionStart = 1,
		canvasPosition = Vector2.zero,
		dirty = false,
	}

	table.insert(
		self.documents,
		document
	)

	self.documentById[
	document.id
	] = document

	self:_createTabButton(
		document
	)

	if not self.activeDocument then
		self.activeDocument =
			document

		self:_loadDocument(
			document
		)

		self:_updateTabAppearance()
	else
		self:SwitchDocument(
			document
		)
	end

	return document
end

function Workspace:SwitchDocument(document)
	if not document
		or document
		== self.activeDocument
	then
		return
	end

	self:_captureDocument(
		self.activeDocument
	)

	self.activeDocument = document

	self:_loadDocument(
		document
	)

	self:_updateTabAppearance()

	task.defer(function()
		if self.Input.Parent then
			self.Input:CaptureFocus()
		end
	end)
end

function Workspace:CloseDocument(document)
	if not document then
		return
	end

	local index =
		table.find(
			self.documents,
			document
		)

	if not index then
		return
	end

	local wasActive =
		document == self.activeDocument

	local button =
		self.tabButtons[document]

	if button then
		button:Destroy()
	end

	self.tabButtons[document] = nil
	self.documentById[document.id] = nil

	table.remove(
		self.documents,
		index
	)

	if wasActive then
		self.activeDocument =
			self.documents[
		math.clamp(
			index,
			1,
			math.max(
				1,
				#self.documents
			)
		)
		]

		if not self.activeDocument then
			self:CreateDocument(
				"Untitled.lua",
				"",
				nil
			)
		else
			self:_loadDocument(
				self.activeDocument
			)
		end
	end

	self:_resizeTabCanvas()
	self:_updateTabAppearance()
end

function Workspace:SaveDocument(
	document,
	forceSaveAs
)
	document =
		document
		or self.activeDocument

	if not document then
		return
	end

	self:_captureDocument(document)

	local function performSave(name)
		name =
			sanitizeFileName(name)

		if self:_writeSavedFile(
			name,
			document.text
			) then
			document.fileName = name
			document.name = name
			document.dirty = false

			self:_updateTabAppearance()
			self:RefreshFileSidebar()
		end
	end

	if forceSaveAs
		or not document.fileName
	then
		self:_showPrompt(
			"Save file as",
			document.fileName
				or document.name,
			"Save",
			performSave
		)
	else
		performSave(
			document.fileName
		)
	end
end

function Workspace:_findOpenFile(fileName)
	fileName =
		sanitizeFileName(fileName)

	for _, document in ipairs(
		self.documents
		) do
		if document.fileName
			== fileName
		then
			return document
		end
	end

	return nil
end

function Workspace:OpenSavedFile(fileName)
	fileName =
		sanitizeFileName(fileName)

	local existing =
		self:_findOpenFile(
			fileName
		)

	if existing then
		self:SwitchDocument(
			existing
		)

		return
	end

	local source =
		self:_readSavedFile(
			fileName
		)

	if type(source) ~= "string" then
		warn(
			"[Potassium IDE] Could not read file:",
			fileName
		)

		return
	end

	self:CreateDocument(
		fileName,
		source,
		fileName
	)
end

function Workspace:RefreshFileSidebar()
	for _, child in ipairs(
		self.FileList:GetChildren()
		) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	for index, fileName in ipairs(
		self:_listSavedFiles()
		) do
		local row =
			Instance.new("Frame")

		row.Name =
			"File_" .. tostring(index)
		row.Size =
			UDim2.new(1, -4, 0, 27)
		row.BackgroundColor3 =
			Color3.fromRGB(39, 39, 39)
		row.BorderSizePixel = 0
		row.LayoutOrder = index
		row.ZIndex = 23
		row.Parent = self.FileList

		makeCorner(row, 3)

		local open =
			Instance.new("TextButton")

		open.Name = "Open"
		open.Size =
			UDim2.new(1, -26, 1, 0)
		open.BackgroundTransparency = 1
		open.Text = "  " .. fileName
		open.TextColor3 =
			Color3.fromRGB(205, 205, 205)
		open.TextXAlignment =
			Enum.TextXAlignment.Left
		open.TextTruncate =
			Enum.TextTruncate.AtEnd
		open.Font = Enum.Font.Code
		open.TextSize = 12
		open.ZIndex = 24
		open.Parent = row

		local delete =
			Instance.new("TextButton")

		delete.Name = "Delete"
		delete.AnchorPoint =
			Vector2.new(1, 0)
		delete.Position =
			UDim2.new(1, 0, 0, 0)
		delete.Size =
			UDim2.fromOffset(24, 27)
		delete.BackgroundTransparency = 1
		delete.Text = "×"
		delete.TextColor3 =
			Color3.fromRGB(145, 145, 145)
		delete.Font = Enum.Font.Code
		delete.TextSize = 14
		delete.ZIndex = 24
		delete.Parent = row

		open.MouseButton1Click:Connect(
			function()
				self:OpenSavedFile(
					fileName
				)
			end
		)

		delete.MouseButton1Click:Connect(
			function()
				self:_deleteSavedFile(
					fileName
				)

				self:RefreshFileSidebar()
			end
		)
	end
end

function Workspace:MarkDirty(source)
	if self.loadingDocument
		or not self.activeDocument
	then
		return
	end

	self.activeDocument.text =
		source

	self.activeDocument.dirty = true

	self:_updateTabAppearance()
end

function Workspace:IsLoadingDocument()
	return self.loadingDocument
end

function Workspace:GetActiveDocument()
	return self.activeDocument
end

function Workspace:_wireBaseUI()
	self.PromptCancel.MouseButton1Click:
		Connect(function()
			self:_closePrompt()
		end)

	self.PromptConfirm.MouseButton1Click:
		Connect(function()
			local callback =
			self.promptCallback

			local value =
			self.PromptInput.Text

			self:_closePrompt()

			if callback then
				callback(value)
			end
		end)

	self.PromptInput.FocusLost:
		Connect(function(enterPressed)
			if not self.FilePrompt.Visible
				or not enterPressed
			then
				return
			end

			local callback =
			self.promptCallback

			local value =
			self.PromptInput.Text

			self:_closePrompt()

			if callback then
				callback(value)
			end
		end)

	self.NewTabButton.MouseButton1Click:
		Connect(function()
			self:_showPrompt(
				"New file",
				"Untitled.lua",
				"Create",
				function(name)
					self:CreateDocument(
						sanitizeFileName(name),
						"",
						nil
					)
				end
			)
		end)

	self.FilePanelNew.MouseButton1Click:
		Connect(function()
			self:_showPrompt(
				"New file",
				"Untitled.lua",
				"Create",
				function(name)
					self:CreateDocument(
						sanitizeFileName(name),
						"",
						nil
					)
				end
			)
		end)

	if self.SaveButton then
		self.SaveButton.Text = "Save"

		self.SaveButton.MouseButton1Click:
			Connect(function()
				self:SaveDocument(
					self.activeDocument,
					false
				)
			end)
	end

	if self.FilesButton then
		self.FilesButton.Text = "Files"

		self.FilesButton.MouseButton1Click:
			Connect(function()
				self.FilePanel.Visible =
				not self.FilePanel.Visible

				self:ApplyLayout()

				if self.callbacks.layoutChanged then
					self.callbacks.layoutChanged()
				end

				if self.FilePanel.Visible then
					self:RefreshFileSidebar()
				end
			end)
	end

	UserInputService.InputBegan:
		Connect(function(
			inputObject,
			_gameProcessed
		)
		if inputObject.UserInputType
			~= Enum.UserInputType.Keyboard
		then
			return
		end

		local control =
			UserInputService:IsKeyDown(
				Enum.KeyCode.LeftControl
			)
			or UserInputService:IsKeyDown(
				Enum.KeyCode.RightControl
			)

		if not control then
			return
		end

		if inputObject.KeyCode
			== Enum.KeyCode.S
		then
			local shift =
				UserInputService:IsKeyDown(
					Enum.KeyCode.LeftShift
				)
				or UserInputService:IsKeyDown(
					Enum.KeyCode.RightShift
				)

			self:SaveDocument(
				self.activeDocument,
				shift
			)

		elseif inputObject.KeyCode
			== Enum.KeyCode.N
		then
			self:CreateDocument(
				"Untitled.lua",
				"",
				nil
			)

		elseif inputObject.KeyCode
			== Enum.KeyCode.W
		then
			self:CloseDocument(
				self.activeDocument
			)
		end
	end)
end

function Workspace:Bind(callbacks)
	self.callbacks =
		callbacks or {}

	self:RefreshFileSidebar()

	if not self.activeDocument then
		self:CreateDocument(
			"Untitled.lua",
			self.callbacks.getText
				and self.callbacks.getText()
				or self.Input.Text,
			nil
		)
	end

	self:ApplyLayout()
end

return Workspace
