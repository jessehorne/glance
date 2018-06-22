local turbo = require("turbo")
local vips = require("vips")
local FrontHandler = class("FrontHandler", turbo.web.RequestHandler)


local template_helper = turbo.web.Mustache.TemplateHelper("templates/")
template_helper:load("dash.html")


function FrontHandler:get(...)
	self:write(template_helper:render("dash.html", {}))
end


return FrontHandler
