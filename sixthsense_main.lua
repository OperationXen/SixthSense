-- Detect enemy player targets
print("SixthSense loaded")

local sixthsense_frame = CreateFrame("Frame")

-- Sweep over all visible enemy nameplates and update the model with their targets
function sixthsense_frame:do_nameplate_sweep()
	for i = 1, 40 do
		unit_id = "nameplate" .. i
		target_guid = get_target_information(unit_id)
		self.target_state:process_target_info(unit_id, target_guid)
	end
end

-- Check the target of the players current target
function sixthsense_frame:do_playertarget_update()
	target_guid = get_target_information("target")
	self.target_state:process_target_info("target", target_guid)
end

-- Scan arena1/2/3 and update the model based on their targets
function sixthsense_frame:do_arenaunit_update()
	for i = 1,3 do
		unit_id = "arena" .. i
		target_guid = get_target_information(unit_id)
		self.target_state:process_target_info(unit_id, target_guid)
	end
end

-- Perform a scan and update the model
function sixthsense_frame:do_update()
	self.target_state:verify_existing_targets()							-- check the current state, remove anyone who's died or not visible anymore
	self:do_playertarget_update()										-- always want to keep on top of the targeted unit
	
	-- scan for new information
	self:do_arenaunit_update()
	self:do_nameplate_sweep()
end

-- Handles all registered events
function sixthsense_frame:event_handler(event, arg1, arg2, arg3, arg4, arg5)
	if (event == "UNIT_TARGET") then
		unit_id = arg1													-- the unit ID of the unit which just switched target (nameplateN, arenaN etc)
		target_guid = get_target_information(unit_id)
		if GUIDIsFriendlyPlayer(target_guid) then
			self.target_state:process_target_info(unit_id, target_guid)
		end
	end
	
	if (event == "GROUP_ROSTER_UPDATE") then							-- when the party changes, we need to update the target model
		-- TODO - this is not the best way to handle this, its a bit of a shortcutty hack
		self.target_state = SixthSense_StateModel.new()					-- easiest way to update the target model is to tear it down and rebuild it...
	end
	
end

-- Called when the underlying API fires the update event
function sixthsense_frame:OnUpdate(elapsed_time)
	if self.time_since_update == nil then
		self.time_since_update = 0
	end
	self.time_since_update = self.time_since_update + elapsed_time
	
	if self.time_since_update > 0.5 then
		self.time_since_update = 0
		self:do_update()
	end
end

sixthsense_frame.target_state = SixthSense_StateModel.new()

-- Register events needed
sixthsense_frame:RegisterEvent("GROUP_ROSTER_UPDATE")					-- need to know when player's group situation changes
sixthsense_frame:RegisterEvent("UNIT_TARGET")							-- update when we see someone's target change
-- Register handlers
sixthsense_frame:SetScript("OnEvent", sixthsense_frame.event_handler)	-- lodge our event handler function to deal with events fired
sixthsense_frame:SetScript("OnUpdate", sixthsense_frame.OnUpdate)		-- logdge our periodic handler to be called repeatedly