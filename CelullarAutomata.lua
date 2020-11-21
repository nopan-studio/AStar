local this = {} 

function this:clampPoint(point, min, max)
    return point < min and min or (point > max and max or point)
end

function this:AliveNeighbors( map, x, y, width, height)
        local count = 0
        local pos= {
            { x=-1, y=0}, --left
            { x=1, y=0}, -- right
            { x=0, y=1}, -- down
            { x=0, y=-1}, -- tops
            { x=-1, y=-1}, --topleft
            { x=1, y=-1}, -- topright
            { x=-1, y=1}, -- botleft
            { x=1, y=1}, -- botright
        }

        for _, p in ipairs(pos) do
            local pX = this:clampPoint(x + p.x, 1, width)
            local pY = this:clampPoint(y + p.y, 1, height)
            if map[pX][pY] then
                count = count + 1
            end
        end

        return count
end

function this:Step( OldMap, width, height, born, death)
    local newMap = {}
        
    for x = 1, height do
        newMap[x] = {}
        for y = 1, width do
            local nbs = this:AliveNeighbors(OldMap, x, y, width, height)

            if y == 1 and x <= width or y == height and x <= width or y <= height and x == 1 or y <= height and x == width then
                newMap[x][y] = true
            elseif OldMap[x][y] then
                if nbs < death then
                    newMap[x][y] = false
                else
                    newMap[x][y] = true
                end
            else
                if nbs > born then
                    newMap[x][y] = true
                else
                    newMap[x][y] = false
                end 
            end
        end
    end
    return newMap
end

function this:GenerateMap( width, height)
    local map = {}
    local chancetoStartAlive = .3
    local step = 10
    local death = 3
    local born = 3
    local discovered = {}

    for x=1, width do 
        map[x] = {}
        for y=1, height do 
            if (math.random() < chancetoStartAlive) then
                map[x][y] = true
            end
        end
    end
   
    for i = 1 ,step  do
        map = this:Step( map, width, height, born, death)
    end

    for x=1, width do 
        for y=1, height do 
            map[x][y] = not map[x][y]
        end
    end

    for x=1, width do 
        for y=1, height do 
            if not map[x][y] then
                discovered = this:BFS(map, {x=x,y=y}, goal, width, height)
            end
        end
    end
    return map
end

function this:DrawMap(map,asset,width,height,gridSize)
    local canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(canvas)
    for x=1, width do 
        for y=1, height do 

            local xx = this:clampPoint(x, 1, height)
            local yy = this:clampPoint(y + 1, 1, height)

            if not map[x][y] and  map[xx][yy] then
                love.graphics.draw(asset.wall,(x-1) * gridSize,(y-1) *gridSize)
            elseif not map[x][y] then
                love.graphics.draw(asset.top,(x-1) * gridSize,(y-1) *gridSize)
            else
                love.graphics.setColor(0.5,0.4,0.5)
                
                love.graphics.draw(asset.top,(x-1) * gridSize,(y-1) *gridSize)
               
                love.graphics.setColor(1,1,1)
            end
        end
    end
    love.graphics.setCanvas()
    return canvas
end

function this:getAdjacent(map,node,width,height)
    local list = {}
    local pos= {
        -- 4 directional
        { x=-1, y=0}, --left
        { x=1, y=0}, -- right
        { x=0, y=1}, -- down
        { x=0, y=-1}, -- tops

        --diagonals
        { x=-1, y=-1}, --topleft
        { x=1, y=-1}, -- topright
        { x=-1, y=1}, -- botleft
        { x=1, y=1}, -- botright
        --]]
    }
    for _, n in ipairs(pos) do
        local px = this:clampPoint(node.x + n.x,1,width)
        local py = this:clampPoint(node.y + n.y,1,height)
        if map[px][py] then
            table.insert(list,{x=px,y=py})
        end
    end

    return list
end

function this:checkList(list,n) 
    for _, node in ipairs(list) do
        if node.x == n.x and node.y == n.y then
            return true
        end
    end
    return false
end

function this:BFS(map, start, goal, width, height) 
    local open = {}
    local closed = {}
    local count = 0
    local discovered = {}
    table.insert(open,start)
    while #open > 0 do
        count = count + 1
        local current = table.remove(open)
        table.insert(closed,current)

        local neighbors = this:getAdjacent(map,current,width,height)
        for ii, n in pairs(neighbors) do
            if not this:checkList(closed,n) then
                if not this:checkList(open,n) then
                    table.insert(open,n)
                end 
            end
        end
    end

    if count < 100 then
        for ii, n in ipairs(closed) do
            map[n.x][n.y] = false
        end
    else
        return closed
    end
end

return this