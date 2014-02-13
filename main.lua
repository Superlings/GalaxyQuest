gamestate = "title"

--resolution of app can be changed in conf.lua but be sure to change it here as well
resolutionX = 1024
resolutionY = 768


function love.keypressed(key)
	--psuedo pause
	if key == "escape" then
		gamestate = "title"
	--cooldown time for shooting
	elseif key == " " then
		if shootcount < 0 then
			shootcount = 1
			shoot()
		end
	end
end

function love.load()
	--loading images
	spaceship = love.graphics.newImage("spaceship.png")
	kirby = love.graphics.newImage("kirby.gif")
	background = love.graphics.newImage("background.jpg")
	
	--hero info
	hero = {}
	hero.x = resolutionX/2 - 16
	hero.y = resolutionY-32
	hero.width = 32
	hero.height = 32
	hero.speed = 200
	
	--table with shots fired
	hero.shots = {}
	
	--table of enemies
	enemies = {}
	for i = 1,6 do
		for ii = 1,4 do
			enemy = {}
			enemy.width = 32
			enemy.height = 32
			enemy.x = resolutionX*0.1347 + (resolutionX/9)*i - (resolutionX/24)
			enemy.y = enemy.height + ii*resolutionY/16
			table.insert(enemies, enemy)
		end
	end
	
	--timer for enemy x movement
	countX = 0
	updateDelayX = 3
	
	--timer for enemy y movement
	countY = 0
	countDelayY = 1
	
	--timer for shooting
	shootcount = 0
end

--dt stands for delta time google for further explanation if unclear
function love.update(dt)
	--title implementation
	if gamestate == "title" then
		if love.keyboard.isDown("return", "enter") then
			gamestate = "play"
		end
	--game implementation
	else
		--updates timer
		countX = countX + dt
		countY = countY + dt
		shootcount = shootcount - dt
		
		--movement of hero
		if love.keyboard.isDown("left") then
			if hero.x < 1 then
			else
				hero.x = hero.x - hero.speed*dt
			end
		elseif love.keyboard.isDown("right") then
			if hero.x > resolutionX-31 then
			else
				hero.x = hero.x + hero.speed*dt
			end
		end

		--movement of enemies horizontally
		if countX < updateDelayX then
			for i,v in ipairs(enemies) do
				v.x = v.x + 1
			end
		elseif countX > updateDelayX then
			for i,v in ipairs(enemies) do
				v.x = v.x - 1
			end
		end
	
		--resets the timer for enemy x movement
		if countX > updateDelayX*3 then
			countX = updateDelayX*-1
		end
		
		--movement of enemies vertically
		if countY > countDelayY then
			for i,v in ipairs(enemies) do
				v.y = v.y + 2
			end
			countY = 0;
		end
		
		--new tables for enemies/shots to be removed
		local remEnemy = {}
		local remShot = {}
		
		for i,v in ipairs(hero.shots) do
			--shots movement
			v.y = v.y - dt * 100
			--shots going off-screen
			if v.y < 0 then
				table.insert(remShot, i)
			end
			--check collision and adding collided enemy and shots to table
			for ii,vv in ipairs(enemies) do
				if CheckCollision(v.x, v.y, 2, 5, vv.x, vv.y, vv.width, vv.height) then
					table.insert(remEnemy, ii)
					table.insert(remShot, i)
				end
			end
		end
		
		--removes enemies from original table
		for i,v in ipairs(remEnemy) do
			table.remove(enemies, v)
		end
		
		--removes shots from table
		for i,v  in ipairs(remShot) do
			table.remove(hero.shots, v)
		end
	end
end

function love.draw()
	--draw title screen
	if gamestate == "title" then
		love.graphics.setNewFont(50)
		love.graphics.print("Press enter to play", 270, 350)
	--draw game screen
	else
		love.graphics.draw(background)
	
		for i,v in ipairs(enemies) do
			love.graphics.draw(spaceship, v.x, v.y)
		end

		love.graphics.draw(kirby, hero.x, hero.y)
	
		love.graphics.setColor(255,255,255,255)
		for i,v in ipairs(hero.shots) do
			love.graphics.rectangle("fill", v.x, v.y, 2, 5)
		end
	end
end

function shoot()
	local shot = {}
	shot.x = hero.x + 10
	shot.y = hero.y
	table.insert(hero.shots, shot)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end