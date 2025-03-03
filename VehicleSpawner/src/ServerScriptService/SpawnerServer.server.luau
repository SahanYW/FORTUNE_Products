--[[

		 __________
		/	______/	Car Parts & Tuning
	   /   /_____ _______ _______ _______ ___ __ ___  __ _____
	  /	  ______//		// 		//__  __//  /  //   \/ // ___/
	 /	 /		/	/  //	/  /   / /	/  /  // /\   // ___/
	/___/	   /______//___\__\	  /_/  /_____//_/  \_//____/
	
	https://www.roblox.com/groups/6769995
	
	Vehicle Spawner
	
	@SW_TK
    
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.CarSpawnerConfig).Server

local vehiclesFolder = ServerStorage:WaitForChild("Vehicles")
local vehicleIds = {}
local playerCars = {}


local function PrepViewportModel(car)
	local displayCar = car:Clone()
	local driveSeatCframe = nil
	
	if displayCar:FindFirstChild("DriveSeat") then
		driveSeatCframe = displayCar.DriveSeat.CFrame
	end
	
	for _, childName in pairs(Config.AutoDeleteObjects) do
		local object = displayCar:FindFirstChild(childName)
		if object then
			object:Destroy()
		end
	end
	
	for _, object in pairs(displayCar:GetDescendants()) do
		if table.find(Config.ObjectExceptions, object.ClassName) then
			continue
		end
		
		local children = object:GetChildren()
		for _, child in pairs(children) do
			
			if table.find(Config.ObjectExceptions, child.ClassName) then
				continue
			end
			
			if child:IsA("Attachment") then		-- Attachments error if not parented to basepart
				child:Destroy()
				continue
			end
			
			child.Parent = displayCar
		end
		
		if not object:IsA("BasePart") then
			object:Destroy()
			continue
		end
		
		if object.Transparency > Config.TransparencyLimit then
			object:Destroy()
			continue
		end
		
		object.Anchored = true
	end
	
	-- Move car to origin
	local modelCframe = displayCar:GetBoundingBox()
	local centerCframe = driveSeatCframe or modelCframe
	
	local centerBrick = Instance.new("Part")
	centerBrick.Name = "_CenterBrick"
	centerBrick.Anchored = true
	centerBrick.Size = Vector3.one
	centerBrick.Transparency = 0
	
	centerBrick.CFrame = centerCframe
	centerBrick.Position = modelCframe.Position
	centerBrick.Parent = displayCar
	
	displayCar.PrimaryPart = centerBrick
	displayCar:PivotTo(CFrame.new(Vector3.zero, Vector3.new(0,0,-1)))
	
	return displayCar
end


local function SpawnCar(plr, carId)
	if playerCars[plr.UserId] == nil then
		playerCars[plr.UserId] = {}
	end

	local cars = playerCars[plr.UserId]
	if #cars > 0 and os.time() - cars[1].timestamp < Config.SpawnerCooldown then
		return false, Config.SpawnerCooldown
	end
	
	if plr.Character == nil then
		return
	end

	if plr.Character.PrimaryPart == nil then
		return
	end
	
	if #cars >= Config.MaxCarsPerPlayer then
		cars[#cars].car:Destroy()
		cars[#cars] = nil
	end
	
	local newCar = vehicleIds[carId]:Clone()
	newCar.Parent = workspace
	
	-- Thanks to @arrivabus415 for the suggestion
	local carCframe = plr.Character.PrimaryPart.CFrame:ToWorldSpace(CFrame.new(0,0,-Config.SpawnerDistance))
	local _, rotY, _ = carCframe:ToOrientation()
	newCar:PivotTo(CFrame.new(carCframe.Position) * CFrame.Angles(0, rotY + math.rad(180), 0))
	newCar:MakeJoints()
	
	local data = {
		car = newCar;
		timestamp = os.time();
	}
	table.insert(cars, 1, data)
	
	return true, Config.SpawnerCooldown
end


local function DeleteCars(plr)
	if playerCars[plr.UserId] == nil then
		return
	end
	
	for _, info in pairs(playerCars[plr.UserId]) do
		info.car:Destroy()
	end
	
	playerCars[plr.UserId] = {}
end


local function Init()
	local displayCarsFolder = Instance.new("Folder")
	displayCarsFolder.Name = "SpawnerViewportModels"
	
	local spawnRemote = Instance.new("RemoteFunction")
	spawnRemote.Name = "SpawnCar"
	spawnRemote.Parent = ReplicatedStorage
	
	local deleteRemote = Instance.new("RemoteEvent")
	deleteRemote.Name = "DeleteCars"
	deleteRemote.Parent = ReplicatedStorage
	
	for index, car in pairs(vehiclesFolder:GetChildren()) do
		local displayCar = PrepViewportModel(car)
		displayCar.Parent = displayCarsFolder
		
		local id = Instance.new("IntValue")
		id.Name = "VehicleId"
		id.Value = index
		id.Parent = displayCar
		
		vehicleIds[index] = car
	end
	
	displayCarsFolder.Parent = ReplicatedStorage
	
	--[[
			When loading in a large number of cars, the client loads the
			cars faster than the server can replicate them due to latency

			Waiting for a specific instance to be created after the folder
			is parented allows the server to finish replicating:
			https://devforum.roblox.com/t/wait-for-model-to-be-fully-replicated-to-client/640718
	]]
	local loadedValue = Instance.new("IntValue")
	loadedValue.Name = "CarsLoaded"
	loadedValue.Value = #displayCarsFolder:GetChildren()
	loadedValue.Parent = ReplicatedStorage
	
	spawnRemote.OnServerInvoke = SpawnCar
	deleteRemote.OnServerEvent:Connect(DeleteCars)
	game:GetService("Players").PlayerRemoving:Connect(DeleteCars)
end

Init()