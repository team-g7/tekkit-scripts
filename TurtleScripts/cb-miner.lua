-- Coordinates: area of mining (x, y) => (0,0) -> (2,2)

--step1: (0,0) -> (0,1) -> (0,2)
--step2: (0,2) -> (1,0) -> (1,1) -> (1,2)
--step3: (1,2) -> (2,0) -> (2,1) -> (2,2)
--step4: go back to step 1

local args = ...



------------------------------------------------------------ ENUMERATION ------------------------------------------------------------
-- Enum: directions to go / mine / look
-- _UP, _DOWN  			changes y-position	| 	_UP  		is positive direction
-- _FORWARD, _BACKWARD 	changes z-position	|	_FORWARD 	is positive direction
-- _LEFT, _RIGHT 		changes x-position	| 	_RIGHT 		is positive direction
local _FORWARD, _RIGHT, _BACKWARD, _LEFT, _UP, _DOWN = 0, 1, 2, 3, 4, 5

-- Enum: wether turtle should keep the ore or drop it
local _KEEP, _DROP = 6, 7

local currentDepth = 0				-- replaced by pos.z ![DEPERICATED]
local currentDirectionOfSight = 0; 	-- starts by looking forward

local oresMined = 0

-- current turtle position
local pos = {["x"] = 1, ["y"] = -1, ["z"] = 0}

local trashItems = {
	"minecraft:stone",
	"minecraft:cobblestone",
	"minecraft:mossy_cobblestone",
	"minecraft:dirt",
	"minecraft:grass"
}

local priorityItems = {
	"minecraft:diamond_ore",
	"minecraft:gold_ore",
	"minecraft:iron_ore",
	"minecraft:coal_ore",
	"minecraft:diamond",
	"minecraft:coal",
	"minecraft:redstone",
	"ic2:tin_ore",
	"ic2:copper_ore"
}

------------------------------------------------------------ FUNCTIONS ------------------------------------------------------------

-- dig and move 1 step to the assigned direction
function digAndMove(direction, item_action)
	--print("Digging and moving to direction...")
	-- dig and move down
	if (direction == _UP) then
		while not turtle.up() do
			turtle.digUp()
		end
		pos.y = pos.y + 1

	-- dig and move down
	elseif (direction == _DOWN) then
		while not turtle.down() do
			turtle.digDown()
		end
		pos.y = pos.y - 1

	-- look, dig and move to the assigned direction
	else
		-- change pos for the values
		if (direction == _RIGHT) then
			pos.x = pos.x + 1
		elseif (direction == _LEFT) then
			pos.x = pos.x - 1
		elseif (direction == _FORWARD) then
			pos.z = pos.z + 1
		elseif (direction == _BACKWARD) then
			pos.z = pos.z - 1
		end

		look(direction)

		-- if the turtle is obstructed by objects, dig it out until its gone
		while not turtle.forward() do
			turtle.dig()
			-- wait a bit for sediments to fall from above (if there are any) before trying to move forwards again
			sleep(.3)
		end
	end
	--print("(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")" .. " CD: " .. currentDirectionOfSight)

	-- -- if specified, remove trash
	-- if (item_action == _DROP) then
	-- 	removeTrash()
	-- end
end

-- turn left x amount of times
function turnLeft(totalRotation) 
	-- if total rotation isn't assigned, assume rotating only once
	totalRotation = totalRotation or 1

	-- rotate turtle and adjust direction of sight variable
	for currentRotation = 1, totalRotation, 1 do
		turtle.turnLeft()
		currentDirectionOfSight = currentDirectionOfSight - 1
	end
end

-- turn right x amount of times
function turnRight(totalRotation) 
	-- if total rotation isn't assigned, assume rotating only once
	totalRotation = totalRotation or 1

	-- rotate turtle and adjust direction of sight variable
	for currentRotation = 1, totalRotation, 1 do
		turtle.turnRight()
		currentDirectionOfSight = currentDirectionOfSight + 1
	end
end

function look(direction) 
	if (currentDirectionOfSight < direction) then
		-- if turtle is looking left to relative direction of sight, turn right x times to the relative sight of direction
		turnRight(direction - currentDirectionOfSight)
	else
		-- if turtle is looking right to relative direction of sight, turn left x times to the relative sight of direction
		turnLeft(currentDirectionOfSight - direction)
	end
end

function refillFuelIfEmpty(steps)
	if (turtle.getFuelLevel() < steps + 2) then
		while (turtle.getFuelLevel() < steps + 2) do

		end
	end
end

-- place a touch where the turtle is currently facing
function placeTouch()
	-- save original slot number to go back to after placing torch
	originalSlotNum = turtle.getSelectedSlot()

	-- select and place tourch
	turtle.select(2)
	turtle.place()

	-- select original slot number
	turtle.select(originalSlotNum)
end

function scanOre(direction) 
	local success, oreToMine;

	-- fetch ore data based on the direction
	if (direction == _UP) then
		success, oreToMine = turtle.inspectUp()
	elseif (direction == _DOWN) then
		success, oreToMine = turtle.inspectDown()
	else 
		success, oreToMine = turtle.inspect()
	end

	-- if an ore is detected, check if its a trash and decide what to do with it
	if (success) then
		if (ore == "minecraft:stone" or ore == "minecraft:dirt" or ore == "minecraft:grass" or ore == "minecraft:cobblestone" or ore == "minecraft:mossy_cobblestone") then
			action = _DROP
		else 
			action = _KEEP
		end
	end

	-- return what to do with the ore
	return action
end

-- looks through all slots and drops the trash if any
function removeTrash()
	oresMined = 0
	for currentSlot = 1, 16, 1 do
		local item_table = turtle.getItemDetail(currentSlot)

		-- if an item is occupying item slot
		if (item_table) then
			local item = item_table.name

			for _, trash in pairs(trashItems) do
				if (item == trash) then
					turtle.select(currentSlot)
					turtle.drop()
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------
-- another version of mining n x n, where n % 2 = 0, and n > 1

-- 4x4: 3x, -1y, -3x, -1y, 3x, -1y, -4x, 4y

-- start at top left
--
-- go right until (max x - 1)
-- go down once
-- go left until (max x - 1)
-- go down once
--
-- repeat the 4 last steps until current y = - max y and current x = min x
-- go up to start pos (y only), dig forwards once (z axis) and redo until max depth (z axis) is reached

function runV2()
	-- auto refuel when starting script for convenience
	turtle.refuel(2)

	local maxX = 8
	local maxY = -8
	local maxZ = 1000

	print("Mining from (" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ") ---> (" .. maxX .. ", " .. maxY .. ", " .. maxZ .. ")")

	while (pos.z < maxZ) do
		print("Digging out all rows for current z pos: " .. pos.z)
		-- clear out every row until y reaches its max
		while pos.y > maxY do
			print("Digging out all elements in the current row (y axis): " .. pos.y)
			-- turtle is at starting x pos
			while pos.x < maxX do
				-- go right until (max x - 1)
				digAndMove(_RIGHT, scanOre())
			end

			-- go down once
			digAndMove(_DOWN, scanOre(_DOWN))
			print("Digging down to next row (y axis): " .. pos.y)

			-- turtle is at end x pos with 1 margin (for the last mining instruction) 
			while pos.x > 2 do
				-- go left until (max x - 1)
				digAndMove(_LEFT, scanOre(_LEFT))
			end

			if (pos.y ~= maxY) then
				-- go down once
				digAndMove(_DOWN, scanOre(_DOWN))
				print("Digging down to next row (y axis): " .. pos.y)
			end
		end
	
		-- mine out first y axis for efficency
		digAndMove(_LEFT, scanOre(_LEFT))

		-- go up to start pos (alter only y pos)
		print("Going up to start pos for x and y...")
		while pos.y < -1 do
			digAndMove(_UP)
		end

		if (pos.z ~= maxZ) then
			print("Digging forward to prepare for the next clearance of z-axis...")
			-- dig forwards and redo the progress until max depth is reached
			digAndMove(_FORWARD, scanOre())
		end

		--print("Itteration " .. pos.z - 1 .. " is done!")
		
		removeTrash()
	end

	-- go back to starting point after finishing
	while (pos.z ~= 0) do
		digAndMove(_BACKWARD, scanOre())
	end
end

------------------------------------------------------------ OUTER SCOPE ------------------------------------------------------------

runV2()
look(_FORWARD)
