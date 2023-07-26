minetest.log("Essentials loading...")

essentials = {}
essentials.storage = minetest.get_mod_storage()

local config = Settings(minetest.get_modpath("essentials") .. "/settings.conf")
essentials.teleportcooldown = config:get("teleport_cooldown")
essentials.maxhomes = config:get("max_homes")

essentials.timer = dofile(minetest.get_modpath("essentials") .. "/lib/timer.lua")
minetest.register_globalstep(function(dt)
	timer.update(dt)
end)

local lib = { "tp" }
for k, v in pairs(lib) do
	dofile(minetest.get_modpath("essentials") .. "/lib/" .. v .. ".lua")
end

local cmd = { "tpa", "home", "misc" }
for k, v in pairs(cmd) do
	dofile(minetest.get_modpath("essentials") .. "/commands/" .. v .. ".lua")
end


