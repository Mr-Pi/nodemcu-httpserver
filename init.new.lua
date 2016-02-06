-- vim: ts=4 sw=4
require"base64_v2"
g={
	luafiles={"httpserver.lua","httpserver-request.lua","httpserver-basicauth.lua","base64_v2.lua","httpserver-static.lua","httpserver-header.lua","httpserver-error.lua","wifi.lua"}
}

-- basic functions
function errorreturn(errormsg)
	print("ERROR: "..tostring(errormsg))
	file.close()
	collectgarbage()
	return nil
end

for _,filename in pairs(g.luafiles) do
	if file.open(filename) then
		file.close()
		print("compile '"..filename.."'")
		node.compile(filename)
		file.remove(filename)
	end
end

-- configuration
print("*** reading configuration")
if not file.open("http-init/config.json") then
	return errorreturn("failed to open configuration")
end

if not pcall(function() g.config=cjson.decode(file.read()) end) then
	return errorreturn("failed to parse configuration")
end

-- wifi
dofile("wifi.lc")

-- httpserver
if g.config.safemode then
	print("*** starting httpserver in safemode")
	g.prefix="http-init/"
	tmr.alarm(0, 30000, tmr.ALARM_SINGLE, function()
		print("*** switching to normal httpserver mode")
		g.prefix="http/"
	end)
else
	print("*** starting httpserver in normal mode")
	g.prefix="http/"
end

collectgarbage()
dofile("httpserver.lc")(80)
