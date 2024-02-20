SHARK = {}

local AnyPlayerNearShark = nil
local isSharkAttack = false
local inZone = false
local sharkDoRepelent = false

SHARK.Spawn = function()
    local model = 0x06C3F072
    RequestModel(model)
	
    while not HasModelLoaded(model) do
        Citizen.Wait(10)
    end

    local pCoords = GetEntityCoords(PlayerPedId())
	local EnemyShark = CreatePed(1, model, pCoords.x+10, pCoords.y+10, pCoords.z-2, 100, true, false)
	
	SetPedSeeingRange(EnemyShark, 100.0)
	SetPedHearingRange(EnemyShark, 80.0)
	SetPedCombatAttributes(EnemyShark, 46, 1)
	SetPedFleeAttributes(EnemyShark, 0, 0)
	SetPedCombatRange(EnemyShark,2)
	SetPedDiesInWater(EnemyShark, false)
	TaskCombatPed(EnemyShark, GetPlayerPed(-1), 0, 16)
	
	isSharkAttack = true

    if not NetworkGetEntityIsNetworked(EnemyShark) then
        NetworkRegisterEntityAsNetworked(EnemyShark)
    end

	SetPedRelationshipGroupHash(EnemyShark, GetHashKey("HATES_PLAYER"))
	SetRelationshipBetweenGroups(5,GetHashKey("PLAYER"),GetHashKey("SHARK"))
	SetRelationshipBetweenGroups(5,GetHashKey("SHARK"),GetHashKey("PLAYER"))
end

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local pedcoords = GetEntityCoords(ped, true)		
			
		if inZone == false and isSharkAttack == false then
			local name = GetNameOfZone(pedcoords.x, pedcoords.y, pedcoords.z)
		
			if name == 'OCEANA' or name == 'PALCOV' then
				local InWater = IsEntityInWater(ped)
				if InWater and not sharkDoRepelent then
					inZone = true
					SHARK.Spawn()
				end
			end		
		end
		
		if isSharkAttack == true then
            Citizen.Wait(1200000)
            isSharkAttack = false
		end
		
		Citizen.Wait(120000)
	end
end)