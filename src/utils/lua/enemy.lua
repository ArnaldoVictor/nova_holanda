local function table_clone_internal(t, copies)
    if type(t) ~= "table" then return t end
    
    copies = copies or {}
    if copies[t] then return copies[t] end
  
    local copy = {}
    copies[t] = copy
  
    for k, v in pairs(t) do
      copy[table_clone_internal(k, copies)] = table_clone_internal(v, copies)
    end
  
    setmetatable(copy, table_clone_internal(getmetatable(t), copies))
  
    return copy
  end
  
local function table_clone(t)
    return table_clone_internal(t)
end
  
local function table_merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")
  
    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end
  
    local result = table_clone(tables_to_merge[1])
  
    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(v) == "table" then
                result[k] = result[k] or {}
                assert(type(result[k]) == "table", string.format("Expected a table: '%s'", k))
                result[k] = table_merge(result[k], v)
            elseif type(k) == "string" then
                result[k] = v
            else
                table.insert(result, v)
            end
        end
    end

    return result

end

friendList = {}

function callback(data, err)
    if err then
        error(err)
        return
    end

    friendList = table_merge(data.novaHolanda, data.sideBySide, data.makers)

    warn(#friendList)

end

HTTP.getJSON('https://raw.githubusercontent.com/ArnaldoVictor/nova_holanda/master/src/data/friends.json', callback)

enemyList = {'*', 'piriguete'}

for index, value in ipairs(enemyList) do
    enemyList[value:lower():trim()] = true
    enemyList[index] = nil
end


for index, value in ipairs(friendList) do
    friendList[value:lower():trim()] = true
    friendList[index] = nil
end


macro(100, 'Enemy', function()
    local pos = pos()
    local actualTarget
    for _, creature in ipairs(getSpectators(pos)) do
        local specHp = creature:getHealthPercent()
        local specPos = creature:getPosition()
        local specName = creature:getName():lower()
        if creature:isPlayer() and specHp and specHp > 0 then
            if (not friendList[specName] and creature:getEmblem() ~= 1 and creature:getShield() < 3 and creature ~= player) or enemyList[specName] then
                if creature:canShoot() then
                    if not actualTarget or actualTargetHp > specHp or (actualTargetHp == specHp and getDistanceBetween(pos, actualTargetPos) > getDistanceBetween(specPos, pos)) then
                        actualTarget, actualTargetPos, actualTargetHp = creature, specPos, specHp
                    end
                end
            end
        end
    end
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        modules.game_interface.processMouseAction(nil, 2, pos, nil, actualTarget, actualTarget)
    end
end)
