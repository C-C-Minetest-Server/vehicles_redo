local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("vehicles:ute", {
	visual = "mesh",
	mesh = "ute.b3d",
	textures = {"vehicles_ute.png"},
	velocity = 17,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1.4, 0, -1.4, 1.4, 1, 1.4},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif self.driver and clicker ~= self.driver and not self.rider then
			clicker:set_attach(self.object, clicker, {x=0, y=5, z=-5}, {x=0, y=0, z=-2})
			self.rider = true
		elseif self.driver and clicker ~=self.driver and self.rider then
			clicker:set_detach()
			self.rider = false
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, false, {x=0, y=2, z=4})
			minetest.sound_play("engine_start",
				{to_player=self.driver:get_player_name(), gain = 4, max_hear_distance = 3, loop = false})
			self.sound_ready = false
			minetest.after(14, function()
				self.sound_ready = true
			end)
		end
	end,
	on_punch = vehicles.on_punch,
	on_activate = function(self)
		self.nitro = true
	end,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 17,
			decell = 0.95,
			boost = true,
			boost_duration = 6,
			boost_effect = "vehicles_nitro.png",
			driving_sound = "engine",
			sound_duration = 11,
			brakes = true,
		},
		function()
			local pos = self.object:get_pos()
			minetest.add_particlespawner(
				15, --amount
				1, --time
				{x=pos.x, y=pos.y, z=pos.z}, --minpos
				{x=pos.x, y=pos.y, z=pos.z}, --maxpos
				{x=0, y=0, z=0}, --minvel
				{x=0, y=0, z=0}, --maxvel
				{x=-0,y=-0,z=-0}, --minacc
				{x=0,y=0,z=0}, --maxacc
				0.5, --minexptime
				1, --maxexptime
				10, --minsize
				15, --maxsize
				false, --collisiondetection
				"vehicles_dust.png" --texture
			)
		end)
	end,
})

vehicles.register_spawner("vehicles:ute", S("Ute (dirty)"), "vehicles_ute_inv.png")

minetest.register_entity("vehicles:ute2", {
	visual = "mesh",
	mesh = "ute.b3d",
	textures = {"vehicles_ute2.png"},
	velocity = 17,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1.4, 0, -1.4, 1.4, 1, 1.4},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif self.driver and clicker ~= self.driver and not self.rider then
			clicker:set_attach(self.object, clicker, {x=0, y=5, z=-5}, {x=0, y=0, z=0})
			self.rider = true
		elseif self.driver and clicker ~=self.driver and self.rider then
			clicker:set_detach()
			self.rider = false
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, false, {x=0, y=2, z=4})
			minetest.sound_play("engine_start",
				{to_player=self.driver:get_player_name(), gain = 4, max_hear_distance = 3, loop = false})
			self.sound_ready = false
			minetest.after(14, function()
				self.sound_ready = true
			end)
		end
	end,
	on_punch = vehicles.on_punch,
	on_activate = function(self)
		self.nitro = true
	end,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 17,
			decell = 0.95,
			boost = true,
			boost_duration = 6,
			boost_effect = "vehicles_nitro.png",
			driving_sound = "engine",
			sound_duration = 11,
			brakes = true,
		})
	end,
})

vehicles.register_spawner("vehicles:ute2", S("Ute (clean)"), "vehicles_ute_inv.png")
