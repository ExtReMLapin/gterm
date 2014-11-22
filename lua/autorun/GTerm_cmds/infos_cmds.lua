

local function pathfixmultipleslash() -- i can't identify my error, so i'm using this fix to remove "//" from path
	GTerm.Path = string.gsub(GTerm.Path, "//", "/")
end

local function pathsanitise(text) -- remove last / 
	if string.sub( text, -1 ) == "/" then
		return string.sub( text, 1, -2 )
	end
	return text
end

local function file_exists(f)
	if file.Exists(f, "BASE_PATH") then return true end
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
			GTerm.writeSpaces( maxsize - strlen )
			MsgC(Color(255,0,0), " | Size -> ");
			MsgC(Color(150,150,255), file.Size(GTerm.Path .. v, "BASE_PATH"));
			GTerm.writeSpaces( maxsize2 - strlen2 )

			MsgC(Color(255,0,0), " | Last time edited -> ");
			MsgC(Color(150,150,255), os.date( "%d.%m.%y", file.Time(GTerm.Path .. v, "BASE_PATH")) .. "\n");
		end
end



---------------------------
------------Cat------------
---------------------------
---Should be tidy enough---
----------for now----------
-----------fghdx-----------
---------------------------
--Once fileio is sussed I can do the rest.

function GTerm.cat(client, command, arguments)
	pathfixmultipleslash() --Fix directory if it is broken
	args = arguments 
	number_of_args = table.getn(args)

	function cat_to_ascii(str) --Turn a string into an array of ascii codes
		if !file_exists(str) then return end --If the file does not exist don't do this.
		local text = file.Read(str, "BASE_PATH") --Set text
		local text = string.Explode("", text) --break the text up into a table. Each letter is a element in the table.
		local ascii = {} --Ascii values for letter will go here.
		for k, v in pairs(text) do --For each letter in text
			table.insert(ascii, string.byte(v)) --Turn it to ascii
		end
		return ascii, text
	end

	if number_of_args == 1 then
		--Not exactly the best way to do it. But ghetto always works.
		--If there is one argument it will either be help or to read
		--A file.

		local file_path = tostring(GTerm.Path)
		local file_name = tostring(args[1])
		local tocat = file_path .. file_name


		if args[1] == "--help" or args[1] == "-h" then --If the arg is --help or -h print the help
			MsgC(Color(255,255,255), "Cat Help:\n")
			MsgC(Color(255,255,255), "Usage:\n")
			MsgC(Color(255,255,255), " cat FILE") GTerm.writeSpaces(20 - string.len("cat FILE")) MsgC(Color(255,255,255), "View the contents of a file\n")
			MsgC(Color(255,255,255), " cat OPTION FILE") GTerm.writeSpaces(20 - string.len("cat OPTION FILE"))  MsgC(Color(255,255,255), "View the contents of a file modified by the option.\n\n")
			MsgC(Color(255,255,255), "Options:\n")
			MsgC(Color(255,255,255), " -n") GTerm.writeSpaces(20 - 2) MsgC(Color(255,255,255), "Print line numbers\n")
			MsgC(Color(255,255,255), " -b") GTerm.writeSpaces(20 - 2) MsgC(Color(255,255,255), "Print line numbers on all non blank lines.\n")
			MsgC(Color(255,255,255), " -A") GTerm.writeSpaces(20 - 2) MsgC(Color(255,255,255), "Print end of line and tab charaters as $(end of line) and ^I(tab)\n")
			MsgC(Color(255,255,255), " -T") GTerm.writeSpaces(20 - 2) MsgC(Color(255,255,255), "Print tab charaters as ^I\n")
			MsgC(Color(255,255,255), " -E") GTerm.writeSpaces(20 - 2) MsgC(Color(255,255,255), "Print end of line charaters as $\n\n")
			MsgC(Color(255,255,255), " More features to come in the future.\n")

			
		else --Otherwise it will just print a file.
			if file_name[-1] == "*" then --If the last character of the file string is * then
				local files, dirs = file.Find(tocat, "BASE_PATH") --Get every file name in the specified directory
				for k, v in pairs(files) do --For each file
					local loc = string.sub(tocat, 1, -2) --Remove the * from the path
					local file_path = loc..v --Append the file name to the path
					if !file_exists(file_path) then GTerm.fuckalert("File does not exist.") return end --Check if the file exists. If it doesn't display an error
					cat_without_options(file_path) --View the cat_without_options function below.
				end
			else --If the last character is not * just do this.
				if !file_exists(tocat) then GTerm.fuckalert("File does not exist.") return end --Check if the file exists. If it doesn't display an error
				cat_without_options(tocat) --view function below
			end

		end
	end

	-- If there are two args it will be for an option and a file.
	if number_of_args == 2 then
		local file_path = tostring(GTerm.Path) 
		local file_name = tostring(args[2])
		local tocat = file_path .. file_name
		
		if file_name[-1] == "*" then --If the last letter of string is *
			local files, dirs = file.Find(tocat, "BASE_PATH") --Get every file and folder in the directory
			for k, v in pairs(files) do --For each file
				local loc = string.sub(tocat, 1, -2) --Remove the * from the string
				if !file_exists(loc..v) then GTerm.fuckalert("File does not exist.") return end --Check if the file exists. If it doesn't display an error
				cat_with_options(loc..v, args[1]) --View the cat_with_options function below
			end
		else --If it is just a normal file
			if !file_exists(tocat) then GTerm.fuckalert("File does not exist.") return end --Check if the file exists. If it doesn't display an error
			cat_with_options(tocat, args[1]) --Print normally
		end


		

	end

end

--This function is for printing a file normally, without options.
function cat_without_options(f)
	MsgC(Color(255,255,255), file.Read(f, "BASE_PATH") .. "\n") --If it does print the contents.
end

--This function is for printing a file with a specified option.
function cat_with_options(f, op)
	local text = file.Read(f, "BASE_PATH") --Text is the contents of the file specified in arg 2.
	local lines = string.Explode("\n", text) --Break the file into a table. Each item in the table will be a line from the file.

	-- -n (--number) print with line numbers
	if op == "-n" then --If the first argument is -n
			for k, v in pairs(lines) do --For every line of the file
				MsgC(Color(255,255,255), k .. " ", v .. "\n") --Print the line number and the line.
			end
	elseif op == "-b" then -- -b (--number-nonblank) Numbers all non blank lines
			local current_line = 1 --Current line is 1.
			for k, v in pairs(lines) do --For each line
				if v == "" or string.byte(v, 1) == 13 then -- If it is blank 
					MsgC(Color(255,255,255),"\n") -- Do nothing but print a new line.
				else --If it is not blank.
					MsgC(Color(255,255,255), current_line .. " ", v .. "\n") --Print a current line along with the text.
					current_line = current_line + 1 -- Add one to the current line.
				end
			end
	elseif op == "-A" or op == "-T" or op == "-E" then -- Print all characters. ^I for tab and $ for end of line
		--There is a better way to do this but I couldn't think of anything.
			local ascii, text = cat_to_ascii(f)

			for k, v in pairs(ascii) do --For each item in ascii
				if v == 9 then --If it is a tab
					if op == "-A" or op == "-T" then --If the option is -A or -T do this
						text[k] = "^I" --Set the value in the text table to be ^I
					end
				elseif v == 13 then -- If it is an end of line character
					if op == "-A" or op == "-E" then --If the option is -A or -E do this
						text[k] = "$" --Change it to $
					end
				end
			end
			MsgC(Color(255,255,255), table.concat(text) .. "\n") --Print the new text
	
	else
		GTerm.fuckalert("Invalid option '" .. op .. "' Try 'cat --help for more information.'") -- Print an error
	end
end
