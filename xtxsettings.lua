--[[
    Settings functions for xtargetx script
]]

local mq = require('mq')
local ImGui = require 'ImGui'

local myName = mq.TLO.Me.DisplayName()
local settings = {}
local configSettings = {}
local xtxheader = "\ay[\agXTargetX\ay]"
local themeFile = mq.configDir .. '/MyThemeZ.lua'
settings.openSettingsGUI, settings.drawSettingsGUI = false, false
local theme = {}
local settings_window_flags = bit32.bor(ImGuiWindowFlags.NoCollapse)
local settings_coloredit_flags = bit32.bor(ImGuiColorEditFlags.AlphaBar, ImGuiColorEditFlags.AlphaPreview,
    ImGuiColorEditFlags.NoInputs)
settings.configPath = 'xtargetx_config_' .. myName .. '.lua'
---comment Check to see if the file we want to work on exists.
---@param name string -- Full Path to file
---@return boolean -- returns true if the file exists and false otherwise
function settings.File_Exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end


function settings.saveTheme()
    configSettings.general.themeName = settings.general.themeName
    mq.pickle(settings.configPath, configSettings)
    settings.initSettings()
end

function settings.loadTheme()
    if settings.File_Exists(themeFile) then
        theme = dofile(themeFile)
        else
        theme = require('themes')
    end
end

settings.initSettings = function()
    settings.window_flags = bit32.bor(ImGuiWindowFlags.None)
    if configSettings.general.showTitlebar == false then
        settings.window_flags = bit32.bor(settings.window_flags, ImGuiWindowFlags.NoTitleBar)
    end
    if configSettings.general.lockWindowSize == true then
        settings.window_flags = bit32.bor(settings.window_flags, ImGuiWindowFlags.NoResize)
    end
    if configSettings.general.lockWindowPosition == true then
        settings.window_flags = bit32.bor(settings.window_flags, ImGuiWindowFlags.NoMove)
    end
    if configSettings.general.autoSize == true then
        settings.window_flags = bit32.bor(settings.window_flags, ImGuiWindowFlags.AlwaysAutoResize)
    end
    if configSettings.general.AdvToolTip == nil then
        configSettings.general.AdvToolTip = true
    end
    settings.hp = configSettings.hp
    settings.aggro = configSettings.aggro
    settings.distance = configSettings.distance
    settings.slow = configSettings.slow
    settings.general = configSettings.general
    settings.AdvToolTip = configSettings.general.AdvToolTip
    settings.colors = {
        red = IM_COL32(255, 0, 0, 255),
        yellow = IM_COL32(255, 255, 0, 255),
        white = IM_COL32(255, 255, 255, 255),
        blue = IM_COL32(0, 0, 255, 2551),
        lightBlue = IM_COL32(0, 255, 255, 255),
        green = IM_COL32(0, 255, 0, 255),
        grey = IM_COL32(158, 158, 158, 255),
        purple = IM_COL32(255, 0, 255, 255),
    }
end

settings.checkConfig = function()
    --Health
    if not configSettings.hp then configSettings.hp = {} end
    if not configSettings.hp.colorNPCHigh then configSettings.hp.colorNPCHigh = IM_COL32(255, 0, 0, 255) end
    if not configSettings.hp.colorNPCMid then configSettings.hp.colorNPCMid = IM_COL32(255, 255, 0, 255) end
    if not configSettings.hp.colorNPCLow then configSettings.hp.colorNPCLow = IM_COL32(0, 255, 0, 255) end
    if not configSettings.hp.colorPCHigh then configSettings.hp.colorPCHigh = IM_COL32(0, 255, 0, 255) end
    if not configSettings.hp.colorPCMid then configSettings.hp.colorPCMid = IM_COL32(255, 255, 0, 255) end
    if not configSettings.hp.colorPCLow then configSettings.hp.colorPCLow = IM_COL32(255, 0, 0, 255) end
    if not configSettings.hp.highThreshold then configSettings.hp.highThreshold = 100 end
    if not configSettings.hp.lowThreshold then configSettings.hp.lowThreshold = 33 end
    if not configSettings.hp.hpAsBar then configSettings.hp.hpAsBar = false end
    --aggro
    if not configSettings.aggro.colorHave then configSettings.aggro.colorHave = IM_COL32(0, 255, 0, 255) end
    if not configSettings.aggro.colorNot then configSettings.aggro.colorNot = IM_COL32(255, 0, 0, 255) end
    if not configSettings.aggro.aggroAsBar then configSettings.aggro.aggroAsBar = false end
    --distance
    if not configSettings.distance.close then configSettings.distance.close = 50 end
    if not configSettings.distance.medium then configSettings.distance.medium = 200 end
    if not configSettings.distance.colorClose then configSettings.distance.colorClose = IM_COL32(0, 255, 0, 255) end
    if not configSettings.distance.colorMid then configSettings.distance.colorMid = IM_COL32(255, 255, 0, 255) end
    if not configSettings.distance.colorFar then configSettings.distance.colorFar = IM_COL32(255, 0, 0, 255) end
    --slow
    if not configSettings.slow.pctThreshold then configSettings.slow.pctThreshold = 75 end
    if not configSettings.slow.colorMax then configSettings.slow.colorMax = IM_COL32(0, 255, 0, 255) end
    if not configSettings.slow.colorMid then configSettings.slow.colorMid = IM_COL32(255, 255, 0, 255) end
    if not configSettings.slow.colorNone then configSettings.slow.colorNone = IM_COL32(255, 0, 0, 255) end
    --general
    if not configSettings.general.showTitlebar then configSettings.general.showTitlebar = false end
    if not configSettings.general.lockWindowSize then configSettings.general.lockWindowSize = false end
    if not configSettings.general.lockWindowPosition then configSettings.general.lockWindowPosition = false end
    if not configSettings.general.lockWindowSize then configSettings.general.lockWindowSize = false end
    if not configSettings.general.autoSize then configSettings.general.autoSize = true end
    if not configSettings.general.useRowHeaders then configSettings.general.useRowHeaders = false end
    if not configSettings.general.showEmptyRows then configSettings.general.showEmptyRows = false end
    if not configSettings.general.showFriendlies then configSettings.general.showFriendlies = false end
    if not configSettings.general.themeName then configSettings.general.themeName = 'Default' end
    if not configSettings.general.AdvToolTip then configSettings.general.AdvToolTip = true end
    if not configSettings.general.friendlyRowColor then
        configSettings.general.friendlyRowColor = IM_COL32(76, 178, 76,
            115)
    end
    if not configSettings.general.targetRowColor then configSettings.general.targetRowColor = IM_COL32(178, 76, 76, 115) end
    if not configSettings.general.friendlyTargetRowColor then
        configSettings.general.friendlyTargetRowColor = IM_COL32(
            178, 76, 178, 115)
    end
    if not configSettings.general.corpseRowColor then configSettings.general.corpseRowColor = IM_COL32(178, 178, 178, 115) end
    if not configSettings.general.colorRowNum then configSettings.general.colorRowNum = IM_COL32(158, 158, 158, 255) end
    if not configSettings.general.colorTableBg then configSettings.general.colorTableBg = IM_COL32(0, 0, 0, 0) end
    if not configSettings.general.colorTableBgAlt then
        configSettings.general.colorTableBgAlt = IM_COL32(255, 255, 255,
            15)
    end
    if not configSettings.general.colorTableHeaderBg then
        configSettings.general.colorTableHeaderBg = IM_COL32(48, 48, 51,
            255)
    end
    mq.pickle(settings.configPath, configSettings)
end

settings.createConfig = function()
    local configData, err = loadfile(mq.configDir .. '/xtargetx_config.lua')
    if err or not configData then
        configSettings.hp = {
            colorNPCHigh = IM_COL32(255, 0, 0, 255),
            colorNPCMid = IM_COL32(255, 255, 0, 255),
            colorNPCLow = IM_COL32(0, 255, 0, 255),
            colorPCHigh = IM_COL32(0, 255, 0, 255),
            colorPCMid = IM_COL32(255, 255, 0, 255),
            colorPCLow = IM_COL32(255, 0, 0, 255),
            highThreshold = 100,
            lowThreshold = 33,
            hpAsBar = false
        }
        configSettings.aggro = {
            colorHave = IM_COL32(0, 255, 0, 255),
            colorNot = IM_COL32(255, 0, 0, 255),
            aggroAsBar = false
        }
        configSettings.distance = {
            close = 50,
            medium = 200,
            colorClose = IM_COL32(0, 255, 0, 255),
            colorMid = IM_COL32(255, 255, 0, 255),
            colorFar = IM_COL32(255, 0, 0, 255)
        }
        configSettings.slow = {
            pctThreshold = 75,
            colorMax = IM_COL32(0, 255, 0, 255),
            colorMid = IM_COL32(255, 255, 0, 255),
            colorNone = IM_COL32(255, 0, 0, 255)
        }
        configSettings.general = {
            lockWindowSize = false,
            lockWindowPosition = false,
            showTitlebar = false,
            autoSize = true,
            useRowHeaders = false,
            showEmptyRows = false,
            showFriendlies = false,
            themeName = 'Default',
            AdvToolTip = true,
            friendlyRowColor = IM_COL32(76, 178, 76, 115),
            targetRowColor = IM_COL32(178, 76, 76, 115),
            friendlyTargetRowColor = IM_COL32(178, 76, 178, 115),
            corpseRowColor = IM_COL32(178, 178, 178, 115),
            colorRowNum = IM_COL32(158, 158, 158, 255),
            colorTableBg = IM_COL32(0, 0, 0, 0),
            colorTableBgAlt = IM_COL32(255, 255, 255, 15),
            colorTableHeaderBg = IM_COL32(48, 48, 51, 255)
        }
    else
        configSettings = configData()
        settings.checkConfig()
    end
    mq.pickle(settings.configPath, configSettings)
end

---comment
---@param themeName string -- name of the theme to load form table
---@return integer, integer -- returns the new counter values 
function settings.DrawTheme(themeName)
    local StyleCounter = 0
    local ColorCounter = 0
    for tID, tData in pairs(theme.Theme) do
        if tData.Name == themeName then
            for pID, cData in pairs(theme.Theme[tID].Color) do
                ImGui.PushStyleColor(pID, ImVec4(cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4]))
                ColorCounter = ColorCounter + 1
            end
            if tData['Style'] ~= nil then
                if next(tData['Style']) ~= nil then
                    
                    for sID, sData in pairs (theme.Theme[tID].Style) do
                        if sData.Size ~= nil then
                            ImGui.PushStyleVar(sID, sData.Size)
                            StyleCounter = StyleCounter + 1
                            elseif sData.X ~= nil then
                            ImGui.PushStyleVar(sID, sData.X, sData.Y)
                            StyleCounter = StyleCounter + 1
                        end
                    end
                end
            end
        end
    end
    return ColorCounter, StyleCounter
end

settings.settingsGUI = function()
    if not settings.openSettingsGUI then return end
    settings.openSettingsGUI, settings.drawSettingsGUI = ImGui.Begin('XTargetX Settings', settings.openSettingsGUI,
        settings_window_flags)
    if settings.drawSettingsGUI then
        ImGui.BeginChild('##Settings_Buttons', ImGui.GetWindowContentRegionWidth(), 25, ImGuiChildFlags.None)
        if ImGui.Button('Save Settings') then
            printf("%s Saving Settings...", xtxheader)
            configSettings.general.themeName = settings.general.themeName
            mq.pickle(settings.configPath, configSettings)
            settings.initSettings()
            settings.openSettingsGUI = false
        end
        ImGui.SameLine()
        ImGui.Dummy(50, 0)
        ImGui.SameLine()
        if ImGui.Button('Default Settings') then
            printf("%s Reseting to default Settings...", xtxheader)
            settings.createConfig()
            settings.initColors()
            settings.openSettingsGUI = false
        end
        ImGui.SameLine()
        ImGui.HelpMarker('Restore all settings to default')
        ImGui.EndChild()
        ImGui.BeginChild('##Settings_Fields')
        if ImGui.CollapsingHeader('General') then
            configSettings.general.showTitlebar = ImGui.Checkbox("Show Titlebar", configSettings.general.showTitlebar)
            ImGui.SameLine()
            ImGui.HelpMarker('Show titlebar on the XtargetX window')
            configSettings.general.autoSize = ImGui.Checkbox("Automatic Window Size", configSettings.general.autoSize)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'Automatically size the XTargetX window. (This will also set Lock Window Size to be checked)')
            if configSettings.general.autoSize == true then
                configSettings.general.lockWindowSize = true
            end
            configSettings.general.lockWindowSize = ImGui.Checkbox("Lock Window Size",
                configSettings.general.lockWindowSize)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'Lock the window size of the XTargetX window. (This can only be disabled when Automatic size is not checked)')
            configSettings.general.lockWindowPosition = ImGui.Checkbox("Lock Window Position",
                configSettings.general.lockWindowPosition)
            ImGui.SameLine()
            ImGui.HelpMarker('Lock the position of the XtargetX window')
            configSettings.general.colorTableHeaderBg = ImGui.ColorEdit4("Row Heading",
                configSettings.general.colorTableHeaderBg, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Background color for the heading row of the XTargetX window')
            configSettings.general.colorTableBg = ImGui.ColorEdit4("Row Color 1",
                configSettings.general.colorTableBg, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Background color for the odd numbered rows of the XTargetX window')
            configSettings.general.colorTableBgAlt = ImGui.ColorEdit4("Row Color 2",
                configSettings.general.colorTableBgAlt, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Background color for the even numbered rows of the XTargetX window')
            configSettings.general.useRowHeaders = ImGui.Checkbox("Show Row Headers",
                configSettings.general.useRowHeaders)
            ImGui.SameLine()
            ImGui.HelpMarker('Show the Row Number column')
            if configSettings.general.useRowHeaders then
                configSettings.general.colorRowNum = ImGui.ColorEdit4("Row Number",
                    configSettings.general.colorRowNum, settings_coloredit_flags)
                ImGui.SameLine()
                ImGui.HelpMarker('Color of the text in the Row Number column')
            end
            configSettings.general.showEmptyRows = ImGui.Checkbox("Show Empty Rows",
                configSettings.general.showEmptyRows)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'Show all 20 rows of the XTargetX Window (This will cause friendlies to be shown even if Show Friendles is unchecked')
            configSettings.general.showFriendlies = ImGui.Checkbox("Show Friendlies",
                configSettings.general.showFriendlies)
            ImGui.SameLine()
            ImGui.HelpMarker(
                'Show friendly targets in the XTargetX Window (Friendlies will automatically be shown if Show Empty Rows is checked')
            if configSettings.general.showFriendlies then
                configSettings.general.friendlyRowColor = ImGui.ColorEdit4("Friendly Row Color",
                    configSettings.general.friendlyRowColor, settings_coloredit_flags)
                ImGui.SameLine()
                ImGui.HelpMarker('Background color of rows containing friendly targets')
            end
            configSettings.general.AdvToolTip = ImGui.Checkbox("Advanced Tooltips", configSettings.general.AdvToolTip)
            ImGui.SameLine()
            ImGui.HelpMarker('Show advanced tooltips for each row')
            if configSettings.general.showFriendlies then
                configSettings.general.friendlyTargetRowColor = ImGui.ColorEdit4("Targeted Friendly Row Color",
                    configSettings.general.friendlyTargetRowColor, settings_coloredit_flags)
                ImGui.SameLine()
                ImGui.HelpMarker('Background color of row containing friendly target that you are targetting')
            end
            configSettings.general.targetRowColor = ImGui.ColorEdit4("Target Row",
                configSettings.general.targetRowColor, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Background color of row containing your current NPC target')
        end
        if ImGui.CollapsingHeader('Health') then
            ImGui.PushItemWidth(35)
            configSettings.hp.highThreshold = ImGui.InputInt('High HP %', configSettings.hp.highThreshold, 0)
            ImGui.SameLine()
            ImGui.HelpMarker('Threshold over which HP will be considered "high"')
            configSettings.hp.lowThreshold = ImGui.InputInt('Low HP %', configSettings.hp.lowThreshold, 0)
            ImGui.SameLine()
            ImGui.HelpMarker('Threshold under which HP will be considered "low"')
            ImGui.PopItemWidth()
            configSettings.hp.hpAsBar = ImGui.Checkbox("Show Health as Progress Bar", configSettings.hp.hpAsBar)
            ImGui.SameLine()
            ImGui.HelpMarker('Show health column as text or a progress bar')
            configSettings.hp.colorNPCHigh = ImGui.ColorEdit4("High NPC Health", configSettings.hp.colorNPCHigh,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for "high" health on a row containing a NPC')
            configSettings.hp.colorNPCMid = ImGui.ColorEdit4("Mid NPC Health", configSettings.hp.colorNPCMid,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for health on a NPC that falls below high but above low')
            configSettings.hp.colorNPCLow = ImGui.ColorEdit4("Low NPC Health", configSettings.hp.colorNPCLow,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for "low" health on a row containing a NPC')
            configSettings.hp.colorPCHigh = ImGui.ColorEdit4("High PC Health", configSettings.hp.colorPCHigh,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for "high" health on a row containing a PC')
            configSettings.hp.colorPCMid = ImGui.ColorEdit4("Mid PC Health", configSettings.hp.colorPCMid,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for health on a PC that falls below high but above low')
            configSettings.hp.colorPCLow = ImGui.ColorEdit4("Low PC Health", configSettings.hp.colorPCLow,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color for "low" health on a row containing a PC')
        end
        if ImGui.CollapsingHeader('Slow') then
            ImGui.PushItemWidth(35)
            configSettings.slow.pctThreshold = ImGui.InputInt('Slow % Threshold',
                configSettings.slow.pctThreshold, 0)
            ImGui.SameLine()
            ImGui.HelpMarker('Threshold of slow % to be considered "max slow"')
            ImGui.PopItemWidth()
            configSettings.slow.colorMax = ImGui.ColorEdit4("Max Slow", configSettings.slow.colorMax,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color when at max slow %')
            configSettings.slow.colorMid = ImGui.ColorEdit4("Mid Slow", configSettings.slow.colorMid,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color when slowed but not at max slow %')
            configSettings.slow.colorNone = ImGui.ColorEdit4("No Slow", configSettings.slow.colorNone,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color when not slowed')
        end
        if ImGui.CollapsingHeader('Aggro') then
            configSettings.aggro.aggroAsBar = ImGui.Checkbox("Show Aggro as Progress Bar",
                configSettings.aggro.aggroAsBar)
            ImGui.SameLine()
            ImGui.HelpMarker('Show aggro column as text or a progress bar')
            configSettings.aggro.colorHave = ImGui.ColorEdit4("Have Aggro", configSettings.aggro.colorHave,
                settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color when you have aggro')
            configSettings.aggro.colorNot = ImGui.ColorEdit4("Do Not Have Aggro",
                configSettings.aggro.colorNot, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Color when you do not have aggro')
        end
        if ImGui.CollapsingHeader('Distance') then
            ImGui.PushItemWidth(50)
            configSettings.distance.close = ImGui.InputInt('Close Range', configSettings
                .distance.medium, 0)
            ImGui.SameLine()
            ImGui.HelpMarker('Range at which target is considered close range')
            configSettings.distance.medium = ImGui.InputInt('Medium Range', configSettings
                .distance.medium, 0)
            ImGui.SameLine()
            ImGui.HelpMarker('Range at which target is considered medium range')
            ImGui.PopItemWidth()
            configSettings.distance.colorClose = ImGui.ColorEdit4("Close Range",
                configSettings.distance.colorClose, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color for target in close range')
            configSettings.distance.colorMid = ImGui.ColorEdit4("Medium Range",
                configSettings.distance.colorMid, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color for target at medium range')
            configSettings.distance.colorFar = ImGui.ColorEdit4("Long Range",
                configSettings.distance.colorFar, settings_coloredit_flags)
            ImGui.SameLine()
            ImGui.HelpMarker('Text color for target at long range')
        end
        ImGui.EndChild()
    end
    ImGui.End()
end

settings.loadSettings = function()
    
    local configData, err = loadfile(mq.configDir .. '/' .. settings.configPath)
    if err then
        settings.createConfig()
    elseif configData then
        configSettings = configData()
        settings.checkConfig()
    end
    settings.loadTheme()
    settings.initSettings()
end

return settings