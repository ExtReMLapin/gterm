GTerm = {}
GTerm.Path = "";

if system.IsLinux() then
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_linux.dll", "BASE_PATH" )
else
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_win32.dll", "BASE_PATH" )
end

function GTerm.pwd()
	MsgC(Color(50,250,50), "./" .. GTerm.Path .. "\n")
end

function GTerm.ls()
	local maxsize = 0;
	local tbl1, tbl2 = file.Find(GTerm.Path .. "*", "BASE_PATH")

		for k, v in pairs(tbl2) do -- folders
			MsgC(Color(50,250,50), string.format("./%s/\n", v))
		end

		for k, v in pairs(tbl1) do -- files
			if string.len(v) > maxsize then 
				maxsize = string.len(v) 
			end
		end


		for k, v in pairs(tbl1) do -- files
			local i = 0;
			local strlen = string.len(v)
			MsgC(Color(150,150,255), v);
			while (strlen < maxsize) do
				MsgC(Color(150,150,255), " ");
				strlen = strlen + 1
			end
			MsgC(Color(255,0,0), " | ");
			MsgC(Color(150,150,255), file.Size(GTerm.Path .. v, "BASE_PATH"));
			MsgC(Color(255,0,0), " | ");
			MsgC(Color(150,150,255), os.date( "%d.%m.%y", file.Time(GTerm.Path .. v, "BASE_PATH")) .. "\n");
		end
	end

local function pastfolder()
	local tblspl = string.Explode("/", GTerm.Path)
		table.remove(tblspl)
		table.remove(tblspl)
		GTerm.Path = table.concat(tblspl, "/") or ""
	return
end

function GTerm.cd(ply, cmd, args) -- darn
	if not args or table.Count(args) == 0 then return end
	if table.Count(args) == 1 and args[1] != "" then
		if args[1][1] == "."  and GTerm.Path == "" then return end
		if args[1] == ".." then
			pastfolder()
			return			
		end
		if (file.IsDir(GTerm.Path .. args[1] .. "/", "BASE_PATH")) then
			GTerm.Path = GTerm.Path .. args[1] .. "/"
		end

		if string.Left(args[1], 3) == "../" and string.len(args[1]) > 3 then
			pastfolder()	
			GTerm.Path = GTerm.Path .. string.Right(args[1], string.len(args[1]) - 3)
		end
	end
end

concommand.Add("pwd", GTerm.pwd,		file.Find("*", "BASE_PATH")[1], "print current folder")
concommand.Add("ls",  GTerm.ls,			{"no args"}, 					"print files and folders in current folder")
concommand.Add("cd",  GTerm.cd,			file.Find("*", "BASE_PATH")[2], "go in another folder")
