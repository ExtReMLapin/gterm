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
	concommand.Add("pwd", GTerm.pwd)
	concommand.Add("ls",  GTerm.ls)
	concommand.Add("cd",  GTerm.cd)
	concommand.Add("mkdir", GTerm.mkdir)
	concommand.Add("specs", GTerm.specs)
	concommand.Add("cat", GTerm.cat) -- meow
end
