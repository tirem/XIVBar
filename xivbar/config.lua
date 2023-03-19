require('common')
local imgui = require('imgui')

local showConfig = false;

-- find all our layouts and strip _alliance and file extensions
-- return a list of all sub directories
---@return table theme_paths
local function get_theme_paths()
    local path = ('%s\\themes'):fmt(addon.path);
    return ashita.fs.get_directory(path);
end 

local function DrawConfigMenu()
	if(imgui.Begin(("xivbar config"), true, ImGuiWindowFlags_AlwaysAutoResize)) then

		-- Use tabs for this config menu
		imgui.BeginTabBar('XivParty Settings Tabs');

		-- General
		if imgui.BeginTabItem('General') then

            local barScale = { settings.Bars.Scale };
			if (imgui.SliderFloat('Bars Scale', barScale, .25, 5, '%.2f')) then
				settings.Bars.Scale = barScale[1];
			end
			imgui.ShowHelp('Scale of the bars');

            if (imgui.Checkbox('Compact Bar', { settings.Theme.Compact })) then
				settings.Theme.Compact = not settings.Theme.Compact;
			end
			imgui.ShowHelp('Use the compact images for this theme');

            if (imgui.Checkbox('Dim TP Bar', { settings.Theme.DimTpBar })) then
				settings.Theme.DimTpBar = not settings.Theme.DimTpBar;
			end
			imgui.ShowHelp('Dim the TP bar when TP is below 1000');

            -- theme
            local theme_paths = get_theme_paths();
            if (imgui.BeginCombo('Theme', settings.Theme.Name)) then
                for i = 1,#theme_paths,1 do
                    local is_selected = i == settings.Theme.Name;

                    if (imgui.Selectable(theme_paths[i], is_selected) and theme_paths[i] ~= settings.Theme.Name) then
                        settings.Theme.Name = theme_paths[i];
                    end

                    if (is_selected) then
                        imgui.SetItemDefaultFocus();
                    end
                end
                imgui.EndCombo();
            end
            imgui.ShowHelp('The theme to use for bar images [xivbar/themes]'); 

            -- font to use
            local fontName = { settings.Texts.Font };
			if imgui.InputText('Font Name', fontName, 999) then
				settings.Texts.Font = fontName[1];
			end
			imgui.ShowHelp('Font to use for text');

            -- Font Settings
			local fontSize = { settings.Texts.Size };
			if (imgui.SliderInt('Font Size', fontSize, 0, 32)) then
				settings.Texts.Size = fontSize[1];
			end
            local fontAlpha = { settings.Texts.Color.Alpha };
			if (imgui.SliderInt('Font Alpha', fontAlpha, 0, 255)) then
				settings.Texts.Color.Alpha = fontAlpha[1];
			end
            local fontRed = { settings.Texts.Color.Red };
			if (imgui.SliderInt('Font Red', fontRed, 0, 255)) then
				settings.Texts.Color.Red = fontRed[1];
			end
            local fontGreen = { settings.Texts.Color.Green };
			if (imgui.SliderInt('Font Green', fontGreen, 0, 255)) then
				settings.Texts.Color.Green = fontGreen[1];
			end
            local fontBlue = { settings.Texts.Color.Blue };
			if (imgui.SliderInt('Font Blue', fontBlue, 0, 255)) then
				settings.Texts.Color.Blue = fontBlue[1];
			end

            -- Stroke Settings
            local strokeWidth = { settings.Texts.Stroke.Width };
			if (imgui.SliderInt('Stroke Width', strokeWidth, 0, 8)) then
				settings.Texts.Stroke.Width = strokeWidth[1];
			end
            local strokeAlpha = { settings.Texts.Stroke.Alpha };
			if (imgui.SliderInt('stroke Alpha', strokeAlpha, 0, 255)) then
				settings.Texts.Stroke.Alpha = strokeAlpha[1];
			end
            local strokeRed = { settings.Texts.Stroke.Red };
			if (imgui.SliderInt('stroke Red', strokeRed, 0, 255)) then
				settings.Texts.Stroke.Red = strokeRed[1];
			end
            local strokeGreen = { settings.Texts.Stroke.Green };
			if (imgui.SliderInt('stroke Green', strokeGreen, 0, 255)) then
				settings.Texts.Stroke.Green = strokeGreen[1];
			end
            local strokeBlue = { settings.Texts.Stroke.Blue };
			if (imgui.SliderInt('stroke Blue', strokeBlue, 0, 255)) then
				settings.Texts.Stroke.Blue = strokeBlue[1];
			end

            -- TP Full Font Settings
            local fullTpRed = { settings.Texts.FullTpColor.Red };
			if (imgui.SliderInt('Full TP Red', fullTpRed, 0, 255)) then
				settings.Texts.FullTpColor.Red = fullTpRed[1];
			end
            local fullTpGreen = { settings.Texts.FullTpColor.Green };
			if (imgui.SliderInt('Full TP Green', fullTpGreen, 0, 255)) then
				settings.Texts.FullTpColor.Green = fullTpGreen[1];
			end
            local fullTpBlue = { settings.Texts.FullTpColor.Blue };
			if (imgui.SliderInt('Full TP Blue', fullTpBlue, 0, 255)) then
				settings.Texts.FullTpColor.Blue = fullTpBlue[1];
			end

			imgui.EndTabItem();
		end
		imgui.EndTabBar();
		imgui.End();
	end
end

ashita.events.register('d3d_present', '__config_present_cb', function ()

    if (showConfig) then
        DrawConfigMenu();
    end

end);

ashita.events.register('command', '__config_command_cb', function (e)
	-- Parse the command arguments
	local command_args = e.command:lower():args()
    if table.contains({'/xivbar', '/xb'}, command_args[1]) then
		-- Toggle the config menu
		showConfig = not showConfig;
		e.blocked = true;
	end
end);