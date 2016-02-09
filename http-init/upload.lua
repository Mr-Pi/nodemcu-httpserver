-- vim: ts=4 sw=4

return function(connection, req, args)
	if req.method=="POST" or req.method=="PUT" then
		local okay=true
		print("*** firmware is updating")
		local data=req.getRequestData()

		for filename,content in pairs(data) do
			if not file.open(filename,"w+") then
				okay=false
				errorreturn("failed to open firmware update file: "..tostring(filename))
			end
			if not file.write(base64.dec(content)) then
				okay=false
				errorreturn("failed to write firmware update file: "..tostring(filename))
			end
			print("*** firmware updated: "..tostring(filename))
			file.close()
			content=nil filename=nil
			collectgarbage()
		end

		data=nil
		connection:send("HTTP/1.0 200 OK\r\nContent-Type: application/json\r\nCache-Control: private, no-store\r\n\r\n")
		connection:send("{\"okay\":"..tostring(okay).."}")
	end
	collectgarbage()
end
