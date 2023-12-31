local c6 = string.char(0x1b) .. "(c@#ffaa00)" --minecraft gold
local cc = string.char(0x1b) .. "(c@#ff5555)" --minecraft red
local c4 = string.char(0x1b) .. "(c@#aa0000)" --minecraft dark red
local cr = string.char(0x1b) .. "(c@#ffffff)" --reset

local timer = essentials.timer
local cooldown = essentials.teleportcooldown

function essentials.teleport(player, dest_pos)
	if player == nil then
		return
	end --wtf
	local name = player:get_player_name()
	local startinghealth = player:get_hp()

	if cooldown ~= nil and cooldown >= 1 then
		minetest.chat_send_player(
			name,
			c6 .. "Teleportation will commence in " .. cc .. cooldown .. c6 .. " seconds. Don't move."
		)
		local failed = false
		local canceltimer
		local oncooldown = timer.create(name.."_cooldown",250, function()
			if not player then --player left probably
				failed = true
				timer.remove(name.."_cooldown")
				return
			end
			local health = player:get_hp()
			if health < startinghealth and not failed then --at least let them heal
				minetest.chat_send_player(name, c4 .. "Pending teleportation request cancelled")
				timer.remove(name.."_cooldown")
				failed = true
			end
			startinghealth = health --prevent players from healing then taking damage over their starting health
			local vel = player:get_velocity() --server crashes randomly when vector.length somehow triggers
			if vector.length(vel or { x = 0, y = 0, z = 0 }) >= 0.4 and not failed then
				minetest.chat_send_player(name, c4 .. "Pending teleportation request cancelled")
				timer.remove(name.."_cooldown")
				failed = true
			end
		end)
		if failed then
			timer.remove(name.."_cooldown")
		end
		timer.once(cooldown*1000, function()
			if not failed then
				timer.remove(name.."_cooldown")
				player:set_pos(dest_pos)
				minetest.chat_send_player(name, c6 .. "Teleportation commencing...")
			end
		end)
	else
		player:set_pos(dest_pos)
		minetest.chat_send_player(name, c6 .. "Teleportation commencing...")
	end
end
