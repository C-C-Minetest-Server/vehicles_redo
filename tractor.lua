local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("vehicles:tractor", {
	visual = "mesh",
	mesh = "tractor.b3d",
	textures = {"vehicles_tractor.png"},
	velocity = 15,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-0.8, 0, -0.8, 0.8, 1.4, 0.8},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=14, z=-10}, true, {x=0, y=2, z=-5})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 8,
			decell = 0.5,
			driving_sound = "engine",
			sound_duration = 11,
			destroy_node = "farming:wheat_8",
			moving_anim = {x=3, y=18},
			stand_anim = {x=1, y=1},
			handling = {initial=1.3, braking=2},
		})
	end,
})

vehicles.register_spawner("vehicles:tractor", S("Tractor"), "vehicles_tractor_inv.png")
