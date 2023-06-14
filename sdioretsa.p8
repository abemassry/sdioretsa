pico-8 cartridge // http://www.pico-8.com
version 38
__lua__


overlay_state = 0

function _init()
	asteroids={}
	bullets={}
	init_asteroid_count = 6 -- initial value
	reset_asteroids = true
	asteroid_count = 0
	bullet_count = 0
	btn_4_hold = 25

	-- there's only one ship so it's ok if global
	a = 0 -- the ship's angle
	thrust = 0 -- the ship's thrust

	t = 0
end


function rotate(x,y,cx,cy,angle)
	-- rotate everything when the ship turns
	local sina=sin(angle)
	local cosa=cos(angle)
 
	x-=cx
	y-=cy
	local rotx=cosa*x-sina*y
	local roty=sina*x+cosa*y
	rotx+=cx
	roty+=cy
 
	return rotx,roty
end

function add_bullet()
	bullet_count+=1
	add(bullets, {
		ox = 64,
		oy = 64,
		rx = 64, -- rotated bullet position
		ry = 64, 
		tx = 0, -- rotated thrust x component
		ty = 0, -- rotated thrust y component
		speedx = 0,
		speedy = 0,
		btimer = 0,
		init_angle = a,
		init_thrust = thrust,

		update=function(self)
			self.btimer+=1
			if self.btimer > 30 then
				bullet_count-=1
				del(bullets, self)
			end

			self.oy-=4 + (self.init_thrust)
			-- the thrust happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			self.tx = sin(a-self.init_angle) * thrust
			self.ty = cos(a-self.init_angle) * thrust
			self.ox+=(self.speedx) + self.tx
			self.oy+=(self.speedy) + self.ty

			-- the asteroid playing field is connected at the ends
			if (self.ox > 128) self.ox = 0
			if (self.ox < 0) self.ox = 128
			if (self.oy > 128) self.oy = 0
			if (self.oy < 0) self.oy = 128

			self.rx,self.ry=rotate(self.ox,self.oy,64,64,a-self.init_angle)
		end,

		draw=function(self)
			pset(self.rx, self.ry, 7)
		end,
		remove=function(self)
			bullet_count-=1
			del(bullets, self)
		end
	})
end

function add_new_asteroid()
	asteroid_count+=1
	large_asteroids = {1,3,5,7}
	add(asteroids, {
		ox=flr(rnd(128)), -- original asteroid position
		oy=flr(rnd(128)),
		rx=0, -- rotated asteroid position
		ry=0,
		xv = 0,
		yv = 0,
		tx = 0, -- rotated thrust x component
		ty = 0, -- rotated thrust y component
		blow_up = 0,
		speedx = (rnd(0.75)-0.25),
		speedy = (rnd(0.75)-0.25),
		size_accel = 0.33,
		a_rnd=rnd({1,2,3,4}),

		update=function(self)
			-- the thrust happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			self.tx = sin(a) * thrust
			self.ty = cos(a) * thrust
			self.ox+=(self.size_accel*self.speedx) + self.tx
			self.oy+=(self.size_accel*self.speedy) + self.ty

			-- the asteroid playing field is connected at the ends
			if (self.ox > 128) self.ox = 0
			if (self.ox < 0) self.ox = 128
			if (self.oy > 128) self.oy = 0
			if (self.oy < 0) self.oy = 128

			self.rx,self.ry=rotate(self.ox,self.oy,64,64,a)
			if self.blow_up > 30 then
				self.blow_up = 0
			end
			for b in all(bullets) do
				if (b.rx > self.rx-8 and b.rx <self.rx+8 and b.ry > self.ry-8 and b.ry < self.ry+8) then
					self.blow_up +=1
					b:remove()
				end
			end

		end,

		draw=function(self)
				if (self.blow_up > 0) then
					rect(self.rx,self.ry,self.rx-2,self.ry-2,8)
				end
				if (self.a_rnd == 1) then
					a1(self.rx, self.ry)
				elseif (self.a_rnd == 2) then
					a2(self.rx, self.ry)
				elseif (self.a_rnd == 3) then
					a3(self.rx, self.ry)
				else
					a4(self.rx, self.ry)
				end
		end
	})

end


function _update60()
	t+=1
	if (t>60) t=0
  -- rotate left
	if (btn(1)) then
		a += 0.006
	end

  -- rotate right
	if (btn(0)) then
		a -= 0.006
	end

  -- up is accelerate
	if (btn(2)) then
		thrust += .15
	else
		thrust -= .02
	end
	if (thrust < 0) thrust = 0
  if (thrust > 3) thrust = 3

	if (btn(4) and bullet_count < 4 and btn_4_hold > 10) then
		btn_4_hold = 0
		add_bullet()
	end
	btn_4_hold+=1

	if (a>1) a = 0
	if (a<0) a = 1
	if (reset_asteroids) then
		reset_asteroids = false
		for i=0,init_asteroid_count,1 do
			add_new_asteroid()
		end
	end
	for a in all(asteroids) do
		a:update()
	end

	for b in all(bullets) do
		b:update()
	end
end

function _draw()
	cls()
	for a in all(asteroids) do
		a:draw()
	end
	for b in all(bullets) do
		b:draw()
	end
	pset(64,64,6)
	pset(63,65,6)
	pset(63,66,6)
	pset(65,65,6)
	pset(65,66,6)
	--line(64,64,62,67,6)
	--line(64,64,66,67,6)


	if (btn(2)) pset(64,67,6)
	print('a:'..a, 0,0,6)
	print('bc:'..bullet_count, 0, 6, 6)
end

function a1(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=0, y=-5},
		 {x=-1, y=-5},
		 {x=-2, y=-5},
		 {x=-3, y=-6},
		 {x=-4, y=-6},
		 {x=-5, y=-6},
		 {x=-6, y=-5},
		 {x=-6, y=-4},
		 {x=-6, y=-3},
		 {x=-6, y=-2},
		 {x=-6, y=-1},
		 {x=-6, y=0},
		 {x=-6, y=1},
		 {x=-6, y=2},
		 {x=-5, y=3},
		 {x=-4, y=4},
		 {x=-3, y=5},
		 {x=-2, y=6},
		 {x=-1, y=6},
		 {x=0, y=6},
		 {x=1, y=6},
		 {x=2, y=6},
		 {x=3, y=6},
		 {x=4, y=6},
		 {x=5, y=6},
		 {x=6, y=5},
		 {x=6, y=4},
		 {x=6, y=3},
		 {x=6, y=2},
		 {x=5, y=1},
		 {x=4, y=0},
		 {x=4, y=-1},
		 {x=5, y=-2},
		 {x=6, y=-2},
		 {x=7, y=-3},
		 {x=6, y=-4},
		 {x=5, y=-5},
		 {x=4, y=-6},
		 {x=3, y=-7},
		 {x=2, y=-7},
		 {x=1, y=-6}
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function a2(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=32 y=8
	-- rx, ry = rotate(x+0, y-7, x, y, a)
	points = {
		{x=-1, y=-7},
		{x=-2, y=-8},
		{x=-3, y=-8},
		{x=-4, y=-8},
		{x=-5, y=-7},
		{x=-6, y=-6},
		{x=-7, y=-5},
		{x=-7, y=-4},
		{x=-7, y=-3},
		{x=-7, y=-2},
		{x=-7, y=-1},
		{x=-7, y=0},
		{x=-6, y=1},
		{x=-5, y=2},
		{x=-4, y=3},
		{x=-3, y=4},
		{x=-2, y=5},
		{x=-1, y=6},
		{x=0, y=6},
		{x=1, y=6},
		{x=2, y=6},
		{x=3, y=6},
		{x=4, y=6},
		{x=5, y=6},
		{x=6, y=5},
		{x=6, y=4},
		{x=6, y=3},
		{x=5, y=2},
		{x=4, y=1},
		{x=3, y=1},
		{x=2, y=0},
		{x=2, y=-1},
		{x=3, y=-1},
		{x=4, y=-2},
		{x=5, y=-2},
		{x=6, y=-3},
		{x=6, y=-4},
		{x=5, y=-5},
		{x=4, y=-6},
		{x=3, y=-6},
		{x=2, y=-6},
		{x=1, y=-7}
	}
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function a3(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=47 y=8
	-- rx, ry = rotate(x+0, y-7, x, y, a)
	points = {
		{x=0, y=-4},
		{x=-1, y=-5},
		{x=-2, y=-6},
		{x=-3, y=-7},
		{x=-4, y=-7},
		{x=-5, y=-6},
		{x=-6, y=-5},
		{x=-7, y=-4},
		{x=-6, y=-3},
		{x=-6, y=-2},
		{x=-5, y=-1},
		{x=-5, y=0},
		{x=-6, y=1},
		{x=-7, y=2},
		{x=-7, y=3},
		{x=-6, y=4},
		{x=-5, y=5},
		{x=-4, y=6},
		{x=-3, y=6},
		{x=-2, y=5},
		{x=-1, y=5},
		{x=0, y=4},
		{x=1, y=4},
		{x=2, y=5},
		{x=3, y=5},
		{x=4, y=6},
		{x=5, y=5},
		{x=6, y=4},
		{x=6, y=3},
		{x=7, y=2},
		{x=8, y=1},
		{x=7, y=0},
		{x=6, y=-1},
		{x=5, y=-1},
		{x=4, y=-2},
		{x=4, y=-3},
		{x=5, y=-3},
		{x=6, y=-4},
		{x=7, y=-5},
		{x=6, y=-6},
		{x=5, y=-7},
		{x=4, y=-7},
		{x=3, y=-6},
		{x=2, y=-5},
		{x=1, y=-5}
	}
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function a4(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=63 y=8
	-- rx, ry = rotate(x+0, y-7, x, y, a)
	points = {
		{x=0, y=-8},
		{x=-1, y=-7},
		{x=-2, y=-7},
		{x=-3, y=-7},
		{x=-4, y=-7},
		{x=-5, y=-7},
		{x=-5, y=-6},
		{x=-4, y=-5},
		{x=-3, y=-4},
		{x=-4, y=-3},
		{x=-5, y=-3},
		{x=-6, y=-3},
		{x=-7, y=-2},
		{x=-7, y=-1},
		{x=-7, y=0},
		{x=-7, y=1},
		{x=-7, y=2},
		{x=-7, y=3},
		{x=-6, y=4},
		{x=-6, y=5},
		{x=-5, y=6},
		{x=-4, y=7},
		{x=-3, y=6},
		{x=-2, y=6},
		{x=-1, y=5},
		{x=0, y=5},
		{x=1, y=5},
		{x=2, y=5},
		{x=3, y=6},
		{x=4, y=6},
		{x=5, y=6},
		{x=6, y=5},
		{x=7, y=4},
		{x=7, y=3},
		{x=6, y=2},
		{x=5, y=1},
		{x=5, y=0},
		{x=4, y=-1},
		{x=3, y=-2},
		{x=4, y=-3},
		{x=5, y=-3},
		{x=6, y=-4},
		{x=7, y=-5},
		{x=6, y=-6},
		{x=5, y=-6},
		{x=4, y=-7},
		{x=3, y=-8},
		{x=2, y=-8},
		{x=1, y=-8}
	}

	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end

end

__gfx__
00000000000000000000000000006660000000000000000000000000000000066660000000660666066660000060060006000660000000000000000000000000
00000000000000000000000000060006660000000006600000066000006666600006000006006006600006000606606060666006000000000000000000000000
00700700000000000660000000600000006660000060060000600600006000000000660006000006600000606000000660000660000000000000000000000000
00077000006660006006000006000000000006000600006066000060000600000000006006000060600066060600000606006000000000000000000000000000
00077000060006660000600006000000000000606000000600000600000060000000060006000006600600600600006006000600000000000000000000000000
00700700060000000000060006000000000000600600000000066000066600000006600000600006600060006000006060000060000000000000000000000000
00000000060000000000006006000000000066000600000000060000600000000060000000060060600006000600600660666006000000000000000000000000
00000000060000000000660006000000006600000060000000006600600000000006000000006600066660000066066006000660000000000000000000000000
00000000060000000006000006000000006000000060000000000060600000000000600000000000000000000000000000000000000000000000000000000000
00000000060000000006000000600000000660000600000000000006600000000000600000000000000060000000000000066000000000000000000000000000
00000000060000000000600000060000000006006000000000000060600000000000060000060000000660000006600000600600000000000000000000000000
00000000060000000000060000006000000000606000000000000600600000000000006000606000006006000060060006006000000000000000000000000000
00000000006000000000060000000600000000600600000660000600060000000000006000060000000660000060060000606000000000000000000000000000
00000000000600000000060000000060000000600060066006606000060000666600060000000000000600000006600000060000000000000000000000000000
00000000000060000000060000000006666666000006600000060000006066000066600000000000000000000000000000000000000000000000000000000000
00000000000006666666600000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000
