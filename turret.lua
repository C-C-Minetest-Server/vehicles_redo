local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("vehicles:bullet", {
	visual = "mesh",
	mesh = "bullet.b3d",
	textures = {"vehicles_bullet.png"},
	velocity = 15,
	acceleration = -5,
	damage = 2,
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_activate = function(self)
		local pos = self.object:get_pos()
		minetest.sound_play("shot",
			{gain = 0.4, max_hear_distance = 3, loop = false})
	end,
	on_step = function(self, obj, pos)
    if self.dtime == nil then self.dtime = 0 end
    self.dtime = self.dtime + dtime
    if self.dtime > 10 then
      self.object:remove()
      return
    end
		local objs = missile_bullet_hit_check(self, obj, pos)
		if objs then
			for _, obj in ipairs(objs) do
				obj:punch(self.launcher, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=5},
				}, nil)
			end
			self.object:remove()
      return
		end
	end,
})

minetest.register_entity("vehicles:turret", {
	visual = "mesh",
	mesh = "turret_gun.b3d",
	textures = {"vehicles_turret.png"},
	velocity = 15,
	acceleration = -5,
	stepheight = 1.5,
	hp_max = 50,
	groups = {fleshy=3, level=5},
	physical = true,
	collisionbox = {-0.6, 0, -0.6, 0.6, 0.9, 0.6},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=5, z=4}, true, {x=0, y=2, z=4})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		self.object:setvelocity({x=0, y=-1, z=0})
		if self.driver then
			vehicles.object_drive(self, dtime, {
				fixed = true,
				shoot_y = 1.5,
				arrow = "vehicles:bullet",
				shoots = true,
				reload_time = 0.2,
			})
			return false
		end
		return true
	end,
})

vehicles.register_spawner("vehicles:turret", S("Gun turret"), "vehicles_turret_inv.png")
