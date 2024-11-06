dofile("./lib/monitor/monitor.lua");
dofile("./features/dvd/dvd_image.lua");

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
