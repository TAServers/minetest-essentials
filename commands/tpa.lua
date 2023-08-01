--colors
local c6 = string.char(0x1b) .. "(c@#ffaa00)" --minecraft gold
local cc = string.char(0x1b) .. "(c@#ff5555)" --minecraft red
local c4 = string.char(0x1b) .. "(c@#aa0000)" --minecraft dark red
local cr = string.char(0x1b) .. "(c@#ffffff)" --reset

local timer = essentials.timer
local teleport = essentials.teleport

local tparequests = {}

local tpamessage = c6
	.. " has requested to teleport to %s.\n"
	.. c6
	.. "To teleport, type "
	.. cc
	.. "/tpaccept\n"
	.. c6
	.. "To deny this request, type "
	.. cc
	.. "/tpdeny\n"
	.. c6
	.. "This request will timeout after "
	.. cc
	.. "30 seconds"

local function tpa(name, target, here)
	if target == nil then
		return false, c6 .. "You must specify a name."
	end

	if name == target then
		return false, c6 .. "You cannot teleport to yourself."
	end

	if tparequests[name] ~= nil then
		return false, c6 .. "You already have a request ongoing. Please cancel or deny it first"
	end

	if tparequests[target] ~= nil then
		return false, c6 .. "That user already has a request ongoing. Please wait until they decide on it."
	end

	local player = minetest.get_player_by_name(name)
	local targetplayer = minetest.get_player_by_name(target)
	if player then
		if targetplayer then
			tparequests[name] = {
				timer = timer.once(30000, function()
					minetest.chat_send_player(name, c6 .. "Request timed out.")
					tparequests[name] = nil
					tparequests[target] = nil
				end),
				target = target,
				here = here or false,
			}
			tparequests[target] = {
				ask = name,
			}
			minetest.chat_send_player(
				target,
				cc .. name .. string.format(tpamessage, here and cc .. "them" or cc .. "you")
			)
			return true,
				c6
					.. "Request sent to "
					.. cc
					.. target
					.. "\n"
					.. c6
					.. "To cancel this request, type "
					.. cc
					.. "/tpacancel"
		else
			return false, cc .. "Error: " .. c4 .. "Player not found."
		end
	else
		return false, "You are not a player"
	end
end

minetest.register_chatcommand("spawn", {
	description = "Teleports you to spawn",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			teleport(player, mcl_spawn.get_world_spawn_pos())
			return true, c6 .. "Teleporting to spawn."
		else
			return false, "You are not a player."
		end
	end,
})

minetest.register_chatcommand("tpa", {
	description = "Ask another player to teleport to them",
	params = "<player>",
	func = function(name, param)
		return tpa(name, param, false)
	end,
})

minetest.register_chatcommand("tpahere", {
	description = "Ask another player to teleport to you",
	params = "<player>",
	func = function(name, param)
		return tpa(name, param, true)
	end,
})

minetest.register_chatcommand("tpdeny", {
	description = "Deny another player's teleport request",
	func = function(name, param)
		if tparequests[name] == nil then
			return false, c6 .. "You do not have any pending teleportation requests."
		end
		local asker = tparequests[name].ask
		if asker then --if player b accepts players a tpa request to player b
			timer.remove(tparequests[asker].timer)
			tparequests[name] = nil
			tparequests[asker] = nil
			minetest.chat_send_player(asker, cc .. name .. c6 .. " has denied your teleport request.")
			return true, c6 .. "Teleport request denied."
		end
	end,
})

minetest.register_chatcommand("tpacancel", {
	description = "Cancel your ongoing teleport request",
	func = function(name, param)
		if tparequests[name] == nil then
			return false, c6 .. "You do not have any pending teleportation requests."
		end
		local target = tparequests[name].target
		timer.remove(tparequests[name].timer)
		tparequests[name] = nil
		tparequests[target] = nil
		minetest.chat_send_player(target, cc .. asker .. c6 .. " has cancelled the teleport request.")
		return true, c6 .. "Teleport request cancelled."
	end,
})

minetest.register_chatcommand("tpaccept", {
	description = "Accept the teleport request",
	func = function(name, param)
		if tparequests[name] == nil then
			return false, c6 .. "You do not have any pending teleportation requests."
		end
		local asker = tparequests[name].ask
		local here = tparequests[asker].here
		if asker then --if player b accepts players a tpa request to player b
			timer.remove(tparequests[asker].timer)
			tparequests[name] = nil
			tparequests[asker] = nil
			minetest.chat_send_player(
				asker,
				cc .. asker .. c6 .. " has accepted your teleport request.\n" .. c6 .. "Teleporting..."
			)
			local dest
			local target
			if here then
				dest = minetest.get_player_by_name(asker)
				target = name
			else
				dest = minetest.get_player_by_name(name)
				target = asker
			end
			teleport(minetest.get_player_by_name(target), dest:get_pos())
			return true, c6 .. "Teleport request accepted."
		end
	end,
})

minetest.register_on_leaveplayer(function(playerref)
	local name = playerref:get_player_name()
	if tparequests[name] ~= nil then
		if tparequests[name].timer then
			timer.remove(tparequests[name].timer)
		end
		local target = tparequests[name].target or tparequests[name].ask
		tparequests[target] = nil
		tparequests[name] = nil
	end
end)
