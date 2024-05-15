-- "gamemodes\\bhop\\gamemode\\essential\\sh_network.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Bunny hop
-- by justa

if (SERVER) then
	util.AddNetworkString("NetworkProtocol")
	util.AddNetworkString("NetworkProtocolEncoded")
end

-- tbls
NETWORK = {}
local DATA = {}

-- Start new network
function NETWORK:StartNetworkMessage(net_tgt, net_id, ...)
	-- What we need to send
	local net_contents = {...}

	-- Send it
	net.Start("NetworkProtocol")
	net.WriteString(net_id)
	net.WriteTable(net_contents)

	-- Target
	if (CLIENT) then
		net.SendToServer()
	elseif (SERVER) and (not net_tgt) then
		net.Broadcast()
	else
		net.Send(net_tgt)
	end
end

-- Encode
function NETWORK:Encode(tbl)
	tbl = util.TableToJSON(tbl)
	tbl = util.Compress(tbl)
	return tbl
end

-- Encoded
function NETWORK:StartEncodedNetworkMessage(net_tgt, net_id, net_content)
	local len = #net_content

	-- Send it
	net.Start("NetworkProtocolEncoded")
	net.WriteString(net_id)
	net.WriteUInt(len, 32)
	net.WriteData(net_content, len)

	-- Target
	if (CLIENT) then
		net.SendToServer()
	elseif (SERVER) and (not net_tgt) then
		net.Broadcast()
	else
		net.Send(net_tgt)
	end
end

-- Listen to a new network
function NETWORK:GetNetworkMessage(id, func)
	DATA[id] = func
end

net.Receive("NetworkProtocol", function(_, cl)
	-- Get the data
	local network_id = net.ReadString()
	local network_data = net.ReadTable()

	-- If this ever happens, I'm retarded
	if (not DATA[network_id]) then return end

	-- Call the function
	DATA[network_id](cl, network_data)
end)

net.Receive("NetworkProtocolEncoded", function(_, cl)
	-- Get the data
	local network_id = net.ReadString()
	local network_len = net.ReadUInt(32)
	local network_data = net.ReadData(network_len)
	network_data = util.JSONToTable(util.Decompress(network_data))

	-- If this ever happens, I'm retarded
	if (not DATA[network_id]) then return end

	-- Call the function
	DATA[network_id](cl, network_data)
end)

--[[-------------------------------------------------------------------------
	Userinterface Networking, I made this after this so...
	I cannot be bothered to go and change it all right now, 
	so ill do this instead.
---------------------------------------------------------------------------]]
UI = UI or {}

function UI:SendToClient(client, uiId, ...)
	NETWORK:StartNetworkMessage(client, "UI", uiId, ...)
end

function UI:SendCallback(handle, data)
	NETWORK:StartNetworkMessage(false, "UI", handle, unpack(data))
end

local DATA2 = {}
function UI:AddListener(id, func)
	DATA2[id] = func
end

function UI:CallListener(id, cl, data)
	DATA2[id](cl, data)
end

NETWORK:GetNetworkMessage("UI", function(cl, data)
	local id = data[1]
	data[1] = nil

	local newdata = {}
	for k, v in pairs(data) do 
		table.insert(newdata, v)
	end

	DATA2[id](cl, newdata)
end)