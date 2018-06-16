local kolba = require("kolba")

local hosting_path = kolba.lfs.currentdir() .. "/default"
local hosting = string.match(hosting_path, "/([^/]+)$")

local config = {
	host="localhost",
	port=7070,
	is_dev=true
}

local app = kolba.create(config)

local icons = {}
icons["text/plain"] = "far fa-file-alt"
icons["image/jpeg"] = "far fa-image"
icons["image/png"] = "far fa-image"


-- Create routes for sub-folders in folder_path
local folders = {}

function get_icon(filepath)
	local icon = "fa-question"

	local mimetype = kolba.mimetypes.guess(filepath)

	if icons[mimetype] then return icons[mimetype] end

	return icon
end

function read_from_file(path)
	local contents
	local file = io.open(path, "rb")

	if file then
		contents = file:read("a")
	end
	file:close()

	return contents
end

function dig(path)
	for folder in kolba.lfs.dir(path) do
		local attr = kolba.lfs.attributes(path .. "/" .. folder)

		if attr.mode == "directory" then
			if folder ~= "." and folder ~= ".." then
				local sub_folder_name = folder
				local sub_folder_path = path .. "/" .. folder
				local sub_folder_route = string.match(sub_folder_path, hosting_path .. "(/.+)$")
				local sub_folder_back = string.match(path, hosting_path .. "(.+)$") or "/"


				local files = {}
				local _folders = {}

				for file in kolba.lfs.dir(path .. "/" .. folder) do
					local file_attr = kolba.lfs.attributes(path .. "/" .. folder .. "/" .. file)

					if file_attr.mode ~= "directory" then
						if file ~= "." and file ~= ".." then
							size = file_attr.size
							if size > 1000000 then
								size = tostring(size/10000.0) .. "MB"
							else
								size = tostring(size/1000.0) .. "KB"
							end
							local _f = {
								name = file,
								icon = get_icon(path .. "/" .. folder .. "/" .. file),
								size = size
							}

							_mimetype = kolba.mimetypes.guess(folder_path)

							if _mimetype == "text/plain" then
								_file.file_body = read_from_file(folder_path)
							elseif _mimetype == "image/jpeg" then
								_file.image = folder_route

								app.route("GET", folder_route, {200, "image/jpeg", read_from_file(folder_path)})
							elseif _mimetype == "image/png" then
								_file.image = folder_route

								app.route("GET", folder_route, {200, "image/png", read_from_file(folder_path)})
							end

							table.insert(files, _f)
						end
					else
						if file ~= "." and file ~= ".." then
							local _f = {
								name = file,
								route = sub_folder_route .. "/" .. file
							}

							table.insert(_folders, _f)
						end
					end
				end

				local view = function()
					local model = {
						title = "glance",
						hosting = hosting,
						folders=_folders,
						files = files,
						back = sub_folder_back
					}

					return {200, "text/html", app.template("index", model)}
				end

				app.route("GET", sub_folder_route, view)

				dig(path .. "/" .. folder)
			end
		end
	end
end
dig(hosting_path)


local folders = {}
local files = {}

for folder in kolba.lfs.dir(hosting_path) do
	local folder_name = folder
	local folder_path = hosting_path .. "/" .. folder_name
	local folder_route = "/" .. folder_name

	local attr = kolba.lfs.attributes(folder_path)

	if attr.mode == "directory" then
		if folder_name ~= "." and folder_name ~= ".." then
			local _f = {
				name = "glance",
				hosting = hosting,
				folder = folder_name,
				route = folder_route,
				back = "/"
			}

			table.insert(folders, _f)
		end
	else
		size = attr.size
		if size > 1000000 then
			size = tostring(size/10000.0) .. "MB"
		else
			size = tostring(size/1000.0) .. "KB"
		end
		local _file = {
			name = folder_name,
			icon = get_icon(folder_path),
			size = size
		}

		_mimetype = kolba.mimetypes.guess(folder_path)

		if _mimetype == "text/plain" then
			_file.file_body = read_from_file(folder_path)
		elseif _mimetype == "image/jpeg" then
			_file.image = folder_route

			app.route("GET", folder_route, function() return {200, "image/jpeg", read_from_file(folder_path)} end)
		elseif _mimetype == "image/png" then
			_file.image = folder_route

			app.route("GET", folder_route, function() return {200, "image/png", read_from_file(folder_path)} end)
		end

		table.insert(files, _file)
	end
end

local view = function()
	local model = {
		title = "glance",
		hosting = hosting,
		folders = folders,
		files = files
	}

	return {200, "text/html", app.template("index", model)}
end

app.route("GET", "/", view)


print("glance will be serving '" .. hosting .. "' (" .. hosting_path .. ").")

app.run()
