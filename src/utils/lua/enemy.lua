function table_merge(...)
    local tables_to_merge = { ... }
    assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

    for k, t in ipairs(tables_to_merge) do
        assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
    end

    local result = tables_to_merge[1]

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]
        for k, v in pairs(from) do
            if type(k) == "number" then
                table.insert(result, v)
            elseif type(k) == "string" then
                if type(v) == "table" then
                    result[k] = result[k] or {}
                    result[k] = table_merge(result[k], v)
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

friendList = {}
enemyMacro = nil

function callback(data, err)
    if err then
        return
    end

    cpList = table_merge(data.novaHolanda, data.sideBySide, data.makers)

    for index, value in ipairs(cpList) do
        friendList[value:lower()] = true
    end

    enemyList = {'*', 'piriguete'}

    for index, value in ipairs(enemyList) do
        enemyList[value:lower():trim()] = true
        enemyList[index] = nil
    end

    enemyMacro = macro(100, 'Enemy', function()
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
    
    enemyIcon = addIcon("Enemy", {item =3292, text = "Enemy"}, enemyMacro )
    enemyIcon:breakAnchors()
    enemyIcon:move(80, 40)


end

HTTP.getJSON("https://raw.githubusercontent.com/ArnaldoVictor/nova_holanda/master/src/data/friends.json", callback)

