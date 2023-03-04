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


local ui = {}

local text_setup = {
    locked = true,
    draw_flags = 0x10,
    background = 
    T{
        visible = false,
    },
    right_justified = true,
}

local images_setup = {
    locked = true,
}

-- ui variables
ui.background = images:new(images_setup)

ui.hp_bar = images:new(images_setup)
ui.mp_bar = images:new(images_setup)
ui.tp_bar = images:new(images_setup)

ui.hp_text = texts:new(text_setup)
ui.mp_text = texts:new(text_setup)
ui.tp_text = texts:new(text_setup)

-- setup images
function setup_image(image, path)
    image.texture = path
    image.visible = true;
    image.can_focus = false;
    image.locked = true;
    image.lockedz = true;
end

-- setup text
function setup_text(text, theme_options)
    text.font = theme_options.font
    text:SetFontHeight(theme_options.font_size)
    text.color = tonumber(string.format('%02x%02x%02x%02x', 255, theme_options.font_color_red, theme_options.font_color_green, theme_options.font_color_blue), 16);
    text.draw_flags = 0x10;
    text.color_outline = 0xFF000000
    text.visible = true;
end

-- load the images and text
function ui:load(theme_options)
    setup_image(self.background, theme_options.bar_background)
    setup_image(self.hp_bar, theme_options.bar_hp)
    setup_image(self.mp_bar, theme_options.bar_mp)
    setup_image(self.tp_bar, theme_options.bar_tp)
    setup_text(self.hp_text, theme_options)
    setup_text(self.mp_text, theme_options)
    setup_text(self.tp_text, theme_options)

    self:position(theme_options)
end

-- position the images and text
function ui:position(theme_options)
    local x = AshitaCore:GetConfigurationManager():GetFloat('boot', 'ffxi.registry', '0001', 1024) / 2 - (theme_options.total_width / 2) + theme_options.offset_x
    local y = AshitaCore:GetConfigurationManager():GetFloat('boot', 'ffxi.registry', '0002', 768) - 60 + theme_options.offset_y

    self.background.position_x = x
    self.background.position_y = y

    self.hp_bar.position_x = x + 15 + theme_options.bar_offset
    self.hp_bar.position_y = y + 2
    self.mp_bar.position_x = x + 25 + theme_options.bar_offset + theme_options.bar_width + theme_options.bar_spacing
    self.mp_bar.position_y = y + 2
    self.tp_bar.position_x = x + 35 + theme_options.bar_offset + (theme_options.bar_width*2) + (theme_options.bar_spacing*2)
    self.tp_bar.position_y = y + 2

    self.hp_text.position_x = x + 65 + theme_options.text_offset
    self.hp_text.position_y = self.background.position_y + 2
    self.mp_text.position_x = x + 80 + theme_options.text_offset + theme_options.bar_width + theme_options.bar_spacing
    self.mp_text.position_y = self.background.position_y + 2
    self.tp_text.position_x = x + 90 + theme_options.text_offset + (theme_options.bar_width*2) + (theme_options.bar_spacing*2)
    self.tp_text.position_y = self.background.position_y + 2
end

-- hide ui
function ui:hide()
    self.background.visible = false
    self.hp_bar.visible = false
    self.hp_text.visible = false
    self.mp_bar.visible = false
    self.mp_text.visible = false
    self.tp_bar.visible = false
    self.tp_text.visible = false
end

-- show ui
function ui:show()
    self.background.visible = true
    self.hp_bar.visible = true
    self.hp_text.visible = true
    self.mp_bar.visible = true
    self.mp_text.visible = true
    self.tp_bar.visible = true
    self.tp_text.visible = true
end

return ui