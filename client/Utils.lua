-- Push iterator items
local ACC = function (Enumerate, output)
	output = output or {}

	for item in Enumerate () do table.insert(output, item) end

	return output
end

local function XYZ (x, y, z)
	if x == nil then
		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	elseif type(x) == 'table' then
		z = x.z
		y = x.y
		x = x.x
	end

	return 1.0 * tonumber(x or 0), 1.0 * tonumber(y or 0), 1.0 * tonumber(z or 0)
end

-- Nearest entity
local function NEAR (Enumerate, players, x, y, z)
	local p
	local d
	local entity
	local distance = math.huge

	x, y, z = XYZ(x, y, z)

	for i in Enumerate() do
		p = GetEntityCoords((players and GetPlayerPed(i)) or i)
		d = GetDistanceBetweenCoords(x, y, z, p.x, p.y, p.z, true)

		if d < distance then
			distance = d
			entity = i
		end
	end

	return entity, distance
end

-- Accumulate nearby entities
local function NEARBY (Enumerate, players, x, y, z, radius, entities)
	local p

	entities = entities or {}

	x, y, z = XYZ(x, y, z)

	radius = 1.0 * (radius or 1.0)

	for i in Enumerate() do
		p = GetEntityCoords((players and GetPlayerPed(i)) or i)

		if GetDistanceBetweenCoords(x, y, z, p.x, p.y, p.z, true) < radius then
			table.insert(entities, i)
		end
	end

	return entities
end

local function EnumeratePlayers ()
	return coroutine.wrap(function ()
		for i = 0, 256 do
			if NetworkIsPlayerActive(i) then
				coroutine.yield(i)
			end
		end
	end)
end

local function toModel (model)
	if type(model) == 'string' then
		model = GetHashKey(model)
	else
		model = tonumber(model) -- or 0
	end

	return model
end

local function LoadModel (model)
	model = toModel(model)

	if not IsModelInCdimage(model) then 
	    return --0 
	end

	RequestModel(model)

	while not HasModelLoaded(model) do Citizen.Wait(0) end

	return model
end

local function IsTimeoutExpired (inst)
	return GetGameTimer() > inst.endTime
end

local function CreateTimeout (time)
	local start = GetGameTimer()
	local time = tonumber(time) or 0
	return {
		timeout = time;
		startTime = start;
		endTime = start + time;
		expired = IsTimeoutExpired;
	}
end

-- EXPORTS | UTILS
UTILS = {
    XYZ = XYZ;

	-- Model name to int
	toModel = toModel;

	-- Load model
	LoadModel = LoadModel;

	-- Timeout to poll - Expired after startTime + time
	CreateTimeout = CreateTimeout;

	IsTimeoutExpired = IsTimeoutExpired;

	-- Link render target to model
	LinkRendertarget = function (name, model)
		local handle = 0

		model = toModel(model)

		if model == nil or name == nil then return handle end

		if not IsNamedRendertargetRegistered(name) then
			RegisterNamedRendertarget(name, 0)
		end

		if not IsNamedRendertargetLinked(model) then
			LinkNamedRendertarget(model)
		end

		if IsNamedRendertargetRegistered(name) then
			handle = GetNamedRendertargetRenderId(name)
		end

		return handle
	end;

	-- Remove render target
	RemoveRenderTarget = function (name)
		if IsNamedRendertargetRegistered(name) then
			ReleaseNamedRendertarget(GetHashKey(name))
		end
	end;

	-- Request scaleform
	RequestScaleform = function (scaleform)
		local handle = RequestScaleformMovie(scaleform)

		if handle ~= 0 then
			while not HasScaleformMovieLoaded(handle) do
				Citizen.Wait(0)
			end
		end

		return handle
	end;

	-- Request texture dictionary
	RequestTextureDictionary = function (dict, timeout)
		local timeout = CreateTimeout(dict, timeout or 750)

		RequestStreamedTextureDict(dict)

		while not HasStreamedTextureDictLoaded(dict) do
			if timeout:expired() then return end

			Citizen.Wait(0)
		end

		return dict
	end;

	-- Request animation dictionary
	RequestAnimationDictionary = function (dict, timeout)
		local timeout = CreateTimeout(dict, timeout or 750)

		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			if timeout:expired() then return end

			Citizen.Wait(0)
		end

		return dict
	end;

	-- Entity iterators
	EnumerateObjects = EnumerateObjects;
	EnumeratePeds = EnumeratePeds;
	EnumerateVehicles = EnumerateVehicles;
	EnumeratePickups = EnumeratePickups;
	EnumeratePlayers = EnumeratePlayers;

	-- World entities
	GetVehicles = function (_obj) return ACC(EnumerateVehicles, _obj) end;
	GetPickups = function (_obj) return ACC(EnumeratePickups, _obj) end;
	GetPeds = function (_obj) return ACC(EnumeratePeds, _obj) end;
	GetObjects = function (_obj) return ACC(EnumerateObjects, _obj) end;
	GetPlayers = function (_obj) return ACC(EnumeratePlayers, _obj) end;
	GetPlayerFromPed = function (p) return NetworkGetPlayerIndexFromPed(p) end;

	-- Find nearest
	GetNearestObject = function (...) return NEAR(EnumerateObjects, false, ...) end;
	GetNearestVehicle = function (...) return NEAR(EnumerateVehicles, false, ...) end;
	GetNearestPickup = function (...) return NEAR(EnumeratePickups, false, ...) end;
	GetNearestPed = function (...) return NEAR(EnumeratePeds, false, ...) end;
	GetNearestPlayer = function (...) return NEAR(EnumeratePlayers, true, ...) end;

	-- Find nearby
	GetNearbyObjects = function (...) return NEARBY(EnumerateObjects, false, ...) end;
	GetNearbyVehicles = function (...) return NEARBY(EnumerateVehicles, false, ...) end;
	GetNearbyPickups = function (...) return NEARBY(EnumeratePickups, false, ...) end;
	GetNearbyPeds = function (...) return NEARBY(EnumeratePeds, false, ...) end;
	GetNearbyPlayers = function (...) return NEARBY(EnumeratePlayers, true, ...) end;

	-- Create
    SpawnPed = function (pedType, model, coords, ang, networked)
        local model = LoadModel(model)
        local x, y, z, entity

        if model then 
            local x, y, z = XYZ(coords)
            local entity = CreatePed(pedType, model, x, y, z, ang or 0.0, networked == true, true)

            SetPedDefaultComponentVariation(entity)
		    SetModelAsNoLongerNeeded(model)

		    return entity         
        end
    end;

	SpawnObject = function (model, coords, ang, networked)
		local model = LoadModel(model)
		local x, y, z, entity
		
		if model then
		    x, y, z = XYZ(coords)
		    entity = CreateObject(model, x, y, z, networked == true, true, true)
		    SetEntityHeading(entity, ang or 0.0)
		    SetModelAsNoLongerNeeded(model)
		    
		    return entity
		end
	end;

    SpawnVehicle = function (model, coords, ang, networked)
        local model = LoadModel(model)
        local x, y, z, entity, id

        if model then
       		x, y, z = XYZ(coords)
            entity = CreateVehicle(model, x, y, z, ang or 0.0, networked == true, true)
            id = NetworkGetNetworkIdFromEntity(entity)         
            
            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(entity,  true,  false)
            SetVehicleHasBeenOwnedByPlayer(entity,  true)
            SetModelAsNoLongerNeeded(model)

            -- RequestCollisionAtCoord(x, y, z)
            -- while not HasCollisionLoadedAroundEntity(entity) do
            --   RequestCollisionAtCoord(x, y, z)
            --   Citizen.Wait(0)
            -- end           

            return entity
        end
    end;

	-- Destroy
	DestroyObject = function (entity)
		SetEntityAsMissionEntity(entity,  false,  true)
		DeleteObject(entity)

		return entity
	end;

	DestroyPed = function (entity)
        SetEntityAsMissionEntity(entity,  false,  true)
   		DeletePed(entity)

		return entity     
    end;

    DestroyVehicle = function (entity)
        SetEntityAsMissionEntity(entity,  false,  true)
   		DeleteVehicle(entity)

		return entity           
    end;
}