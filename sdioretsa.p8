pico-8 cartridge // http://www.pico-8.com
version 38
__lua__


overlay_state = 0

function _init()
	asteroids={}
	max_asteroid_count = 2 -- initial value
	asteroid_count = 0

	-- there's only one ship so it's ok if global
	a = 0 -- the ship's angle
	thrust = 0 -- the ship's thrust
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

function add_new_asteroid()
	asteroid_count+=1
	add(asteroids, {
		ox=flr(rnd(128)), -- original asteroid position
		oy=flr(rnd(128)),
		rx=0, -- rotated asteroid position
		ry=0,
		xv = 0,
		yv = 0,
		tx = 0, -- rotated thrust x component
		ty = 0, -- rotated thrust y component


		update=function(self)
			-- the thrust happens in the y direction but
			-- after rotation could have an x component
			-- it effects everything else on screen
			self.tx = sin(a) * thrust
			self.ty = cos(a) * thrust
			self.ox+=.1 + self.tx
			self.oy+= .1 + self.ty

			-- the asteroid playing field is connected at the ends
			if (self.ox > 128) self.ox = 0
			if (self.ox < 0) self.ox = 128
			if (self.oy > 128) self.oy = 0
			if (self.oy < 0) self.oy = 128

			self.rx,self.ry=rotate(self.ox,self.oy,64,64,a)

		end,

		draw=function(self)
			pset(self.rx,self.ry,7)
		
		end
	})

end


function _update60()

	if (btn(1)) then
		a += 0.003
	end
	if (btn(0)) then
		a -= 0.003
	end

	if (btn(2)) then
		thrust += .09
	else
		thrust -= .09
	end
	if (thrust < 0) thrust = 0

	if (a>1) a = 0
	if (a<0) a = 1
	if (asteroid_count < max_asteroid_count) add_new_asteroid()
	for a in all(asteroids) do
		a:update()
	end
end

function _draw()
	cls()
	for a in all(asteroids) do
		a:draw()
	end
	line(64,64,62,69,7)
	line(64,64,66,69,7)
	print('a:'..a, 0,0,7)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
