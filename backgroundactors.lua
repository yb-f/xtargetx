local mq = require 'mq'
local actors = require 'actors'




local actor = actors.register(function(message)

end)




local function casting(line, arg1)
    local ID
    if mq.TLO.Me.Class.ShortName() == 'SHM' then
        if string.find(arg1, "Turgur's Virulent Swarm") then
            local xtargs = mq.TLO.Me.XTarget()
            if mq.TLO.Me.XTarget() > 0 then
                for i = 1, 20 do
                    if mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                        if mq.TLO.Me.XTarget(i).Distance() <= mq.TLO.Spell("Turgur's Virulent Swarm").AERange() then
                            ID = mq.TLO.Me.XTarget(i).ID()
                            actor:send({ script = 'xtargetx' },
                                {
                                    script = 'xtargetx',
                                    id = 'slowed',
                                    targetID = ID,
                                    result = 'CAST_SUCCESS',
                                    slowPct =
                                        mq.TLO.Spell("Turgur's Virulent Swarm").SlowPct()
                                })
                        end
                    end
                end
            end
        else
            ID = mq.TLO.Target.ID()
            local slowPct = mq.TLO.Me.Casting.SlowPct()
            if slowPct ~= 0 and slowPct ~= nil then
                while mq.TLO.Me.Casting() ~= nil do
                    mq.delay(1)
                end
                local result = mq.TLO.Cast.Result()
                actor:send({ script = 'xtargetx' },
                    { script = 'xtargetx', id = 'slowed', targetID = ID, result = result, slowPct = slowPct })
            end
        end
    elseif mq.TLO.Me.Class.ShortName() == 'BRD' then
        if string.find(arg1, "Dirge of the Sleepwalker") then
            while mq.TLO.Me.Casting() ~= nil do
                mq.delay(1)
            end
            local result = mq.TLO.Cast.Result()
            actor:send({ script = 'xtargetx' }, { script = 'xtargetx', id = 'mezzed', targetID = ID, result = result })
        elseif mq.TLO.Me.Casting.Subcategory() == 'Enthrall' then
            if mq.TLO.Me.Casting.AERange() > 0 then
                if mq.TLO.Me.XTarget() > 0 then
                    for i = 1, 20 do
                        if mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                            if mq.TLO.Me.XTarget(i).Distance() <= mq.TLO.Me.Casting.AERange() then
                                ID = mq.TLO.Me.XTarget(i).ID()
                                actor:send({ script = 'xtargetx' },
                                    { script = 'xtargetx', id = 'mezzed', targetID = ID, result = 'CAST_SUCCESS' })
                            end
                        end
                    end
                end
                return
            end
            ID = mq.TLO.Target.ID()
            while mq.TLO.Me.Casting() ~= nil do
                mq.delay(1)
            end
            local result = mq.TLO.Cast.Result()
            actor:send({ script = 'xtargetx' }, { script = 'xtargetx', id = 'mezzed', targetID = ID, result = result })
        elseif mq.TLO.Me.Casting.Subcategory() == 'Slow' then
            ID = mq.TLO.Target.ID()
            local slowPct = mq.TLO.Me.Casting.SlowPct()
            if slowPct ~= 0 and slowPct ~= nil then
                while mq.TLO.Me.Casting() ~= nil do
                    mq.delay(1)
                end
                local result = mq.TLO.Cast.Result()
                actor:send({ script = 'xtargetx' },
                    { script = 'xtargetx', id = 'slowed', targetID = ID, result = result, slowPct = slowPct })
            end
        end
    elseif mq.TLO.Me.Class.ShortName() == 'ENC' then
        if string.find(arg1, "Enveloping Helix") then
            if mq.TLO.Me.XTarget() > 0 then
                for i = 1, 20 do
                    if mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                        if mq.TLO.Me.XTarget(i).Distance() <= mq.TLO.Spell("Enveloping Helix").AERange() then
                            ID = mq.TLO.Me.XTarget(i).ID()
                            actor:send({ script = 'xtargetx' },
                                {
                                    script = 'xtargetx',
                                    id = 'slowed',
                                    targetID = ID,
                                    result = 'CAST_SUCCESS',
                                    slowPct =
                                        mq.TLO.Spell("Enveloping Helix").SlowPct()
                                })
                        end
                    end
                end
            end
        elseif string.find(arg1, "Noctambulate") then
            while mq.TLO.Me.Casting() ~= nil do
                mq.delay(1)
            end
            local result = mq.TLO.Cast.Result()
            actor:send({ script = 'xtargetx' }, { script = 'xtargetx', id = 'mezzed', targetID = ID, result = result })
        elseif mq.TLO.Me.Casting.Subcategory() == 'Enthrall' then
            if mq.TLO.Me.Casting.AERange() > 0 then
                if mq.TLO.Me.XTarget() > 0 then
                    for i = 1, 20 do
                        if mq.TLO.Me.XTarget(i).Type() == 'NPC' then
                            if mq.TLO.Me.XTarget(i).Distance() <= mq.TLO.Me.Casting.AERange() then
                                ID = mq.TLO.Me.XTarget(i).ID()
                                actor:send({ script = 'xtargetx' },
                                    { script = 'xtargetx', id = 'mezzed', targetID = ID, result = 'CAST_SUCCESS' })
                            end
                        end
                    end
                end
                return
            end
            ID = mq.TLO.Target.ID()
            while mq.TLO.Me.Casting() ~= nil do
                mq.delay(1)
            end
            local result = mq.TLO.Cast.Result()
            actor:send({ script = 'xtargetx' }, { script = 'xtargetx', id = 'mezzed', targetID = ID, result = result })
        else
            ID = mq.TLO.Target.ID()
            local slowPct = mq.TLO.Me.Casting.SlowPct()
            if slowPct ~= 0 and slowPct ~= nil then
                while mq.TLO.Me.Casting() ~= nil do
                    mq.delay(1)
                end
                local result = mq.TLO.Cast.Result()
                actor:send({ script = 'xtargetx' },
                    { script = 'xtargetx', id = 'slowed', targetID = ID, result = result, slowPct = slowPct })
            end
        end
    elseif mq.TLO.Me.Class.ShortName() == 'BST' then
        if mq.TLO.Me.Casting.Subcategory() == 'Slow' then
            ID = mq.TLO.Target.ID()
            local slowPct = mq.TLO.Me.Casting.SlowPct()
            if slowPct ~= 0 and slowPct ~= nil then
                while mq.TLO.Me.Casting() ~= nil do
                    mq.delay(1)
                end
                local result = mq.TLO.Cast.Result()
                actor:send({ script = 'xtargetx' },
                    { script = 'xtargetx', id = 'slowed', targetID = ID, result = result, slowPct = slowPct })
            end
        else
            ID = mq.TLO.Target.ID()
            local slowPct = mq.TLO.Me.Casting.SlowPct()
            if slowPct ~= 0 and slowPct ~= nil then
                while mq.TLO.Me.Casting() ~= nil do
                    mq.delay(1)
                end
                local result = mq.TLO.Cast.Result()
                actor:send({ script = 'xtargetx' },
                    { script = 'xtargetx', id = 'slowed', targetID = ID, result = result, slowPct = slowPct })
            end
        end
    end
end

mq.event('casting', "You begin casting #1#", casting)
mq.event('singing', "You begin singing #1#", casting)

while true do
    mq.doevents()
    mq.delay(1)
end
