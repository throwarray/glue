Player = {
	GetServerId = function ()
		return GetPlayerServerId(PlayerId())
	end;

	SetModel = function (model)
		model = UTILS.LoadModel(model)

		if model and model ~= 0 then
			SetPlayerModel(PlayerId(), model)
			SetPedDefaultComponentVariation(PlayerPedId())
			SetModelAsNoLongerNeeded(model)
		end

		return model
	end;

	Teleport = function (x, y, z)
	    local timeout

		timeout = UTILS.CreateTimeout(750)

		x, y, z = UTILS.XYZ(x, y, z)

		RequestCollisionAtCoord(x, y, z)

		while not HasCollisionLoadedAroundEntity(GetPlayerPed(-1)) do
			if timeout:expired() then break end

			RequestCollisionAtCoord(x, y, z)

			Citizen.Wait(0)
		end

		SetEntityCoords(GetPlayerPed(-1),  x,  y,  z)
	end;
}