--log path
local folderPath = "F:/FF14/!gil/"
-- first char cardinality and variable declaration
local feesh_c = 2

--define the fisherpeople here
local which_one = {
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0},
{"Firstname Lastname@Server", 0}
}

--[[
the above table works like this:
firstname last name@server (obvious), ?
? = 0 or 1,
0 means teleport to fc estate and try to get into FC entrance. 
1 means teleport to fc estate and use a nearby retainer bell (navmesh)


you need navmesh and visland, you need to NOT use "wait in lobby" in autoretainer
you need the version of snd related to the repo where you found this
you need to have each char on the fisher job.  lalter version will fix this.
having liza's discard helper will help with discarding garbage fish



---------
---TODO
---------
for next version use
if IsAddonVisible("IKDResult") then
    yield("/wait 15")
    yield("/pcall IKDResult false 0")
end
--to exit summary

--add this somewhere to verify right char
GetCharacterName(true) gives full name and server

--check pinned mesages with @em for some stuff like changing jobs automatically whicih requires gearsets for instructions
--add in config file that checks levels of chars. if they are under 90 they will be considered. and lowest level one will be selected

------------------------------------------------
------------------------------------------------
------------------------------------------------
------------------------------------------------
------------------------------------------------
------------------------------------------------
------------------------------------------------
--
checking charconditions
pre fishing condition 1
33 34 35 56 while watching cutscene intro
34 56 while waiting on prep ring to dissapear to let people start duty
6 34 56 while fishing
+42 sometimes (when reeling catch or casting) and 43 always once casted. 6 is always on while in gathering mode. while fishing
+35 for cutscene transitions to new areas
33 34 while looking at leave menu, 35 is off _> this is what we use
]]--

function visland_stop_moving()
 yield("/wait 3")
 muuv = 1
 muuvX = GetPlayerRawXPos()
 muuvY = GetPlayerRawYPos()
 muuvZ = GetPlayerRawZPos()
 while muuv == 1 do
	yield("/wait 1")
	if muuvX == GetPlayerRawXPos() and muuvY == GetPlayerRawYPos() and muuvZ == GetPlayerRawZPos() then
		muuv = 0
	end
	muuvX = GetPlayerRawXPos()
	muuvY = GetPlayerRawYPos()
	muuvZ = GetPlayerRawZPos()
 end
 yield("/echo movement stopped - time for GC turn ins or whatever")
 yield("/visland stop")
 yield("/wait 3")
end

-- random number function
function getRandomNumber(min, max)
  return math.random(min,max)
end

-- main fishing function will run per set interval time
local feesh_char = "firstname lastname@server"  --placeholder don't change this variable

--for echoing later
smol_increment = 0

local function vich_one()
	if feesh_c == 0 then feesh_c = #which_one end
	if feesh_c > #which_one then feesh_c = 1 end
	feesh_char = which_one[feesh_c][1]
end

--prep the variable for the echo at the end
vich_one()

function fishing()  
--turn off multi for teleporting to limsa to queue for fishing
--	yield("/ays multi")

	--set the variable for the char to load
	vich_one()
	feesh_c = feesh_c + 1

	yield("/echo "..feesh_char)
	
	--now we have to keep trying until we are on the right character.... just in case we are not.
	while feesh_char ~= GetCharacterName(true) do
		yield("/ays relog " ..feesh_char)
		yield("/wait 3")

		-- set the echo variable again so we can say what is next
		vich_one()

		yield("/waitaddon _ActionBar <maxwait.600><wait.5>")
	end

	--ok we made it to the right character. let us continue.
	
	-- Teleport to Lisma
	yield("/tp Limsa Lominsa Lower Decks <wait.5>")
	yield("/waitaddon _ActionBar <maxwait.600><wait.10>")
	
	yield("/target Aetheryte <wait.2>")
	yield("/target Aetheryte <wait.2>")
	yield("/target Aetheryte <wait.2>")

	yield("/lockon on")
	yield("/automove on")
	yield("/send D")
	yield("/send D")
	yield("/wait 3")

	yield("/pinteract <wait.2>")
	yield("/pcall SelectString true 0")
	yield("/pcall TelepotTown false 11 3u <wait.1>") -- Arcanists' Guild
	yield("/pcall TelepotTown false 11 3u <wait.1>")
	yield("/wait 10")

	yield("/ac sprint")

	--repair catte if we are at 99% durability or lower and have at least 5000 gil
	while NeedsRepair(99) and  GetItemCount(1) > 4999 do
		PathfindAndMoveTo(-397.46423339844,3.0999958515167,78.562309265137,false) 
		visland_stop_moving()
		yield("/target Merchant & Mender")
		yield("/wait 1")
		yield("/lockon on")
		yield("/wait 1")
		yield("/pinteract")
		yield("/wait 1")
		yield("/pcall SelectIconString true 1")
		yield("/wait 1")
		yield("/pcall Repair true 0")
		yield("/wait 1")
		yield("/pcall Repair true 1")
		yield("/wait 1")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1>")
		yield("/wait 3")
	end

	--dryskthota
	PathfindAndMoveTo(-409.42459106445,3.9999997615814,74.483444213867,false) 
	visland_stop_moving()
	yield("/wait 1")
	fishqtest = false
	toolong = 0
	fishqtest = GetCharacterCondition(91)
	while (type(fishqtest) == "boolean" and fishqtest == false) do
		yield("/target Dryskthota")
		yield("/pinteract <wait.2>")
		yield("/wait 1")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1.5>")
		yield("/send ESCAPE <wait.1>")
		yield("/wait 10")
		fishqtest = GetCharacterCondition(91)
		toolong = toolong  + 1
		if toolong > 30 then
			fishqtest = true
		end
	end

	--get current area
	yield("/echo Current area"..GetZoneID())
	zown = GetZoneID()
	fzown = GetZoneID()
	--check if area has changed every 5 seconds.
	while (zown == fzown) and (toolong < 30) do
		fzown = GetZoneID()	
		yield("/wait 5")
	end
	--if so then wait for 30 seconds then start heading to the visland location
	yield("<wait.30.0>")
	--yield("/visland execonce OceanFishing")
	--yield("/visland moveto 7.451 6.750 -4.043")
	local randomNum = getRandomNumber(1,8)
    if randomNum == 1 then yield("/visland moveto 6.641 6.711 -0.335")
		elseif randomNum == 2 then yield("/visland moveto 7.451 6.750 -4.043")
		elseif randomNum == 3 then yield("/visland moveto 7.421 6.750 -5.462")
		elseif randomNum == 4 then yield("/visland moveto 7.391 6.711 -7.936")
		elseif randomNum == 5 then yield("/visland moveto -7.450 6.711 -8.982")
		elseif randomNum == 6 then yield("/visland moveto -7.548 6.750 -6.590")
		elseif randomNum == 7 then yield("/visland moveto -7.482 6.739 -2.633")
		elseif randomNum == 8 then yield("/visland moveto -7.419 6.711 -0.113")
	end	--keep checking for that original area - once it is back. turn /ays multi back on
	--also spam fishing

	while (zown ~= fzown) do
		fzown = GetZoneID()
		if GetCharacterCondition(43)==false then
		   yield("/discardall")
		   yield("/wait 5")
		end
		if GetCharacterCondition(43)==false then
			yield("/ac cast")
			yield("/wait 1")
		end
		if GetCharacterCondition(33)==true then
			if GetCharacterCondition(34)==true then
				if GetCharacterCondition(35)==false then
				--LEAVE MENU!!!!!!!!
				yield("/send NUMPAD0 <wait.1.0>")
				yield("/send NUMPAD0 <wait.1.0>")
				end
			end
		end
		yield("/wait 1")
	end

	yield("/wait 30")
	-- Teleport back to FC House
	yield("/waitaddon _ActionBar <maxwait.600><wait.5>")
	yield("/tp Estate Hall <wait.10>")
	yield("/waitaddon _ActionBar <maxwait.600><wait.5>")

	--normal small house shenanigans
	if which_one[feesh_c][2] == 0 then
		yield("/hold W <wait.1.0>")
		yield("/release W")
		yield("/target Entrance <wait.1>")
		yield("/lockon on")
		yield("/automove on <wait.2.5>")
		yield("/automove off <wait.1.5>")
		yield("/hold Q <wait.2.0>")
		yield("/release Q")
	end

	--retainer bell nearby shenanigans
	if which_one[feesh_c][2] == 1 then
		yield("/target \"Summoning Bell\"")
		yield("/wait 2")
		PathfindAndMoveTo(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"), false)
		visland_stop_moving() --added so we don't accidentally end before we get to the bell
	end

end --of fishing()

while true do 
  local currentTime = os.date("*t")
  local formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.min, currentTime.sec)
	
	if GetCharacterCondition(1)==false then
		yield("<wait.30.0>")  -- Wait for 30 seconds because we are at the login screen
	end
	
	--secret variable
	wheeequeheeheheheheheehhhee = 0
	
	--The next 2 lines of code copied from https://raw.githubusercontent.com/plottingCreeper/FFXIV-scripts-and-macros/main/SND/FishingRaid.lua
	--line 319 to line 320
	--thanks botting creeper!
    if os.date("!*t").hour%2==0 and os.date("!*t").min<15 then
      if os.date("!*t").min>=1 then
		wheeequeheeheheheheheehhhee = 1
	  end
    end

   --if taskTimes[currentTime.hour] and taskTimeMin[currentTime.min]  then
   if wheeequeheeheheheheheehhhee == 1 then
	if GetCharacterCondition(31)==false then
		if GetCharacterCondition(32)==false then
			 --yield("/ays multi")
			 yield("/ays multi d")
		 	 yield("/send ESCAPE <wait.1.5>")
			 yield("/send ESCAPE <wait.1.5>")
			 yield("/send ESCAPE <wait.1.5>")
			 yield("/waitaddon _ActionBar <maxwait.600><wait.2>")
			 fishing()
			 --drop a log file entry on the charname + Level
			 -- Define the folder path
			--feesh_c = feesh_c - 1
			--vich_one()
			-- Open a file in write mode within the specified folder
			local file = io.open(folderPath .. "FeeshLevels.txt", "a")

			if file then
				-- Write text to the file
				--file:write("Hello, this is some text written to a file using Lua!\n")
				currentTime = os.date("*t")
				formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.min, currentTime.sec)
				file:write(formattedTime.." - "..feesh_char.." - Fisher Lv - "..GetLevel().."\n")
				--file:write("Writing to files in Lua is straightforward.\n")
				-- Close the file handle
				file:close()
				--print("Text has been written to '" .. folderPath .. "output.txt'")
				yield("/echo Text has been written to '" .. folderPath .. "FeeshLevels.txt'")
			else
				--print("Error: Unable to open file for writing")
				yield("/echo Error: Unable to open file for writing")
				--file:write("Error: Unable to open file for writing\n")
			end
			--feesh_c = feesh_c + 1
			vich_one()
 			--yield("/ays multi")
 			yield("/ays multi e")
		end
	end
   end  -- end if

  yield("/wait 0.3")  -- Wait for 0.3 second before checking again
  smol_increment = smol_increment + 1
  if smol_increment > 180 then
	smol_increment = 0
	yield("/echo Next Feeshing, Char = "..feesh_char..", Cardinality - "..feesh_c)
  end
end -- while loop
