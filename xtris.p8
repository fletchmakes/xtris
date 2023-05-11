pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- xtris - a game by fletch
-- globals

level1 = {
    rows = 2,
    cols = 3,
    start = 1,
    tiles = {
        true,  true, true,
        false, true, false,
    }
}

level2 = {
    rows = 3,
    cols = 3,
    start = 5,
    tiles = {
        false, true, false,
        true,  true, true,
        false, true, false,
    }
}

level3 = {
    rows = 3,
    cols = 3,
    start = 5,
    tiles = {
        true, true, true,
        true, true, true,
        true, true, true,
    }
}

current_level = {}
tiles = {}

points = 0
goal_idx = nil
player_idx = nil
fade_idx = nil
fade_table = {}
elapsed_time = 0
game_over = false

-->8
-- lifecycle functions
function _init()
    -- set to 64x64 mode
    poke(0x5f2c,3)

    -- populate the fade table
    for i=0,64 do
        add(fade_table, 0)
    end

    -- load the level
    load_level(level1)
end

function _update()
    -- iterate over each pixel in the fade_idx tile - if we see a green pixel, roll a dice to see if we should set it to black
    for i=0,64 do
        local top_x, top_y = tiles[fade_idx].x, tiles[fade_idx].y
        local pixel_color = fade_table[i+1]
        -- we roll a d100 - if the dice is greater than 70, then we set that pixel to black
        if (pixel_color == 3 and rnd() > 0.7) then
            fade_table[i+1] = 0
        end
    end

    -- determine the game end condition
    elapsed_time = t()
    if (elapsed_time > 63) then
        game_over = true
        return
    end

    -- if we haven't hit game end condition yet, we fall here
    if (btnp(0) and check_left()) then -- left was pressed
        player_idx -= 1
    elseif (btnp(1) and check_right()) then -- right was pressed
        player_idx += 1
    elseif (btnp(2) and check_up()) then -- up was pressed
        player_idx -= current_level.cols
    elseif (btnp(3) and check_down()) then -- down was pressed
        player_idx += current_level.cols
    end

    -- check to see if we've hit the goal
    if (player_idx == goal_idx) then
        points += 1
        while (goal_idx == player_idx or tiles[goal_idx] == "EMPTY") do 
            goal_idx = rnd(#tiles)\1 + 1
        end

        fade_tile(player_idx)
    end
end

function _draw()
    cls(0)

    -- draw the fade array to the fade tile
    for i=0,64 do
        local top_x, top_y = tiles[fade_idx].x, tiles[fade_idx].y
        local pixel_color = fade_table[i+1]
        pset(top_x + i\8, top_y + i%8, pixel_color)
    end

    -- print out the player's points
    print(pad_score(points), 0, 0, 7)

    -- show the timer
    line(0, 63, elapsed_time, 63)

    -- draw the tiles
    for idx,tile in ipairs(tiles) do
        if (tile ~= "EMPTY") then
            local                           color = 5 -- dark grey
            if (game_over) then             color = 8 -- red
            elseif (idx == goal_idx) then   color = 3 -- dark green
            elseif (idx == player_idx) then color = 7 -- white
            end

            -- print the rectangle
            rect(tile.x, tile.y, tile.x+8, tile.y+8, color)

            -- print the X if we're in a goal slot
            if (idx == goal_idx) then
                print("x", tile.x+3, tile.y+2, color)
            end
        end
    end
end

-->8
-- helper functions
function pad_score(score)
    if (score < 10) then
        return "00"..score
    elseif (score < 100) then
        return "0"..score
    else
        return score
    end
end

function fade_tile(tile_idx)
    fade_idx = tile_idx
    for i=0,64 do
        fade_table[i+1] = 3 -- set the whole fade table to dark green
    end
end

function load_level(level)
    -- set player position
    player_idx = level.start

    current_level.rows = level.rows
    current_level.cols = level.cols

    local top_left_x = 32 - ((level.cols * 10) / 2)
    local top_left_y = 32 - ((level.rows * 10) / 2)

    for idx,tile in ipairs(level.tiles) do
        if (tile) then
            add(tiles, {
                x=top_left_x + ((idx-1)%level.cols * 10),
                y=top_left_y + ((idx-1)\level.cols * 10)
            })
        else
            add(tiles, "EMPTY")
        end
    end

    -- set goal position
    while (goal_idx == nil or goal_idx == player_idx or tiles[goal_idx] == "EMPTY") do 
        goal_idx = rnd(#tiles)\1 + 1
    end

    fade_idx = goal_idx
end

function check_left()
    return (player_idx % current_level.cols ~= 1) and (tiles[player_idx - 1] ~= "EMPTY")
end

function check_right()
    return (player_idx % current_level.cols ~= 0) and (tiles[player_idx + 1] ~= "EMPTY")
end

function check_up()
    return (player_idx - current_level.cols > 0) and (tiles[player_idx - current_level.cols] ~= "EMPTY")
end

function check_down()
    return (player_idx + current_level.cols <= #tiles) and (tiles[player_idx + current_level.cols] ~= "EMPTY")
end

__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000077777777777777777700555555555555555555005555555555555555550000000000000000000000000000000000
00000000000000000000000000000000000077777777777777777700555555555555555555005555555555555555550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077000000000000007700550000000000000055005500000000000000550000000000000000000000000000000000
00000000000000000000000000000000000077777777777777777700555555555555555555005555555555555555550000000000000000000000000000000000
00000000000000000000000000000000000077777777777777777700555555555555555555005555555555555555550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000333333333333333333000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000333333333333333333000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000000000000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000000000000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000003300000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000003300000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000330033000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000000000000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000330000000000000033000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000333333333333333333000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000333333333333333333000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

