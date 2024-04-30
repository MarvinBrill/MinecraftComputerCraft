-- Client

rednet.open("left")

while true do
    -- Abrufen der gespeicherten Energie vom Reaktor
    local storedPower = peripheral.call("back", "getEnergyStored")
    local dataToSendStored = "[STORED]" .. storedPower

    -- Abrufen der erzeugten Energie vom Reaktor
    local generatedPower = peripheral.call("back", "getEnergyProducedLastTick")
    local dataToSendGenerated = "[GENERATED]" .. generatedPower

    print("Generated: " .. peripheral.call("back", "getEnergyStored"))
    print("Produced: " .. peripheral.call("back", "getEnergyProducedLastTick"))

    print(dataToSendStored .. "|" .. dataToSendGenerated)

    -- Senden der Daten über das Funkmodem
    rednet.broadcast(dataToSendStored .. "|" .. dataToSendGenerated)

    sleep(0.05) -- Wartezeit vor dem nächsten Senden
end
