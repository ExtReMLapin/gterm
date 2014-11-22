GTerm.Path = "";

local function pathfixmultipleslash() -- i can't identify my error, so i'm using this fix to remove "//" from path
	GTerm.Path = string.gsub(GTerm.Path, "//", "/")
end

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


function GTerm.pwd() -- print path
	pathfixmultipleslash()
	MsgC(Color(50,250,50), "./" .. GTerm.Path .. "\n")
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
