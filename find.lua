local this = {}
this.map = nil

function this:getDistance(node1,node2)
    local dx = node1.x - node2.x
    local dy = node1.y - node2.y
    local dist = math.sqrt((dx)^2 + (dy)^2)
    return dist
end

function this:isOpen(x,y)
    return this.map[x][y] 
end

function this:getScore(current,node,goal)
    local G_COST = current.score + 1
    local H_COST = this:getDistance(node,goal)
    return G_COST + H_COST, G_COST, H_COST
end

function this:checkList(list,n) 
    for _, node in ipairs(list) do
        if node.x == n.x and node.y == n.y then
            return true
        end
    end
    return false
end

function this:checkItem(list,n)
    for _, node in ipairs(list) do
        if node.x == n.x and node.y == n.y then
            return node
        end
    end
end

function this:clampPoint(point, min, max)
    return point < min and min or (point > max and max or point)
end

function this:convertPointToReal(point, mapGrid, gap)
    local p = point * mapGrid
    if gap then
        p  = p + gap
    end
    return math.floor(p)
end

function this:convertPointToMap(point, mapGrid)
    return math.floor(point / mapGrid)
end

function this:convertPathToReal(path,mapGrid,gap)
    local p = assert(path,"path is empty")
    local g = gap or 0
        for _=1, #path do
            p[_].x = this:convertPointToReal(p[_].x ,mapGrid,g)
            p[_].y = this:convertPointToReal(p[_].y ,mapGrid,g)
        end
    return p
end 

function this:getNext(node,width,height)
    assert(node,"node is empty")
    assert(width,"width is empty")
    assert(width,"height is empty")
    --##
    local list = {}
    local pos= {
        -- 4 directional
        { x=-1, y=0}, --left
        { x=1, y=0}, -- right
        { x=0, y=1}, -- down
        { x=0, y=-1}, -- tops

        --[[diagonals
        { x=-1, y=-1}, --topleft
        { x=1, y=-1}, -- topright
        { x=-1, y=1}, -- botleft
        { x=1, y=1}, -- botright
        --]]
    }
    for _, n in ipairs(pos) do
        local px = this:clampPoint(node.x + n.x,1,width)
        local py = this:clampPoint(node.y + n.y,1,height)
        local check = this:isOpen(px,py)
        if check then
            table.insert(list,{x=px,y=py})
        end
    end

    return list
end

function this:findPath(start,goal,width,height)

    local pathFound = false
    local open = {}
    local closed = {}

    start.score = 0 
    start.gscore = 0 
    start.hscore = this:getDistance(start,goal)
    start.parent = {x=0,y=0}

    table.insert(open,start)

    while not pathFound and #open > 0 do
        table.sort(open,function(a,b) return a.score > b.score end)
        local current = table.remove(open)
        table.insert(closed,current)

        pathFound = this:checkList(closed,goal)

        if not pathFound then
            
            local neighbors = this:getNext(current,width,height)

            for _, n in ipairs(neighbors) do
                if not this:checkList(closed, n) then
                    if not this:checkList(open, n) then
                        n.score = this:getScore(current,n,goal)
                        n.parent = current
                        table.insert(open,n)
                    end
                end
            end
        end
    end

    if not pathFound then
        --print("CANNNOT FIND PATH")
        return false
    else
        --print("PATH FOUND")
    end

    local node = this:checkItem(closed,closed[#closed])
    local path = {}

    while node do
        table.insert(path,1,{x=node.x,y=node.y,score=node.score,timer=3})
        node = this:checkItem(closed,node.parent)
    end 

    return path
end

function this:followPath( path, object, mapGrid, mapSize, gap)
    local path = path
    if object.step <= #path then
        if object.vx == 0 and player.vy == 0 and player.step < #path then
            --
            if object.step == 1 then
                print("NODE ["..object.step.."] X:"..math.floor(object.tx/mapGrid)+1 .."\t Y:"..math.floor(object.ty/mapGrid)+1)
            end
            --
            object.step = object.step + 1
            object.tx = this:convertPointToReal( path[object.step].x -1, mapGrid ,gap)
            object.ty = this:convertPointToReal( path[object.step].y -1, mapGrid ,gap)
            --
            object.lx = object.x
            object.ly = object.y
            --
            object.dist = (object.tx - object.x)^2 + (object.ty - object.y)^2
            --
            if object.dist == 0 then
                object.vx = 0
                object.vy = 0
            else
                local dist = math.sqrt(object.dist)
                object.vx = (object.x - object.tx) / dist * object.speed
                object.vy = (object.y - object.ty) / dist * object.speed
                print("NODE ["..object.step.."] X:"..math.floor(object.tx/mapGrid)+1 .."\t Y:"..math.floor(object.ty/mapGrid)+1)
            end
        end
        --
        object.x = object.x - object.vx * love.timer.getDelta()
        object.y = object.y - object.vy * love.timer.getDelta()
        
        local dist = (object.lx - object.x) ^ 2 + (object.ly - object.y)^2

        if dist >= object.dist then
            object.vx = 0
            object.vy = 0
            object.x = object.tx
            object.y = object.ty
        end

        if this:convertPointToMap(object.x,mapGrid) == path[#path].x -1 and 
            this:convertPointToMap(object.y,mapGrid) == path[#path].y -1 and 
                goal.found == false then
                print("GOAL REACHED")
                print("PATH LENGTH :"..#path)
                goal.found = not goal.found
                return true
        end
    end
end

return this 