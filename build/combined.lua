local monitor = peripheral.find("monitor");
local mWidth = 0;
local mHeight = 0;

local mCursorX = 1;
local mCursorY = 1;
local mScrollX = 0;
local mScrollY = 0;
local mBackgroundColor = colors.black;
local mTextColor = colors.green;
local lines = {};
local pixels = {};
local staticPixels = {};
local buttons = {};

function string.split(input, separator)
    local elements = {}
    local separator = separator or "%s"
    local pattern = string.format("([^%s]+)", separator)

    input:gsub(pattern, function(c) elements[#elements + 1] = c end)

    return elements
end

if not monitor then
    print("Kein Monitor gefunden!");
    return;
else
    monitor.setTextScale(1);
    monitor.setBackgroundColor(mBackgroundColor);
    monitor.clear();
    monitor.setCursorPos(mCursorX, mCursorY);
    monitor.setTextColor(mTextColor);
    mWidth, mHeight = monitor.getSize();
end

function GetMonitorWidth()
    return mWidth;
end

function GetMonitorHeight()
    return mHeight;
end

function GetMonitorScrollX()
    return mScrollX;
end

function GetMonitorScrollY()
    return mScrollY;
end

function MonitorSetStaticPixel(x, y, color)
    staticPixels[x .. "," .. y] = color;
    monitor.setBackgroundColor(color);
    monitor.setCursorPos(x, y);
    monitor.write(" ");
    monitor.setBackgroundColor(mBackgroundColor);
end

function MonitorSetPixel(x, y, color)
    pixels[x .. "," .. y] = color;
    monitor.setBackgroundColor(color);
    monitor.setCursorPos(x - mScrollX, y - mScrollY);
    local line = lines[y];
    if line ~= nil and string.len(line) >= x then
        monitor.write(string.sub(line, x, x));
    else
        monitor.write(" ");
    end
    monitor.setBackgroundColor(mBackgroundColor);
end

local function monitorDraw(x, y, s, bgColor, textColor)
    monitor.setBackgroundColor(bgColor);
    monitor.setTextColor(textColor);
    monitor.setCursorPos(x, y);
    monitor.write(s);
end

local function drawButton(name, cordX, cordY, scale, borderColor, backgroundColor, textColor)
    local nameLength = string.len(name);
    local endX = cordX + nameLength + (scale * 2) + 1;
    local endY = cordY + (scale * 2) + 2;
    local nameStartX = math.floor(endX - ((endX - cordX) / 2)) - math.floor(nameLength / 2) + (1 - (nameLength % 2));
    local nameStartY = math.floor(endY - ((endY - cordY) / 2));
    for y = cordY, endY, 1 do
        local x = cordX
        while x <= endX do
            if x == nameStartX and y == nameStartY then
                monitorDraw(x, y, name, backgroundColor, textColor)
                x = x + nameLength
            else
                if x == cordX or y == cordY or x == endX or y == endY then
                    monitorDraw(x, y, " ", borderColor, textColor)
                else
                    monitorDraw(x, y, " ", backgroundColor, textColor)
                end
                x = x + 1
            end
        end
    end
end

function MonitorScrollTo(x, y)
    mScrollX = x;
    mScrollY = y;
    local cursorY = 1;
    monitor.setBackgroundColor(mBackgroundColor);
    monitor.clear();
    monitor.setCursorPos(1, cursorY);

    --lines
    for i = 1 + y, #lines, 1 do
        if lines[i] then
            monitor.write(string.sub(lines[i], x + 1));
        end
        cursorY = cursorY + 1;
        monitor.setCursorPos(1, cursorY);
    end

    --pixels
    for key, value in pairs(pixels) do
        local cord = string.split(key, ",");
        MonitorSetPixel(tonumber(cord[1]), tonumber(cord[2]), value);
    end

    --static pixels
    for key, value in pairs(staticPixels) do
        local cord = string.split(key, ",");
        MonitorSetStaticPixel(tonumber(cord[1]), tonumber(cord[2]), value);
    end

    --buttons
    for key, value in pairs(buttons) do
        if value ~= nil then
            local curButton = string.split(value, ",");
            drawButton(key, tonumber(curButton[1]), tonumber(curButton[2]), tonumber(curButton[3]), tonumber(curButton[4]), tonumber(curButton[5]), tonumber(curButton[6]));
        end
    end

    monitor.setBackgroundColor(mBackgroundColor);
    monitor.setTextColor(mTextColor);
    monitor.setCursorPos(mCursorX, mCursorY);
end

function MonitorRefresh()
    MonitorScrollTo(mScrollX, mScrollY);
end

function MonitorSetTextColor(color)
    monitor.setTextColor(color);
    MonitorRefresh();
end

function MonitorSetTextScale(size)
    monitor.setTextScale(size);
    mWidth, mHeight = monitor.getSize();
    MonitorRefresh();
end

function MonitorSetBackgroundColor(color)
    mBackgroundColor = color;
    MonitorRefresh();
end

function MonitorLineBreak()
    mCursorY = mCursorY + 1;
    monitor.setCursorPos(mCursorX, mCursorY);
end

function MonitorJumpDown()
    mCursorY = #lines + 1;
    monitor.setCursorPos(mCursorX, mCursorY);
end

function MonitorScrollDown()
    MonitorJumpDown();
    if #lines > GetMonitorHeight() then
        mScrollY = #lines - GetMonitorHeight();
    end
end

function MonitorWrite(s)
    if lines[mCursorY] then
        lines[mCursorY] = lines[mCursorY] .. s;
    else
        lines[mCursorY] = s;
    end

    MonitorRefresh();
end

function MonitorWriteLine(s)
    MonitorWrite(s);
    mCursorY = mCursorY + 1;
    monitor.setCursorPos(mCursorX, mCursorY);
end

function MonitorWriteLineAt(s, n)
    mCursorY = n;
    local length = #lines;
    if (mCursorY - 1) > length then
        local i = length + 1;
        while i < mCursorY do
            lines[i] = "";
            i = i + 1;
        end
    end
    lines[mCursorY] = s;
    MonitorRefresh();
end

function MonitorDeleteLine(n)
    lines[n] = "";
    MonitorRefresh();
end

function MonitorCreateButton(name, x, y, scale, borderColor, backgroundColor, textColor)
    buttons[name] = x .. "," .. y .. "," .. scale .. "," .. borderColor .. "," .. backgroundColor .. "," .. textColor;
    MonitorRefresh();
end

function MonitorDeleteButton(name)
    buttons[name] = nil;
    MonitorRefresh();
end

function MonitorRemovePixels()
    pixels = {}
    MonitorRefresh();
end

function MonitorRemoveStaticPixels()
    staticPixels = {}
    MonitorRefresh();
end

function StartMonitorTouchListener(onTouch)
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch");
        if event == "monitor_touch" then
            local touched = {}
            for key, value in pairs(buttons) do
                if value ~= nil then
                    local buttonProps = string.split(value, ",");
                    local cordX = tonumber(buttonProps[1]);
                    local cordY = tonumber(buttonProps[2]);
                    local scale = tonumber(buttonProps[3]);
                    local nameLength = string.len(key);
                    local endX = cordX + nameLength + (scale * 2) + 2;
                    local endY = cordY + 1 + (scale * 2) + 2;
                    touched[key] = x >= cordX and x <= endX and y >= cordY and y <= endY;
                end
            end
            onTouch(x, y, touched);
        end
    end
end

function DebugMonitorTouchListener()
    local function onTouch(x, y, touched)
        print("X: " .. x .. " Y: " .. y);
        print("Touched elements:");
        for key, value in pairs(touched) do
            print(key .. " -- " .. tostring(value));
        end
    end
    StartMonitorTouchListener(onTouch);
end
;
local pixels = {}
pixels["0,0"] = colors.black
pixels["1,0"] = colors.black
pixels["2,0"] = colors.black
pixels["3,0"] = colors.black
pixels["4,0"] = colors.black
pixels["5,0"] = colors.black
pixels["6,0"] = colors.black
pixels["7,0"] = colors.black
pixels["8,0"] = colors.black
pixels["9,0"] = colors.black
pixels["10,0"] = colors.black
pixels["11,0"] = colors.black
pixels["12,0"] = colors.black
pixels["13,0"] = colors.black
pixels["14,0"] = colors.black
pixels["15,0"] = colors.black
pixels["16,0"] = colors.black
pixels["17,0"] = colors.black
pixels["18,0"] = colors.black
pixels["19,0"] = colors.black
pixels["20,0"] = colors.black
pixels["21,0"] = colors.black
pixels["22,0"] = colors.black
pixels["23,0"] = colors.black
pixels["24,0"] = colors.black
pixels["0,1"] = colors.black
pixels["1,1"] = colors.black
pixels["2,1"] = colors.black
pixels["3,1"] = colors.black
pixels["4,1"] = colors.black
pixels["5,1"] = colors.black
pixels["6,1"] = colors.black
pixels["7,1"] = colors.black
pixels["8,1"] = colors.black
pixels["9,1"] = colors.black
pixels["10,1"] = colors.black
pixels["11,1"] = colors.black
pixels["12,1"] = colors.black
pixels["13,1"] = colors.black
pixels["14,1"] = colors.black
pixels["15,1"] = colors.black
pixels["16,1"] = colors.black
pixels["17,1"] = colors.black
pixels["18,1"] = colors.black
pixels["19,1"] = colors.black
pixels["20,1"] = colors.black
pixels["21,1"] = colors.black
pixels["22,1"] = colors.black
pixels["23,1"] = colors.black
pixels["24,1"] = colors.black
pixels["0,2"] = colors.black
pixels["1,2"] = colors.black
pixels["2,2"] = colors.black
pixels["3,2"] = colors.black
pixels["4,2"] = colors.black
pixels["5,2"] = colors.black
pixels["6,2"] = colors.black
pixels["7,2"] = colors.black
pixels["8,2"] = colors.black
pixels["9,2"] = colors.black
pixels["10,2"] = colors.black
pixels["11,2"] = colors.black
pixels["12,2"] = colors.black
pixels["13,2"] = colors.black
pixels["14,2"] = colors.black
pixels["15,2"] = colors.black
pixels["16,2"] = colors.black
pixels["17,2"] = colors.black
pixels["18,2"] = colors.black
pixels["19,2"] = colors.black
pixels["20,2"] = colors.black
pixels["21,2"] = colors.black
pixels["22,2"] = colors.black
pixels["23,2"] = colors.black
pixels["24,2"] = colors.black
pixels["0,3"] = colors.black
pixels["1,3"] = colors.black
pixels["2,3"] = colors.black
pixels["3,3"] = colors.black
pixels["4,3"] = colors.black
pixels["5,3"] = colors.black
pixels["6,3"] = colors.black
pixels["7,3"] = colors.black
pixels["8,3"] = colors.black
pixels["9,3"] = colors.black
pixels["10,3"] = colors.black
pixels["11,3"] = colors.black
pixels["12,3"] = colors.black
pixels["13,3"] = colors.black
pixels["14,3"] = colors.black
pixels["15,3"] = colors.black
pixels["16,3"] = colors.black
pixels["17,3"] = colors.black
pixels["18,3"] = colors.black
pixels["19,3"] = colors.black
pixels["20,3"] = colors.black
pixels["21,3"] = colors.black
pixels["22,3"] = colors.black
pixels["23,3"] = colors.black
pixels["24,3"] = colors.black
pixels["0,4"] = colors.black
pixels["1,4"] = colors.black
pixels["2,4"] = colors.black
pixels["3,4"] = colors.black
pixels["4,4"] = colors.black
pixels["5,4"] = colors.black
pixels["6,4"] = colors.black
pixels["7,4"] = colors.black
pixels["8,4"] = colors.black
pixels["9,4"] = colors.black
pixels["10,4"] = colors.black
pixels["11,4"] = colors.black
pixels["12,4"] = colors.black
pixels["13,4"] = colors.black
pixels["14,4"] = colors.black
pixels["15,4"] = colors.black
pixels["16,4"] = colors.black
pixels["17,4"] = colors.black
pixels["18,4"] = colors.black
pixels["19,4"] = colors.black
pixels["20,4"] = colors.black
pixels["21,4"] = colors.black
pixels["22,4"] = colors.black
pixels["23,4"] = colors.black
pixels["24,4"] = colors.black
pixels["0,5"] = colors.black
pixels["1,5"] = colors.black
pixels["2,5"] = colors.black
pixels["3,5"] = colors.black
pixels["4,5"] = colors.black
pixels["5,5"] = colors.black
pixels["6,5"] = colors.black
pixels["7,5"] = colors.black
pixels["8,5"] = colors.black
pixels["9,5"] = colors.black
pixels["10,5"] = colors.black
pixels["11,5"] = colors.black
pixels["12,5"] = colors.black
pixels["13,5"] = colors.black
pixels["14,5"] = colors.black
pixels["15,5"] = colors.black
pixels["16,5"] = colors.black
pixels["17,5"] = colors.black
pixels["18,5"] = colors.black
pixels["19,5"] = colors.black
pixels["20,5"] = colors.black
pixels["21,5"] = colors.black
pixels["22,5"] = colors.black
pixels["23,5"] = colors.black
pixels["24,5"] = colors.black
pixels["0,6"] = colors.black
pixels["1,6"] = colors.black
pixels["2,6"] = colors.black
pixels["3,6"] = colors.black
pixels["4,6"] = colors.black
pixels["5,6"] = colors.black
pixels["6,6"] = colors.black
pixels["7,6"] = colors.black
pixels["8,6"] = colors.black
pixels["9,6"] = colors.black
pixels["10,6"] = colors.black
pixels["11,6"] = colors.black
pixels["12,6"] = colors.black
pixels["13,6"] = colors.black
pixels["14,6"] = colors.black
pixels["15,6"] = colors.black
pixels["16,6"] = colors.black
pixels["17,6"] = colors.black
pixels["18,6"] = colors.black
pixels["19,6"] = colors.black
pixels["20,6"] = colors.black
pixels["21,6"] = colors.black
pixels["22,6"] = colors.black
pixels["23,6"] = colors.black
pixels["24,6"] = colors.black
pixels["0,7"] = colors.black
pixels["1,7"] = colors.black
pixels["2,7"] = colors.black
pixels["3,7"] = colors.white
pixels["4,7"] = colors.white
pixels["5,7"] = colors.white
pixels["6,7"] = colors.white
pixels["7,7"] = colors.white
pixels["8,7"] = colors.white
pixels["9,7"] = colors.white
pixels["10,7"] = colors.white
pixels["11,7"] = colors.white
pixels["12,7"] = colors.black
pixels["13,7"] = colors.black
pixels["14,7"] = colors.black
pixels["15,7"] = colors.white
pixels["16,7"] = colors.white
pixels["17,7"] = colors.white
pixels["18,7"] = colors.white
pixels["19,7"] = colors.white
pixels["20,7"] = colors.white
pixels["21,7"] = colors.white
pixels["22,7"] = colors.white
pixels["23,7"] = colors.black
pixels["24,7"] = colors.black
pixels["0,8"] = colors.black
pixels["1,8"] = colors.black
pixels["2,8"] = colors.black
pixels["3,8"] = colors.black
pixels["4,8"] = colors.black
pixels["5,8"] = colors.black
pixels["6,8"] = colors.black
pixels["7,8"] = colors.white
pixels["8,8"] = colors.white
pixels["9,8"] = colors.white
pixels["10,8"] = colors.white
pixels["11,8"] = colors.white
pixels["12,8"] = colors.black
pixels["13,8"] = colors.black
pixels["14,8"] = colors.white
pixels["15,8"] = colors.white
pixels["16,8"] = colors.black
pixels["17,8"] = colors.black
pixels["18,8"] = colors.black
pixels["19,8"] = colors.black
pixels["20,8"] = colors.black
pixels["21,8"] = colors.white
pixels["22,8"] = colors.white
pixels["23,8"] = colors.white
pixels["24,8"] = colors.black
pixels["0,9"] = colors.black
pixels["1,9"] = colors.black
pixels["2,9"] = colors.black
pixels["3,9"] = colors.white
pixels["4,9"] = colors.white
pixels["5,9"] = colors.black
pixels["6,9"] = colors.black
pixels["7,9"] = colors.black
pixels["8,9"] = colors.white
pixels["9,9"] = colors.white
pixels["10,9"] = colors.white
pixels["11,9"] = colors.white
pixels["12,9"] = colors.white
pixels["13,9"] = colors.white
pixels["14,9"] = colors.white
pixels["15,9"] = colors.white
pixels["16,9"] = colors.white
pixels["17,9"] = colors.white
pixels["18,9"] = colors.white
pixels["19,9"] = colors.black
pixels["20,9"] = colors.black
pixels["21,9"] = colors.white
pixels["22,9"] = colors.white
pixels["23,9"] = colors.white
pixels["24,9"] = colors.black
pixels["0,10"] = colors.black
pixels["1,10"] = colors.black
pixels["2,10"] = colors.black
pixels["3,10"] = colors.white
pixels["4,10"] = colors.white
pixels["5,10"] = colors.black
pixels["6,10"] = colors.black
pixels["7,10"] = colors.white
pixels["8,10"] = colors.white
pixels["9,10"] = colors.white
pixels["10,10"] = colors.black
pixels["11,10"] = colors.white
pixels["12,10"] = colors.white
pixels["13,10"] = colors.white
pixels["14,10"] = colors.white
pixels["15,10"] = colors.black
pixels["16,10"] = colors.white
pixels["17,10"] = colors.white
pixels["18,10"] = colors.black
pixels["19,10"] = colors.black
pixels["20,10"] = colors.black
pixels["21,10"] = colors.white
pixels["22,10"] = colors.white
pixels["23,10"] = colors.black
pixels["24,10"] = colors.black
pixels["0,11"] = colors.black
pixels["1,11"] = colors.black
pixels["2,11"] = colors.white
pixels["3,11"] = colors.white
pixels["4,11"] = colors.white
pixels["5,11"] = colors.white
pixels["6,11"] = colors.white
pixels["7,11"] = colors.white
pixels["8,11"] = colors.white
pixels["9,11"] = colors.black
pixels["10,11"] = colors.black
pixels["11,11"] = colors.white
pixels["12,11"] = colors.white
pixels["13,11"] = colors.white
pixels["14,11"] = colors.black
pixels["15,11"] = colors.black
pixels["16,11"] = colors.white
pixels["17,11"] = colors.white
pixels["18,11"] = colors.white
pixels["19,11"] = colors.white
pixels["20,11"] = colors.white
pixels["21,11"] = colors.white
pixels["22,11"] = colors.black
pixels["23,11"] = colors.black
pixels["24,11"] = colors.black
pixels["0,12"] = colors.black
pixels["1,12"] = colors.black
pixels["2,12"] = colors.white
pixels["3,12"] = colors.white
pixels["4,12"] = colors.white
pixels["5,12"] = colors.white
pixels["6,12"] = colors.black
pixels["7,12"] = colors.black
pixels["8,12"] = colors.black
pixels["9,12"] = colors.black
pixels["10,12"] = colors.black
pixels["11,12"] = colors.white
pixels["12,12"] = colors.white
pixels["13,12"] = colors.black
pixels["14,12"] = colors.black
pixels["15,12"] = colors.black
pixels["16,12"] = colors.white
pixels["17,12"] = colors.white
pixels["18,12"] = colors.white
pixels["19,12"] = colors.black
pixels["20,12"] = colors.black
pixels["21,12"] = colors.black
pixels["22,12"] = colors.black
pixels["23,12"] = colors.black
pixels["24,12"] = colors.black
pixels["0,13"] = colors.black
pixels["1,13"] = colors.black
pixels["2,13"] = colors.black
pixels["3,13"] = colors.black
pixels["4,13"] = colors.black
pixels["5,13"] = colors.black
pixels["6,13"] = colors.black
pixels["7,13"] = colors.black
pixels["8,13"] = colors.black
pixels["9,13"] = colors.black
pixels["10,13"] = colors.black
pixels["11,13"] = colors.black
pixels["12,13"] = colors.black
pixels["13,13"] = colors.black
pixels["14,13"] = colors.black
pixels["15,13"] = colors.black
pixels["16,13"] = colors.black
pixels["17,13"] = colors.black
pixels["18,13"] = colors.black
pixels["19,13"] = colors.black
pixels["20,13"] = colors.black
pixels["21,13"] = colors.black
pixels["22,13"] = colors.black
pixels["23,13"] = colors.black
pixels["24,13"] = colors.black
pixels["0,14"] = colors.black
pixels["1,14"] = colors.black
pixels["2,14"] = colors.black
pixels["3,14"] = colors.white
pixels["4,14"] = colors.white
pixels["5,14"] = colors.white
pixels["6,14"] = colors.white
pixels["7,14"] = colors.white
pixels["8,14"] = colors.white
pixels["9,14"] = colors.white
pixels["10,14"] = colors.white
pixels["11,14"] = colors.white
pixels["12,14"] = colors.white
pixels["13,14"] = colors.white
pixels["14,14"] = colors.white
pixels["15,14"] = colors.white
pixels["16,14"] = colors.white
pixels["17,14"] = colors.white
pixels["18,14"] = colors.white
pixels["19,14"] = colors.white
pixels["20,14"] = colors.black
pixels["21,14"] = colors.black
pixels["22,14"] = colors.black
pixels["23,14"] = colors.black
pixels["24,14"] = colors.black
pixels["0,15"] = colors.black
pixels["1,15"] = colors.black
pixels["2,15"] = colors.white
pixels["3,15"] = colors.white
pixels["4,15"] = colors.white
pixels["5,15"] = colors.white
pixels["6,15"] = colors.white
pixels["7,15"] = colors.white
pixels["8,15"] = colors.white
pixels["9,15"] = colors.black
pixels["10,15"] = colors.black
pixels["11,15"] = colors.black
pixels["12,15"] = colors.black
pixels["13,15"] = colors.black
pixels["14,15"] = colors.white
pixels["15,15"] = colors.white
pixels["16,15"] = colors.white
pixels["17,15"] = colors.white
pixels["18,15"] = colors.white
pixels["19,15"] = colors.white
pixels["20,15"] = colors.white
pixels["21,15"] = colors.white
pixels["22,15"] = colors.black
pixels["23,15"] = colors.black
pixels["24,15"] = colors.black
pixels["0,16"] = colors.black
pixels["1,16"] = colors.black
pixels["2,16"] = colors.black
pixels["3,16"] = colors.black
pixels["4,16"] = colors.white
pixels["5,16"] = colors.white
pixels["6,16"] = colors.white
pixels["7,16"] = colors.white
pixels["8,16"] = colors.white
pixels["9,16"] = colors.white
pixels["10,16"] = colors.white
pixels["11,16"] = colors.white
pixels["12,16"] = colors.white
pixels["13,16"] = colors.white
pixels["14,16"] = colors.white
pixels["15,16"] = colors.white
pixels["16,16"] = colors.white
pixels["17,16"] = colors.white
pixels["18,16"] = colors.white
pixels["19,16"] = colors.black
pixels["20,16"] = colors.black
pixels["21,16"] = colors.black
pixels["22,16"] = colors.black
pixels["23,16"] = colors.black
pixels["24,16"] = colors.black
pixels["0,17"] = colors.black
pixels["1,17"] = colors.black
pixels["2,17"] = colors.black
pixels["3,17"] = colors.black
pixels["4,17"] = colors.black
pixels["5,17"] = colors.black
pixels["6,17"] = colors.black
pixels["7,17"] = colors.black
pixels["8,17"] = colors.black
pixels["9,17"] = colors.black
pixels["10,17"] = colors.black
pixels["11,17"] = colors.black
pixels["12,17"] = colors.black
pixels["13,17"] = colors.black
pixels["14,17"] = colors.black
pixels["15,17"] = colors.black
pixels["16,17"] = colors.black
pixels["17,17"] = colors.black
pixels["18,17"] = colors.black
pixels["19,17"] = colors.black
pixels["20,17"] = colors.black
pixels["21,17"] = colors.black
pixels["22,17"] = colors.black
pixels["23,17"] = colors.black
pixels["24,17"] = colors.black
pixels["0,18"] = colors.black
pixels["1,18"] = colors.black
pixels["2,18"] = colors.black
pixels["3,18"] = colors.black
pixels["4,18"] = colors.black
pixels["5,18"] = colors.black
pixels["6,18"] = colors.black
pixels["7,18"] = colors.black
pixels["8,18"] = colors.black
pixels["9,18"] = colors.black
pixels["10,18"] = colors.black
pixels["11,18"] = colors.black
pixels["12,18"] = colors.black
pixels["13,18"] = colors.black
pixels["14,18"] = colors.black
pixels["15,18"] = colors.black
pixels["16,18"] = colors.black
pixels["17,18"] = colors.black
pixels["18,18"] = colors.black
pixels["19,18"] = colors.black
pixels["20,18"] = colors.black
pixels["21,18"] = colors.black
pixels["22,18"] = colors.black
pixels["23,18"] = colors.black
pixels["24,18"] = colors.black
pixels["0,19"] = colors.black
pixels["1,19"] = colors.black
pixels["2,19"] = colors.black
pixels["3,19"] = colors.black
pixels["4,19"] = colors.black
pixels["5,19"] = colors.black
pixels["6,19"] = colors.black
pixels["7,19"] = colors.black
pixels["8,19"] = colors.black
pixels["9,19"] = colors.black
pixels["10,19"] = colors.black
pixels["11,19"] = colors.black
pixels["12,19"] = colors.black
pixels["13,19"] = colors.black
pixels["14,19"] = colors.black
pixels["15,19"] = colors.black
pixels["16,19"] = colors.black
pixels["17,19"] = colors.black
pixels["18,19"] = colors.black
pixels["19,19"] = colors.black
pixels["20,19"] = colors.black
pixels["21,19"] = colors.black
pixels["22,19"] = colors.black
pixels["23,19"] = colors.black
pixels["24,19"] = colors.black
pixels["0,20"] = colors.black
pixels["1,20"] = colors.black
pixels["2,20"] = colors.black
pixels["3,20"] = colors.black
pixels["4,20"] = colors.black
pixels["5,20"] = colors.black
pixels["6,20"] = colors.black
pixels["7,20"] = colors.black
pixels["8,20"] = colors.black
pixels["9,20"] = colors.black
pixels["10,20"] = colors.black
pixels["11,20"] = colors.black
pixels["12,20"] = colors.black
pixels["13,20"] = colors.black
pixels["14,20"] = colors.black
pixels["15,20"] = colors.black
pixels["16,20"] = colors.black
pixels["17,20"] = colors.black
pixels["18,20"] = colors.black
pixels["19,20"] = colors.black
pixels["20,20"] = colors.black
pixels["21,20"] = colors.black
pixels["22,20"] = colors.black
pixels["23,20"] = colors.black
pixels["24,20"] = colors.black
pixels["0,21"] = colors.black
pixels["1,21"] = colors.black
pixels["2,21"] = colors.black
pixels["3,21"] = colors.black
pixels["4,21"] = colors.black
pixels["5,21"] = colors.black
pixels["6,21"] = colors.black
pixels["7,21"] = colors.black
pixels["8,21"] = colors.black
pixels["9,21"] = colors.black
pixels["10,21"] = colors.black
pixels["11,21"] = colors.black
pixels["12,21"] = colors.black
pixels["13,21"] = colors.black
pixels["14,21"] = colors.black
pixels["15,21"] = colors.black
pixels["16,21"] = colors.black
pixels["17,21"] = colors.black
pixels["18,21"] = colors.black
pixels["19,21"] = colors.black
pixels["20,21"] = colors.black
pixels["21,21"] = colors.black
pixels["22,21"] = colors.black
pixels["23,21"] = colors.black
pixels["24,21"] = colors.black
pixels["0,22"] = colors.black
pixels["1,22"] = colors.black
pixels["2,22"] = colors.black
pixels["3,22"] = colors.black
pixels["4,22"] = colors.black
pixels["5,22"] = colors.black
pixels["6,22"] = colors.black
pixels["7,22"] = colors.black
pixels["8,22"] = colors.black
pixels["9,22"] = colors.black
pixels["10,22"] = colors.black
pixels["11,22"] = colors.black
pixels["12,22"] = colors.black
pixels["13,22"] = colors.black
pixels["14,22"] = colors.black
pixels["15,22"] = colors.black
pixels["16,22"] = colors.black
pixels["17,22"] = colors.black
pixels["18,22"] = colors.black
pixels["19,22"] = colors.black
pixels["20,22"] = colors.black
pixels["21,22"] = colors.black
pixels["22,22"] = colors.black
pixels["23,22"] = colors.black
pixels["24,22"] = colors.black
pixels["0,23"] = colors.black
pixels["1,23"] = colors.black
pixels["2,23"] = colors.black
pixels["3,23"] = colors.black
pixels["4,23"] = colors.black
pixels["5,23"] = colors.black
pixels["6,23"] = colors.black
pixels["7,23"] = colors.black
pixels["8,23"] = colors.black
pixels["9,23"] = colors.black
pixels["10,23"] = colors.black
pixels["11,23"] = colors.black
pixels["12,23"] = colors.black
pixels["13,23"] = colors.black
pixels["14,23"] = colors.black
pixels["15,23"] = colors.black
pixels["16,23"] = colors.black
pixels["17,23"] = colors.black
pixels["18,23"] = colors.black
pixels["19,23"] = colors.black
pixels["20,23"] = colors.black
pixels["21,23"] = colors.black
pixels["22,23"] = colors.black
pixels["23,23"] = colors.black
pixels["24,23"] = colors.black

function GetDVDLogo()
    local xy = {};
    for x = 2, 23, 1 do
        for y = 7, 16, 1 do
            xy[x - 1 .. "," .. y - 6] = pixels[x .. "," .. y];
        end
    end
    return xy;
end

function GetDVDLogoWidth()
    return 23 - 2 + 1;
end

function GetDVDLogoHeight()
    return 16 - 7 + 1;
end
;

local width;
local height;

local dvdLogo;
local dvdWidth;
local dvdHeight;

local function init()
    MonitorSetTextScale(0.5);
    MonitorSetBackgroundColor(colors.black);

    width = GetMonitorWidth();
    height = GetMonitorHeight();

    dvdLogo = GetDVDLogo();
    dvdWidth = GetDVDLogoWidth();
    dvdHeight = GetDVDLogoHeight();
end

local function drawLogo(startX, startY)
    for x = 1, dvdWidth, 1 do
        for y = 1, dvdHeight, 1 do
            MonitorSetStaticPixel(startX + x, startY + y, dvdLogo[x .. "," .. y]);
        end
    end
end

local function downRight(x, y)
    local pos = {}
    pos.x = x + 1;
    pos.y = y + 1;
    return pos;
end

local function downLeft(x, y)
    local pos = {}
    pos.x = x - 1;
    pos.y = y + 1;
    return pos;
end

local function upLeft(x, y)
    local pos = {}
    pos.x = x - 1;
    pos.y = y - 1;
    return pos;
end

local function upRight(x, y)
    local pos = {}
    pos.x = x + 1;
    pos.y = y - 1;
    return pos;
end

local function xOutOfBounce(x, width)
    return not (x >= 0 and x <= width);
end

local function yOutOfBounce(y, height)
    return not (y >= 0 and y <= height);
end

local function main()
    local direction = math.random(1, 4);
    local x = math.random(1, width - dvdWidth);
    local y = math.random(1, height - dvdHeight);

    local surfaceWidth = width - dvdWidth;
    local surfaceHeigth = height -dvdHeight;

    while true do
        sleep(0.05);

        local pos = {}

        ::retry::

        if direction == 1 then
            pos = upRight(x, y);
            if xOutOfBounce(pos.x, surfaceWidth) then
                direction = 2;
                goto retry;
            elseif yOutOfBounce(pos.y, surfaceHeigth) then
                direction = 4;
                goto retry;
            end
        elseif direction == 2 then
            pos = upLeft(x, y);
            if xOutOfBounce(pos.x, surfaceWidth) then
                direction = 1;
                goto retry;
            elseif yOutOfBounce(pos.y, surfaceHeigth) then
                direction = 3;
                goto retry;
            end
        elseif direction == 3 then
            pos = downLeft(x, y);
            if xOutOfBounce(pos.x, surfaceWidth) then
                direction = 4;
                goto retry;
            elseif yOutOfBounce(pos.y, surfaceHeigth) then
                direction = 2;
                goto retry;
            end
        elseif direction == 4 then
            pos = downRight(x, y);
            if xOutOfBounce(pos.x, surfaceWidth) then
                direction = 3;
                goto retry;
            elseif yOutOfBounce(pos.y, surfaceHeigth) then
                direction = 1;
                goto retry;
            end
        end

        x = pos.x;
        y = pos.y;

        MonitorRemoveStaticPixels();
        drawLogo(x, y);
    end
end

init();

parallel.waitForAll(main);
;
