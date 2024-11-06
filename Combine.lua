-- Kombiniere deine .lua-Dateien zu einer einzigen Datei
local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        error("Fehler beim Öffnen der Datei: " .. path)
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function replaceDofile(filePath, seenFiles)
    seenFiles = seenFiles or {}
    if seenFiles[filePath] then
        return "-- Datei " .. filePath .. " wurde bereits importiert\n"
    end

    seenFiles[filePath] = true
    print(filePath);
    local content = readFile(filePath)

    -- Ersetze `dofile("path/to/file.lua")` durch den Inhalt der referenzierten Datei
    content = content:gsub('dofile%("(.-)"%)', function(importPath)
        return replaceDofile(importPath, seenFiles)
    end)

    return content
end

local function combineLuaScripts(entryFile, outputFile)
    local combinedContent = replaceDofile(entryFile)
    local output = io.open(outputFile, "w")
    output:write(combinedContent)
    output:close()
    print("Kombinierte Datei wurde erfolgreich erstellt: " .. outputFile)
end

combineLuaScripts('./main.lua', './build/combined.lua')