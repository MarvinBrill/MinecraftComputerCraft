dofile("./lib/monitor/monitor.lua");

peripheral.find("modem", rednet.open);


local serverID = nil;

local function receiver()
    while true do
        local senderID, message, protocol = rednet.receive();
        
        if serverID == nil and message == "#+join-accepted" then
            serverID = senderID;
        elseif serverID == nil then
            goto continue
        end
        ::continue::
    end
end

local function writer()

end

local function join()
    rednet.broadcast("#+join");
end

join();

parallel.waitForAll(receiver, writer);