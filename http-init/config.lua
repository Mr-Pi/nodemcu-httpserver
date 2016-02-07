-- vim: ts=4 sw=4

local function updateWiFi(config)
	wificonf=require"wlan"

	if	g.config.wifiap.ssid          ~=config.wifiap.ssid or
		g.config.wifiap.password      ~=config.wifiap.password or
		g.config.wifiap.hidden        ~=config.wifiap.hidden or
		g.config.wifiap.authentication~=config.wifiap.authentication then
		wificonf.configAP()
	end

	if	g.config.wificlient.ssid    ~=config.wificlient.ssid or
		g.config.wificlient.password~=config.wificlient.password or
		g.config.wificlient.auto    ~=config.wificlient.auto then
		wificonf.configStation()
	end

	if g.config.wifimode~=config.wifimode then
		wificonf.configMode()
	end

	wificonf=nil
	config=nil
	collectgarbage()
end

return function(connection, req, args)
	if req.method=="POST" or req.method=="PUT" then
		print("*** updating configuration")
		local json=""
		local config=req.getRequestData()

		if not pcall(function() json=cjson.encode(config) end) then
			return errorreturn("failed to encode configuration")
		end
		if not file.open("http-init/config.json","w+") then
			return errorreturn("failed to open configuration file")
		end
		file.write(json)
		file.close()

		updateWiFi(config)
		g.config=config

		json=nil
		config=nil
		connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
		connection:send("{\"okay\":true}")
		print("*** configuration updated")
		print("heap: "..tostring(node.heap()))
		tmr.unregister(0)
	end
	collectgarbage()
end
