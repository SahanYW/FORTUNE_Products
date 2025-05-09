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
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local Config = require(ReplicatedStorage:WaitForChild("CarSpawnerConfig")).Client
local TopbarIcon = require(ReplicatedStorage.Icon)
local MouseOver = require(script.MouseOverModule)

local spawnRemote = ReplicatedStorage:WaitForChild("SpawnCar")
local deleteRemote = ReplicatedStorage:WaitForChild("DeleteCars")

local CategoryInfo = {}

local gui = script.Parent
local window = gui.Window

local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
local hoveringButton = nil
local viewportAngles = {}

local activeFrame = nil
local connections: { [any]: RBXScriptConnection } = {}

local cooldownActive = false

local function ClearButtonConnections()
	for _, buttonConnection in pairs(connections) do
		buttonConnection:Disconnect()
	end
end

local function ToggleWindow(isSelected)
	window.Visible = isSelected
	
	if isSelected == true then
		StartCarButtonConnections()
		return
	end
	
	hoveringButton = nil
	ClearButtonConnections()
end

local function PrepareViewportFrame(car: Model, viewportFrame: ViewportFrame)
	local displayCar = car:Clone()
	displayCar.Parent = viewportFrame

	local carSize = displayCar:GetExtentsSize()
	local camera = Instance.new("Camera")
	
	local maxDimension = math.max(carSize.X, carSize.Z)		-- Get largest dimension from length/width
	local cameraPosition = Vector3.new(
		2 * maxDimension * math.sin(math.rad(Config.ViewportCameraAngle)),
		carSize.Y,
		2 * maxDimension * math.cos(math.rad(Config.ViewportCameraAngle))
	)

	camera.CFrame = CFrame.new(cameraPosition, Vector3.zero)
	camera.FieldOfView = Config.DefaultFov
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera

	displayCar.Parent = viewportFrame
end

local function MouseOverCarButton(button: GuiButton)
	
	if window.Visible == false then
		return
	end
	
	hoveringButton = button
	
	local displayCar = button.ViewportFrame:FindFirstChildOfClass("Model")
	local carSize = displayCar:GetExtentsSize()
	local maxDimension = math.max(carSize.X, carSize.Z)

	local camera = button.ViewportFrame.CurrentCamera
	local rotationIncrement = 360 / (Config.RotationTime * 60)
	local startAngle = viewportAngles[button]
	
	TweenService:Create(camera, tweenInfo, { FieldOfView = Config.HoverFov }):Play()
	
	local count = 0
	while hoveringButton == button do
		local angle = startAngle + (rotationIncrement * count)
		viewportAngles[button] = angle % 360
		
		local cameraPosition = Vector3.new(
			2 * maxDimension * math.sin(math.rad(angle)),
			carSize.Y,
			2 * maxDimension * math.cos(math.rad(angle))
		)
		camera.CFrame = CFrame.new(cameraPosition, Vector3.zero)
		count +=  1
		
		task.wait()
	end
end

local function MouseLeaveCarButton(button: GuiButton)
	hoveringButton = nil
	
	local displayCar = button.ViewportFrame:FindFirstChildOfClass("Model")
	local carSize = displayCar:GetExtentsSize()
	local maxDimension = math.max(carSize.X, carSize.Z)

	local camera = button.ViewportFrame.CurrentCamera
	local rotationRemaining = (360 + Config.ViewportCameraAngle) - viewportAngles[button]
	local startAngle = viewportAngles[button]
	
	TweenService:Create(camera, tweenInfo, { FieldOfView = Config.DefaultFov }):Play()
	
	for i = 0, Config.ReturnTime, 1/60 do
		local percentComplete = i / Config.ReturnTime
		local quartFunction = 1 - math.pow(1 - percentComplete, 4)
		
		local angle = startAngle + (quartFunction * rotationRemaining)
		viewportAngles[button] = angle % 360
		
		local cameraPosition = Vector3.new(
			2 * maxDimension * math.sin(math.rad(angle)),
			carSize.Y,
			2 * maxDimension * math.cos(math.rad(angle))
		)
		camera.CFrame = CFrame.new(cameraPosition, Vector3.zero)
		
		if hoveringButton == button then
			return
		end
		
		task.wait()
	end
	
	local cameraPosition = Vector3.new(
		2 * maxDimension * math.sin(math.rad(Config.ViewportCameraAngle)),
		carSize.Y,
		2 * maxDimension * math.cos(math.rad(Config.ViewportCameraAngle))
	)

	camera.CFrame = CFrame.new(cameraPosition, Vector3.zero)
	viewportAngles[button] = Config.ViewportCameraAngle
end

local function StartCooldownTimer(cooldownTime: number)
	cooldownActive = true
	local timerFrame = window.Cooldown
	timerFrame.Visible = true

	local timeStart = os.clock()
	while task.wait() do
		local percent = (os.clock() - timeStart) / cooldownTime

		if percent > 1 then
			break
		end

		local rotationL = math.clamp(-180 + 360 * percent, 0, 180)
		local rotationR = math.clamp(180 + 360 * percent, 180, 360)

		timerFrame.Frame1.ImageLabel.UIGradient.Rotation = rotationL
		timerFrame.Frame2.ImageLabel.UIGradient.Rotation = rotationR
	end

	timerFrame.Visible = false
	cooldownActive = false
end

local function CarButtonClicked(button: GuiButton)
	if cooldownActive == true then
		coroutine.wrap(function()
			for i = 0, 3 do
				window.Cooldown.Flash.Visible = true
				task.wait(0.1)
				window.Cooldown.Flash.Visible = false
				task.wait(0.1)
			end
		end)()
		return
	end

	local displayCar = button.ViewportFrame:FindFirstChildOfClass("Model")
	local success, cooldown = spawnRemote:InvokeServer(displayCar:GetAttribute("VehicleId"))

	if success == true then
		TopbarIcon.getIcon("SpawnerGuiToggle"):deselect()
		coroutine.wrap(StartCooldownTimer)(cooldown)
	else
		warn(cooldown)
	end
end

function StartCarButtonConnections()
	for _, button in pairs(activeFrame:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		local mouseEnter, mouseLeave = MouseOver.MouseEnterLeaveEvent(button)
		local mouseEnterConnection = mouseEnter:Connect(function()
			MouseOverCarButton(button)
		end)
		local mouseLeaveConnection = mouseLeave:Connect(function()
			MouseLeaveCarButton(button)
		end)

		local mouseClickConnection = button.MouseButton1Click:Connect(function()
			CarButtonClicked(button)
		end)

		table.insert(connections, mouseEnterConnection)
		table.insert(connections, mouseLeaveConnection)
		table.insert(connections, mouseClickConnection)
	end
end

local function CreateCategoryHeader(categoryName: string, layout: "List" | "Grid"): GuiObject
	local header = window[layout].CategoryHeader:Clone()
	header.TextLabel.Text = categoryName
	
	local textBounds = TextService:GetTextSize(
		categoryName,
		header.TextLabel.TextSize,
		Enum.Font.Montserrat,
		header.TextLabel.AbsoluteSize
	)
	local borderSize = UDim2.new(0.45,-(textBounds.X/1.5),0,1)
	header.LeftBorder.Size = borderSize
	header.RightBorder.Size = borderSize
	header.Visible = true
	
	return header
end

local function CreateButton(car: Model, layout: "List" | "Grid"): GuiButton
	local button = window[layout].Template:Clone()
	button.VehicleName.Text = car.Name
	button.Name = car.Name
	button.Visible = true

	if layout == "Grid" then
		button.Size = UDim2.new(
			1 / Config.GridColumns,
			-((100 / Config.GridColumns) + ((Config.GridColumns-1) * Config.GridPadding)/Config.GridColumns),
			0,
			150
		)
	end

	return button
end

local function CreateButtons(viewportModels: {})
	local previousCategory = nil
	local categoryCount = 0
	local categoryCarCount = 0
	local gridStart = 0
	local rowCount = 0

	for carCount, car in pairs(viewportModels) do
        local category = car:GetAttribute("CarCategory")
		if category ~= "Default" and CategoryInfo[category].HIDDEN then		--TODO: fix unexpected behavior when CarCategory is ""
			continue
		end

		if previousCategory ~= category then
			local categoryDisplayName = if CategoryInfo[category]
				then CategoryInfo[category].NAME
				else category
			local listHeader = CreateCategoryHeader(categoryDisplayName, "List")
			local gridHeader = CreateCategoryHeader(categoryDisplayName, "Grid")

			listHeader.Position = UDim2.new(
				0,
				0,
				0,
				window.List.CategoryHeader.Size.Y.Offset * categoryCount + (window.List.Template.Size.Y.Offset + Config.ListPadding) * (carCount-1)
			)
			
			rowCount += math.ceil(categoryCarCount / Config.GridColumns)
			gridHeader.Position = UDim2.new(
				0,
				0,
				0,
				window.Grid.CategoryHeader.Size.Y.Offset * categoryCount + (window.Grid.Template.Size.Y.Offset + Config.GridPadding) * rowCount
			)

			listHeader.Parent = window.List
			gridHeader.Parent = window.Grid
	
			previousCategory = category
			categoryCount += 1
			categoryCarCount = 0
			gridStart = gridHeader.Position.Y.Offset + gridHeader.Size.Y.Offset
		end
		-- Create buttons for both layouts
        local listButton = CreateButton(car, "List")
        local gridButton = CreateButton(car, "Grid")
        
        -- Set List button position
        listButton.Position = UDim2.new(
            0.5,
            0,
            0,
            (window.List.Template.Size.Y.Offset + Config.ListPadding) * (carCount-1) + window.List.CategoryHeader.Size.Y.Offset * categoryCount
        )
        
        -- Set Grid button position
        local row = math.floor(categoryCarCount / Config.GridColumns)
        local column = categoryCarCount % Config.GridColumns
        gridButton.Position = UDim2.new(
            column * (1 / Config.GridColumns),
            50 - (column * 100 / Config.GridColumns) + (column * Config.GridPadding/(Config.GridColumns-1)),
            0,
            row * (150 + Config.GridPadding) + gridStart--window.Grid.CategoryHeader.Size.Y.Offset * categoryCount
        )
        
        -- Setup viewport frames
        PrepareViewportFrame(car, listButton.ViewportFrame)
        PrepareViewportFrame(car, gridButton.ViewportFrame)
        
        -- Set parent and initialize viewport angles
        listButton.Parent = window.List
        gridButton.Parent = window.Grid
        viewportAngles[listButton] = Config.ViewportCameraAngle
        viewportAngles[gridButton] = Config.ViewportCameraAngle
		categoryCarCount += 1
	end

	window.List.CanvasSize = UDim2.new(
		0,0,0,
		(window.List.Template.Size.Y.Offset + Config.ListPadding) * #viewportModels + window.List.CategoryHeader.Size.Y.Offset * categoryCount
	)
	window.Grid.CanvasSize = UDim2.new(
		0,0,0,
		math.ceil(categoryCarCount / Config.GridColumns) * (150 + Config.GridPadding) + gridStart
	)
end

local function SelectSortType(sortType: "List" | "Grid")
	local button = window.Sort[sortType].Button
	button.BackgroundColor3 = Color3.new(1,1,1)
	button.UIGradient.Rotation = 270
	
	local otherSortType = "List"
	if sortType == "List" then
		otherSortType = "Grid"
	end

	local otherButton: GuiButton = window.Sort[otherSortType].Button
	otherButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
	otherButton.UIGradient.Rotation = 90
	
	window[button.Parent.Name].Visible = true
	window[otherSortType].Visible = false
	
	activeFrame = window[button.Parent.Name]
	ClearButtonConnections()
	StartCarButtonConnections()
end

local function Init()
	SelectSortType("Grid")
	ToggleWindow(false)
	
	local toggleButton = TopbarIcon.getIcon("Car Spawner")
	if toggleButton == nil then
		toggleButton = TopbarIcon.new()
			:setName("SpawnerGuiToggle")
			:setLabel("Car Spawner")
			:setImage("rbxassetid://99376475343734")
			:setImageScale(0.75)
			:align("Center")
			:autoDeselect(false)
	end
	toggleButton.toggled:Connect(ToggleWindow)
	
	local deleteButton = TopbarIcon.getIcon("Delete Cars")
	if deleteButton == nil then
		deleteButton = TopbarIcon.new()
			:setName("SpawnerGuiDelete")
			:setLabel("Delete Cars", "Viewing")
			:setImage("rbxassetid://9912835297")
			:setImageScale(0.75)
			:align("Center")
			:modifyTheme({
				{"IconButton", "BackgroundColor3", Color3.fromRGB(255, 255, 255)},
				{"IconGradient", "Color", ColorSequence.new(Color3.fromRGB(176, 0, 0), Color3.fromRGB(100, 0, 0))},
				{"IconGradient", "Enabled", true}
			})
	end
	
	deleteButton:bindEvent("deselected", function()
		deleteRemote:FireServer()
	end)
	deleteButton:oneClick()
	

	local categoryOrder = {}
	for _, categoryModule in pairs(ReplicatedStorage:WaitForChild("CarSpawnerCategories"):GetChildren()) do
		if string.sub(categoryModule.Name, 1, 1) == "." then
			continue
		end

		local info = require(categoryModule)
		categoryOrder[info.ATTRIBUTE] = info.PRIORITY
		CategoryInfo[info.ATTRIBUTE] = info
	end
	categoryOrder["Default"] = -1
	
	-- janky way to assign priorities to categories without an existing module
	local viewportModels = ReplicatedStorage:WaitForChild("SpawnerViewportModels"):GetChildren()
	for index, car in pairs(viewportModels) do
		local category = car:GetAttribute("CarCategory") or "Default"
		if categoryOrder[category] ~= nil then
			continue
		end

		categoryOrder[category] = index
	end

	table.sort(viewportModels, function(a, b)
		local categoryA = a:GetAttribute("CarCategory") or "Default"
		local categoryB = b:GetAttribute("CarCategory") or "Default"
		return categoryOrder[categoryA] < categoryOrder[categoryB]
	end)

	CreateButtons(viewportModels)

	window.List.Template:Destroy()
	window.Grid.Template:Destroy()
	
	for _, frame in pairs(window.Sort:GetChildren()) do
		frame.Button.MouseButton1Click:Connect(function()
			SelectSortType(frame.Name)
		end)
	end
end

Init()
