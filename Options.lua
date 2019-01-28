-- getter and setter methods for options table

function SixthSense:GetMessage(info)
	return self.options_db.char.message
end

function SixthSense:SetMessage(info, newVal)
	self.options_db.char.message = newVal
end

function SixthSense:SetFrameXOffset(info, val)
	unit_id = "player"

	self.options_db.profile.frame_loc[unit_id].x = val
	self:UpdateFrames()										-- redraw the frames on save
end	

function SixthSense:SetFrameYOffset(info, val)
	unit_id = "player"
	
	self.options_db.profile.frame_loc[unit_id].y = val
	self:UpdateFrames()
end

defaults = {
    profile = {
		ignore_mobs = true,
		update_frequency = 1,
		
		frame_scale = 2,
		frame_loc = {
			["player"] = { x = 0, y = 0 },
			["party1"] = { x = 0, y = 40 },
			["party2"] = { x = 0, y = 80 },
			["party3"] = { x = 0, y = 120 },
			["party4"] = { x = 0, y = 160 },
		},
    },
}


-- options table for ace_config
SixthSense_options = { 
    name = "Sixth Sense Target Detection",
    handler = SixthSense,
    type = "group",
	
	args = {
		general_settings = {
			name = "General",
			desc = "General Settings",
			type = "group",
			inline = true,
			order = 1,
			
			args = {
				ignore_mobs = {
					name = "Ignore non-player mobs",
					desc = "Description text I guess",
					type = "toggle",
					set = function(info,val) SixthSense.options_db.profile.ignore_mobs = val end,
					get = function(info) return SixthSense.options_db.profile.ignore_mobs end
				},
				update_frequency = {
					name = "Update Speed",
					desc = "Updates per second (may cause high CPU use)",
					type = "select",
					values = {[2] = "Slow (2s)", [1] = "Normal (1s)", [0.5] = "Fast (0.5s)", [0.2] = "v. Fast (0.2s)", [0.1] = "Extreme (0.1s)"},
					set = function(info,val) SixthSense.options_db.profile.update_frequency = val end,
					get = function(info) return SixthSense.options_db.profile.update_frequency end
				},
			},
		},	-- end of general_settings group
		frame_locations = {
			name = "Layout - Solo",
			desc = "Display positions",
			type = "group",
			order = 1,
			args = {
				player_frame_scale = {
					name = "Scale",
					desc = "Frame scale",
					type = "range",
					min = 0.1,
					max = 2.5,
					step = 0.1,
					width = "double",
					get = function(info) return SixthSense.options_db.profile.frame_scale end,
					set = function(info, val) SixthSense.options_db.profile.frame_scale = val end
				},
				frame_x_location = {
					name = "X - Axis Offset",
					desc = "Horizonal Offset",
					width = "full",
					type = "range",
					min = -2500,
					max = 2500,
					softMin = -800,
					softMax = 800,
					step = 1,
					unit_id = "player",		-- putting this here to be passed into Set function via info param
					-- arrays start at 0. Fuck LUA.
					get = function(info) return SixthSense.options_db.profile.frame_loc.player.x end,
					set = "SetFrameXOffset"
				},
				frame_y_location = {
					name = "Y - Axis Offset",
					desc = "Vertical Offset",
					width = "full",
					type = "range",
					min = -2500,
					max = 2500,
					softMin = -800,
					softMax = 800,
					step = 1,
					-- arrays start at 0. Fuck LUA.
					get = function(info) return SixthSense.options_db.profile.frame_loc.player.y end,
					set = function(info, val) SixthSense.options_db.profile.frame_loc.player.y = val end
				},
				
			},
		},	-- end of frame_locations group		
	},
}