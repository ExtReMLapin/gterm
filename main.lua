GTerm = {}

GTerm.Path = "";

if system.IsLinux() then
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_linux.dll", "BASE_PATH" )
else
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_win32.dll", "BASE_PATH" )
end

function GTerm.pwd()
	if GTerm.Path == "" then 
		print("./")
	else
		print(GTerm.Path)
	end
end

function GTerm.ls()
	local tbl1, tbl2 = file.Find(GTerm.Path .. "*", "BASE_PATH")

		for k, v in pairs(tbl2) do -- folders
			print(string.format("./%s/", v))
		end

		for k, v in pairs(tbl1) do -- files
			print(string.format("%s | %i", v, string.len(file.Read(GTerm.Path .. v, "BASE_PATH"))))
		end
	end


function GTerm.cd(ply, cmd, args) -- darn
	if not args or table.Count(args) == 0 then return end

	if table.Count(args) == 1 and args[1] != "" then
		if args[1][1] == "."  and GTerm.Path == "" then return end
		if args[1] == ".." then
			local tblspl = string.Explode("/", GTerm.Path)
			table.remove(tblspl)
			table.remove(tblspl)
			GTerm.Path = table.concat(tblspl, "/") or ""
			return
		end
		GTerm.Path = GTerm.Path .. args[1] .. "/"
	end
end

concommand.Add("pwd", GTerm.pwd,		file.Find("*", "BASE_PATH")[1], "print current folder")
concommand.Add("ls",  GTerm.ls,			{"no args"}, 					"print files and folders in current folder")
concommand.Add("cd",  GTerm.cd,			file.Find("*", "BASE_PATH")[2], "go in another folder")
