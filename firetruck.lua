local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("vehicles:water", {
	visual = "sprite",
	textures = {"vehicles_trans.png"},
	velocity = 15,
	acceleration = -5,
	damage = 2,
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_activate = function(self)
		self.object:setacceleration({x=0, y=-1, z=0})
	end,
	on_step = function(self, obj, pos)
		minetest.after(5, function()
			self.object:remove()
		end)
		local pos = self.object:get_pos()
		minetest.add_particlespawner({
			amount = 1,
			time = 1,
			minpos = {x=pos.x, y=pos.y, z=pos.z},
			maxpos = {x=pos.x, y=pos.y, z=pos.z},
			minvel = {x=0, y=0, z=0},
			maxvel = {x=0, y=-0.2, z=0},
			minacc = {x=0, y=-1, z=0},
			maxacc = {x=0, y=-1, z=0},
			minexptime = 1,
			maxexptime = 1,
			minsize = 4,
			maxsize = 5,
			collisiondetection = false,
			vertical = false,
			texture = "vehicles_water.png",
		})
		local node = minetest.env:get_node(pos).name
		if node == "fire:basic_flame" then
			minetest.remove_node(pos)
		end
	end
})

minetest.register_entity("vehicles:firetruck", {
	visual = "mesh",
	mesh = "firetruck.b3d",
	textures = {"vehicles_firetruck.png"},
	velocity = 15,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1.1, 0, -1.1, 1.1, 1.9, 1.1},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=5, z=5}, false, {x=0, y=2, z=5})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 10,
			decell = 0.5,
			shoots = true,
			arrow = "vehicles:water",
			infinite_arrow = true,
			reload_time = 0.2,
			driving_sound = "engine",
			sound_duration = 11,
			handling = {initial=1.3, braking=2},
		})
	end,
})

vehicles.register_spawner("vehicles:firetruck", S("Fire truck"), "vehicles_firetruck_inv.png")
