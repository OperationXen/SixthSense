-- test

-- Class definition for the state model class, holds a representation of who is targeting members of your raid
SixthSense_StateModel = {}
SixthSense_StateModel.__index = SixthSense_StateModel
function SixthSense_StateModel:new()
	local self = {}
	self.model = {}
	setmetatable(self, SixthSense_StateModel);
	
	self:add_unit("player")												-- we're always going to have a player unit
	for i = 1, 4 do
		unit_id = "party" .. i
		if UnitExists(unit_id) then										-- but we may or may not have a party
			self:add_unit(unit_id)
		end
	end
	return self
end

function SixthSense_StateModel:remove_specific(unit_id, hostile_unit_guid)
	print(unit_id .. " is no longer targeted by " .. hostile_unit_guid)
	self.model[unit_id].hostiles[hostile_unit_guid] = nil
end

-- Scan through the current state, check it's still valid and remove anything inaccurate
function SixthSense_StateModel:verify_existing_targets()
	for unit_id, data in pairs(self.model) do
		for hostile_unit_guid, hostile_unit_id in pairs(data.hostiles) do
			if not UnitExists(hostile_unit_id) then								-- if the unit no longer exists
				self:remove_specific(unit_id, hostile_unit_guid)				-- remove it from the model
			elseif hostile_unit_guid ~= UnitGUID(hostile_unit_id) then			-- if the unit occupying this unit ID has changed
				self:remove_specific(unit_id, hostile_unit_guid)				-- remove it immediately
			elseif data.guid ~= get_target_information(hostile_unit_id) then	-- if the units target has changed
				self:remove_specific(unit_id, hostile_unit_guid)				-- then remove it, its no longer targeting this unit
			end
		end
	end
end

-- helper function, adds a unit to the model
function SixthSense_StateModel:add_unit(unit_id)
	self.model[unit_id] = {}
	self.model[unit_id].guid = UnitGUID(unit_id)
	self.model[unit_id].hostiles = {}
end

-- helper function, removes a unit from the model
function SixthSense_StateModel:remove_unit(unit_id)
	self.model[unit_id] = nil											-- this is apparently "the way its done" in LUA...
end

-- Search through the model for any instance of the hostile refered to by GUID, and remove them
function SixthSense_StateModel:remove_targeting_hostile(hostile_unit_guid)
	local model_changed = false

	for unit_id, data in pairs(self.model) do							-- Iterate through each friendly we're tracking
		if data.hostiles[hostile_unit_guid] ~= nil then					-- if the list of hostiles targeting it contains the guid in question
			self.model[unit_id].hostiles[hostile_unit_guid] = nil		-- remove it from the list (note we're operating on the model directly
			model_changed = true										-- note that we've made a change, perhaps need to do an update
		end
	end
	return model_changed
end

-- add a hostile to the list of people currently targeting the friendly refered to by key
function SixthSense_StateModel:add_targeting_hostile(friendly_unit_id, hostile_unit_id, guid)
	local model_changed = false
	
	if self.model[friendly_unit_id] == nil then							-- check that we have a unit in our model that corresponds
		return model_changed											-- TODO add unit to model?
	end
	if self.model[friendly_unit_id].hostiles[guid] == nil then			-- check that we're not about to attempt to duplicate information	
		self.model[friendly_unit_id].hostiles[guid] = hostile_unit_id	-- add the hostile guid to the list of targeting units
		model_changed = true											-- we've made changes
	end
	return model_changed
end

-- checks to see if a given hostile is listed as targeting a given tracked unit
function SixthSense_StateModel:is_targeted_by(unit_id, hostile_unit_guid)
	if self.model[unit_id].hostiles[hostile_unit_guid] == nil then
		return false
	else
		return true
	end
end

-- Process the information we've gathered, updating the model
function SixthSense_StateModel:process_target_info(targeting_unit_id, target_guid)
	if (target_guid == nil) then												-- sanity check first, target_guid exists and is a player
		return
	end
	hostile_unit_guid = UnitGUID(targeting_unit_id)								-- convert the targeting unit into a GUID
	
	for friendly_unit_id, data in pairs(self.model) do						
		if data.guid == target_guid	then										-- if the target_guid matches someone in our model
			if self:is_targeted_by(friendly_unit_id, hostile_unit_guid) then	-- check to see if this is already reflected in the model
				return
			end
			
			self:remove_targeting_hostile(hostile_unit_guid)					-- update model, this hostile isn't targeting anything else
			self:add_targeting_hostile(friendly_unit_id, targeting_unit_id, hostile_unit_guid)		-- update model, friendly player now targetted by hostile
						
			print_update(friendly_unit_id, hostile_unit_guid)
		end
	end
end
-- #####################################################################################################