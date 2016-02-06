-- vim: ts=4 sw=4
local wifimap={AUTH_OPEN=0,AUTH_WEP=1,AUTH_WPA_PSK=2,AUTH_WPA2_PSK=3,AUTH_WPA_WPA2_PSK=4}
local hiddenwifi=0

print("*** configure wifi")
wifi.sta.eventMonStop("unreg all")

wifi.sta.config(
	g.config.wificlient.ssid,
	g.config.wificlient.password,
	g.config.wificlient.auto
)

if g.config.wifiap.hidden then hiddenwifi=1 end
wifi.ap.config({
	ssid=g.config.wifiap.ssid,
	pwd=g.config.wifiap.password,
	auth=wifimap[g.config.wifiap.authentication],
	hidden=hiddenwifi
})

wifi.setmode(wifi[g.config.wifimode])
if g.config.wifimode~="SOFTAP" then
	wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("WIFI STATION: IDLE") end)
	wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("WIFI STATION: CONNECTING") end)
	wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("WIFI STATION: WRONGPWD") end)
	wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("WIFI STATION: APNOTFOUND") end)
	wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("WIFI STATION: FAILED") end)
	wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("WIFI STATION: GOTIP "..wifi.sta.getip()) end)
	wifi.sta.eventMonStart(250)
end
if g.config.wifimode~="STATION" then
	print("WIFI AP: "..tostring(wifi.ap.getip()))
end
