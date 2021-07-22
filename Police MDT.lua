script_author('AMR')
script_name('Police MDT')

local sampev = require 'lib.samp.events'
memory = require "memory"
encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8
require "lib.moonloader"
imgui = require 'imgui'
local overlay = imgui.ImBool(false)
local sus = false
local radar = true
RadarMessageTable = {}

suspects = {' '}

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(1)
    end
	sampRegisterChatCommand("mdt", function(arg) 
	if arg == '' then
	overlay.v = not overlay.v
	end
	if arg == 'radar' then
	sampAddChatMessage("Radar dispatch alerts toggled", 0x00DD00)
	sus = false
	radar = not radar
	end
	if arg == 'suspects' then
	radar = false
	sus = not sus
	end
	imgui.ShowCursor = false
	
	end)

    while sampGetGamestate() < 3 do
        wait(1)
    end
	
     while true do
         wait(0)
         imgui.Process = overlay.v
     end
end


function imgui.OnDrawFrame()
    if overlay.v then
		if radar then
		local sw, sh = getScreenResolution()
        imgui.SetNextWindowPos(imgui.ImVec2(1150,560),imgui.Cond.Always,imgui.ImVec2(0.5,0.5)) -- позиция
        imgui.Begin("Test", overlay.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		imgui.Text(u8"Police Mobile Data Terimnal Version 1.0 BETA")
        imgui.Text(u8"State Of San Andreas Police Department                                     ")
		imgui.TextColored(imgui.ImVec4(1,1,0,256), u8"---------------------------------------------------------------------------------")
			for i=15,1,-1 do
				if RadarMessageTable[i] == nil then
					imgui.Text(u8"")
				else
					if string.find(RadarMessageTable[i],'----------^Suspect^----------') then
						imgui.TextColored(imgui.ImVec4(1,0,0,256), u8""..RadarMessageTable[i])
					else
						imgui.Text(u8""..RadarMessageTable[i])
					end
				end
			end
		imgui.TextColored(imgui.ImVec4(1,1,0,256), u8"---------------------------------------------------------------------------------")
        imgui.TextColored(imgui.ImVec4(1,1,1,256), u8"RADAR DISPATCH ALERT")
        imgui.End()
		end
		if sus then
			local sw, sh = getScreenResolution()
			imgui.SetNextWindowPos(imgui.ImVec2(1150,560),imgui.Cond.Always,imgui.ImVec2(0.5,0.5)) -- позиция
			imgui.Begin("Sus", overlay.v, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
			imgui.Text(u8"Police Mobile Data Terimnal Version 1.0 BETA")
			imgui.Text(u8"State Of San Andreas Police Department                                     ")
			imgui.TextColored(imgui.ImVec4(1,1,0,256), u8"---------------------------------------------------------------------------------")
				for i=15,1,-1 do
					if suspects[i] == nil then
						imgui.Text(u8"")
					else
					imgui.TextColored(imgui.ImVec4(1,1,0,256), u8""..suspects[i])
					end
				end
			imgui.TextColored(imgui.ImVec4(1,1,0,256), u8"---------------------------------------------------------------------------------")
			imgui.TextColored(imgui.ImVec4(1,1,1,256), u8"SUSPECTS TAB")
			imgui.End()
		end
    end
end

function addRadarOverlay(arg)
		arg = arg:gsub("{%w+}","")
		arg = arg:gsub("%[Dispatch%] Radar:","")
		arg = arg:gsub("%(plate","")
		arg = arg:gsub("%) going",":")
		arg = arg:gsub("km/h at","km/h :")
		arg = arg:gsub("Las Venturas","LV")
		arg = arg:gsub("Los Santos","LS")
	file = io.open('moonloader/Speeders.txt', "a")
	file:write("\n"..arg)
	file:close()
		for i=18,1,-1 do
		RadarMessageTable[i] = RadarMessageTable[i-1]
			if i == 1 then
				RadarMessageTable[1] = arg
			end
		end
end

function sampev.onServerMessage(color, text)

		if overlay.v then
			if (string.find(text, "Radar:") and string.find(text, "plate:") and string.find(text, "going") and string.find(text, "h at")) or string.find(text, "This vehicle is being driven by a wanted person.") then
				text = text:gsub(" This vehicle is being driven by a wanted person.","----------^Suspect^----------")
				addRadarOverlay(text)
				else
				sampAddChatMessage(text, bit.rshift(color, 8))
			end

			return false
		end

		if  not overlay.v and ((string.find(text, "Radar:") and string.find(text, "plate:") and string.find(text, "going") and string.find(text, "h at")) or string.find(text, "This vehicle is being driven by a wanted person.")) then
		file = io.open('moonloader/Speeders.txt', "a")
		file:write("\n"..text)
		file:close()
		end
	end
	
function sampev	.onShowDialog(dialogId, style, title, button1, button2, text)
	encodedtext = u8(text)
	savedtext = u8:decode(encodedtext)
	if string.find(savedtext, "SUSPECTED BY	SUSPECT	DATE") then
	suspects = {' '}
   local i = 1
   for k, v in string.gmatch(savedtext, "(%a+_%a+%(%d+%))	202") do
    table.insert(suspects,i,k)
    i = i+1
    end
end
return {dialogId, style, title, button1, button2, text}
end