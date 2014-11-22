FReader = {}

FReader.Headers = {}
FReader.Headers.Linux_Binary = "\x7F" .."ELF" -- [strange char]ELF 
FReader.Headers.Windows_Binary = "\x4D\x5A\x90\x00" -- MZ

function FReader.getfiletype(fullpath)
	local tmpstr = string.Left(file.Read(fullpath, "BASE_PATH"), 4)
	
	for k, v in pairs(FReader.Headers) do
		if v == tmpstr then
			return k
		end
	end
end


local intropart1 = [[
 ___________________________________________________________
/-----------------------------------------------------------\
|---------------------------GTerm---------------------------|
\-----------------------------------------------------------/]]
local intropart2 = "\n |->"
local introend =[[
/                                                           \
\___________________________________________________________/
]]

 --heavy weird shit incoming, be ready
 local WindowsNT = {}

 WindowsNT["5.0"] = "Windows 2000"
 WindowsNT["5.1"] = "Windows XP"
 WindowsNT["5.2"] = "Windows XP"
 WindowsNT["6.0"] = "Windows Vista"
 WindowsNT["6.1"] = "Windows 7"
 WindowsNT["6.2"] = "Windows 8"
 WindowsNT["6.3"] = "Windows 8.1"
 WindowsNT["6.4"] = "Windows 10"

 local function get_dumps()
 	return file.Find("hl2_*",  "BASE_PATH")
 end

 local function get_lastdump()
 	if #get_dumps() > 0 then
 		local tmp = get_dumps()
 		return tmp[#get_dumps()]
 	else 
 		return "false"
 	end
 end

 local function get_dump()
		if string.len(file.Read(get_lastdump(), "BASE_PATH")) < 10000 then return "false" end -- come on how can your minidump file be empty
		return file.Read(get_lastdump(), "BASE_PATH") -- not on the wiki, don't ask me why
	end

	-------------------------------------
	----------------GPU------------------
	-------------------------------------
	
	local function gc_adr()
		if get_lastdump() == "false" then return 0 end
		if get_dump() == "false" then return 0 end
		return string.find(get_dump(), "Driver Name") + 13 -- oh no 13 nononononono
	end

	local function gc_adrend()
	if get_lastdump() == "false" then return 0 end
	if get_dump() == "false" then return 0 end
	return string.find(get_dump(), "\n", gc_adr() ) - 1
end

local function gc_get()
	if get_lastdump() == "false" then return "unknown" end
	if get_dump() == "false" then return "unknown" end
		return string.Right((string.Left(get_dump(), gc_adrend())), string.len((string.Left(get_dump(), gc_adrend())))-gc_adr()) -- yes, i know
	end

	-------------------------------------
	---------------OS--------------------
	-------------------------------------

	local function os_adr()
		if get_lastdump() == "false" then return 0 end
		if get_dump() == "false" then return 0 end
		return string.find(get_dump(), ") version ") + 9
	end

--[[			^^^^^^^^^^
				||||||||||
		Some players have a working minidump file but don't have some data
		Some investigations are required, feel free to fix that if you can
		--]]

		local function os_adrend()
		if get_lastdump() == "false" then return 0 end
		if get_dump() == "false" then return 0 end
		return string.find(get_dump(), "\n", os_adr() ) -1
	end

	local function os_get()
		if get_lastdump() == "false" then return nil end
		if get_dump() == "false" then return nil end
		return WindowsNT[string.Right((string.Left(get_dump(), os_adrend())), string.len((string.Left(get_dump(), os_adrend())))-os_adr())] -- yes, i know
	end

	-------------------------------------
	----------------RAM------------------
	-------------------------------------
	
	
	local function ram_adr()
		if get_lastdump() == "false" then return 0 end
		return string.find(get_dump(), "totalPhysical Mb") + 16
	end

	local function ram_adrend()
	if get_lastdump() == "false" then return 0 end
	return string.find(get_dump(), "\n", ram_adr() ) -2 
end

local function ram_get()
	if get_lastdump() == "false" then return "unknown" end
	if get_dump() == "false" then return "unknown" end
		return string.Right((string.Left(get_dump(), ram_adrend())), string.len((string.Left(get_dump(), ram_adrend())))-ram_adr()) .. "Mb" -- too lazy to format this, do it if you wants
	end
	
	-------------------------------------
	-------------------------------------

	local function getOSString()
	--	if 	system.IsSteamOS() then return "Linux (SteamOS)" end
	if 	system.IsLinux() then return "Linux" end
	if 	system.IsOSX() then return "OSX" end
	if 	system.IsWindows() then return os_get() or "Windows" end
end


function GTerm.specs()
	if system.IsWindows() then -- Lets go boi
		MsgC(Color(170,170,255), intropart1)
		if getOSString() != "Windows" then	MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), getOSString())	GTerm.writeSpaces( 55 - #getOSString() )		MsgC(Color(170,170,255), "|")end
		if gc_get() != "unknown" then		MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), gc_get()) 		GTerm.writeSpaces( 55 - #gc_get() )			MsgC(Color(170,170,255), "|")end
		if ram_get() != "unknown" then		MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), ram_get()) 		GTerm.writeSpaces( 55 - #ram_get() )			MsgC(Color(170,170,255), "|")end
		MsgC(Color(170,170,255), "\n")
		MsgC(Color(170,170,255), introend)
	end
end
