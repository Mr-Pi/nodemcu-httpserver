-- vim: ts=4 sw=4

wifi.sta.config(
	g.config.wificlient.ssid,
	g.config.wificlient.password,
	g.config.wificlient.auto
)
local hiddenwifi=0
local wifimap={AUTH_OPEN=0,AUTH_WEP=1,AUTH_WPA_PSK=2,AUTH_WPA2_PSK=3,AUTH_WPA_WPA2_PSK=4}
if g.config.wifiap.hidden then hiddenwifi=1 end
wifi.ap.config({
	ssid=g.config.wifiap.ssid,
	pwd=g.config.wifiap.password,
	auth=wifimap[g.config.wifiap.authentication],
	hidden=hiddenwifi
})
wifi.setmode(wifi[g.config.wifimode])
if g.config.wifimode~="STATION" then
	print("WIFI AP: "..tostring(wifi.ap.getip()))
end
