--colors
local c6 = string.char(0x1b) .. "(c@#ffaa00)" --minecraft gold
local cc = string.char(0x1b) .. "(c@#ff5555)" --minecraft red
local c4 = string.char(0x1b) .. "(c@#aa0000)" --minecraft dark red
local cr = string.char(0x1b) .. "(c@#ffffff)" --reset

local maxhomes = essentials.maxhomes
local teleport = essentials.teleport
local storage = essentials.storage

local function validname(str)
	return str:match("%W")
end

minetest.register_chatcommand("home", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local homes = minetest.parse_json(storage:get_string(name .. ":homes") or "") or {}
			if param == nil and #homes == 1 then
				teleport(player, home.pos)
				return true
			end
			for k, home in ipairs(homes) do
				if home.name == param then
					teleport(player, home.pos)
					return true
				end
			end
			return false, cc .. "Error: " .. c4 .. "Could not find a home with that name."
		else
			return false, "You are not a player."
		end
	end,
})

minetest.register_chatcommand("sethome", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			if not validname(param) then
				return false, cc .. "Error: " .. c4 .. "Home names must be alphanumeric."
			end
			local homename = string.split(param, " ")[1]
			local homes = minetest.parse_json(storage:get_string(name .. ":homes") or "") or {}
			for k, home in ipairs(homes) do
				if home.name == param then
					return false, cc .. "Error: " .. c4 .. "That home already exists."
				end
			end
			if #homes >= maxhomes then
				return false, cc .. "Error: " .. c4 .. "Maximum number of homes reached."
			end
			--they can possibly set it midair but like, why
			table.insert(homes, {
				name = param,
				pos = player:get_pos(),
				h = player:get_look_horizontal(),
				v = player:get_look_vertical(),
			})
			storage:set_string(name .. ":homes", minetest.write_json(homes))
			return true, c6 .. "Home " .. cc .. param .. c6 .. " set"
		else
			return false, "You are not a player."
		end
	end,
})

minetest.register_chatcommand("homes", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if player then
			local homes = minetest.parse_json(storage:get_string(name .. ":homes") or "")
			print(homes)
			if homes == nil then
				return true, c6 .. "You do not have any homes."
			end
			local names = ""
			for k, home in ipairs(homes) do
				names = names .. home.name .. ", "
			end
			return true, c6 .. "Homes: " .. cr .. string.sub(names, 0, -3)
		else
			return false, "You are not a player."
		end
	end,
})
