--[[
    Block placement script
    @version 1.0.0
    @author ANicholasson
--]]

-- Clear terminal
function clearTerminal()
    term.clear()
    term.setCursorPos(1, 1)
end

-- Init
clearTerminal()
print("Block Placement Script\n")

write("Width: ")
local width = tonumber(read())

write("Length: ")
local length = tonumber(read())

write("Height (+ up / - down): ")
local height = tonumber(read())

local volume = (width * length * height)
if (volume < 0) then
    volume = volume * (-1)
end

print("\nYou will need " .. volume .. " number of blocks")
print("\nYou will need a minimum of " .. math.ceil(volume / 64) .. " coal\n")
local ready = false
while (ready == false) do 
    write("Ready to run? (y/n): ")
    local answ = read();
    if (answ == "y") then 
        ready = true
    end
end

-- Refuel the turtle when neccessary
function refuel()
    local currentFuel = turtle.getFuelLevel()
    if currentFuel >= 10 then
        return
    else
        turtle.select(1)
        if turtle.getItemCount() > 0 then
            print("Refueling turtle...")
            turtle.refuel(1)
        else
            print("Please supply turtle with more fuel..")
        end
    end
    turtle.select(2)
end

--Check inventory
function checkInventory()
    local itemFound = false
    local selectedSlot = 2
    while (itemFound == false) do
        if (turtle.getItemCount(selectedSlot) > 0) then
            print("Found " .. turtle.getItemCount(selectedSlot) .. " blocks...")
            itemFound = true
        else
            selectedSlot = selectedSlot + 1
        end
    end
    turtle.select(selectedSlot)
end

-- Places a single row
function placeRow()
    local widthLengthTravelled = 0
    while (widthLengthTravelled < width) do 
        turtle.back()
        widthLengthTravelled = widthLengthTravelled + 1
        if (turtle.getFuelLevel() < (width * height)) then
            refuel()
        end
        if (turtle.getItemCount(turtle.getSelectedSlot()) <= 0) then 
            checkInventory()
        end
        turtle.place()
    end
end

-- Places a wall from bottom to top
function placePositiveWall()
    local heightDone = 0
    while (heightDone < height) do
        placeRow()
        turtle.up()
        heightDone = heightDone + 1
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.back()
    end
end

-- Places a wall from top to bottom
function placeNegativeWall()
    local heightDone = 0
    while (heightDone > height) do 
        placeRow()
        turtle.down()
        heightDone = heightDone - 1
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.back()
    end
end

-- Main application
function build3DBlock()
    turtle.select(2)
    local numbOfWallCompleted = 0
    while (numbOfWallCompleted < length) do 
        if (height > 0) then
            placePositiveWall()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnRight()
            turtle.down()
            turtle.down()
        else
            placeNegativeWall()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnRight()
            turtle.up()
            turtle.up()
        end
        numbOfWallCompleted = numbOfWallCompleted + 1
    end
end

clearTerminal()
print("Initialization complete. Starting program...")

-- Starting main application
build3DBlock()