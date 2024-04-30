local function updateScript(code, name)
    shell.run("pastebin", "get", code, name) -- Aktualisiert das Skript von Pastebin
end

local function deleteScript(name)
    if fs.exists(name) then
        fs.delete(name) -- Löscht die existierende Datei
        print("Datei '" .. name .. "' gelöscht.")
    end
end

local function readScriptList(filename)
    local scripts = {}
    local file = fs.open(filename, "r")
    if file then
        local line = file.readLine()
        while line do
            local parts = string.gmatch(line, "%S+")
            local code = parts() -- Erstes Wort in der Zeile als Code
            local name = parts() -- Zweites Wort in der Zeile als Name
            if code and name then
                table.insert(scripts, {code = code, name = name})
            end
            line = file.readLine()
        end
        file.close()
    else
        print("Datei '" .. filename .. "' nicht gefunden.")
    end
    return scripts
end

local function main()
    local filename = "scripts.txt" -- Datei mit den Pastebin-Links

    if fs.exists("/disk/" .. filename) then
        filename = "/disk/" .. filename
        shell.run("cd", "/")
        if fs.exists("/disk/UpdateAll") then
            if fs.exists("/UpdateAll") then
                fs.delete("/UpdateAll")
            end
            shell.run("copy", "/disk/UpdateAll", "/")
        elseif fs.exists("/disk/UpdateAll.lua") then
            if fs.exists("/UpdateAll.lua") then
                fs.delete("/UpdateAll.lua")
            end
            shell.run("copy", "/disk/UpdateAll.lua", "/")
        end
    end


    local scripts = readScriptList(filename)

    if #scripts > 0 then
        for _, script in ipairs(scripts) do
            deleteScript(script.name)
            updateScript(script.code, script.name)
        end
    else
        print("Keine Skripte zum Aktualisieren gefunden.")
    end
end

main()

