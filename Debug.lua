local monitor = peripheral.find("monitor")
local obj = peripheral.wrap("back")

if obj then
    local file = fs.open("debug_content.txt", "w")
    if file then
        file.write(obj.getDocs())
        file.close()
        print("Docs Inhalte wurde geschrieben")
    else
        print("Konnte die Datei nicht öffnen.")
    end
else
    print("Kein Gerät gefunden.")
end
