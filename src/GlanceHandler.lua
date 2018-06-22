local turbo = require("turbo")
local lfs = require("lfs")
local mimetypes = require("mimetypes")
local vips = require "vips"
local GlanceHandler = class("GlanceHandler", turbo.web.RequestHandler)


HOST_PATH = "/home/jesseh/Documents/glance_test"
HOST_NAME = "glance_test"


GlanceHandler.template_helper = turbo.web.Mustache.TemplateHelper("templates/")


-- load templates
GlanceHandler.template_helper:load("index.html")


local icons = {}
icons["text/plain"] = "far fa-file-alt"
icons["image/jpeg"] = "far fa-image"
icons["image/png"] = "far fa-image"

local folders = {}

function get_icon(filepath)
	local icon = "fa-question"

	local mimetype = mimetypes.guess(filepath)

	if icons[mimetype] then return icons[mimetype] end

	return icon
end

function read_from_file(file_path)
	local file = io.open(file_path, "rb")
	if file then
		return file:read("a")
	end
end

function dig(look_path)
	for folder in lfs.dir(look_path) do
		local attr = lfs.attributes(look_path .. "/" .. folder)

		if attr.mode == "directory" then
			if folder ~= "." and folder ~= ".." then
				local sub_folders = {}
				local sub_files = {}

				for sub_folder in lfs.dir(look_path .. "/" .. folder) do
					local sub_attr = lfs.attributes(look_path .. "/" .. folder .. "/" .. sub_folder)

					if sub_attr.mode == "directory" then
						if sub_folder ~= "." and sub_folder ~= ".." then
							local _sub_folder = {
								name = sub_folder,
								route = HOST_NAME .. "/" .. folder .. "/" .. sub_folder
							}
							print("routeeeee", _sub_folder.route)

							table.insert(sub_folders, _sub_folder)
						end
					else
						local _sub_file = {
							name = sub_folder,
							route = "/" .. HOST_NAME .. "/" .. folder .. "/" .. sub_folder,
						}

						local _mimetype = mimetypes.guess(HOST_PATH .. "/" .. folder .. "/" .. sub_folder)
						if _mimetype == "text/plain" then
							_sub_file.file_body = read_from_file(HOST_PATH .. "/" .. folder .. "/" .. sub_folder)
						elseif _mimetype == "image/png" or _mimetype == "image/jpg" then
							_sub_file.image = true
						end

						table.insert(sub_files, _sub_file)
					end
				end

				local _f = {
					name = folder,
					route = "/" .. HOST_NAME .. "/" .. folder,
					folders = sub_folders,
					files = sub_files
				}

				table.insert(folders, _f)

				dig(look_path .. "/" .. folder)
			end
		end
	end
end
dig(HOST_PATH)

local sub_folders = {}
local sub_files = {}

for sub_folder in lfs.dir(HOST_PATH) do
	local sub_attr = lfs.attributes(HOST_PATH .. "/" .. sub_folder)

	if sub_attr.mode == "directory" then
		if sub_folder ~= "." and sub_folder ~= ".." then
			local _sub_folder = {
				name = sub_folder,
				route = "/" .. HOST_NAME .. "/" .. sub_folder
			}

			table.insert(sub_folders, _sub_folder)
		end
	else
		local _sub_file = {
			name = sub_folder,
			route = "/" .. HOST_NAME .. "/" .. sub_folder
		}

		local _mimetype = mimetypes.guess(HOST_PATH .. "/" .. sub_folder)
		if _mimetype == "text/plain" then
			_sub_file.file_body = read_from_file(HOST_PATH .. "/" .. sub_folder)
		elseif _mimetype == "image/png" or _mimetype == "image/jpeg" then
			_sub_file.image = true
		end

		table.insert(sub_files, _sub_file)
	end
end

local _f = {
	name = HOST_NAME,
	route = "/",
	folders = sub_folders,
	files = sub_files
}

table.insert(folders, _f)

for i,v in ipairs(folders) do
	print("FOLDER - " .. v.name .. " (" .. v.route .. ")\n")
	for ii,vv in ipairs(v.folders) do
		print("\tfolder name " .. vv.name .. " (" .. vv.route .. ")")
	end
	print("-------")
	for ii,vv in ipairs(v.files) do
		print("\tfile name " .. vv.name .. " (" .. vv.route .. ")")
	end
end

function GlanceHandler:get(...)
	for i,v in ipairs(folders) do
		print("V ROUTE ", v.route, "WAT ", "/" .. HOST_NAME .. ...)
		if v.route == ("/" .. HOST_NAME .. ...) then
			self:write(self.template_helper:render("index.html", v))
		elseif ... == "" then
			self:write(self.template_helper:render("index.html", _f))
		end
	end
end

return GlanceHandler
