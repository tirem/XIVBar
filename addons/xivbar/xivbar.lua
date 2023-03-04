--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Addon description
addon.name = 'xivbar'
addon.author = ' Tirem (Rework) Edeon (Original)'
addon.version = '1.0'

-- Libs
config = require('settings');
texts  = require('fonts')
images = require('primitives')
gStatusHelpers = require('status.statushelpers');

-- User settings
local defaults = require('defaults')
local settings = config.load(defaults);

config.register('settings', 'settings_update', function (s)
    if (s ~= nil) then
        config.save();
    end
end);


-- Load theme options according to settings
local theme = require('theme')
local theme_options = theme.apply(settings)

-- Addon Dependencies
local ui = require('ui')
local player = require('player')
local xivbar = require('variables')

-- initialize addon
function initialize()
    ui:load(theme_options)

    local ashitaParty = AshitaCore:GetMemoryManager():GetParty();
    local ashitaPlayer = AshitaCore:GetMemoryManager():GetPlayer();
	
    if ashitaPlayer ~= nil and ashitaParty ~= nil then
        player.hpp = math.clamp(ashitaParty:GetMemberHPPercent(0), 0, 100);
        player.mpp = math.clamp(ashitaParty:GetMemberMPPercent(0), 0, 100);
        player.current_hp = ashitaParty:GetMemberHP(0);
        player.current_mp = ashitaParty:GetMemberMP(0);
        player.current_tp = ashitaParty:GetMemberTP(0);

        player:calculate_tpp()

        xivbar.initialized = true
    end
end

-- update a bar
function update_bar(bar, text, width, current, pp, flag)
    local old_width = width
    local new_width = math.floor((pp / 100) * theme_options.bar_width)

    if new_width ~= nil and new_width >= 0 then
        if old_width == new_width then
            if new_width == 0 then
                bar.visible = false
            end

            if flag == 1 then
                xivbar.update_hp = false
            elseif flag == 2 then
                xivbar.update_mp = false
            elseif flag == 3 then
                xivbar.update_tp = false
            end
        else
            local x = old_width

            if old_width < new_width then
                x = old_width + math.ceil((new_width - old_width) * 0.1)

                x = math.min(x, theme_options.bar_width)
            elseif old_width > new_width then
                x = old_width - math.ceil((old_width - new_width) * 0.1)

                x = math.max(x, 0)
            end

            if flag == 1 then
                xivbar.hp_bar_width = x
            elseif flag == 2 then
                xivbar.mp_bar_width = x
            elseif flag == 3 then
                xivbar.tp_bar_width = x
            end

            bar.width = x;
            bar.height = theme_options.total_height;
            bar.visible = true;
        end
    end

    if flag == 3 and current < 1000 then
        text.color = tonumber(string.format('%02x%02x%02x%02x', theme_options.dim_tp_bar and 100 or 255, theme_options.full_tp_color_red, theme_options.full_tp_color_green, theme_options.full_tp_color_blue), 16);
    else
        text.color = tonumber(string.format('%02x%02x%02x%02x', 255, theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue), 16);
    end

    text:SetText(tostring(current))
end

-- hide the addon
function hide()
    ui:hide()
    xivbar.ready = false
end

-- show the addon
function show()
    if xivbar.initialized == false then
        initialize()
    end

    ui:show()
    xivbar.ready = true
    xivbar.update_hp = true
    xivbar.update_mp = true
    xivbar.update_tp = true
end


-- Bind Events
-- ON LOAD
ashita.events.register('load', 'load_cb', function ()
    if gStatusHelpers.GetGameInterfaceHidden() == false then
        initialize()
        show()
    end
end)

local function CheckVitals()
    local ashitaParty = AshitaCore:GetMemoryManager():GetParty();
    local ashitaPlayer = AshitaCore:GetMemoryManager():GetPlayer();
	
    if ashitaPlayer ~= nil and ashitaParty ~= nil then

        local currentHpp = math.clamp(ashitaParty:GetMemberHPPercent(0), 0, 100);
        if (player.hpp ~= currentHpp) then
            player.hpp = currentHpp
            xivbar.update_hp = true
        end

        local currentMpp = math.clamp(ashitaParty:GetMemberMPPercent(0), 0, 100);
        if (player.mpp ~= currentMpp) then
            player.mpp = currentMpp
            xivbar.update_mp = true
        end

        local current_hp = ashitaParty:GetMemberHP(0);
        if (player.current_hp ~= current_hp) then
            player.current_hp = current_hp
            xivbar.update_hp = true
        end

        local current_mp = ashitaParty:GetMemberMP(0);
        if (player.current_mp ~= current_mp) then
            player.current_mp = current_mp
            xivbar.update_mp = true
        end

        local current_tp = ashitaParty:GetMemberTP(0);
        if (player.current_tp ~= current_tp) then
            player.current_tp = current_tp
            player:calculate_tpp()
            xivbar.update_tp = true
        end
    end
end

ashita.events.register('d3d_present', 'present_cb', function ()

    -- handle hiding bars
    if xivbar.hide_bars == false and gStatusHelpers.GetGameInterfaceHidden() == true then
        xivbar.hide_bars = true
        hide()
    elseif xivbar.hide_bars == true and gStatusHelpers.GetGameInterfaceHidden() == false then
        xivbar.hide_bars = false
        show()
    end

    CheckVitals();

    if xivbar.ready == false then
        return
    end

    if xivbar.update_hp then
        update_bar(ui.hp_bar, ui.hp_text, xivbar.hp_bar_width, player.current_hp, player.hpp, 1)
    end

    if xivbar.update_mp then
        update_bar(ui.mp_bar, ui.mp_text, xivbar.mp_bar_width, player.current_mp, player.mpp, 2)
    end

    if xivbar.update_tp then
        update_bar(ui.tp_bar, ui.tp_text, xivbar.tp_bar_width, player.current_tp, player.tpp, 3)
    end
end)