local kolba = require("kolba")

local folder_path = "/home/jesseh/Documents/glance_test"
local folder_name = string.match(folder_path, "/([^/]+)$")

local config = {
	host="localhost",
	port=7070,
	is_dev=true
}

local app = kolba.create(config)

-- Create routes for sub-folders in folder_path
local folders = {}

function dig(path)
	for folder in kolba.lfs.dir(path) do
		local attr = kolba.lfs.attributes(path .. "/" .. folder)

		if attr.mode == "directory" then
			if folder ~= "." and folder ~= ".." then
				local sub_folder_name = folder
				local sub_folder_path = path .. "/" .. folder
				local sub_folder_route = string.match(sub_folder_path, folder_path .. "(/.+)$")
				local sub_folder_back = string.match(path, folder_path .. "(.+)$") or "/"


				local files = {}
				local _folders = {}

				for file in kolba.lfs.dir(path .. "/" .. folder) do
					local file_attr = kolba.lfs.attributes(path .. "/" .. folder .. "/" .. file)

					if file_attr.mode ~= "directory" then
						if file ~= "." and file ~= ".." then
							local _f = {
								name = file
							}
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
						title = "Glance",
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
dig(folder_path)


local folders = {}
local files = {}

for folder in kolba.lfs.dir(folder_path) do
	local folder_name = folder
	local folder_path = folder_path .. "/" .. folder_name
	local folder_route = "/" .. folder_name

	local attr = kolba.lfs.attributes(folder_path)

	if attr.mode == "directory" then
		if folder_name ~= "." and folder_name ~= ".." then
			local _f = {
				name = folder_name,
				route = folder_route,
				back = "/"
			}

			table.insert(folders, _f)
		end
	else
		local _file = {
			name = folder_name
		}

		table.insert(files, _file)
	end
end

local view = function()
	local model = {
		title = "Glance",
		folders=folders,
		files = files
	}

	return {200, "text/html", app.template("index", model)}
end

app.route("GET", "/", view)


print("glance will be serving '" .. folder_name .. "' (" .. folder_path .. ").")

app.run()
