package = "glance"
version = "0.1.0-0"
source = {
   url = "http://github.com/jessehorne/glance" -- We don't have one yet
}
description = {
   summary = "A beautiful file browsing application built with Turbo.",
   detailed = [[
		coming soon...
   ]],
   homepage = "http://github.com/jessehorne/glance",
   license = "MIT"
}
dependencies = {
   "turbo >= 2.1-2",
	"luafilesystem",
	"mimetypes",
	"lua-vips",
	"basexx"
}
build = {
   type = "builtin",
	modules = {}
}
