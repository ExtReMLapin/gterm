local table = table

GTerm = {}
GTerm.Path = "";


local function pastfolder()  -- from ./garrysmod/lua/ to ./garrysmod/
	local tblspl = string.Explode("/", GTerm.Path)
		table.remove(tblspl)
		table.remove(tblspl)
		GTerm.Path = table.concat(tblspl, "/") .. "/" or ""
	return
end

local function pathsanitise(text) -- remove last / 
	if string.sub( text, -1 ) == "/" then
		return string.sub( text, 1, -2 )
	end
	return text
end

local function writeSpaces( num )
	MsgC( Color(255,255,255), string.rep( " ", num ) )
end

local function pathfixmultipleslash() -- i can't identify my error, so i'm using this fix to remove "//" from path
	GTerm.Path = string.gsub(GTerm.Path, "//", "/")
end

if system.IsLinux() then -- checking if we can write into folders
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_linux.dll", "BASE_PATH" )
else
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_win32.dll", "BASE_PATH" )
end

if GTerm.CanWrite then require("fileio") end


function GTerm.pwd() -- print path
	pathfixmultipleslash()
	MsgC(Color(50,250,50), "./" .. GTerm.Path .. "\n")
end

local function fuckalert(message)
	MsgC(Color(255,0,0), "/!\\   ");
	MsgC(Color(255,215,0), message);
	MsgC(Color(255,0,0), "   /!\\ \n");
end


function GTerm.mkdir(ply, cmd, args) -- make a new directory
	pathfixmultipleslash()
	if not GTerm.CanWrite then fuckalert("module fileio is missing") return end
	if not args[1] then return end
	if file.Exists(GTerm.Path .. args[1], "BASE_PATH") or file.IsDir(GTerm.Path .. args[1], "BASE_PATH") then return end
	---fileio.MakeDirectory() -- later
end

function GTerm.ls() -- print files infos and directories
	pathfixmultipleslash()
	local maxsize = 0;
	local maxsize2 = 0;
	local tbl1, tbl2 = file.Find(GTerm.Path .. "*", "BASE_PATH")

		for k, v in pairs(tbl2) do -- folders
			MsgC(Color(50,250,50), string.format("./%s/\n", v))
		end

		for k, v in pairs(tbl1) do -- files
			if #v > maxsize then 
				maxsize = #v
			end
		end

		for k, v in pairs(tbl1) do -- files
			if #tostring(file.Size(GTerm.Path .. v, "BASE_PATH")) > maxsize2 then 
				maxsize2 = #tostring(file.Size(GTerm.Path .. v, "BASE_PATH"))
			end
		end


		for k, v in pairs(tbl1) do 
			local strlen = #v
			local strlen2 =#tostring(file.Size(GTerm.Path .. v, "BASE_PATH"))

			MsgC(Color(150,150,255), v);
			writeSpaces( maxsize - strlen )
			MsgC(Color(255,0,0), " | Size -> ");
			MsgC(Color(150,150,255), file.Size(GTerm.Path .. v, "BASE_PATH"));
			writeSpaces( maxsize2 - strlen2 )

			MsgC(Color(255,0,0), " | Last time edited -> ");
			MsgC(Color(150,150,255), os.date( "%d.%m.%y", file.Time(GTerm.Path .. v, "BASE_PATH")) .. "\n");
		end
end



function GTerm.cd(ply, cmd, args) -- fall back !
	pathfixmultipleslash()
	if not args or #args == 0 then return end
	text = args[1]
	text = pathsanitise(text)

	if #args == 1 and text  != "" then
		if text[1] == "."  and GTerm.Path == "" then return end
		if text == ".." then
			pastfolder()
			return			
		end
		if (file.IsDir(GTerm.Path .. text .. "/", "BASE_PATH")) then
			GTerm.Path = GTerm.Path .. text .. "/"
		end

		if string.Left(text, 3) == "../" and #args[1] > 3 then
			pastfolder()
			if (file.IsDir(GTerm.Path ..string.Right(text, #args[1] - 3) .. "/", "BASE_PATH")) then
				GTerm.Path = GTerm.Path .. string.Right(text, #args[1] - 3) .. "/"
			end
			--GTerm.Path = GTerm.Path .. "/"
		end
	end
end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--------------------------------Files analyse start---------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--------------------------------Local System----------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


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

	--[[net.Receive( "specs_GetInfo", function( length, client )
		local system = system
		local 	tbl = {}
				tbl["Country"] = system.GetCountry() 	-- Country
				tbl["OperatingSystem"] = getOSString()	-- Operating System
				tbl["ScrW"] = ScrW()					-- ScrW
				tbl["ScrH"] = ScrH()					-- ScrH
				tbl["TotalPixels"] = ScrH()*ScrW()		-- How many pixels ?
				tbl["GraphicCard"] = gc_get()			-- ho god it's slow
				tbl["RAM"] = ram_get()					-- still slow
				
		net.Start( "specs_SendInfo" )
		net.WriteTable(tbl)
		net.SendToServer()
				
	end ) -- ]]
	
	
function GTerm.specs()
	if system.IsWindows() then -- Lets go boi
											MsgC(Color(170,170,255), intropart1)
		if getOSString() != "Windows" then	MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), getOSString())	writeSpaces( 55 - #getOSString() )		MsgC(Color(170,170,255), "|")end
		if gc_get() != "unknown" then		MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), gc_get()) 		writeSpaces( 55 - #gc_get() )			MsgC(Color(170,170,255), "|")end
		if ram_get() != "unknown" then		MsgC(Color(170,170,255), intropart2) MsgC(Color(50,250,50), ram_get()) 		writeSpaces( 55 - #ram_get() )			MsgC(Color(170,170,255), "|")end
											MsgC(Color(170,170,255), "\n")
											MsgC(Color(170,170,255), introend)
	end
end





concommand.Add("pwd", GTerm.pwd)
concommand.Add("ls",  GTerm.ls)
concommand.Add("cd",  GTerm.cd)
concommand.Add("mkdir", GTerm.mkdir)
concommand.Add("specs", GTerm.specs)
