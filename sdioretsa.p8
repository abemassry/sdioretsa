pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
overlay_state = 0

function _init()
	asteroids={}
	bullets={}
	ufos={}
	ufo_bullets={}
	ufo_count = 0
	new_ufo_timer = 0
	init_asteroid_count = 4 -- initial value
	reset_asteroids = true
	btn_4_press = false
	asteroid_count = 0
	bullet_count = 0
	ufo_bullet_count = 0
	btn_4_hold = 25

	lives = 2
	lose = 0
	score_ones = 0
	score_tens = 0
	score_hundreds = 0
	score_thousands = 0
	score_tenthousands = 0
	score_hundredthousands = 0
	score_millions = 0
	score_tenmillions = 0
	score_hundredmillions = 0
	score_billions = 0

	new_high_score = false
	high_score_ones = 0
	high_score_tens = 0
	high_score_hundreds = 0
	high_score_thousands = 0
	high_score_tenthousands = 0
	high_score_hundredthousands = 0
	high_score_millions = 0
	high_score_tenmillions = 0
	high_score_hundredmillions = 0
	high_score_billions = 0

	-- there's only one ship so it's ok if global
	a = 0 -- the ship's angle
	t_a = 0 -- the ship's angle thrust activate
	pt_a = 0 -- previous thrust angle
	t_x = 0 -- x component of ship thrust
	t_y = 0 -- y component of ship thrust
	tvx = 0 -- thrust x component
	tvy = 0 -- thrust y copmonent
	thrust = 0 -- the ship's thrust

	velocity = 0 -- the ship's speed (can be added to or subtracted from by thrust)
	vx = 0 -- ship's velocity x component
	vy = 0 -- ship's velocity y component
	vt = 0
	tx = 0 -- the rotated x thrust component
	ty = 0 -- the rotated y thrust component

	t = 0
	one_up_particles={}
	overlay_state = 0
	-- overlay_state 0 title screen
	-- overlay_state 1 main play
	-- overlay_state 2 pause
	-- overlay_state 3 end of level
	-- overlay_state 4 transition
	attract_timer = 0
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
		vx = 0, -- rotated velocity x component
		vy = 0, -- rotated velocity y component
		speedx = 0,
		speedy = 0,
		btimer = 0,
		init_angle = a,
		init_velocity = velocity,
		dir_x = flr(rnd(20)) - 10,
		dir_y = flr(rnd(20)) - 10,

		update=function(self)
			self.btimer+=1
			if self.btimer > 45 then
				bullet_count-=1
				del(bullets, self)
			end

			self.oy-=2 + (self.init_velocity)
			-- the velocity happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			self.vx = sin(a-self.init_angle) * velocity
			self.vy = cos(a-self.init_angle) * velocity
			self.ox+=((self.speedx) + self.vx) * self.dir_x
			self.oy+=((self.speedy) + self.vy) * self.dir_y

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

function add_ufo_bullet(xinit, yinit)
	ufo_bullet_count+=1
	add(ufo_bullets, {
		ox = xinit,
		oy = yinit,
		rx = xinit, -- rotated ufo_bullet position
		ry = yinit, 
		vx = 0, -- rotated velocity x component
		vy = 0, -- rotated velocity y component
		speedx = 0,
		speedy = 0,
		btimer = 0,
		init_angle = a,
		init_velocity = velocity,

		update=function(self)
			self.btimer+=1
			if self.btimer > 45 then
				ufo_bullet_count-=1
				del(ufo_bullets, self)
			end

			--self.oy+=xinit
			--self.ox+=yinit
			-- the velocity happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			self.vx = sin(a-self.init_angle) * self.init_velocity
			self.vy = cos(a-self.init_angle) * self.init_velocity
			self.ox+=(self.speedx) + self.vx
			self.oy+=(self.speedy) + self.vy

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
			ufo_bullet_count-=1
			del(ufo_bullets, self)
		end
	})
end

function add_explode_particle(xinit, yinit, rinit, direction, tinit)
	for ri=rinit,rinit+1,1 do
		for i=0,1,0.25 do
			add(one_up_particles, {
				-- x=xinit+(((ri+tinit)*cos(i))*0.4),
				-- y=yinit+((((ri+tinit)*sin(i))+tinit)*0.4),
				x=xinit,
				y=yinit,
				t=tinit,
				d=direction,
				draw=function(self)
					if (flr(rnd(2)) == 0) then
						pset((self.x)+(flr(rnd(3)-1))*((self.t)*(rnd(i)*.5)), (self.y)+(flr(rnd(3)-1))*((self.t)*(rnd(i)*.5)), 7)
					end
				end,
				update=function(self)
					self.t+=1
					if self.t > 20 then
						del(one_up_particles, self)
					end
				end,
				remove=function(self)
					del(one_up_particles, self)
				end
			})
		end
	end
end

function draw_one_up_explode(xinit, yinit, rinit, direction, tinit)
	-- TODO: remove direction
	offset = 1.5
	add_explode_particle(xinit, yinit, rinit, direction, tinit)

end

function add_new_asteroid(size_new, xinit, yinit)
	asteroid_count+=1
	large_asteroids = {1,3,5,7}

	add(asteroids, {
		ox=xinit, -- original asteroid position
		oy=yinit,
		rx=0, -- rotated asteroid position
		ry=0,
		vx = 0, -- rotated velocity x component
		vy = 0, -- rotated velocity y component
		tx = 0, -- rotated thrust x component
		ty = 0, -- rotated thrust y component
		tdirection = -1,
		blow_up = 0,
		speedx = (rnd(0.75)*(8/size_new)-0.25),
		speedy = (rnd(0.75)*(8/size_new)-0.25),
		size_accel = 0.33,
		a_rnd=rnd({1,2,3,4}),
		init_angle = 0,
		size=size_new,

		lose_reset=function(self)
			--self.vx = self.speedx
			--self.vy = self.speedy
			self.vx = 0
			self.vy = 0
		end,

		update=function(self)
			-- the thrust happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			if (btn(2) and lose == 0) then
				self.vx = self.vx + (tvx * 0.04) -- thrust component against velocity
				self.vy = self.vy + (tvy * 0.04) -- can be negative
			end
			if (self.vx > 2.5) self.vx = 2.5 -- speed limits
			if (self.vx < -2.5) self.vx = -2.5
			if (self.vy > 2.5) self.vy = 2.5
			if (self.vy < -2.5) self.vy = -2.5
			if (self.vx > 0) self.vx -= .001 -- deceleration due to inertia
			if (self.vx < 0) self.vx += .001
			if (self.vy > 0) self.vy -= .001
			if (self.vy < 0) self.vy += .001

			self.ox+=((self.size_accel*self.speedx) + self.vx) -- update non rotated x
			self.oy+=((self.size_accel*self.speedy) + self.vy) -- update non rotated y

			-- the asteroid playing field is connected at the ends
			if (self.ox > 128) self.ox = 0
			if (self.ox < 0) self.ox = 128
			if (self.oy > 128) self.oy = 0
			if (self.oy < 0) self.oy = 128

			self.rx,self.ry=rotate(self.ox,self.oy,64,64,a) -- determine rotated pos
			if self.blow_up > 0 then
				self.blow_up +=1
			end
			if self.blow_up > 30 then
				self:remove()
			end
			for b in all(bullets) do
				-- check for collisions between all bullets and this asteroid
				-- the idea is there are less bullets than asteroids so it's
				-- less expensive
				if (b.rx > self.rx-self.size and b.rx <self.rx+self.size and b.ry > self.ry-self.size and b.ry < self.ry+self.size and self.blow_up < 1) then
					self.blow_up +=1
					b:remove()
					if (self.size == 8) then
						add_new_asteroid(4, self.ox, self.oy)
						add_new_asteroid(4, self.ox, self.oy)
						score_tens += 2
					elseif (self.size == 4) then
						add_new_asteroid(2, self.ox, self.oy)
						add_new_asteroid(2, self.ox, self.oy)
						score_tens += 5
					else
						score_hundreds += 1
					end
					calc_score()
				end
			end

			local hit_box_adjust = 1
			if (self.size == 2) hit_box_adjust = 0

			-- check for collision with player's ship
			if (self.rx+(self.size-hit_box_adjust) > 64 and self.rx-(self.size-hit_box_adjust) < 64 and self.ry+(self.size-hit_box_adjust) > 64 and self.ry-(self.size-hit_box_adjust) < 64 and self.blow_up == 0 and lose == 0 and overlay_state == 1) then 
				lose = 1
				lives-=1
				self.blow_up +=1
				if (self.size == 8) then
					add_new_asteroid(4, self.ox, self.oy)
					add_new_asteroid(4, self.ox, self.oy)
					score_tens += 2
				elseif (self.size == 4) then
					add_new_asteroid(2, self.ox, self.oy)
					add_new_asteroid(2, self.ox, self.oy)
					score_tens += 5
				else
					score_hundreds += 1
				end
				calc_score()
			end

		end,

		draw=function(self)
				if (self.blow_up > 0) then
					-- do astroid particle animation
					if (self.blow_up == 1) draw_one_up_explode(self.rx, self.ry, 0, 0, 6)
					if self.blow_up > 1 then
						for op in all(one_up_particles) do
							op:update()
							op:draw()
						end
					end
				else
					-- determine which asteroid to draw
					if (self.a_rnd == 1) then
						if (self.size == 8) then
							a1(self.rx, self.ry)
						elseif (self.size == 4) then
							a1m(self.rx, self.ry)
						elseif (self.size == 2) then
							a1s(self.rx, self.ry)
						end
					elseif (self.a_rnd == 2) then
						if (self.size == 8) then
							a2(self.rx, self.ry)
						elseif (self.size == 4) then
							a2m(self.rx, self.ry)
						elseif (self.size == 2) then
							a2s(self.rx, self.ry)
						end
					elseif (self.a_rnd == 3) then
						if (self.size == 8) then
							a3(self.rx, self.ry)
						elseif (self.size == 4) then
							a3m(self.rx, self.ry)
						elseif (self.size == 2) then
							a3s(self.rx, self.ry)
						end
					else
						if (self.size == 8) then
							a4(self.rx, self.ry)
						elseif (self.size == 4) then
							a4m(self.rx, self.ry)
						elseif (self.size == 2) then
							a4s(self.rx, self.ry)
						end
					end
				end
		end,

		remove=function(self)
			del(asteroids, self)
			asteroid_count-=1
		end
	})

end

function add_ufo(size, xinit, yinit)
	ufo_count+=1
	new_ufo_timer=0
	add(ufos, {
		ox=xinit, -- original ufo position
		oy=yinit,
		rx=0, -- rotated ufo position
		ry=0,
		vx = 0, -- rotated velocity x component
		vy = 0, -- rotated velocity y component
		tx = 0, -- rotated thrust x component
		ty = 0, -- rotated thrust y component
		tdirection = -1,
		blow_up = 0,
		speedx = 1,
		speedy = 0,
		size_accel = 0.33,
		a_rnd=rnd({1,2,3,4}),
		init_angle = 0,
		size=size,
		life_timer=0,

		lose_reset=function(self)
			--self.vx = self.speedx
			--self.vy = self.speedy
			self.vx = 0
			self.vy = 0
		end,

		update=function(self)
			self.life_timer+=1
			-- the thrust happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			if (btn(2) and lose == 0) then
				self.vx = self.vx + (tvx * 0.04) -- thrust component against velocity
				self.vy = self.vy + (tvy * 0.04) -- can be negative
			end
			if (self.vx > 2.5) self.vx = 2.5 -- speed limits
			if (self.vx < -2.5) self.vx = -2.5
			if (self.vy > 2.5) self.vy = 2.5
			if (self.vy < -2.5) self.vy = -2.5
			if (self.vx > 0) self.vx -= .001 -- deceleration due to inertia
			if (self.vx < 0) self.vx += .001
			if (self.vy > 0) self.vy -= .001
			if (self.vy < 0) self.vy += .001

			self.ox+=((self.size_accel*self.speedx) + self.vx) -- update non rotated x
			self.oy+=((self.size_accel*self.speedy) + self.vy) -- update non rotated y

			-- the asteroid playing field is connected at the ends
			if (self.ox > 128) self.ox = 0
			if (self.ox < 0) self.ox = 128
			if (self.oy > 128) self.oy = 0
			if (self.oy < 0) self.oy = 128

			self.rx,self.ry=rotate(self.ox,self.oy,64,64,a) -- determine rotated pos
			if self.blow_up > 0 then
				self.blow_up +=1
			end
			if self.blow_up > 30 then
				self:remove()
			end
			for b in all(bullets) do
				-- check for collisions between all bullets and the ufo
				-- the idea is that the same code worked for asteroids so reuse it for ufos
				if (b.rx > self.rx-self.size and b.rx <self.rx+self.size and b.ry > self.ry-self.size and b.ry < self.ry+self.size and self.blow_up < 1) then
					self.blow_up +=1
					b:remove()
					if (self.size == 6) then
						score_hundreds += 2
					else
						score_thousands += 1
					end
					calc_score()
				end
			end

			local hit_box_adjust = 1
			if (self.size == 3) hit_box_adjust = 0

			if (self.rx+(self.size-hit_box_adjust) > 64 and self.rx-(self.size-hit_box_adjust) < 64 and self.ry+(self.size-hit_box_adjust) > 64 and self.ry-(self.size-hit_box_adjust) < 64 and self.blow_up == 0 and lose == 0 and overlay_state == 1) then 
				lose = 1
				lives-=1
				self.blow_up +=1
					if (self.size == 6) then
						score_hundreds += 2
					else
						score_thousands += 1
					end
				calc_score()
			end

			if self.life_timer > 60 and self.life_timer <= 180 then
				self.speedy = -1
			elseif self.life_timer > 180 and self.life_timer <= 240 then
				self.speedy = 0
			elseif self.life_timer > 240 then
				self.speedy = 1
			end

			if (self.life_timer % 10 == 0) add_ufo_bullet(self.ox, self.oy)

			if (self.life_timer > 300) self:remove()

		end,

		draw=function(self)
				if (self.blow_up > 0) then
					-- do ufo particle animation
					if (self.blow_up == 1) draw_one_up_explode(self.rx, self.ry, 0, 0, 6)
					if self.blow_up > 1 then
						for op in all(one_up_particles) do
							op:update()
							op:draw()
						end
					end
				else
					-- determine which asteroid to draw
					if (self.size == 6) then
						ufo_big(self.rx, self.ry)
					else
						ufo_small(self.rx, self.ry)
					end
				end
		end,

		remove=function(self)
			del(ufos, self)
			ufo_count-=1
		end
	})

end


function _update60()
	if overlay_state == 0 then
		attract_timer+=1
		if (attract_timer > 60) attract_timer = 0
		if (reset_asteroids) then
			reset_asteroids = false
			for i=1,init_asteroid_count,1 do
				add_new_asteroid(8, flr(rnd(128)), flr(rnd(128)))
			end
		end
		for a in all(asteroids) do
			a:update()
		end
		if (btn(5)) then
			overlay_state = 1
			for a in all(asteroids) do
				a:remove()
			end
			reset_asteroids = true
			lives = 2
		end

	elseif overlay_state == 1 then

		-- timers
		t+=1
		if (ufo_count == 0) new_ufo_timer+=1
		if (t>60) t=0

		if lose > 0 then
			lose+=1
		end
		if (lose>90 and lives > -1) then 
			lose=0
			a = 0 -- the ship's angle
			t_a = 0 -- the ship's angle thrust activate
			pt_a = 0 -- previous thrust angle
			t_x = 0 -- x component of ship thrust
			t_y = 0 -- y component of ship thrust
			tvx = 0 -- thrust x component
			tvy = 0 -- thrust y copmonent
			thrust = 0 -- the ship's thrust

			velocity = 0 -- the ship's speed (can be added to or subtracted from by thrust)
			vx = 0 -- ship's velocity x component
			vy = 0 -- ship's velocity y component
			vt = 0
			tx = 0 -- the rotated x thrust component
			ty = 0 -- the rotated y thrust component

			for a in all(asteroids) do
				a:lose_reset()
			end
		end


		if (lose > 300 and lives == -1) then
			calc_highscore()
			lose=0
			a = 0 -- the ship's angle
			t_a = 0 -- the ship's angle thrust activate
			pt_a = 0 -- previous thrust angle
			t_x = 0 -- x component of ship thrust
			t_y = 0 -- y component of ship thrust
			tvx = 0 -- thrust x component
			tvy = 0 -- thrust y copmonent
			thrust = 0 -- the ship's thrust

			velocity = 0 -- the ship's speed (can be added to or subtracted from by thrust)
			vx = 0 -- ship's velocity x component
			vy = 0 -- ship's velocity y component
			vt = 0
			tx = 0 -- the rotated x thrust component
			ty = 0 -- the rotated y thrust component
			overlay_state = 0
			for a in all(asteroids) do
				a:remove()
			end
			reset_asteroids = true
		end

		-- rotate left
		if (btn(1) and lose == 0) then
			a += 0.008
		end

		-- rotate right
		if (btn(0) and lose == 0) then
			a -= 0.008
		end

		-- up is accelerate
		-- first part of ship acceleration and velocity
		if (btn(2) and lose == 0) then
			t_a = a
			if (velocity > 0) then
				tvx = sin(t_a) * velocity -- thrust x component
				tvy = cos(t_a) * velocity -- thrust y component
			end
			thrust = .1
		else
			thrust = -.005
		end
		velocity += thrust
		if (velocity < 0) velocity = 0
		if (velocity > 3) velocity = 3

		-- if (btn(4) and bullet_count < 4 and btn_4_hold > 30) then
		if (btn_4_press == false and btn(4) and bullet_count < 4 and btn_4_hold > 5 and lose == 0) then
			btn_4_hold = 0
			add_bullet()
		end
		btn_4_hold+=1
		if (btn(4)) then
			btn_4_press = true
		else
			btn_4_press = false
		end
		-- if (not btn(4)) btn_4_hold = 0

		if (a>1) a = 0
		if (a<0) a = 1
		if (reset_asteroids) then
			reset_asteroids = false
			for i=1,init_asteroid_count,1 do
				local xinit = flr(rnd(128))
				local yinit = flr(rnd(128))
				while (xinit <= 64+8 and xinit >= 64-8 and yinit <= 64+8 and yinit >= 64-8) do
					xinit = flr(rnd(128))
					yinit = flr(rnd(128))
				end
				add_new_asteroid(8, xinit, yinit)
			end
		end
		
		-- run update methods
		for a in all(asteroids) do
			a:update()
		end

		for b in all(bullets) do
			b:update()
		end

		for u in all(ufos) do
			u:update()
		end

		for ub in all(ufo_bullets) do
			ub:update()
		end

		if (asteroid_count == 0) reset_asteroids = true
		-- big ufo is 6
		-- small ufo is 3
		if (ufo_count == 0 and new_ufo_timer > 300) add_ufo(6, 30, 30)
	elseif overlay_state == 2 then
		-- do highscore select
	end
end

function _draw()
	if overlay_state == 0 then
		cls()
		for a in all(asteroids) do
			a:draw()
		end
		if (attract_timer < 30) then
			new_high_score = false
			spr(48, 38, 34, 4, 1) -- PUSH
			spr(54, 74, 34, 1, 1) -- X
			spr(55, 30, 44, 1, 1) -- T
			spr(36, 38, 44, 1, 1) -- O
			spr(50, 52, 44, 1, 1) -- S
			spr(55, 60, 44, 1, 1) -- T
			spr(33, 68, 44, 1, 1) -- A
			spr(39, 76, 44, 1, 1) -- R
			spr(55, 84, 44, 1, 1) -- T
		end
	draw_score()
	draw_high_score()

	elseif overlay_state == 1 then
		cls()

		-- run draw methods
		for a in all(asteroids) do
			a:draw()
		end
		for b in all(bullets) do
			b:draw()
		end
		for u in all(ufos) do
			u:draw()
		end

		for ub in all(ufo_bullets) do
			ub:draw()
		end

		if lose == 0 then
			pset(64,64,6)
			pset(63,65,6)
			pset(63,66,6)
			pset(65,65,6)
			pset(65,66,6)
		elseif lose > 0 then
			pset(64+(lose/4),64+(lose/4),7)
			pset(63-(lose/4),65,7)
			pset(63-(lose/4),66,7)
			pset(65+(lose/4),65,7)
			pset(66+(lose/4),66,7)
		end


		if (btn(2) and lose == 0) pset(64,67,6)
		draw_lives()
		if (lives == -1 and lose > 60) then
			-- game over
			spr(32, 30, 64, 4, 1)
			spr(36, 68, 64, 4, 1)
			calc_highscore()
			if new_high_score then
				spr(40, 10, 76, 1, 1) -- N
				spr(38, 18, 76, 1, 1) -- E
				spr(41, 26, 76, 1, 1) -- W
				spr(51, 38, 76, 1, 1) -- H
				spr(42, 38+8, 76, 1, 1) -- I
				spr(32, 38+16, 76, 1, 1) -- G
				spr(51, 38+24, 76, 1, 1) -- H
				spr(50, 38+24+16, 76, 1, 1) -- S
				spr(43, 38+24+16+8, 76, 1, 1) -- C
				spr(36, 38+24+16+16, 76, 1, 1) -- O
				spr(39, 38+24+16+24, 76, 1, 1) -- R
				spr(38, 38+24+16+32, 76, 1, 1) -- E
			end



			score_ones = 0
			score_tens = 0
			score_hundreds = 0
			score_thousands = 0
			score_tenthousands = 0
			score_hundredthousands = 0
			score_millions = 0
			score_tenmillions = 0
			score_hundredmillions = 0
			score_billions = 0
		end
		draw_score()
		draw_high_score()
	end
end

function draw_lives()
	for i=0,lives*4,4 do
		pset(2+i,1+6,6)
		pset(1+i,2+6,6)
		pset(1+i,3+6,6)
		pset(3+i,2+6,6)
		pset(3+i,3+6,6)
	end
end

function draw_score()
	-- spr(80, 0, 0, 1, 1) -- 0
	-- spr(81, 6, 0, 1, 1) -- 1
	-- spr(82, 12, 0, 1, 1) -- 2
	-- spr(83, 18, 0, 1, 1) -- 3
	-- spr(84, 24, 0, 1, 1) -- 4
	-- spr(85, 30, 0, 1, 1) -- 5
	-- spr(86, 36, 0, 1, 1) -- 6
	-- spr(87, 42, 0, 1, 1) -- 7
	-- spr(88, 48, 0, 1, 1) -- 8
	-- spr(89, 54, 0, 1, 1) -- 9
	if (score_billions > 0) then
		spr(score_billions+80, 0, 0, 1, 1) 
		spr(score_hundredmillions+80, 6, 0, 1, 1) 
		spr(score_tenmillions+80, 12, 0, 1, 1) 
		spr(score_millions+80, 18, 0, 1, 1) 
		spr(score_hundredthousands+80, 24, 0, 1, 1) 
		spr(score_tenthousands+80, 30, 0, 1, 1) 
		spr(score_thousands+80, 36, 0, 1, 1) 
		spr(score_hundreds+80, 42, 0, 1, 1) 
		spr(score_tens+80, 48, 0, 1, 1) 
		spr(score_ones+80, 54, 0, 1, 1) 
	elseif (score_hundredmillions > 0) then
		spr(score_hundredmillions+80, 0, 0, 1, 1) 
		spr(score_tenmillions+80, 6, 0, 1, 1) 
		spr(score_millions+80, 12, 0, 1, 1) 
		spr(score_hundredthousands+80, 18, 0, 1, 1) 
		spr(score_tenthousands+80, 24, 0, 1, 1) 
		spr(score_thousands+80, 30, 0, 1, 1) 
		spr(score_hundreds+80, 36, 0, 1, 1) 
		spr(score_tens+80, 42, 0, 1, 1) 
		spr(score_ones+80, 48, 0, 1, 1) 
		
	elseif (score_tenmillions > 0) then
		-- ten mil
		spr(score_tenmillions+80, 0, 0, 1, 1) 
		spr(score_millions+80, 6, 0, 1, 1) 
		spr(score_hundredthousands+80, 12, 0, 1, 1) 
		spr(score_tenthousands+80, 18, 0, 1, 1) 
		spr(score_thousands+80, 24, 0, 1, 1) 
		spr(score_hundreds+80, 30, 0, 1, 1) 
		spr(score_tens+80, 36, 0, 1, 1) 
		spr(score_ones+80, 42, 0, 1, 1) 
	elseif (score_millions > 0) then
		-- mil
		spr(score_millions+80, 0, 0, 1, 1) 
		spr(score_hundredthousands+80, 6, 0, 1, 1) 
		spr(score_tenthousands+80, 12, 0, 1, 1) 
		spr(score_thousands+80, 18, 0, 1, 1) 
		spr(score_hundreds+80, 24, 0, 1, 1) 
		spr(score_tens+80, 30, 0, 1, 1) 
		spr(score_ones+80, 36, 0, 1, 1) 
	elseif (score_hundredthousands > 0) then
		-- hundred thou
		spr(score_hundredthousands+80, 0, 0, 1, 1) 
		spr(score_tenthousands+80, 6, 0, 1, 1) 
		spr(score_thousands+80, 12, 0, 1, 1) 
		spr(score_hundreds+80, 18, 0, 1, 1) 
		spr(score_tens+80, 24, 0, 1, 1) 
		spr(score_ones+80, 30, 0, 1, 1) 
	elseif (score_tenthousands > 0) then
		-- ten thou
		spr(score_tenthousands+80, 0, 0, 1, 1) 
		spr(score_thousands+80, 6, 0, 1, 1) 
		spr(score_hundreds+80, 12, 0, 1, 1) 
		spr(score_tens+80, 18, 0, 1, 1) 
		spr(score_ones+80, 24, 0, 1, 1) 
	elseif (score_thousands > 0) then
		-- thousand
		spr(score_thousands+80, 0, 0, 1, 1) 
		spr(score_hundreds+80, 6, 0, 1, 1) 
		spr(score_tens+80, 12, 0, 1, 1) 
		spr(score_ones+80, 18, 0, 1, 1) 
	elseif (score_hundreds > 0) then
		-- hundred
		spr(score_hundreds+80, 0, 0, 1, 1) 
		spr(score_tens+80, 6, 0, 1, 1) 
		spr(score_ones+80, 12, 0, 1, 1) 
	elseif (score_tens > 0) then
		-- ten
		spr(score_tens+80, 0, 0, 1, 1) 
		spr(score_ones+80, 6, 0, 1, 1) 
	else
		-- one
		spr(score_tens+80, 0, 0, 1, 1) 
		spr(score_ones+80, 6, 0, 1, 1) 
	end
end
function draw_high_score()
	-- spr(80, 0, 0, 1, 1) -- 0
	-- spr(81, 6, 0, 1, 1) -- 1
	-- spr(82, 12, 0, 1, 1) -- 2
	-- spr(83, 18, 0, 1, 1) -- 3
	-- spr(84, 24, 0, 1, 1) -- 4
	-- spr(85, 30, 0, 1, 1) -- 5
	-- spr(86, 36, 0, 1, 1) -- 6
	-- spr(87, 42, 0, 1, 1) -- 7
	-- spr(88, 48, 0, 1, 1) -- 8
	-- spr(89, 54, 0, 1, 1) -- 9
	if (high_score_billions > 0) then
		spr(high_score_billions+80, 122-54, 0, 1, 1) 
		spr(high_score_hundredmillions+80, 122-48, 0, 1, 1) 
		spr(high_score_tenmillions+80, 122-42, 0, 1, 1) 
		spr(high_score_millions+80, 122-36, 0, 1, 1) 
		spr(high_score_hundredthousands+80, 122-30, 0, 1, 1) 
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_hundredmillions > 0) then
		spr(high_score_hundredmillions+80, 122-48, 0, 1, 1) 
		spr(high_score_tenmillions+80, 122-42, 0, 1, 1) 
		spr(high_score_millions+80, 122-36, 0, 1, 1) 
		spr(high_score_hundredthousands+80, 122-30, 0, 1, 1) 
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
		
	elseif (high_score_tenmillions > 0) then
		-- ten mil
		spr(high_score_tenmillions+80, 122-42, 0, 1, 1) 
		spr(high_score_millions+80, 122-36, 0, 1, 1) 
		spr(high_score_hundredthousands+80, 122-30, 0, 1, 1) 
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_millions > 0) then
		-- mil
		spr(high_score_millions+80, 122-36, 0, 1, 1) 
		spr(high_score_hundredthousands+80, 122-30, 0, 1, 1) 
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_hundredthousands > 0) then
		-- hundred thou
		spr(high_score_hundredthousands+80, 122-30, 0, 1, 1) 
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_tenthousands > 0) then
		-- ten thou
		spr(high_score_tenthousands+80, 122-24, 0, 1, 1) 
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_thousands > 0) then
		-- thousand
		spr(high_score_thousands+80, 122-18, 0, 1, 1) 
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_hundreds > 0) then
		-- hundred
		spr(high_score_hundreds+80, 122-12, 0, 1, 1) 
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	elseif (high_score_tens > 0) then
		-- ten
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	else
		-- one
		spr(high_score_tens+80, 122-6, 0, 1, 1)
		spr(high_score_ones+80, 122, 0, 1, 1) 
	end
end

function calc_score()
	if score_ones == 10 then
		score_tens += 1
		score_ones = 0
	end
	if score_tens >= 10 then
		local ten_remainder = score_tens % 10
		score_hundreds += 1
		score_tens = 0 + ten_remainder
	end
	if score_hundreds >= 10 then
		local hundred_remainder = score_hundreds % 10
		score_thousands += 1
		score_hundreds = 0 + hundred_remainder
	end
	if score_thousands == 10 then
		local thousand_remainder = score_thousands % 10
		score_tenthousands += 1
		-- every 10000 points you get an extra life
		lives+=1
		score_thousands = 0 + thousand_remainder
	end
	if score_tenthousands == 10 then
		local tenthousand_remainder = score_tenthousands % 10
		score_hundredthousands += 1
		score_tenthousands = 0 + tenthousand_remainder
	end
	if score_hundredthousands == 10 then
		local hundredthousand_remainder = score_hundredthousands % 10
		score_millions += 1
		score_hundredthousands = 0 + hundredthousand_remainder
	end
	if score_millions == 10 then
		local million_remainder = score_millions % 10
		score_tenmillions += 1
		score_millions = 0 + million_remainder
	end
	if score_tenmillions == 10 then
		local tenmillion_remainder = score_tenmillions % 10
		score_hundredmillions += 1
		score_tenmillions = 0 + tenmillion_remainder
	end
	if score_hundredmillions == 10 then
		score_billions += 1
		score_hundredmillions = 0
	end
end

function calc_highscore()
	if (comp_nhs()) then 
		newer_high_score()
		new_high_score = true
	end
end

function comp_nhs()
	if score_billions > high_score_billions then
		return true
	elseif score_billions < high_score_billions then
		return false
	end

	if score_hundredmillions > high_score_hundredmillions then
		return true
	elseif score_hundredmillions < high_score_hundredmillions then
		return false
	end

	if score_tenmillions > high_score_tenmillions then
		return true 
	elseif score_tenmillions < high_score_tenmillions then
		return false
	end

	if score_millions > high_score_millions then
		return true
	elseif score_millions < high_score_millions then
		return false
	end

	if score_hundredthousands > high_score_hundredthousands then
		return true
	elseif score_hundredthousands < high_score_hundredthousands then
		return false
	end

	if score_tenthousands > high_score_tenthousands then
		return true
	elseif score_tenthousands < high_score_tenthousands then
		return false
	end

	if score_thousands > high_score_thousands then
		return true
	elseif score_thousands < high_score_thousands then
		return false
	end

	if score_hundreds > high_score_hundreds then
		return true
	elseif score_hundreds < high_score_hundreds then
		return false
	end

	if score_tens > high_score_tens then
		return true
	elseif score_tens < high_score_tens then
		return false
	end

	if score_ones > high_score_ones then
		return true 
	elseif score_ones < high_score_ones then
		return false
	end

	return false
end

function newer_high_score()
	 high_score_billions = score_billions
	 high_score_ones = score_ones
	 high_score_tens = score_tens
	 high_score_hundreds = score_hundreds
	 high_score_thousands = score_thousands
	 high_score_tenthousands = score_tenthousands
	 high_score_hundredthousands = score_hundredthousands
	 high_score_millions = score_millions
	 high_score_tenmillions = score_tenmillions
	 high_score_hundredmillions = score_hundredmillions
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

function a1m(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=0, y=-3},
		{x=-1, y=-4},
		{x=-2, y=-4},
		{x=-3, y=-3},
		{x=-3, y=-2},
		{x=-3, y=-1},
		{x=-3, y=0},
		{x=-2, y=1},
		{x=-1, y=2},
		{x=0, y=3},
		{x=1, y=3},
		{x=2, y=2},
		{x=3, y=1},
		{x=3, y=0},
		{x=2, y=-1},
		{x=3, y=-2},
		{x=3, y=-3},
		{x=3, y=-4},
		{x=2, y=-4},
		{x=1, y=-4},
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function a2m(x,y)
	local rx = 0
	local ry = 0
	points = {
		{x=0, y=-4},
		{x=-1, y=-4},
		{x=-2, y=-4},
		{x=-3, y=-3},
		{x=-3, y=-2},
		{x=-3, y=-1},
		{x=-3, y=0},
		{x=-3, y=1},
		{x=-3, y=2},
		{x=-2, y=3},
		{x=-1, y=3},
		{x=0, y=3},
		{x=1, y=3},
		{x=2, y=2},
		{x=1, y=1},
		{x=0, y=0},
		{x=1, y=-1},
		{x=2, y=-1},
		{x=3, y=0},
		{x=4, y=-1},
		{x=3, y=-2},
		{x=2, y=-3},
		{x=1, y=-4}
	}
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end
function a3m(x,y)
	local rx = 0
	local ry = 0
	points = {
		{x=0, y=-3},
		{x=-1, y=-3},
		{x=-2, y=-4},
		{x=-3, y=-3},
		{x=-4, y=-2},
		{x=-3, y=-1},
		{x=-3, y=0},
		{x=-4, y=1},
		{x=-3, y=2},
		{x=-2, y=3},
		{x=-1, y=3},
		{x=0, y=2},
		{x=1, y=3},
		{x=2, y=3},
		{x=3, y=2},
		{x=2, y=1},
		{x=2, y=0},
		{x=3, y=-1},
		{x=3, y=-2},
		{x=2, y=-3},
		{x=1, y=-4}
	}
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end
function a4m(x,y)
	local rx = 0
	local ry = 0
	points = {
		{x=0, y=-1},
		{x=0, y=-3},
		{x=-1, y=-3},
		{x=-2, y=-3},
		{x=-3, y=-4},
		{x=-4, y=-3},
		{x=-4, y=-2},
		{x=-3, y=-1},
		{x=-3, y=0},
		{x=-4, y=1},
		{x=-4, y=2},
		{x=-3, y=3},
		{x=-2, y=2},
		{x=-1, y=2},
		{x=0, y=2},
		{x=1, y=3},
		{x=2, y=3},
		{x=3, y=2},
		{x=2, y=1},
		{x=1, y=0},
		{x=1, y=-2},
		{x=2, y=-2},
		{x=3, y=-3},
		{x=2, y=-4}
	}
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function a1s(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=0, y=1},
		{x=-1, y=0},
		{x=1, y=0},
		{x=0, y=-1},
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end
function a2s(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=0, y=-1},
		{x=0, y=-2},
		{x=-1, y=-1},
		{x=-2, y=0},
		{x=-1, y=1},
		{x=-1, y=2},
		{x=0, y=1},
		{x=1, y=0}
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end
function a3s(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=1, y=-2},
		{x=0, y=-2},
		{x=-1, y=-1},
		{x=-1, y=0},
		{x=0, y=1},
		{x=1, y=1},
		{x=2, y=0},
		{x=2, y=-1}
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end
function a4s(x,y)
	local rx = 0
	local ry = 0
	-- center in drawing is x=15 y=a9
	points = {
		{x=0, y=0},
		{x=0, y=-2},
		{x=-1, y=-2},
		{x=-2, y=-1},
		{x=-3, y=0},
		{x=-2, y=1},
		{x=-1, y=2},
		{x=0, y=1},
		{x=1, y=-1}
	}
	--print(points.p0.y, 0,18,7)
	for p in all(points) do
		rx, ry = rotate(x+p.x, y+p.y, x, y, a)
		pset(rx, ry, 6)
	end
end

function ufo_big(x,y)
  rect(x+0, y+0, x+8, y+4, 6)
end

function ufo_small(x,y)
  rect(x+0, y+0, x+4, y+2, 6)
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
66666660000600006600066066666660666666606000006066666660666666606000006060000060666666606666666000000000000000000000000000000000
60000060006060006060606060000000600000606000006060000000600000606600006060000060000600006000000000000000000000000000000000000000
60000000060006006006006060000000600000600600060060000000600000606060006066060660000600006000000000000000000000000000000000000000
60066660600000606000006066666660600000600600060066666660666666606006006006060600000600006000000000000000000000000000000000000000
60000060666666606000006060000000600000600060600060000000600060006000606006666600000600006000000000000000000000000000000000000000
60000060600000606000006060000000600000600060600060000000600006006000066000606000000600006000000000000000000000000000000000000000
66666660600000606000006066666660666666600006000066666660600000606000006000606000666666606666666000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660600000606666666060000060600000006000006060000060666666600000000000000000000000000000000000000000000000000000000000000000
60000060600000606000000060000060600000000600060006000600000600000000000000000000000000000000000000000000000000000000000000000000
60000060600000606000000060000060600000000060600000606000000600000000000000000000000000000000000000000000000000000000000000000000
66666660600000606666666066666660600000000006000000060000000600000000000000000000000000000000000000000000000000000000000000000000
60000000600000600000006060000060600000000006000000606000000600000000000000000000000000000000000000000000000000000000000000000000
60000000600000600000006060000060600000000006000006000600000600000000000000000000000000000000000000000000000000000000000000000000
60000000666666606666666060000060666666000006000060000060000600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66660000600000006666000066660000600600006666000060000000666600006666000066660000000000000000000000000000000000000000000000000000
60060000600000000006000000060000600600006000000060000000000600006006000060060000000000000000000000000000000000000000000000000000
60060000600000006666000066660000666600006666000066660000000600006666000066660000000000000000000000000000000000000000000000000000
60060000600000006000000000060000000600000006000060060000000600006006000000060000000000000000000000000000000000000000000000000000
66660000600000006666000066660000000600006666000066660000000600006666000000060000000000000000000000000000000000000000000000000000
