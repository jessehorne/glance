local turbo = require("turbo")
local lfs = require("lfs")
local FileHandler = class("FileHandler", turbo.web.RequestHandler)


local files = {}
local project_path = "/home/jesseh/Documents/glance_test/test"
local project_name = "test"

local dig_files = {}

function dig(path)
	local dig_files = {}

	for folder in lfs.dir(path) do
		local full_folder_path = path .. "/" .. folder
		local folder_route = string.match(full_folder_path, project_path .. "(/.+)$")

		local folder_attr = lfs.attributes(full_folder_path)

		if folder_attr.mode ~= "directory" then
			if folder ~= "." and folder ~= ".." then
				local _f = {
					name = folder,
					path = full_folder_path
				}

				local is = function(p) return string.find(full_folder_path, p) end

				if is(".jpg") or is(".png") then
					_f.contents = "Images cannot currently be displayed."
				elseif is(".txt") then
					local file = io.open(full_folder_path, "rb")
					if file then
						_f.contents = file:read("a")
					end
					file:close()
				else
					_f.contents = "The filetype of this file is unsupported."
				end

				table.insert(dig_files, _f)
			end
		else
			if folder ~= ".." and folder ~= "." then
				local _f = {
					name = folder,
					path = full_folder_path,
					files = dig(full_folder_path)
				}

				table.insert(dig_folders, _f)
			end
		end
	end

	-- table.insert(dig_folders, dig_files)

	return dig_files
end

function FileHandler:get()
	-- self:write(template_helper:render("dash.html", {}))
	dig_folders = {}
	local files = dig(project_path)

	self:write({folders=dig_folders, files=files})
end

return FileHandler
