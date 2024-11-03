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
