local MP = minetest.get_modpath(minetest.get_current_modname())
local WP = minetest.get_worldpath()
local function LoadModule(mn)
  return dofile(MP .. "/" .. mn .. ".lua")
end

--[[
Remember to add this line before **EVERY** module to let them get translate details

local S = minetest.get_translator(minetest.get_current_modname())


]]

LoadModule("api")
LoadModule("missiles")
LoadModule("firetruck")
LoadModule("turret")
LoadModule("assaultsuit") -- depends on turret
LoadModule("tractor")
LoadModule("cars/geep")
LoadModule("cars/ambulance")
LoadModule("cars/ute")
