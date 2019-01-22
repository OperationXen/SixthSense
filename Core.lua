-- Contains Ace stuff for creating addon

SixthSense = LibStub("AceAddon-3.0"):NewAddon("SixthSense", "AceConsole-3.0", "AceEvent-3.0")

-- Called with the addon is initialised - ie at load time
function SixthSense:OnInitialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SixthSense", SixthSense_options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SixthSense", "Sixth Sense")
	self:RegisterChatCommand("sixthsense", "ChatCommand")
	self:RegisterChatCommand("6s", "ChatCommand")
	SixthSense.message = "I see pwnd people..."
end

-- Called when the addon is enabled, so when the UI loads
function SixthSense:OnEnable()
	self.Model = SixthSense_StateModel.new()

	self:RegisterEvent("UNIT_TARGET")				-- A unit we can see has changed its target
	self:RegisterEvent("GROUP_ROSTER_UPDATE")		-- The player's group / raid has changed
end

function SixthSense:OnDisable()
    -- Called when the addon is disabled
end

-- Handles a user doing /sixthsense slash command
function SixthSense:ChatCommand(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	else
		-- extended options
		LibStub("AceConfigCmd-3.0"):HandleCommand("sixthsense", "SixthSense", input)
	end
end
-- ------------------------------------------------------------------------ --

-- event handlers
function SixthSense:UNIT_TARGET(unit_id)
	-- when a unit changes target this function is called, param is unit ID (nameplateN, arenaN etc)
	target_guid = get_target_information(unit_id)
	if GUIDIsFriendlyPlayer(target_guid) then
		self.Model:process_target_info(unit_id, target_guid)
	end
end

function SixthSense:GROUP_ROSTER_UPDATE()
	-- should probably do something to handle group changes a little more efficiently...
	self.target_state = SixthSense_StateModel.new()					-- easiest way to update the target model is to tear it down and rebuild it...
end

-- ------------------------------------------------------------------------ --

-- Check the target of the players current target
function SixthSense:do_playertarget_update()
	target_guid = get_target_information("target")
	self.target_state:process_target_info("target", target_guid)
end

-- Scan arena1/2/3 and update the model based on their targets
function SixthSense:do_arenaunit_update()
	for i = 1,3 do
		unit_id = "arena" .. i
		target_guid = get_target_information(unit_id)
		self.target_state:process_target_info(unit_id, target_guid)
	end
end

-- Sweep over all visible enemy nameplates and update the model with their targets
function SixthSense:do_nameplate_sweep()
	for i = 1, 40 do
		unit_id = "nameplate" .. i
		target_guid = get_target_information(unit_id)
		self.target_state:process_target_info(unit_id, target_guid)
	end
end

function SixthSense:PerformScan()
	self.target_state:verify_existing_targets()							-- check the current state, remove anyone who's died or not visible anymore
	self:do_playertarget_update()										-- always want to keep on top of the targeted unit's target
	
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
	
	if self.time_since_update > 0.5 then								-- check if the update period has expired or not
		self.time_since_update = 0										-- reset the counter
		self:do_update()
	end
end
