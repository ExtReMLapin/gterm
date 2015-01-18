GTerm = {}

function GTerm.writeSpaces( num )
	MsgC( Color(255,255,255), string.rep( " ", num ) )
end

function GTerm.fuckalert(message)
	MsgC(Color(255,0,0), "/!\\   ");
	MsgC(Color(255,215,0), message);
	MsgC(Color(255,0,0), "   /!\\ \n");
end

include("GTerm_cmds/move_cmds.lua")
include("GTerm_cmds/fileio_cmds.lua")
include("GTerm_cmds/file_analysis.lua")
include("GTerm_cmds/infos_cmds.lua")

if SERVER then
	concommand.Add("pwd", 	GTerm.pwd, nil, "Print the current directory")
	concommand.Add("ls",  	GTerm.ls, nil, "Print files and folders in the current directory")
	concommand.Add("cd",  	GTerm.cd, GTerm.get_all_poss_paths, "Move to another directory")
	concommand.Add("mkdir", GTerm.mkdir, nil, "Make a dir")
	concommand.Add("specs", GTerm.specs, nil, "Get specs" )
	concommand.Add("cat", 	GTerm.cat, nil, "Grint a file") -- meow
end
