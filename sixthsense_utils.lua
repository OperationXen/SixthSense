-- Utility functions 

-- Check to see if a string starts with a second string
function starts_with(str, start)
   return str:sub(1, #start) == start
end

-- Helper function, from a unit id pull out and process target information
function get_target_information(unit_id)
	if UnitExists(unit_id) and 
		(not UnitIsFriend("player", unit_id)) then							-- we're only interested in hostile player's targetting decisions
		
		target_guid = UnitGUID(unit_id .. "target")							-- get the GUID of the new target
		return target_guid
	else
		return nil
	end
end

-- Checks that the target guid represents a friendly player
function GUIDIsFriendlyPlayer(target_guid)
	if target_guid == nil then
		return false
	elseif (not starts_with(target_guid, "Player")) then					-- Don't bother if the GUID isn't at least a player ID
		return false
	end
	
	className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID(target_guid)
	if UnitExists(name) and UnitIsFriend("player", name) then
		return true
	else
		return false
	end
end