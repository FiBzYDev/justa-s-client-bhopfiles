-- "gamemodes\\bhop\\gamemode\\modules\\admin\\sh_admin.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
-- Admin module
-- written by justa

-- Module Setup
Admin = Admin or {}
Admin.ranks = {}
Admin.commands = {}
Admin.whitelist = {"STEAM_0:0:53974417"}

-- Helpful
AC = _C["Prefixes"]["Admin"]
CW = color_white

-- Register a new rank 
function Admin:RegisterRank(rank_id, name)
	rank_data = {name = name}

	-- Let's make they key within the table for easy calling later 
	rank_data["id"] = rank_id 

	-- Add it to our list
	self.ranks[rank_id] = rank_data
end

-- TODO: Make this configurable in-game
Admin:RegisterRank("user", "User")
Admin:RegisterRank("zoner", "Zoner")
Admin:RegisterRank("admin", "Admin")
Admin:RegisterRank("manager", "Manager")
Admin:RegisterRank("founder", "Founder")
Admin:RegisterRank("owner", "Owner")

-- TODO: Make this configurable in-game
AccessTree = {"user", "zoner", "admin", "manager", "founder", "owner"}

-- Get a user rank 
function Admin:GetUserRank(user)
	return self.ranks[user.rank and user.rank or "user"]
end

-- Get console data
function Admin:GetConsole()
	user = {}
	function user:SteamID()
		return "CONSOLE"
	end
	function user:Name()
		return "CONSOLE"
	end
	return user
end

-- Registering a command
function Admin:RegisterCommand(func, title, prefixes, default_access)
	local id = #self.commands + 1

	table.insert(self.commands, {
		func = func,
		title = title, 
		prefixes = prefixes,
		access = default_access,
		help_text = "",
		arguments = {},
		category = "",
		SetHelpText = function(self, text)
			Admin.commands[id].help_text = text
		end,
		SetArguments = function(self, arguments)
			Admin.commands[id].arguments = arguments
		end,
		SetCategory = function(self, category)
			Admin.commands[id].category = category
		end,
		id = id 
	})

	return self.commands[id]
end

-- Checking whether someone has access to a command
function Admin:CheckAccess(user, command)
	local user_access = self:GetUserRank(user).id
	return table.KeyFromValue(AccessTree, command.access) <= table.KeyFromValue(AccessTree, user_access)
end

-- Getting all commands for a certain access level
function Admin:GetCommandsForUser(user) 
	local cmds = {}

	for k, v in pairs(self.commands) do 
		if self:CheckAccess(user, v) then 
			table.insert(cmds, v)
		end 
	end 

	return cmds 
end 

-- Get access level
function Admin:HasAccessLevel(user, rank)
	local user_access = self:GetUserRank(user).id
	return table.KeyFromValue(AccessTree, rank) <= table.KeyFromValue(AccessTree, user_access)
end

-- Getting the usage string of a command to print
-- !ban {target: player} {time: time} {reason: string}
function Admin:GetUsageString(command)
	local s = "!" .. command.prefixes[1]
	for k, v in pairs(command.arguments) do
		s = s .. " {" .. v.id .. ": " .. v.typ .. "}" 
	end
	return s 
end

-- Get admins
function Admin:GetAdmins()
	local admins = {}

	for k, v in pairs(player.GetHumans()) do 
		if (self:HasAccessLevel(v, "admin")) then 
			table.insert(admins, v)
		end
	end

	return admins
end

-- Can target someone
function Admin:CanTarget(user, target, allowsame)
	local user_access = self:GetUserRank(user).id
	local target_access = self:GetUserRank(target).id

	local canTarget
	if (not allowsame) then
		canTarget = table.KeyFromValue(AccessTree, target_access) < table.KeyFromValue(AccessTree, user_access)
	else 
		canTarget = table.KeyFromValue(AccessTree, target_access) <= table.KeyFromValue(AccessTree, user_access)
	end

	return canTarget
end

-- Valid SteamID
function Admin:ValidSteamID(steamid)
	return string.match(steamid, "STEAM_[0-5]:%d:%d+") or false
end

-- Get Command by ID
function Admin:GetCommandByPrefix(prefix)
	for k, v in pairs(self.commands) do 
		if table.HasValue(v.prefixes, prefix) then 
			return v
		end
	end
end

-- Networking
if (CLIENT) then 
	net.Receive("admin_protocol", function()
		local pl = net.ReadEntity()
		local rank = net.ReadString()

		pl.rank = rank
	end)

	function Admin:ExecuteCommand(cmd, args)
		NETWORK:StartNetworkMessage(false, "admin.command", cmd, args)
	end 
end
