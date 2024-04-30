-- Host

local monitor = peripheral.find("monitor")

monitor.setTextScale(1)

--RFReactor
local rfStoredEnergy = "0"
local rfGeneratedEnergy = "0"

function all_trim(s)
    return s:match"^%s*(.*)":match"(.-)%s*$"
end

-- Funktion zum Anzeigen der empfangenen Daten auf dem Monitor
local function refreshDisplayData()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("RF Reactor: ")
    monitor.setCursorPos(3, 3)
    monitor.write("Stored Energy: " .. rfStoredEnergy)
    monitor.setCursorPos(3, 4)
    monitor.write("Generated Engery: " .. rfGeneratedEnergy)
end

rednet.open("left")

-- Funktion zum Teilen eines Strings anhand eines Trennzeichens
local function splitString(inputString, separator)
    local parts = {}
    local startIndex = 1
    local endIndex = inputString:find(separator)

    while endIndex do
        table.insert(parts, inputString:sub(startIndex, endIndex - 1))
        startIndex = endIndex + 1
        endIndex = inputString:find(separator, startIndex)
    end

    table.insert(parts, inputString:sub(startIndex))

    return parts
end

repeat
    local event, senderID, message, distance = os.pullEvent()
    if event == "rednet_message" then
        -- Teile den Eingabestring an dem Trennzeichen "|"
        local parts = splitString(message, "|")
        
        -- Extrahiere die Energiewerte aus den Teilen
        rfStoredEnergy = parts[1]:gsub("%[STORED]", "")
        rfGeneratedEnergy = parts[2]:gsub("%[GENERATED]", "")

        refreshDisplayData()
    end
until event == "char" and senderID == "x"

