-- vim: ts=4 sw=4
g={
	luafiles={"httpserver.lua","httpserver-request.lua","httpserver-basicauth.lua","base64_v2.lua","httpserver-conf.lua","httpserver-static.lua","httpserver-header.lua","httpserver-error.lua","wifi.lua"}
}

-- basic functions
function errorreturn(errormsg)
	print("ERROR: "..tostring(errormsg))
	file.close()
	collectgarbage()
	return nil
end

for _,filename in pairs(g.luafiles) do
	print("compile '"..filename.."'")
	node.compile(filename)
	file.remove(filename)
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
print("*** configure wifi")
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("WIFI STATION: IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("WIFI STATION: CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("WIFI STATION: WRONGPWD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("WIFI STATION: APNOTFOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("WIFI STATION: FAILED") end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("WIFI STATION: GOTIP "..tostring(wifi.sta.getip())) end)
wifi.sta.eventMonStart(250)
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

dofile("httpserver.lc")(80)
