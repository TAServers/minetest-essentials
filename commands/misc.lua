local c6 = string.char(0x1b) .. "(c@#ffaa00)" --minecraft gold
local cc = string.char(0x1b) .. "(c@#ff5555)" --minecraft red
local c4 = string.char(0x1b) .. "(c@#aa0000)" --minecraft dark red
local cr = string.char(0x1b) .. "(c@#ffffff)" --reset

local maxusers = minetest.settings:get("max_users")
minetest.register_on_mods_loaded(function()
	minetest.override_chatcommand("list", {
		func = function(name, param)
			local players = minetest.get_connected_players()
			local player_names = ""
			for _, player in ipairs(players) do
				player_names = player_names .. player:get_player_name() .. ", "
			end
			return true,
				c6
					.. "There are "
					.. cc
					.. #players
					.. c6
					.. " out of maximum "
					.. cc
					.. max_users
					.. c6
					.. " players online."
					.. "\n"
					.. string.sub(player_names, 0, -3)
		end,
	})
end)