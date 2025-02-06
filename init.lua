--[[
    Information about targets in the xtarget window
--]]

local mq = require 'mq'
local ImGui = require 'ImGui'
local actors = require 'actors'
local settings = require 'xtxsettings'
local Icons = require('mq.ICONS')
local running = true
local xtxheader = "\ay[\agXTargetX\ay]"
local myName = mq.TLO.Me.DisplayName()
local theme = require('themes')
local max_xtargs = 1
local themeFile = mq.configDir .. '/MyThemeZ.lua'
local size = 25
local angle = 0
local tmpBgColor = ImGui.GetStyleColorVec4(ImGuiCol.TableRowBg)
if mq.TLO.Me.XTargetSlots() ~= nil then
    max_xtargs = mq.TLO.Me.XTargetSlots()
end

local window_flags = bit32.bor(ImGuiWindowFlags.None)
local treeview_table_flags = bit32.bor(ImGuiTableFlags.Reorderable, ImGuiTableFlags.Hideable, ImGuiTableFlags.RowBg,
    ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable)

settings.loadSettings()
if settings.File_Exists(themeFile) then
    theme = dofile(themeFile)
end
--settings.initSettings()

local slowedList = {}
local mezzedList = {}

local openGUI, drawGUI = true, true

function RotatePoint(p, cx, cy, angle)
    local radians = math.rad(angle)
    local cosA = math.cos(radians)
    local sinA = math.sin(radians)

    local newX = cosA * (p.x - cx) - sinA * (p.y - cy) + cx
    local newY = sinA * (p.x - cx) + cosA * (p.y - cy) + cy

    return ImVec2(newX, newY)
end

function DrawArrow(topPoint, width, height, color)
    local draw_list = ImGui.GetWindowDrawList()
    local p1 = ImVec2(topPoint.x, topPoint.y)
    local p2 = ImVec2(topPoint.x + width, topPoint.y + height)
    local p3 = ImVec2(topPoint.x - width, topPoint.y + height)

    -- center
    local center_x = (p1.x + p2.x + p3.x) / 3
    local center_y = (p1.y + p2.y + p3.y) / 3

    -- rotate
    angle = angle + .01
    p1 = RotatePoint(p1, center_x, center_y, angle)
    p2 = RotatePoint(p2, center_x, center_y, angle)
    p3 = RotatePoint(p3, center_x, center_y, angle)

    draw_list:AddTriangleFilled(p1, p2, p3, ImGui.GetColorU32(color))
end

local actor = actors.register(function(message)
    if message.content.id == 'slowed' then
        local ID = message.content.targetID
        local result = message.content.result
        local slowPct = message.content.slowPct
        if result == 'CAST_SUCCESS' or result == 'CAST_NOTARGET' then
            slowedList[ID] = slowPct
        end
    elseif message.content.id == 'mezzed' then
        local ID = message.content.targetID
        local result = message.content.result
        if result == 'CAST_SUCCESS' then
            mezzedList[ID] = Icons.MD_SNOOZE
        elseif result == 'CAST_IMMUNE' then
            mezzedList[ID] = Icons.FA_EXCLAMATION
        end
    end
end)

local listCleanup = function()
    for ID in pairs(slowedList) do
        local remove = false
        remove = mq.TLO.Me.XTarget() == 0
        for i = 1, max_xtargs do
            if mq.TLO.Me.XTarget(i).Type() == 'NPC' or mq.TLO.Me.XTarget(i).Type() == 'Pet' then
                if mq.TLO.Me.XTarget(i).ID() == ID then
                    remove = false
                    break
                else
                    remove = true
                end
            end
        end
        if remove == true then
            slowedList[ID] = nil
        end
    end
    for ID in pairs(mezzedList) do
        local remove = false
        remove = mq.TLO.Me.XTarget() == 0
        for i = 1, max_xtargs do
            if mq.TLO.Me.XTarget(i).Type() == 'NPC' or mq.TLO.Me.XTarget(i).Type() == 'Pet' then
                if mq.TLO.Me.XTarget(i).ID() == ID then
                    remove = false
                    break
                else
                    remove = true
                end
            end
        end
        if remove == true then
            mezzedList[ID] = nil
        end
    end
end

local getConLevel = function(spawn)
    local conColor = spawn.ConColor()
    local level = spawn.Level()
    local textColor = settings.colors.purple
    if conColor == 'GREY' then
        textColor = settings.colors.grey
    elseif conColor == 'GREEN' then
        textColor = settings.colors.green
    elseif conColor == 'LIGHT BLUE' then
        textColor = settings.colors.lightBlue
    elseif conColor == 'BLUE' then
        textColor = settings.colors.blue
    elseif conColor == 'WHITE' then
        textColor = settings.colors.white
    elseif conColor == 'YELLOW' then
        textColor = settings.colors.yellow
    elseif conColor == 'RED' then
        textColor = settings.colors.red
    end
    return textColor, level
end

local getName = function(spawn)
    local name = spawn.CleanName()
    return name
end

local getPctHp = function(spawn)
    local pctHp = spawn.PctHPs()
    local textColor = settings.colors.purple
    if pctHp == nil then
        pctHp = 0
        return textColor, pctHp
    end
    if pctHp >= settings.hp.highThreshold then
        textColor = settings.hp.colorNPCHigh
    elseif pctHp >= settings.hp.lowThreshold then
        textColor = settings.hp.colorNPCMid
    elseif pctHp >= 0 then
        textColor = settings.hp.colorNPCLow
    end
    pctHp = pctHp / 100
    return textColor, pctHp
end

local getPctHpFriendly = function(spawn)
    local pctHp = spawn.PctHPs()
    local textColor = settings.colors.purple
    if pctHp == nil then
        pctHp = 0
        return textColor, pctHp
    end
    if pctHp >= settings.hp.highThreshold then
        textColor = settings.hp.colorPCHigh
    elseif pctHp >= settings.hp.lowThreshold then
        textColor = settings.hp.colorPCMid
    elseif pctHp >= 0 then
        textColor = settings.hp.colorPCLow
    end
    pctHp = pctHp / 100
    return textColor, pctHp
end

local getPctMpFriendly = function(spawn)
    local pctMp = spawn.PctMana()
    local textColor = settings.colors.purple
    if pctMp == nil then
        pctMp = 0
        return textColor, pctMp
    end
    if pctMp >= 60 then
        textColor = settings.colors.green
    elseif pctMp >= 40 then
        textColor = settings.colors.yellow
    elseif pctMp >= 0 then
        textColor = settings.colors.red
    end
    return textColor, pctMp
end

local getAggroPct = function(spawn)
    local pctAggro = spawn.PctAggro() / 100
    local textColor = settings.colors.purple
    if pctAggro >= 1 then
        textColor = settings.aggro.colorHave
    else
        textColor = settings.aggro.colorNot
    end
    return textColor, pctAggro
end

local getSlow = function(spawn)
    local ID = spawn.ID()
    local slowPct = 0
    local textColor = settings.colors.purple
    if ID == mq.TLO.Target.ID() then
        if mq.TLO.Target.Slowed() == nil then
            slowPct = 0
        else
            slowPct = mq.TLO.Target.Slowed.Spell.SlowPct()
        end
    elseif slowedList[ID] ~= nil then
        slowPct = slowedList[ID]
    end
    if slowPct == settings.slow.pctThreshold then
        textColor = settings.slow.colorMax
    elseif slowPct > 0 then
        textColor = settings.slow.colorMid
    else
        textColor = settings.slow.colorNone
    end
    return textColor, slowPct
end

local getMez = function(spawn)
    local ID = spawn.ID()
    local mezzed = ''
    local textColor = settings.colors.purple
    if ID == mq.TLO.Target.ID() then
        if mq.TLO.Target.Mezzed() == nil then
            mezzed = ''
        else
            mezzed = Icons.MD_SNOOZE
        end
    elseif mezzedList[ID] then
        mezzed = mezzedList[ID]
    end
    if mezzed == Icons.MD_SNOOZE then
        textColor = settings.colors.green
    elseif mezzed == Icons.FA_EXCLAMATION
    then
        textColor = settings.colors.red
    end
    return textColor, mezzed
end

local getDistance = function(spawn)
    local distance = spawn.Distance()
    local textColor = settings.colors.purple
    if distance == nil then
        distance = -1
        return textColor, distance
    end
    distance = tonumber(string.format("%d", math.floor(spawn.Distance())))
    if distance <= settings.distance.close then
        textColor = settings.distance.colorClose
    elseif distance <= settings.distance.medium then
        textColor = settings.distance.colorMid
    elseif distance > settings.distance.medium then
        textColor = settings.distance.colorFar
    end
    return textColor, distance
end

local rowContext = function(row)
    if ImGui.BeginPopupContextItem(row) then
        if ImGui.BeginMenu("NPC Targets") then
            if ImGui.MenuItem("Empty Target") then
                printf("%s \agSeting Slot \ar%s \agto \arEmpty Target", xtxheader, row)
                mq.cmdf("/xtarget set %s emptytarget", row)
            end
            if ImGui.MenuItem("Auto Hater") then
                printf("%s \agSeting Slot \ar%s \agto \arAuto Hater", xtxheader, row)
                mq.cmdf("/xtarget set %s autohater", row)
            end
            if ImGui.MenuItem("Target's Target") then
                printf("%s \agSeting Slot \ar%s \agto \arTarget's Target", xtxheader, row)
                mq.cmdf("/xtarget set %s targetstarget", row)
            end
            if ImGui.MenuItem("Group Mark Target 1") then
                printf("%s \agSeting Slot \ar%s \agto \arGroup Mark Target 1", xtxheader, row)
                mq.cmdf("/xtarget set %s groupmark1", row)
            end
            if ImGui.MenuItem("Group Mark Target 2") then
                printf("%s \agSeting Slot \ar%s \agto \arGroup Mark Target 2", xtxheader, row)
                mq.cmdf("/xtarget set %s groupmark2", row)
            end
            if ImGui.MenuItem("Group Mark Target 3") then
                printf("%s \agSeting Slot \ar%s \agto \arGroup Mark Target 3", xtxheader, row)
                mq.cmdf("/xtarget set %s groupmark3", row)
            end
            if ImGui.MenuItem("Raid Mark Target 1") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Mark Target 1", xtxheader, row)
                mq.cmdf("/xtarget set %s raidmark1", row)
            end
            if ImGui.MenuItem("Raid Mark Target 2") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Mark Target 2", xtxheader, row)
                mq.cmdf("/xtarget set %s raidmark2", row)
            end
            if ImGui.MenuItem("Raid Mark Target 3") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Mark Target 3", xtxheader, row)
                mq.cmdf("/xtarget set %s raidmark3", row)
            end
            if ImGui.MenuItem("My Pet's Target") then
                printf("%s \agSeting Slot \ar%s \agto \arMy Pet's Target", xtxheader, row)
                mq.cmdf("/xtarget set %s pettarget", row)
            end
            if ImGui.MenuItem("My Mercenary's Target") then
                printf("%s \agSeting Slot \ar%s \agto \arMy Mercenary's Target", xtxheader, row)
                mq.cmdf("/xtarget set %s mercenarytarget", row)
            end
            ImGui.EndMenu()
        end
        if ImGui.BeginMenu("Friendly Targets") then
            if ImGui.MenuItem("Group Tank") then
                printf("%s \agSeting Slot \ar%s \agto \arGroup Tank", xtxheader, row)
                mq.cmdf("/xtarget set %s grouptank", row)
            end
            if ImGui.MenuItem("Group Assist") then
                printf("%s \agSeting Slot \ar%s \agto \arGroup Assist", xtxheader, row)
                mq.cmdf("/xtarget set %s groupassist", row)
            end
            if ImGui.MenuItem("Puller") then
                printf("%s \agSeting Slot \ar%s \agto \arPuller", xtxheader, row)
                mq.cmdf("/xtarget set %s puller", row)
            end
            if ImGui.MenuItem("Raid Assist 1") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Assist 1", xtxheader, row)
                mq.cmdf("/xtarget set %s raidassist1", row)
            end
            if ImGui.MenuItem("Raid Assist 2") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Assist 2", xtxheader, row)
                mq.cmdf("/xtarget set %s raidassist2", row)
            end
            if ImGui.MenuItem("Raid Assist 3") then
                printf("%s \agSeting Slot \ar%s \agto \arRaid Assist 3", xtxheader, row)
                mq.cmdf("/xtarget set %s raidassist3", row)
            end
            if ImGui.MenuItem("My Pet") then
                printf("%s \agSeting Slot \ar%s \agto \arMy Pet", xtxheader, row)
                mq.cmdf("/xtarget set %s mypet", row)
            end
            if ImGui.MenuItem("My Mercenary") then
                printf("%s \agSeting Slot \ar%s \agto \arMy Mercenary", xtxheader, row)
                mq.cmdf("/xtarget set %s mymercenary", row)
            end
            ImGui.EndMenu()
        end
        if mq.TLO.Group.GroupSize() ~= nil then
            if ImGui.BeginMenu("Group Members") then
                for i = 0, mq.TLO.Group.GroupSize() - 1 do
                    if ImGui.MenuItem(mq.TLO.Group.Member(i).Name()) then
                        printf("%s \agSeting Slot \ar%s \agto \ar%s", xtxheader, row, mq.TLO.Group.Member(i).Name())
                        mq.cmdf("/xtarget set %s %s", row, mq.TLO.Group.Member(i).Name())
                    end
                end
                ImGui.EndMenu()
            end
        end
        if mq.TLO.Raid.Members() > 0 then
            if ImGui.BeginMenu("Raid Members") then
                for i = 0, mq.TLO.Raid.Members() - 1 do
                    if ImGui.MenuItem(mq.TLO.Raid.Member(i).Name()) then
                        printf("%s \agSeting Slot \ar%s \agto \ar%s", xtxheader, row, mq.TLO.Group.Member(i).Name())
                        mq.cmdf("/xtarget set %s %s", row, mq.TLO.Raid.Member(i).Name())
                    end
                end
                ImGui.EndMenu()
            end
        end
        ImGui.Separator()
        if ImGui.BeginMenu('ThemeZ') then
            local ThemeName = settings.general.themeName
            for k, data in pairs(theme.Theme) do
                if ImGui.MenuItem(data.Name, '', (data.Name == ThemeName)) then
                    theme.LoadTheme = data.Name
                    ThemeName = theme.LoadTheme
                    settings.general.themeName = ThemeName
                    settings.saveTheme()
                end
            end
            ImGui.Separator()
            _ = ImGui.MenuItem('Reload', '')
            if _ then
                settings.loadTheme()
            end
            ImGui.EndMenu()
        end
        ImGui.Separator()
        if ImGui.Selectable("Settings", false, ImGuiSelectableFlags.SpanAllColumns) then
            mq.cmd('/xtx settings')
        end
        ImGui.Separator()
        if ImGui.Selectable("Exit", false, ImGuiSelectableFlags.SpanAllColumns) then
            mq.cmd('/xtx exit')
        end
        ImGui.EndPopup()
    end
end

local function CleanXtar()
    if mq.TLO.Me.XTarget() > 0 then
        for i = 1, mq.TLO.Me.XTargetSlots() do
            local xType = mq.TLO.Me.XTarget(i).Type()
            local xID = mq.TLO.Me.XTarget(i).ID()
            local xName = mq.TLO.Me.XTarget(i).Name()
            if xType == 'PC' then
                printf("\ayxFix\aw:: Skipping \agPC\ax Xtarget Slot:: \at%s", i)
                goto continue
            end
            if not (xID > 0 and xType ~= 'Corpse' and xType ~= 'Chest') then
                local xCount = mq.TLO.Me.XTarget() or 0
                if (xCount > 0 and xID == 0) or (xType == 'Corpse') or (xType == 'Chest') then
                    if ((xName ~= 'NULL' and xID == 0) or (xType == 'Corpse') or (xType == 'Chest')) then
                        mq.cmdf("/squelch /xtarg set %s ET", i)
                        mq.delay(100)
                        mq.cmdf("/squelch /xtarg set %s AH", i)
                        local debugString = string.format('\ayxFix\aw:: Cleaning Xtarget Slot::\at %s\aw XTarget Count::\ao %s\aw Name::\ag %s\aw Type:: \at%s', i, xCount, xName,
                            xType)
                        print(debugString)
                    end
                end
            end
            ::continue::
        end
    end
end

local drawRow = function(drawData)
    ImGui.TableNextRow()
    --Set row color for target and/or friendly

    if drawData.spawn.ID() == mq.TLO.Target.ID() and drawData.friendly == false then
        ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, getConLevel(drawData.spawn))
    elseif drawData.spawn.ID() == mq.TLO.Target.ID() and drawData.friendly == true then
        ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, settings.general.friendlyTargetRowColor)
    elseif drawData.friendly == true then
        ImGui.TableSetBgColor(ImGuiTableBgTarget.RowBg0, settings.general.friendlyRowColor)
    end
    ImGui.TableSetBgColor(ImGuiTableBgTarget.CellBg, getConLevel(drawData.spawn), 0)

    --row headers
    if settings.general.useRowHeaders == true then
        ImGui.TableNextColumn()
        ImGui.TextColored(settings.general.colorRowNum, tostring(drawData.row))
    end
    --level
    ImGui.TableNextColumn()
    ImGui.Text("%s", drawData.spawn.Level() or 0)
    --name
    ImGui.TableNextColumn()
    if ImGui.Selectable(drawData.name .. "##" .. drawData.spawn.ID(), false, ImGuiSelectableFlags.SpanAllColumns) then
        printf("%s \agTargeting \ar%s \agID \ar%s", xtxheader, drawData.name, drawData.spawn.ID())
        mq.cmdf('/target id %s', drawData.spawn.ID())
    end
    if ImGui.IsItemHovered() and settings.AdvToolTip then
        ImGui.BeginTooltip()
        ImGui.Text("%s", drawData.name)
        ImGui.SameLine()
        ImGui.Text("Lvl: %s", drawData.level)
        ImGui.Text("Dist: %s", drawData.distance)
        ImGui.SameLine()
        ImGui.Text("Aggro: %s", drawData.pctAggro * 100)
        -- ImGui.Text("HP: %s",drawData.pctHp * 100)
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, settings.colors.red)
        ImGui.SetWindowFontScale(0.8)
        ImGui.ProgressBar(drawData.pctHp, 150, 10, "##hp")
        ImGui.SameLine()
        ImGui.SetCursorPos(60, ImGui.GetCursorPosY() - 3)
        ImGui.Text("HP %d %%", (drawData.pctHp * 100))
        ImGui.SetWindowFontScale(1)
        ImGui.PopStyleColor()
        ImGui.EndTooltip()
    end
    rowContext(drawData.row)
    --distance
    ImGui.TableNextColumn()
    ImGui.TextColored(drawData.distTextColor, tostring(drawData.distance))
    --Direction
    ImGui.TableNextColumn()
    local cursorScreenPos = ImGui.GetCursorScreenPosVec()
    if drawData.spawn.HeadingTo.Degrees() ~= nil and mq.TLO.Me.Heading.Degrees() ~= nil then
        angle = drawData.spawn.HeadingTo.Degrees() - mq.TLO.Me.Heading.Degrees()
    else
        angle = 0
    end
    DrawArrow(ImVec2(cursorScreenPos.x + size / 2, cursorScreenPos.y), 5, 15, drawData.distTextColor)
    --hp
    ImGui.TableNextColumn()
    if settings.hp.hpAsBar == true then
        ImGui.PushStyleColor(ImGuiCol.PlotHistogram, drawData.hpTextColor)
        ImGui.ProgressBar(drawData.pctHp, ImGui.GetColumnWidth(), 17, "##hp")
        ImGui.PopStyleColor()
        ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 20)
        ImGui.SetCursorPosX(ImGui.GetCursorPosX() + (ImGui.GetColumnWidth() / 2) - 14)
        ImGui.Text(tostring(drawData.pctHp * 100) .. "%")
    else
        ImGui.TextColored(drawData.hpTextColor, tostring(drawData.pctHp * 100))
    end
    --mp
    ImGui.TableNextColumn()
    if drawData.friendly == true then
        ImGui.TextColored(drawData.mpTextColor, tostring(drawData.pctMp))
    end
    --aggro
    ImGui.TableNextColumn()
    if drawData.friendly == false then
        if settings.aggro.aggroAsBar == true then
            ImGui.PushStyleColor(ImGuiCol.PlotHistogram, drawData.aggroTextColor)
            ImGui.ProgressBar(drawData.pctAggro, ImGui.GetColumnWidth(), 17, "##aggro")
            ImGui.PopStyleColor()
            ImGui.SetCursorPosY(ImGui.GetCursorPosY() - 20)
            ImGui.SetCursorPosX(ImGui.GetCursorPosX() + (ImGui.GetColumnWidth() / 2) - 14)
            ImGui.Text(tostring(drawData.pctAggro * 100) .. "%")
        else
            ImGui.TextColored(drawData.aggroTextColor, tostring(drawData.pctAggro * 100))
        end
    end
    --slowed
    ImGui.TableNextColumn()
    if drawData.friendly == false then
        ImGui.TextColored(drawData.slowTextColor, tostring(drawData.slowPct))
    end
    --mezzed
    ImGui.TableNextColumn()
    ImGui.TextColored(drawData.mezTextColor, drawData.mezzed)
end

local displayGUI = function()
    if not openGUI then running = false end
    local ColorCount, StyleCount = settings.DrawTheme(settings.general.themeName)
    openGUI, drawGUI = ImGui.Begin('XTargetX##' .. myName, openGUI, settings.window_flags)
    local drawn = false
    if drawGUI then
        ImGui.BeginGroup()
        ImGui.PushStyleColor(ImGuiCol.TableRowBg, settings.general.colorTableBg)
        ImGui.PushStyleColor(ImGuiCol.TableRowBgAlt, settings.general.colorTableBgAlt)
        ImGui.PushStyleColor(ImGuiCol.TableHeaderBg, settings.general.colorTableHeaderBg)
        if settings.general.useRowHeaders == true then
            ImGui.BeginTable('##table1', 10, treeview_table_flags)
            ImGui.TableSetupColumn("Row", bit32.bor(ImGuiTableColumnFlags.None), 30)
        else
            ImGui.BeginTable('##table1', 9, treeview_table_flags)
        end
        ImGui.TableSetupColumn("Lvl", bit32.bor(ImGuiTableColumnFlags.None), 30)
        ImGui.TableSetupColumn("Name", bit32.bor(ImGuiTableColumnFlags.None), 100)
        ImGui.TableSetupColumn("Dist", bit32.bor(ImGuiTableColumnFlags.None), 50)
        ImGui.TableSetupColumn("Dir", bit32.bor(ImGuiTableColumnFlags.None), 30)
        if settings.hp.hpAsBar == true then
            ImGui.TableSetupColumn("HP", bit32.bor(ImGuiTableColumnFlags.None), 100)
        else
            ImGui.TableSetupColumn("HP", bit32.bor(ImGuiTableColumnFlags.None), 35)
        end
        ImGui.TableSetupColumn("MP", bit32.bor(ImGuiTableColumnFlags.None), 35)
        if settings.aggro.aggroAsBar == true then
            ImGui.TableSetupColumn("Aggro", bit32.bor(ImGuiTableColumnFlags.None), 100)
        else
            ImGui.TableSetupColumn("Aggro", bit32.bor(ImGuiTableColumnFlags.None), 40)
        end
        ImGui.TableSetupColumn("Slow", bit32.bor(ImGuiTableColumnFlags.None), 40)
        ImGui.TableSetupColumn("Mez", bit32.bor(ImGuiTableColumnFlags.None), 60)
        ImGui.TableSetupScrollFreeze(0, 1)
        ImGui.TableHeadersRow()
        for i = 1, max_xtargs do
            if mq.TLO.Me.XTarget(i)() ~= nil and mq.TLO.Me.XTarget(i)() ~= 0 then
                local drawData = {}
                drawData.row = i
                drawData.spawn = mq.TLO.Me.XTarget(i)
                drawData.conTextColor = settings.colors.purple
                drawData.hpTextColor = settings.colors.purple
                drawData.mpTextColor = settings.colors.purple
                drawData.aggroTextColor = settings.colors.purple
                drawData.slowTextColor = settings.colors.purple
                drawData.distTextColor = settings.colors.purple
                drawData.mezTextColor = settings.colors.purple
                drawData.level = 0
                drawData.pctHp = 0
                drawData.pctMp = 0
                drawData.name = ''
                drawData.pctAggro = -1
                drawData.slowPct = -1
                drawData.distance = 0
                drawData.mezzed = ''
                drawData.friendly = false
                local targetType = mq.TLO.Me.XTarget(i).Type()
                if targetType == 'Pet' then
                    targetType = mq.TLO.Me.XTarget(i).Master.Type()
                end
                if targetType == 'NPC' then
                    drawData.conTextColor, drawData.level = settings.colors.default, drawData.level
                    drawData.name = getName(drawData.spawn)
                    drawData.hpTextColor, drawData.pctHp = getPctHp(drawData.spawn)
                    drawData.aggroTextColor, drawData.pctAggro = getAggroPct(drawData.spawn)
                    drawData.slowTextColor, drawData.slowPct = getSlow(drawData.spawn)
                    drawData.mezTextColor, drawData.mezzed = getMez(drawData.spawn)
                    drawData.distTextColor, drawData.distance = getDistance(drawData.spawn)
                elseif ((targetType == 'PC' or targetType == 'Mercenary') and (settings.general.showFriendlies or settings.general.showEmptyRows)) then
                    drawData.conTextColor, drawData.level = settings.colors.default, drawData.level
                    drawData.name = getName(drawData.spawn)
                    drawData.hpTextColor, drawData.pctHp = getPctHpFriendly(drawData.spawn)
                    drawData.mpTextColor, drawData.pctMp = getPctMpFriendly(drawData.spawn)
                    drawData.distTextColor, drawData.distance = getDistance(drawData.spawn)
                    drawData.friendly = true
                end
                if drawData.level == nil or drawData.name == nil or drawData.pctHp == 0 or drawData.distance == -1 then
                    break
                end
                drawRow(drawData)
                drawn = true
            elseif settings.general.showEmptyRows then
                ImGui.TableNextRow()
                if settings.general.useRowHeaders == true then
                    ImGui.TableNextColumn()
                    ImGui.TextColored(settings.general.colorRowNum, tostring(i))
                end
                ImGui.TableNextColumn()
                ImGui.Selectable("##" .. i, false, ImGuiSelectableFlags.SpanAllColumns)
                rowContext(i)
            end
        end
        ImGui.EndTable()
        ImGui.PopStyleColor(3)
        ImGui.EndGroup()
        if not drawn then rowContext(1) end
    end
    if ColorCount > 0 then ImGui.PopStyleColor(ColorCount) end
    if StyleCount > 0 then ImGui.PopStyleVar(StyleCount) end
    ImGui.End()
end

local cmd_xtx = function(cmd)
    if cmd == nil or cmd == 'help' then
        printf("%s \ar/xtx exit \ao--- Exit script (Also \ar/xtx stop \aoand \ar/xtx quit)", xtxheader)
        printf("%s \ar/xtx settings \ao--- Open Settings Window", xtxheader)
    end
    if cmd == 'exit' or cmd == 'quit' or cmd == 'stop' then
        mq.cmd('/dgae /lua stop xtargetx/backgroundactors')
        running = false
    end
    if cmd == 'settings' then
        settings.openSettingsGUI = true
        settings.drawSettingsGUI = true
    end
end

local function init()
    mq.imgui.init('displayGUI', displayGUI)
    mq.imgui.init('settingsGUI', settings.settingsGUI)
    if mq.TLO.Plugin('mq2dannet').IsLoaded() == false then
        printf("%s \aoDanNet is required for this plugin.  \arExiting", xtxheader)
        mq.exit()
    end
    mq.cmd('/dgae /lua run xtargetx/backgroundactors')
    mq.bind('/xtx', cmd_xtx)
    printf("%s \agstarting. Use \ar/xtx help \ag for a list of commands.", xtxheader)
end

local function main()
    while running do
        if mq.TLO.Window('CharacterListWnd').Open() then running = false end
        local xFix = mq.TLO.Lua.Script('xfix').Status()
        if xFix ~= 'RUNNING' then
            CleanXtar()
        end
        listCleanup()
        mq.delay(300)
    end
    mq.unbind('/xtx')
    mq.exit()
end

init()
main()
