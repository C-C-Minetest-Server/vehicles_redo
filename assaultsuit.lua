-- depends: turret
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("vehicles:assaultsuit", {
	visual = "mesh",
	mesh = "assaultsuit.b3d",
	textures = {"vehicles_assaultsuit.png"},
	velocity = 15,
	acceleration = -5,
	owner = "",
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-0.8, 0, -0.8, 0.8, 3, 0.8},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, false, {x=0, y=20, z=8})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 8,
			decell = 0.5,
			shoots = true,
			arrow = "vehicles:bullet",
			reload_time = 0.2,
			shoots2 = true,
			arrow2 = "vehicles:missile_2",
			reload_time2 = 1,
			moving_anim = {x=120, y=140},
			stand_anim = {x=1, y=1},
			jump_type = "hover",
			jump_anim = {x=60, y=70},
			shoot_anim = {x=40, y=51},
			shoot_anim2 = {x=40, y=51},
			shoot_y = 3.5,
			shoot_y2 = 4,
		},
		function() self.standing = false end,
		function()
			if not self.standing then
				self.object:set_animation({x=1, y=1}, 20, 0)
				self.standing = true
			end
		end)
	end,
})

vehicles.register_spawner("vehicles:assaultsuit", "Assault Suit", "vehicles_assaultsuit_inv.png")
