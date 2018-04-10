local function GetPlayerIdentifer (source, ident, _sub)
 	local len
	local identifiers

    if ident == nil then return end

	identifiers = GetPlayerIdentifiers(source)

    if _sub then 
    	len = string.len(ident)
    
    	for i, identifier in ipairs(identifiers) do
    		if string.sub(identifier, 1, len) == ident then
    			return identifier
    		end
	    end
    else
        for i, identifier in ipairs(identifiers) do 
            if ident == identifier then
                return identifier
            end
        end
    end
end;

local LIC = 'license:'
local function GetPlayerLicense (i) return GetPlayerIdentifer(i, LIC, true) end;

local STM =	'steam:'
local function GetPlayerSteamId (i) return GetPlayerIdentifer(i, STM, true) end;

local function PlayerHasIdentifier (source, identifier)
    return GetPlayerIdentifer(source, identifier, false) ~= nil
end;

local function GetPlayerFromIdentifier (identifier)
    for k, playerId in ipairs(GetPlayers()) do
        if PlayerHasIdentifier(playerId, identifier) then
            return playerId
        end
    end
end;

-- EXPORTS | UTILS

UTILS = {
    PlayerHasIdentifier = PlayerHasIdentifier;
	GetPlayerLicense = GetPlayerLicense;
	GetPlayerSteamId = GetPlayerSteamId;
    GetPlayerFromIdentifier = GetPlayerFromIdentifier;
}