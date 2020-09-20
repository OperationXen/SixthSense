-- Contains Ace stuff for creating addon

SixthSense = LibStub("AceAddon-3.0"):NewAddon("SixthSense", "AceConsole-3.0", "AceEvent-3.0")
AceGUI = LibStub("AceGUI-3.0")

-- Called when the addon is initialised - ie at load time
function SixthSense:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SixthSense", configuration_options)
	self.options_db = LibStub("AceDB-3.0"):New("SixthSenseDB", defaults, true)
	
	-- Add an options menu
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SixthSense", "Sixth Sense")
	
	-- add two shortcuts for chat box commands - "sixthsense" or "6s"
	self:RegisterChatCommand("sixthsense", "ChatCommand")
	self:RegisterChatCommand("6s", "ChatCommand")
end

-- Called when the addon is enabled, so when the UI loads
function SixthSense:OnEnable()
	self.StateModel = SixthSense_StateModel.new()	-- create a new model, getting current party state
	self.UIFrames = SixthSense_GUI.new()			-- Create the frames to hold the UI

	self:RegisterEvent("UNIT_TARGET")				-- A unit we can see has changed its target
	self:RegisterEvent("GROUP_ROSTER_UPDATE")		-- The player's group / raid has changed
	
	self.UIFrames.Initialise()
	self.UIFrames.CreateTestFrame()
	-- self:UpdateFrames()								-- do the UI draw
end

function SixthSense:OnDisable()
    -- Called when the addon is disabled
end

-- Handles a user doing /sixthsense slash command
function SixthSense:ChatCommand(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)		-- first time it opens the wrong thing,
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)		-- calling this twice is a known workaround...
																	-- Yeah, I know.
	else
		-- extended options
		LibStub("AceConfigCmd-3.0"):HandleCommand("sixthsense", "SixthSense", input)
	end
end
-- ------------------------------------------------------------------------ --

-- event handlers
function SixthSense:UNIT_TARGET(unit_id)
	-- Called when unit changes target, param is unit ID eg "nameplateN", "arenaN"
	target_guid = get_target_GUID(unit_id)			-- Get the GUID of the target of the specified unit
	if GUIDIsFriendlyPlayer(target_guid) then		-- Only interested when target is friendly
		self.StateModel:process_targetting_event(unit_id, target_guid)
	end
end

function SixthSense:GROUP_ROSTER_UPDATE()
	-- TODO creating a new model is an inefficient approach
	self.StateModel = SixthSense_StateModel.new()		-- easiest way to update the target model is to tear it down and rebuild it...
end

-- ------------------------*------------------------------------------------ --

-- Check the target of the players current target
function SixthSense:do_playertarget_update()
	target_guid = get_target_GUID("target")			-- get the GUID of players current target's target
	self.StateModel:process_targetting_event("target", target_guid)
end

-- Scan arena1/2/3 and update the model based on their targets
function SixthSense:do_arenaunit_update()
	for i = 1,3 do
		unit_id = "arena" .. i
		target_guid = get_target_GUID(unit_id)
		self.StateModel:process_targetting_event(unit_id, target_guid)
	end
end

-- Sweep over all visible enemy nameplates and update the model with their targets
function SixthSense:do_nameplate_sweep()
	for i = 1, 40 do
		unit_id = "nameplate" .. i
		target_guid = get_target_GUID(unit_id)
		self.StateModel:process_targetting_event(unit_id, target_guid)
	end
end

function SixthSense:do_update()
	print("updating...")
	self:PerformScan()
end

function SixthSense:PerformScan()
	self.StateModel:verify_existing_targets()			-- check the current state, remove anyone who's died or not visible anymore
	self:do_playertarget_update()						-- always want to keep on top of the targeted unit's target
	
	-- scan for new information
	self:do_arenaunit_update()
	self:do_nameplate_sweep()
end

-- Called when the underlying API fires the update event
function SixthSense:OnUpdate(elapsed_time)
	if self.time_since_update == nil then
		self.time_since_update = 0
	end
	self.time_since_update = self.time_since_update + elapsed_time
	
	if self.time_since_update > self.options_db.char.update_frequency then	-- check if the update period has expired or not
		self.time_since_update = 0											-- reset the counter
		self:do_update()
	end
end

-- not used
function SixthSense:UpdateFrames()
	print("redrawing...")
	unit_id = "player"
	
	if self.options_db.profile.active_solo then
		local x_pos = self.options_db.profile.frame_loc[unit_id].x
		local y_pos = self.options_db.profile.frame_loc[unit_id].y
		self.frames[unit_id] = self:CreateTargetFrame(unit_id, x_pos, y_pos)
	end
end
