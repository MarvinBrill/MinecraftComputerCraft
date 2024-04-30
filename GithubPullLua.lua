-- Funktion zur base64-Dekodierung
local function base64Decode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- GitHub Repository Informationen
local owner = "Ste4lthPr0xy"  -- Besitzer des Repositories
local repo = "ComputerCraftLuaStuff"    -- Name des Repositories
local filepath = "Debug.lua"  -- Pfad zur Datei im Repository

-- GitHub API-URL
local api_url = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. filepath

-- Funktion zum Herunterladen und Speichern der Datei
local function downloadAndSaveFile(url, path)
    local response = http.get(url)
    if response then
        local responseData = response.readAll()
        response.close()
        
        -- base64 decodieren
        local decodedContent = textutils.unserializeJSON(responseData).content
        local decodedContentBytes = base64Decode(decodedContent)
        
        -- Datei speichern
        local file = fs.open(path, "w")
        file.write(decodedContentBytes)
        file.close()
        
        print("Datei wurde erfolgreich heruntergeladen und gespeichert als " .. path)
    else
        print("Fehler: Datei konnte nicht heruntergeladen werden.")
    end
end

-- Die Datei herunterladen und speichern
--downloadAndSaveFile(api_url, "local/path/to/save/Debug.lua")  -- Lokaler Pfad zum Speichern der Datei auf dem Computer
downloadAndSaveFile(api_url, "Debug.lua")  -- Lokaler Pfad zum Speichern der Datei auf dem Computer
