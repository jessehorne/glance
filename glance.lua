local turbo = require("turbo")
local FileHandler = require("src.FileHandler")
local FrontHandler = require("src.FrontHandler")

local app = turbo.web.Application:new({
	{"^/static/(.*)$", turbo.web.StaticFileHandler, "./static/"},
	{"^/files$", FileHandler},
	{"^/dash$", FrontHandler}
})

app.port = 8888

print("Glance is running on post " .. app.port)

app:listen(app.port)
turbo.ioloop.instance():start()
