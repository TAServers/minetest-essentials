minetest.log("Essentials loading...")

essentials = {}
essentials.storage = minetest.get_mod_storage()

local config = Settings(minetest.get_modpath("essentials") .. "/settings.conf")
essentials.teleportcooldown = tonumber(config:get("teleport_cooldown")) or 0
essentials.maxhomes = config:get("max_homes")

local timer = dofile(minetest.get_modpath("essentials") .. "/lib/timer.lua")
minetest.register_globalstep(function()
	timer.update()
end)
essentials.timer = timer

local lib = { "tp" }
for k, v in pairs(lib) do
	dofile(minetest.get_modpath("essentials") .. "/lib/" .. v .. ".lua")
end

local cmd = { "tpa", "home", "misc" }
for k, v in pairs(cmd) do
	dofile(minetest.get_modpath("essentials") .. "/commands/" .. v .. ".lua")
end


