-- Class definition for the state model class, holds a representation of who is targeting members of your raid
SixthSense_StateModel = {}
SixthSense_StateModel.__index = SixthSense_StateModel

-- Build a new statemodel, adding all party members to it
function SixthSense_StateModel:new()
	local self = {}
	self.model = {}
	setmetatable(self, SixthSense_StateModel);
	
	self:add_unit("player")							-- we're always going to have a player unit
	for i = 1, 9 do
		unit_id = "party" .. i
		if UnitExists(unit_id) then					-- but we may or may not have a party
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
		for hostile_unit_guid, hostile_unit_id in pairs(data.targeted_by) do
			if not UnitExists(hostile_unit_id) then								-- if the unit no longer exists
				self:remove_specific(unit_id, hostile_unit_guid)				-- remove it from the model
			elseif hostile_unit_guid ~= UnitGUID(hostile_unit_id) then			-- if the unit occupying this unit ID has changed
				self:remove_specific(unit_id, hostile_unit_guid)				-- remove it immediately
			elseif data.guid ~= get_target_GUID(hostile_unit_id) then			-- if the units target has changed
				self:remove_specific(unit_id, hostile_unit_guid)				-- then remove it, its no longer targeting this unit
			end
		end
	end
end

-- helper function, adds a unit to the model
function SixthSense_StateModel:add_unit(unit_id)
	self.model[unit_id] = {}
	self.model[unit_id].guid = UnitGUID(unit_id)
	self.model[unit_id].targeted_by = {}
end

-- helper function, removes a unit from the model
function SixthSense_StateModel:remove_unit(unit_id)
	self.model[unit_id] = nil											-- this is apparently "the way its done" in LUA...
end

-- Search through the model for any instance of the hostile refered to by GUID, and remove them
function SixthSense_StateModel:remove_targeting_hostile(hostile_unit_guid)
	local model_changed = false

	for unit_id, data in pairs(self.model) do							-- Iterate through each friendly we're tracking
		if data.targeted_by[hostile_unit_guid] ~= nil then				-- if the list of hostiles targeting it contains the guid in question
			self.model[unit_id].targeted_by[hostile_unit_guid] = nil	-- remove it from the list (note we're operating on the model directly)
			model_changed = true										-- now that we've made a change, perhaps need to do an update
		end
	end
	return model_changed
end

-- add a hostile to the list of people currently targeting the friendly refered to by key
function SixthSense_StateModel:add_targeting_hostile(friendly_unit_id, hostile_unit_id, guid)
	local model_changed = false
	
	if self.model[friendly_unit_id] == nil then							-- check that we have a unit in our model that corresponds
		return model_changed											-- TODO add new friendly unit to model?
	end
	if self.model[friendly_unit_id].targeted_by[guid] == nil then			-- check that the data we're adding isn't in the model already	
		self.model[friendly_unit_id].targeted_by[guid] = hostile_unit_id	-- add the hostile guid to the list of targeting units
		model_changed = true												-- we've made changes
	end
	return model_changed
end

-- checks to see if a given hostile is listed as targeting a given tracked unit
function SixthSense_StateModel:is_targeted_by(unit_id, hostile_unit_guid)
	if self.model[unit_id].targeted_by[hostile_unit_guid] == nil then
		return false
	else
		return true
	end
end

-- Process the information we've gathered, updating the model
function SixthSense_StateModel:process_targetting_event(targeting_unit_id, target_guid)
	-- sanity check first, target_guid exists and is a player
	if (target_guid == nil) then			
		return
	end
	
	hostile_unit_guid = UnitGUID(targeting_unit_id)		
	
	-- step through each friendly unit in the model
	for friendly_unit_id, data in pairs(self.model) do						
		if data.guid == target_guid	then				-- only process if targeted unit is in the model
			-- check to see if this is already reflected in the model
			if self:is_targeted_by(friendly_unit_id, hostile_unit_guid) then
				return									-- if its already there, no update needed
			end
			
			-- update model
			-- this hostile isn't now targeting what it was, so we remove it from that user
			-- if it was previously targeting a different friendly in the model, known_hostile will be TRUE
			-- if its a new hostile player barrelling in, known_hostile should be FALSE
			known_hostile = self:remove_targeting_hostile(hostile_unit_guid)
			
			-- update the model to show friendly player now targeted by hostile
			self:add_targeting_hostile(friendly_unit_id, targeting_unit_id, hostile_unit_guid)
			if not known_hostile then
				print_update(friendly_unit_id, hostile_unit_guid)		-- debug output
				-- https://wow.gamepedia.com/API_PlaySound play a sound, perhaps some animation?
			end
									
			print_update(friendly_unit_id, hostile_unit_guid) 	-- debugging line
		end
	end
end
-- #####################################################################################################