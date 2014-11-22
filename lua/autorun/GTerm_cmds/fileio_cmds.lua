if system.IsLinux() then -- checking if we can write into folders
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_linux.dll", "BASE_PATH" )
else
	GTerm.CanWrite = file.Exists( "garrysmod/lua/bin/gmsv_fileio_win32.dll", "BASE_PATH" )
end

if GTerm.CanWrite then require("fileio") end


function GTerm.mkdir(ply, cmd, args) -- make a new directory
	pathfixmultipleslash()
	if not GTerm.CanWrite then GTerm.fuckalert("module fileio is missing") return end
	if not args[1] then return end
	if file.Exists(GTerm.Path .. args[1], "BASE_PATH") or file.IsDir(GTerm.Path .. args[1], "BASE_PATH") then return end
	---fileio.MakeDirectory() -- later
end