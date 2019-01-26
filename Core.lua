local me = CreateFrame('ScrollFrame', "SunderstruckFrame", UIParent, "Sunderstruck_Frame")
me:SetScript('OnUpdate', function() me.UPDATE() end)
me:SetScript('OnEvent', function() me.EVENT() end)
me:RegisterEvent('VARIABLES_LOADED')
me:RegisterEvent('CHAT_MSG_SPELL_FAILED_LOCALPLAYER')
me:RegisterEvent('CHAT_MSG_SPELL_SELF_DAMAGE')
me:RegisterEvent('CHAT_MSG_ADDON')

_G = getglobal
if Sunderstruck_Vars == nil then
    Sunderstruck_Vars = {}
    Sunderstruck_Vars.hide = false
    Sunderstruck_Vars.lock = false
    Sunderstruck_Vars.alpha = 0.3
    Sunderstruck_Vars.row_alpha = 0.5
end

-- Wait time for errors after sunder cast
local ERROR_WAIT_TIME = 0.25

local sunder_cast_time = nil
local err_cant_cast = false
local err_missed = false


function me.EVENT()
    if event == 'VARIABLES_LOADED' then
        me.check_hide()
        me.check_lock()
        me.check_alpha()
        me.check_row_alpha()
        
        _G(me:GetName() .. "_Rows"):SetAllPoints(me)
        
        me.print("loaded - type '/ss' for additional info")
    elseif event == 'CHAT_MSG_SPELL_FAILED_LOCALPLAYER' then
        err_cant_cast = true
    elseif event == 'CHAT_MSG_SPELL_SELF_DAMAGE' then
        err_missed = true
    elseif event == 'CHAT_MSG_ADDON' and arg1 == "Sunderstruck" then
        me.newsunder(arg4, arg2)
    end
end

function me.UPDATE()
    if sunder_cast_time then
        if err_cant_cast or err_missed or GetTime() - sunder_cast_time >= ERROR_WAIT_TIME then
            sunder_cast_time = nil
            -- not Out of range / out of rage / etc...
            if not err_cant_cast then
                if GetNumRaidMembers() > 0 then
                    SendAddonMessage("Sunderstruck", tostring(err_missed), "RAID")
                elseif GetNumPartyMembers() > 0 then
                    SendAddonMessage("Sunderstruck", tostring(err_missed), "PARTY")
                else
                    me.newsunder(UnitName("player"), tostring(err_missed))
                end
            end
            err_cant_cast = false
            err_missed = false
        end
    else
        err_cant_cast = false
        err_missed = false 
    end
end

local last_frame = 0
function me.newsunder(caster, missed)
    -- move rows down
    for i=1,20 do
        local row = _G(me:GetName() .. "_Rows" .. i)
        _, _, _, _, yOfs = row:GetPoint()
        row:SetPoint("TOPLEFT", 0, yOfs-20)
    end

    -- reuse last row    
    last_frame = last_frame > 19 and 1 or last_frame + 1
    local last_row = _G(me:GetName() .. "_Rows" .. last_frame)
    _G(last_row:GetName() .. "_Name"):SetText(caster)
    if missed == "true" then
        _G(last_row:GetName() .. "_Background"):SetTexture(1,0,0,Sunderstruck_Vars.row_alpha)
    else
        _G(last_row:GetName() .. "_Background"):SetTexture(0,1,0,Sunderstruck_Vars.row_alpha)
    end
    last_row:SetPoint("TOPLEFT", 0, 0)
    last_row:Show()
end

me.savedaddsunderthreat = klhtm.combat.addsunderthreat
me.addsunderthreat = function()
    sunder_cast_time = GetTime()
    me.savedaddsunderthreat()
end
klhtm.combat.addsunderthreat = me.addsunderthreat

function me.print(msg)
    if DEFAULT_CHAT_FRAME and msg then
        DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<sunderstruck> ' .. msg)
    end
end

function me.status(test)
    return test and '|cff00ff00on|r' or '|cffff0000off|r'
end

function me.check_lock()
    if Sunderstruck_Vars.lock then
        me:EnableMouse(false)
        _G(me:GetName() .. "_Resize"):Hide()
    else
        me:EnableMouse(true)
        _G(me:GetName() .. "_Resize"):Show()
    end
end

function me.check_hide()
    if Sunderstruck_Vars.hide then
        me:SetAlpha(0)
        me:EnableMouse(false)
        _G(me:GetName() .. "_Resize"):Hide()
    else
        me:SetAlpha(1)
        me.check_lock()
    end
end

function me.check_alpha()
    _G(me:GetName() .. "_Background"):SetTexture(0,0,0,Sunderstruck_Vars.alpha)
end

function me.check_row_alpha()
    for i=1,20 do
        _G(me:GetName() .. "_Rows" .. i .. "_Background"):SetTexture(0,0,0,Sunderstruck_Vars.row_alpha)
    end
end

SLASH_SUNDERSTRUCK1 = '/ss'
function SlashCmdList.SUNDERSTRUCK(msg)
    if not msg then return end

    local _,_,cmd,arg = string.find(msg,"([%w%p]+)%s*(.*)$");

    if cmd == 'lock' then
        Sunderstruck_Vars.lock = not Sunderstruck_Vars.lock
        me.check_lock()
    elseif cmd == 'hide' then
        Sunderstruck_Vars.hide = not Sunderstruck_Vars.hide
        me.check_hide()
    elseif cmd == 'alpha' and tonumber(arg) then
        arg = tonumber(arg)
        arg = arg > 1 and 1 or (arg < 0 and 0 or arg)
        Sunderstruck_Vars.alpha = arg
        me.check_alpha()
    elseif cmd == 'row_alpha' and tonumber(arg) then
        arg = tonumber(arg)
        arg = arg > 1 and 1 or (arg < 0 and 0 or arg)
        Sunderstruck_Vars.row_alpha = arg
        me.check_row_alpha()
    elseif cmd == 'test' then
        last_frame = 0
        for i=20,1,-1 do
            local row = _G(me:GetName() .. "_Rows" .. i)
            row:SetPoint("TOPLEFT", me, "TOPLEFT", 0, (20-i)*(-20))
            row:Show()
        end
    elseif cmd == 'clear' then
        last_frame = 0
        for i=1,20 do
            local row = _G(me:GetName() .. "_Rows" .. i)
            row:SetPoint("TOPLEFT", me, "TOPLEFT", 0, 0)
            row:Hide()
        end
    else
        me.print('Usage:')
        me.print('- hide [' .. me.status(Sunderstruck_Vars.hide) .. ']')
        me.print('- lock [' .. me.status(Sunderstruck_Vars.lock) .. ']')
        me.print('- alpha <0-1> [|cff444444' .. Sunderstruck_Vars.alpha .. '|r]')
        me.print('- row_alpha <0-1> [|cff444444' .. Sunderstruck_Vars.row_alpha .. '|r]')
        me.print('- test')
        me.print('- clear')
    end
end
