

local function pathfixmultipleslash() -- i can't identify my error, so i'm using this fix to remove "//" from path
	GTerm.Path = string.gsub(GTerm.Path, "//", "/")
end

local function pathsanitise(text) -- remove last / 
	if string.sub( text, -1 ) == "/" then
		return string.sub( text, 1, -2 )
	end
	return text
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
--I am making this better--
--------As we speak--------
-----------fghdx-----------
---------------------------
--TODO:
--Remake and tidy it up.
--Find out a way to write outside of data folder.
--Add more features.

function GTerm.cat(client, command, arguments)
	pathfixmultipleslash()
	args = arguments
	number_of_args = table.getn(args)

	if number_of_args == 1 then

		--Not exactly the best way to do it. But ghetto always works.
		--If there is one argument it will either be help or to read
		--A file.

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
			if file.Exists(GTerm.Path .. args[1], "BASE_PATH") then --Check if the file exists.
				MsgC(Color(255,255,255), file.Read(GTerm.Path .. args[1], "BASE_PATH") .. "\n") --If it does print the contents.
			else
				GTerm.fuckalert("File does not exist.") --If it doesn't display an error
			end
		end
	end

	-- If there are two args it will be for an option and a file.
	if number_of_args == 2 then

		-- -n (--number) print with line numbers
		if args[1] == "-n" then --If the first argument is -n
			if file.Exists(GTerm.Path .. args[2], "BASE_PATH") then --check if file exists. I will probably move that to a function when I can be fucked.
				local text = file.Read(GTerm.Path .. args[2], "BASE_PATH") --Text is the contents of the file specified in arg 2.
				local lines = string.Explode("\n", text) --Break the file into a table. Each item in the table will be a line from the file.

				for k, v in pairs(lines) do --For every line of the file
					MsgC(Color(255,255,255), k .. " ", v .. "\n") --Print the line number and the line.
				end

			else
				GTerm.fuckalert("File does not exist.") --If it doesn't exist we display an error.
			end

		elseif args[1] == "-b" then -- -b (--number-nonblank) Numbers all non blank lines
			if file.Exists(GTerm.Path .. args[2], "BASE_PATH") then --If it exists yada yda
				local text = file.Read(GTerm.Path .. args[2], "BASE_PATH") --text = the file
				local lines = string.Explode("\n", text) -- Break the text up on every new line
				local current_line = 1 --Current line is 1.
				for k, v in pairs(lines) do --For each line
					if v == "" or string.byte(v, 1) == 13 then -- If it is blank 
						MsgC(Color(255,255,255),"\n") -- Do nothing but print a new line.
					else --If it is not blank.
						MsgC(Color(255,255,255), current_line .. " ", v .. "\n") --Print a current line along with the text.
						current_line = current_line + 1 -- Add one to the current line.
					end
				end
			else
				GTerm.fuckalert("File does not exist.") --Error if file does not exist.
			end
		elseif args[1] == "-A" then -- Print all characters. ^I for tab and $ for end of line
			--There is a better way to do this but I couldn't think of anything.
			if file.Exists(GTerm.Path .. args[2], "BASE_PATH") then --Check file
				local text = file.Read(GTerm.Path .. args[2], "BASE_PATH") --Set text
				local text = string.Explode("", text) --break the text up into a table. Each letter is a element in the table.
				local ascii = {} --Ascii values for letter will go here.

				for k, v in pairs(text) do --For each letter in text
					table.insert(ascii, string.byte(v)) --Turn it to ascii
				end
				
				for k, v in pairs(ascii) do --For each item in ascii
					if v == 9 then --If it is a tab
						text[k] = "^I" --Set the value in the text table to be ^I
					elseif v == 13 then -- If it is an end of line character
						text[k] = "$" --Change it to $
					end
				end

				text = table.concat(text) --Concat the table
				MsgC(Color(255,255,255), text .. "\n") --Print the new text
			else
				GT("File does not exist.")
			end
		elseif args[1] == "-T" then -- Prints tabs as ^I
			--This is pretty much the exact same as -A and -E
			if file.Exists(GTerm.Path .. args[2], "BASE_PATH") then --Check file
				local text = file.Read(GTerm.Path .. args[2], "BASE_PATH") --Set text
				local text = string.Explode("", text) --Explode text
				local ascii = {} --Make ascii table

				for k, v in pairs(text) do -- for rach letter
					table.insert(ascii, string.byte(v)) --Turn to ascii
				end

				for k, v in pairs(ascii) do --For each item in ascii
					if v == 9 then --chance the tabs
						text[k] = "^I" -- to this
					end
				end

				text = table.concat(text) --Concat table
				MsgC(Color(255,255,255), text .. "\n") --Print the text
			else
				GTerm.fuckalert("File does not exist.")
			end
		elseif args[1] == "-E" then -- Prints end of line characters as $
			--Same as others.
			if file.Exists(GTerm.Path .. args[2], "BASE_PATH") then --Check file
				local text = file.Read(GTerm.Path .. args[2], "BASE_PATH") --Read file
				local text = string.Explode("", text) --Split text
				local ascii = {} --ascii array

				for k, v in pairs(text) do --For each letter
					table.insert(ascii, string.byte(v)) --Make is ascii
				end
				
				for k, v in pairs(ascii) do --For each ascii
					if v == 13 then --if it is end of line
						text[k] = "$" --Make is $
					end
				end
 
				text = table.concat(text) --Concat
				MsgC(Color(255,255,255), text .. "\n") --Print
			else
				GTerm.fuckalert("File does not exist.")
			end
		else
			GTerm.fuckalert("Invalid option '" .. args[1] .. "' Try 'cat --help for more information.'") --If the option is not valid print this.
		end


	end

end
