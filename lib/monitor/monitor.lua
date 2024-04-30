local monitor = peripheral.find("monitor");
local mWidth = 0;
local mHeight = 0;

local mCursorX = 1;
local mCursorY = 1;
local lines = {};

if not monitor then
    print("Kein Monitor gefunden!");
    return;
else
    monitor.clear();
    monitor.setTextScale(1);
    monitor.setBackgroundColor(colors.black);
    monitor.setCursorPos(mCursorX, mCursorY);
    monitor.setTextColor(colors.green);
    mWidth, mHeight = monitor.getSize();
end

local function getMonitorWidth()
    return mWidth;
end

local function getMonitorHeight()
    return mHeight;
end

local function monitorLineBreak()
    mCursorY = mCursorY + 1;
    monitor.setCursorPos(mCursorX, mCursorY);
end

local function monitorWrite(s)
    local clength = 0;

    if lines[mCursorY] then
        clength = string.len(lines[mCursorY]);
        lines[mCursorY] = lines[mCursorY] .. s;
    else
        lines[mCursorY] = s;
    end

    monitor.setCursorPos(mCursorX + clength, mCursorY);
    monitor.write(lines[mCursorY]);
end

local function writeLine(s)
    monitorWrite(s);
    mCursorY = mCursorY + 1;
    monitor.setCursorPos(mCursorX, mCursorY);
end

local function writeAt(s, x, y)
    mCursorX = x;
    mCursorY = y;
    monitor.setCursorPos(mCursorX, mCursorY);
    monitor.write(s);
end

local function scrollUp(steps)
    
end

local function scrollDown(steps)
    
end

local function scrollLeft(steps)
    
end

local function scrollRight(steps)
    
end
