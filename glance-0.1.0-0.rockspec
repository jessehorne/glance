package = "glance"
version = "0.1.0-0"
source = {
   url = "http://github.com/jessehorne/glance" -- We don't have one yet
}
description = {
   summary = "A beautiful file browsing application built with kolba.",
   detailed = [[
		coming soon...
   ]],
   homepage = "http://github.com/jessehorne/glance",
   license = "MIT"
}
dependencies = {
   "lua == 5.3",
	"luafilesystem"
}
build = {
   type = "builtin",
	modules = {}
}
