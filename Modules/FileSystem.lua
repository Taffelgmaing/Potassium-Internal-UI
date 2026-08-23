local HttpService = game:GetService("HttpService")

local FileSystem = {}

-- ============================================================
-- PATHS
-- ============================================================

local MainFolderPath = "Potassium Internal"
local DataPath = MainFolderPath .. "/Data"

FileSystem.MainPath = MainFolderPath
FileSystem.DataPath = DataPath

-- ============================================================
-- INTERNAL UTILITIES
-- ============================================================

local function normalizePath(path)
	assert(type(path) == "string", "Path must be a string")

	path = path:gsub("\\", "/")
	path = path:gsub("/+", "/")

	-- Remove trailing slash
	if #path > 1 then
		path = path:gsub("/$", "")
	end

	return path
end

local function joinPath(...)
	local parts = {...}
	local result = {}

	for _, part in ipairs(parts) do
		if part ~= nil then
			part = tostring(part)
			part = part:gsub("\\", "/")
			part = part:gsub("^/+", "")
			part = part:gsub("/+$", "")

			if part ~= "" then
				table.insert(result, part)
			end
		end
	end

	return table.concat(result, "/")
end

local function getParentPath(path)
	path = normalizePath(path)

	return path:match("^(.*)/[^/]+$")
end

local function encodeData(data)
	if type(data) == "string" then
		return data
	end

	local success, result = pcall(
		HttpService.JSONEncode,
		HttpService,
		data
	)

	if not success then
		error("Failed to encode data: " .. tostring(result), 3)
	end

	return result
end

local function decodeData(data)
	local success, result = pcall(
		HttpService.JSONDecode,
		HttpService,
		data
	)

	if success then
		return result
	end

	return nil
end

-- ============================================================
-- PATH UTILITIES
-- ============================================================

function FileSystem.Join(...)
	return joinPath(...)
end

function FileSystem.GetParent(path)
	return getParentPath(path)
end

function FileSystem.GetName(path)
	path = normalizePath(path)

	return path:match("([^/]+)$")
end

-- ============================================================
-- EXISTS
-- ============================================================

function FileSystem.FileExists(path)
	path = normalizePath(path)

	return isfile(path)
end

function FileSystem.FolderExists(path)
	path = normalizePath(path)

	return isfolder(path)
end

function FileSystem.Exists(path)
	path = normalizePath(path)

	return isfile(path) or isfolder(path)
end

-- ============================================================
-- FOLDERS
-- ============================================================

function FileSystem.CreateFolder(path)
	path = normalizePath(path)

	if isfolder(path) then
		return true
	end

	-- Create folders one by one.
	-- Example:
	-- Potassium Internal/Data/Projects

	local currentPath = ""

	for folder in path:gmatch("[^/]+") do
		if currentPath == "" then
			currentPath = folder
		else
			currentPath = currentPath .. "/" .. folder
		end

		if not isfolder(currentPath) then
			local success, err = pcall(makefolder, currentPath)

			if not success then
				warn(
					"[FileSystem] Failed to create folder:",
					currentPath,
					err
				)

				return false
			end
		end
	end

	return true
end

function FileSystem.DeleteFolder(path)
	path = normalizePath(path)

	if not isfolder(path) then
		return false
	end

	if not delfolder then
		warn("[FileSystem] delfolder is not supported")
		return false
	end

	local success, err = pcall(delfolder, path)

	if not success then
		warn(
			"[FileSystem] Failed to delete folder:",
			path,
			err
		)

		return false
	end

	return true
end

-- ============================================================
-- FILE CREATION
-- ============================================================

function FileSystem.CreateFile(path, name, data)
	local fullPath

	if name then
		fullPath = joinPath(path, name)
	else
		fullPath = normalizePath(path)
		data = data or ""
	end

	local parent = getParentPath(fullPath)

	if parent then
		FileSystem.CreateFolder(parent)
	end

	if isfile(fullPath) then
		return false, fullPath
	end

	local content = encodeData(data or "")

	local success, err = pcall(
		writefile,
		fullPath,
		content
	)

	if not success then
		warn(
			"[FileSystem] Failed to create file:",
			fullPath,
			err
		)

		return false
	end

	return true, fullPath
end

-- ============================================================
-- READ
-- ============================================================

function FileSystem.ReadFile(path)
	path = normalizePath(path)

	if not isfile(path) then
		return nil, "File does not exist"
	end

	local success, result = pcall(readfile, path)

	if not success then
		return nil, result
	end

	return result
end

function FileSystem.ReadJSON(path)
	local contents, err = FileSystem.ReadFile(path)

	if not contents then
		return nil, err
	end

	local decoded = decodeData(contents)

	if decoded == nil then
		return nil, "Failed to decode JSON"
	end

	return decoded
end

-- ============================================================
-- WRITE / SAVE
-- ============================================================

function FileSystem.SaveFile(path, data)
	path = normalizePath(path)

	local parent = getParentPath(path)

	if parent then
		FileSystem.CreateFolder(parent)
	end

	local content = encodeData(data)

	local success, err = pcall(
		writefile,
		path,
		content
	)

	if not success then
		warn(
			"[FileSystem] Failed to save file:",
			path,
			err
		)

		return false, err
	end

	return true
end

function FileSystem.SaveJSON(path, data)
	assert(
		type(data) == "table",
		"SaveJSON expected a table"
	)

	path = normalizePath(path)

	local success, encoded = pcall(
		HttpService.JSONEncode,
		HttpService,
		data
	)

	if not success then
		return false, encoded
	end

	local parent = getParentPath(path)

	if parent then
		FileSystem.CreateFolder(parent)
	end

	local writeSuccess, writeError = pcall(
		writefile,
		path,
		encoded
	)

	if not writeSuccess then
		return false, writeError
	end

	return true
end

-- ============================================================
-- UPDATE JSON
-- ============================================================

function FileSystem.UpdateJSON(path, newData)
	assert(
		type(newData) == "table",
		"UpdateJSON expected a table"
	)

	local currentData = {}

	if isfile(path) then
		local loaded = FileSystem.ReadJSON(path)

		if type(loaded) == "table" then
			currentData = loaded
		end
	end

	for key, value in pairs(newData) do
		currentData[key] = value
	end

	local success, err = FileSystem.SaveJSON(
		path,
		currentData
	)

	if not success then
		return false, err
	end

	return true, currentData
end

-- ============================================================
-- DELETE FILE
-- ============================================================

function FileSystem.DeleteFile(path)
	path = normalizePath(path)

	if not isfile(path) then
		return false
	end

	if not delfile then
		warn("[FileSystem] delfile is not supported")
		return false
	end

	local success, err = pcall(delfile, path)

	if not success then
		warn(
			"[FileSystem] Failed to delete file:",
			path,
			err
		)

		return false
	end

	return true
end

-- ============================================================
-- LIST FILES
-- ============================================================

function FileSystem.GetFiles(path)
	path = normalizePath(path)

	if not isfolder(path) then
		return {}
	end

	local success, files = pcall(
		listfiles,
		path
	)

	if not success then
		warn(
			"[FileSystem] Failed to list:",
			path,
			files
		)

		return {}
	end

	return files
end

-- ============================================================
-- APPEND
-- ============================================================

function FileSystem.AppendFile(path, data)
	path = normalizePath(path)

	data = tostring(data)

	local parent = getParentPath(path)

	if parent then
		FileSystem.CreateFolder(parent)
	end

	if appendfile then
		local success, err = pcall(
			appendfile,
			path,
			data
		)

		return success, err
	end

	-- Fallback if appendfile isn't available

	local oldData = ""

	if isfile(path) then
		oldData = readfile(path)
	end

	return FileSystem.SaveFile(
		path,
		oldData .. data
	)
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function FileSystem.Initialize()
	FileSystem.CreateFolder(
		FileSystem.MainPath
	)

	FileSystem.CreateFolder(
		FileSystem.DataPath
	)

	local configPath = FileSystem.Join(
		FileSystem.DataPath,
		"Data.cfg"
	)

	if not FileSystem.FileExists(configPath) then
		FileSystem.SaveJSON(
			configPath,
			{}
		)
	end

	return true
end

-- ============================================================
-- START FILESYSTEM
-- ============================================================

FileSystem.Initialize()

return FileSystem
