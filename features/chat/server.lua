peripheral.find("modem", rednet.open);

local IDList = {}

local function acceptJoinRequest(senderID)
    local isInList = false;
    for i = 1, #IDList, 1 do
        if IDList[i] == senderID then
            isInList = true;
            break;
        end
    end

    if isInList == false then
        IDList[#IDList+1] = senderID;
    end

    rednet.send(senderID, "#+join-accepted");
end

local function receiver()
    while true do
        local senderID, message, protocol = rednet.receive();

        if message == "#+join" then
            acceptJoinRequest(senderID)
        end

    end
end

parallel.waitForAll(receiver);
