gamestate = "title"

--resolution of app can be changed in conf.lua but be sure to change it here as well
resolutionX = 1024
resolutionY = 768


function love.keypressed(key)
	--psuedo pause
	if key == "escape" then
		gamestate = "title"
		click()
	--cooldown time for shooting
	elseif key == " " then
		if shootcount >= 0.25 then
			shootcount = 0
			shoot()
		end
	end
end

function love.load()
	--load sprites
	spaceship = love.graphics.newImage("res/sprites/spaceship.png")
	kirby = love.graphics.newImage("res/sprites/kirby.gif")
	background = love.graphics.newImage("res/sprites/background.jpg")
	explosion = love.graphics.newImage("res/sprites/explosion.gif")
  ex1 = love.graphics.newImage("res/sprites/ex1.png")
  ex2 = love.graphics.newImage("res/sprites/ex2.png")
  ex3 = love.graphics.newImage("res/sprites/ex3.png")
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
			--state 1 means the enemy is alive
			--state >= 2 means the enemy is dying
			--state == 18 means the enemy is dead
			enemy.state = 1
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

	--load epic background theme
	music = love.audio.newSource("res/music/hypertechnoremix.mp3")

	--initiate epic background theme
	music:play()
end

--dt stands for delta time google for further explanation if unclear
function love.update(dt)
	--title implementation
	if gamestate == "title" then
		if love.keyboard.isDown("return", "enter") then
			gamestate = "play"
			shots = 0
			kills = 0
			click()
		end
	--game implementation
	else
		--updates timer
		countX = countX + dt
		countY = countY + dt
		shootcount = shootcount + dt

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
			v.y = v.y - dt * 250
			--shots going off-screen
			if v.y < 0 then
				table.insert(remShot, i)
			end
			--check collision and adding collided enemy and shots to table
			--setting enemy state to 2 starts the death animation
			for ii,vv in ipairs(enemies) do
				if CheckCollision(v.x, v.y, 2, 5, vv.x, vv.y, vv.width, vv.height) then
				vv.state = 2
					table.insert(remEnemy, ii)
					table.insert(remShot, i)
				end
			end
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
		love.graphics.setNewFont(48)
		love.graphics.print("Press enter to play", 270, 350)
	--draw game screen
	else
		love.graphics.draw(background)
		
		--Draw enemies
		for i,v in ipairs(enemies) do
  		if v.state == 1 then
  			love.graphics.draw(spaceship, v.x, v.y)
  			
  			--if state == 2 then start death animation
  			--changes the enemy's image every few frames to an explosion
  			--after 18 frames the enemy is removd.
  		elseif v.state == 2 then
  		  local boomChickaBoom = love.audio.newSource("res/sound/explosion.wav", "static")
      boomChickaBoom:play()
      kills = kills + 1
  		  v.state = v.state + 1
  			love.graphics.draw(ex1, v.x, v.y)
  			elseif v.state < 5 then
        v.state = v.state + 1
  			love.graphics.draw(ex1, v.x, v.y)
  			elseif v.state < 9 then
        v.state = v.state + 1
        love.graphics.draw(ex2, v.x, v.y)
        elseif v.state < 14 then
        v.state = v.state + 1
        love.graphics.draw(ex3, v.x, v.y)
        elseif v.state < 17 then 
       table.remove(enemies, i)
  			end
		end

		love.graphics.draw(kirby, hero.x, hero.y)

		love.graphics.setColor(255,255,255,255)
		for i,v in ipairs(hero.shots) do
			love.graphics.rectangle("fill", v.x, v.y, 2, 5)
		end

		love.graphics.setNewFont(24)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(string.format("Shots: %d", shots), 0, 0)
		love.graphics.print(string.format("Kills: %d", kills), 0, 24)
	end
end

function shoot()
	local shot = {}
	shot.x = hero.x + 10
	shot.y = hero.y
	table.insert(hero.shots, shot)

	shots = shots + 1

	local pew = love.audio.newSource("res/sound/pewpew.wav", "static")
	pew:play()
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function click()
	local click = love.audio.newSource("res/sound/button.wav", "static")
	click:play()
end
