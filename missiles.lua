local S = minetest.get_translator(minetest.get_current_modname())

local function missile_bullet_hit_check(self, obj, pos)
  local pos = self.object:get_pos()
  do
    local return_v = {}
    local if_return = false
    for _, obj in ipairs(minetest.get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)) do
      function no_launcher_or_not_attched()
        local b1, b2 = pcall(function() return obj ~= self.launcher:get_attach() end)
        if not b1 then
          return true -- no launcher
        else
          return b2 -- obj ~= attched object
        end
      end
      if obj:get_luaentity() ~= nil and obj ~= self.object and obj ~= self.vehicle and obj ~= self.launcher and no_launcher_or_not_attched() and obj:get_luaentity().name ~= "__builtin:item" then
        if_return = true
        return_v[#return_v+1]=obj
      end
    end
    if if_return then
      return return_v
    end
  end

  for dx=-1,1 do
    for dy=-1,1 do
      for dz=-1,1 do
        local p = {x=pos.x+dx, y=pos.y, z=pos.z+dz}
        local t = {x=pos.x+dx, y=pos.y+dy, z=pos.z+dz}
        local n = minetest.env:get_node(p)
        if n.name ~= "air" and n.drawtype ~= "airlike" then
          return {}
        end
      end
    end
  end
  return false
end

local function missile_on_step_auxiliary(self, obj, pos)
  local pos = self.object:get_pos()
  local vec = self.object:get_velocity()
  minetest.add_particlespawner({
    amount = 1,
    time = 0.5,
    minpos = {x=pos.x-0.2, y=pos.y, z=pos.z-0.2},
    maxpos = {x=pos.x+0.2, y=pos.y, z=pos.z+0.2},
    minvel = {x=-vec.x/2, y=-vec.y/2, z=-vec.z/2},
    maxvel = {x=-vec.x, y=-vec.y, z=-vec.z},
    minacc = {x=0, y=-1, z=0},
    maxacc = {x=0, y=-1, z=0},
    minexptime = 0.2,
    maxexptime = 0.6,
    minsize = 3,
    maxsize = 4,
    collisiondetection = false,
    texture = "vehicles_smoke.png",
  })
  local objs = missile_bullet_hit_check(self, obj, pos)
  if objs then
    for _, obj in ipairs(objs) do
      local puncher = self.object
      if self.launcher then puncher = self.launcher end
      obj:punch(puncher, 1.0, {
        full_punch_interval=1.0,
        damage_groups={fleshy=12},
      }, nil)
    end
    tnt.boom(self.object:get_pos(), {damage_radius=5,radius=5,ignore_protection=false})
    self.object:remove()
  end
end

minetest.register_entity("vehicles:missile", {
	visual = "mesh",
	mesh = "missile.b3d",
	textures = {"vehicles_missile.png"},
	velocity = 15,
	acceleration = -5,
	damage = 2,
	collisionbox = {-1, -0.5, -1, 1, 0.5, 1},
	on_rightclick = function(self, clicker)
		clicker:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=1,z=0})
	end,
	on_step = function(self, dtime)
		local player = self.launcher
    if self.dtime == nil then self.dtime = 0 end
    self.dtime = self.dtime + dtime
    if self.dtime > 10 then
      self.object:remove()
      return
    end
		if player == nil or player:get_player_name() == "" then
			self.object:remove()
			return
		end
    if minetest.global_exists("hangglider") then
      if not hangglider.can_fly(player:get_player_name(),self.object:get_pos()) then
        vehicles.explodinate(self, 1, 1)
        self.object:remove()
        minetest.chat_send_player(player:get_player_name(),"Your missile was shot down by anti-aircraft guns!")
        return
      end
    end
		local dir = player:get_look_dir()
		local vec = {x=dir.x*16,y=dir.y*16,z=dir.z*16}
		local yaw = player:get_look_horizontal()
		self.object:setyaw(yaw+math.pi/2)
		self.object:setvelocity(vec)
		missile_on_step_auxiliary(self, obj, pos)
	end,
})

minetest.register_entity("vehicles:missile_2", {
	visual = "mesh",
	mesh = "missile.b3d",
	textures = {"vehicles_missile.png"},
	velocity = 15,
	acceleration = -5,
	damage = 2,
	collisionbox = {0, 0, 0, 0, 0, 0},
	on_step = function(self, dtime)
	  local player = self.launcher
    if self.dtime == nil then self.dtime = 0 end
    self.dtime = self.dtime + dtime
    if self.dtime > 10 then
      self.object:remove()
      return
    end
    if minetest.global_exists("hangglider") then
      if not hangglider.can_fly(player:get_player_name(),self.object:get_pos()) then
        vehicles.explodinate(self, 1, 1)
        self.object:remove()
        minetest.chat_send_player(player:get_player_name(),"Your missile was shot down by anti-aircraft guns!")
        return
      end
    end
		local velo = self.object:get_velocity()
		if velo.y <= 1.2 and velo.y >= -1.2 then
			self.object:set_animation({x=1, y=1}, 5, 0)
		elseif velo.y <= -1.2 then
			self.object:set_animation({x=4, y=4}, 5, 0)
		elseif velo.y >= 1.2 then
			self.object:set_animation({x=2, y=2}, 5, 0)
		end
		missile_on_step_auxiliary(self, obj, pos)
	end,
})

minetest.register_entity("vehicles:tank", {
	visual = "mesh",
	mesh = "tank.b3d",
	textures = {"vehicles_tank.png"},
	velocity = 15,
	acceleration = -5,
	owner = "",
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1, 0, -0.9, 1, 1.5, 0.9},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=25, z=-3}, true, {x=0, y=6, z=-2})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 6,
			decell = 0.5,
			shoots = true,
			arrow = "vehicles:missile_2",
			reload_time = 1,
			shoot_y = 2,
			moving_anim = {x=3, y=8},
			stand_anim = {x=1, y=1},
		})
	end,
})

minetest.register_entity("vehicles:tank2", {
	visual = "mesh",
	mesh = "tank.b3d",
	textures = {"vehicles_tank2.png"},
	velocity = 15,
	acceleration = -5,
	owner = "",
	stepheight = 1.5,
	hp_max = 200,
	physical = true,
	collisionbox = {-1, 0, -0.9, 1, 1.5, 0.9},
	on_rightclick = function(self, clicker)
		if self.driver and clicker == self.driver then
			vehicles.object_detach(self, clicker, {x=1, y=0, z=1})
		elseif not self.driver then
			vehicles.object_attach(self, clicker, {x=0, y=25, z=-3}, true, {x=0, y=6, z=-2})
		end
	end,
	on_punch = vehicles.on_punch,
	on_step = function(self, dtime)
		return vehicles.on_step(self, dtime, {
			speed = 6,
			decell = 0.5,
			shoots = true,
			arrow = "vehicles:missile_2",
			reload_time = 1,
			shoot_y = 2,
			moving_anim = {x=3, y=8},
			stand_anim = {x=1, y=1},
		})
	end,
})

-- Items
vehicles.register_spawner("vehicles:tank", S("Tank"), "vehicles_tank_inv.png")
vehicles.register_spawner("vehicles:tank2", S("Desert Tank"), "vehicles_tank2_inv.png")

minetest.register_craftitem("vehicles:missile_2_item", {
  description = S("Missile"),
  inventory_image = "vehicles_missile_inv.png"
})

minetest.register_tool("vehicles:rc", {
  description = S("Rc (use with missiles)"),
  inventory_image = "vehicles_rc.png",
  wield_scale = {x = 1.5, y = 1.5, z = 1},
  tool_capabilities = {
    full_punch_interval = 0.7,
    max_drop_level=1,
    groupcaps={
      snappy={times={[1]=2.0, [2]=1.00, [3]=0.35}, uses=30, maxlevel=3},
    },
    damage_groups = {fleshy=1},
  },
  on_use = function(item, placer, pointed_thing)
    local dir = placer:get_look_dir()
    local playerpos = placer:get_pos()
    local pname = placer:get_player_name()
    local inv = minetest.get_inventory({type="player", name=pname})
    if inv:contains_item("main", "vehicles:missile_2_item") then
      local creative_mode = creative and creative.is_enabled_for and creative.is_enabled_for(placer:get_player_name())
      if not creative_mode then inv:remove_item("main", "vehicles:missile_2_item") end
      local obj = minetest.env:add_entity({x=playerpos.x+0+dir.x,y=playerpos.y+1+dir.y,z=playerpos.z+0+dir.z}, "vehicles:missile")
      local object = obj:get_luaentity()
      object.launcher = placer
      object.vehicle = nil
      object.dtime = 0
      local vec = {x=dir.x*6,y=dir.y*6,z=dir.z*6}
      obj:setvelocity(vec)
      return item
    end
  end,
})
