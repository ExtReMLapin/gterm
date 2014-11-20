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
	local text1 = text
	while (string.reverse(text1)[1] == "/") do
			text1 = string.Left(text1,#(text1)-1)
	end
	return text1
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

concommand.Add("pwd", GTerm.pwd,		file.Find("*", "BASE_PATH")[1], "print current folder")
concommand.Add("ls",  GTerm.ls,			{"no args"}, 					"print files and folders in current folder")
concommand.Add("cd",  GTerm.cd,			file.Find("*", "BASE_PATH")[2], "go in another folder")
concommand.Add("mkdir", GTerm.mkdir)
