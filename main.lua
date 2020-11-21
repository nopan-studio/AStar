    cm = require "CelullarAutomata"
    find = require "find"
    
    math.randomseed(os.time() + math.pi)

    function love.load()
        asset = {
            wall = love.graphics.newImage("testBlock.png"),
            top = love.graphics.newImage("testBlocktop.png"),
            floor = love.graphics.newImage("testBlockfloor.png")
        }
        width = 40
        height = 40
        grid_size = 16
        love.window.setMode(width*grid_size,height*grid_size,{display = 1 })
        --
        map = cm:GenerateMap(width,height)
        find.map = map 
        
        start = {x=1,y=5}
        goal = {x=5,y=1,found = false}

        player = {
            step = 1,
            speed = 200 ,
            size = grid_size / 2,
            x= find:convertPointToReal(start.x-1,grid_size) ,
            y= find:convertPointToReal(start.y-1,grid_size) ,
            ly= 0,
            lx= 0,
            tx= 0,
            ty= 0,
            vx= 0,
            vy= 0,
            dist= 0,
        }

        line = love.graphics.newCanvas()
        map_image = cm:DrawMap(map,asset,width,height,grid_size)
    end

    function love.update(dt)
        if path then
            follow = find:followPath(path,player,grid_size)
        end
    end

    function love.draw()
        for x = 1, height do
            for y = 1, width do
                if not map[x][y] then
                    love.graphics.rectangle("fill",(x-1) * grid_size, (y-1) * grid_size,grid_size,grid_size)
                end
            end 
        end
        love.graphics.draw(map_image)

        if start then
            love.graphics.setColor(1,1,0)
            love.graphics.rectangle("fill",find:convertPointToReal(start.x-1,grid_size) ,find:convertPointToReal(start.y-1,grid_size),grid_size,grid_size)
        end

        if goal then
            love.graphics.setColor(0,1,0)
            love.graphics.rectangle("fill",find:convertPointToReal(goal.x-1,grid_size) ,find:convertPointToReal(goal.y-1,grid_size),grid_size,grid_size)
            love.graphics.setColor(1,1,1)
        end

        love.graphics.setColor(0,1,1)
        love.graphics.setCanvas(line)
        love.graphics.rectangle("fill",(math.floor((player.x /grid_size))) * grid_size,(math.floor((player.y /grid_size))) * grid_size  ,grid_size,grid_size)
        love.graphics.setCanvas()
        love.graphics.draw(line)
        love.graphics.setColor(1,1,1)

        love.graphics.print("player.x:"..math.floor((player.x)/grid_size + 1), 10,10)
        love.graphics.print("player.y:"..math.floor((player.y)/grid_size + 1), 10,25)
    end

    function love.mousepressed(x,y, button)
        local mx = math.floor(x / grid_size)  + 1
        local my = math.floor(y / grid_size)  + 1

        if button == 1 then
            start = {x=mx,y=my}
        end

        if button == 2 then
           
            line = love.graphics.newCanvas()
            player.x = find:convertPointToReal(start.x-1,grid_size)
            player.y = find:convertPointToReal(start.y-1,grid_size)
            goal.x = mx 
            goal.y = my
            goal.found = false
            player.step = 1
            path = find:findPath(start,goal,width,height)
           
        end
        
    end

    function love.keypressed(key)
        if key == "space" then
            map = cm:GenerateMap(width,height)
            map_image = cm:DrawMap(map,asset,width,height,grid_size)
            find.map = map 
            line = love.graphics.newCanvas()
    
        end
    end