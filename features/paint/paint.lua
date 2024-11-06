dofile("./lib/monitor/monitor.lua");

local buttonHeight;
local buttonWidth;
local borderPos;
local height;
local width;

local currentColor;

local function setCurrentColor(color)
    MonitorSetStaticPixel(borderPos - 1, 1, color);
    MonitorSetStaticPixel(borderPos - 1, 2, color);
    MonitorSetStaticPixel(borderPos - 1, 3, color);
    currentColor = color;
end

local function init()
    MonitorSetTextScale(0.5);
    MonitorSetBackgroundColor(colors.white);

    buttonHeight = 2;
    buttonWidth = 3;
    height = GetMonitorHeight();
    width = GetMonitorWidth();
    
    MonitorCreateButton("<", 1, height - 2, -1, colors.gray, colors.gray, colors.white);
    MonitorCreateButton(">", 5, height - 2, -1, colors.gray, colors.gray, colors.white);
    MonitorCreateButton("^", 3, height - 4, -1, colors.gray, colors.gray, colors.white);
    MonitorCreateButton("v", 3, height, -1, colors.gray, colors.gray, colors.white);
    MonitorCreateButton("red", 1, 1, -1, colors.red, colors.red, colors.white);
    MonitorCreateButton("grn", 1, 1 + buttonHeight, -1, colors.green, colors.green, colors.white);
    MonitorCreateButton("blu", 1, 1 + (buttonHeight * 2), -1, colors.blue, colors.blue, colors.white);
    MonitorCreateButton("yel", 1, 1 + (buttonHeight * 3), -1, colors.yellow, colors.yellow, colors.white);
    MonitorCreateButton("org", 1, 1 + (buttonHeight * 4), -1, colors.orange, colors.orange, colors.white);
    MonitorCreateButton("pin", 1, 1 + (buttonHeight * 5), -1, colors.pink, colors.pink, colors.white);
    MonitorCreateButton("prl", 1, 1 + (buttonHeight * 6), -1, colors.purple, colors.purple, colors.white);
    MonitorCreateButton("wht", 1, 1 + (buttonHeight * 7), -1, colors.white, colors.white, colors.black);
    MonitorCreateButton("blk", 1, 1 + (buttonHeight * 8), -1, colors.black, colors.black, colors.white);

    borderPos = (buttonWidth * 2) + 1;

    MonitorCreateButton("X", borderPos - 1, height, -1, colors.red, colors.red, colors.white);

    for x = 1, borderPos - 1, 1 do
        for y = 1, height, 1 do
            MonitorSetStaticPixel(x, y, colors.black);
        end
    end

    for i = 1, height, 1 do
        MonitorSetStaticPixel(borderPos, i, colors.gray);
    end

    setCurrentColor(colors.red);

    MonitorRefresh();
end

init();

local function onTouch(x, y, touched)
    if x > borderPos then
        MonitorSetPixel(x + GetMonitorScrollX(), y + GetMonitorScrollY(), currentColor);
        return;
    end

    if touched["<"] == true then
        MonitorScrollTo(GetMonitorScrollX() - 1, GetMonitorScrollY());
    end
    if touched[">"] == true then
        MonitorScrollTo(GetMonitorScrollX() + 1, GetMonitorScrollY());
    end
    if touched["^"] == true then
        MonitorScrollTo(GetMonitorScrollX(), GetMonitorScrollY() - 1);
    end
    if touched["v"] == true then
        MonitorScrollTo(GetMonitorScrollX(), GetMonitorScrollY() + 1);
    end
    if touched["red"] == true then
        setCurrentColor(colors.red);
    end
    if touched["grn"] == true then
        setCurrentColor(colors.green);
    end
    if touched["blu"] == true then
        setCurrentColor(colors.blue);
    end
    if touched["yel"] == true then
        setCurrentColor(colors.yellow);
    end
    if touched["org"] == true then
        setCurrentColor(colors.orange);
    end
    if touched["pin"] == true then
        setCurrentColor(colors.pink);
    end
    if touched["prl"] == true then
        setCurrentColor(colors.purple);
    end
    if touched["wht"] == true then
        setCurrentColor(colors.white);
    end
    if touched["blk"] == true then
        setCurrentColor(colors.black);
    end
    if touched["X"] == true then
        MonitorRemovePixels();
        MonitorScrollTo(0, 0);
    end
end

StartMonitorTouchListener(onTouch);