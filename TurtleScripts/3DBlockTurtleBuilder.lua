-- Init
clearTerminal()
print("Block Placement Script")

write("Width: ")
local width = tonumber(read())

write("Length: ")
local length = tonumber(read())

write("Height: ")
local height = tonumber(read())

term.clear()
print("Initialization complete. Starting program...")

-- Refuel the turtle when neccessary
function refuel(state)
    local currentFuel = turtle.getFuelLevel()
    if currentFuel >= 10 then
        return
    else
        turtle.select(1)
        if turtle.getItemCount() > 0 then
            turtle.refuel(1)
        else
            print("Please supply turtle with more fuel..")
        end
    end
end

function Build3DBlock()
    -- body
end

-- Clear terminal
function clearTerminal()
    term.clear()
    term.setCursorPos(1, 1)
end