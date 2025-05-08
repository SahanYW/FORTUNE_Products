--!strict
--[[

		 __________
		/	______/	Car Parts & Tuning
	   /   /_____ _______ _______ _______ ___ __ ___  __ _____
	  /	  ______//		// 		//__  __//  /  //   \/ // ___/
	 /	 /		/	/  //	/  /   / /	/  /  // /\   // ___/
	/___/	   /______//___\__\	  /_/  /_____//_/  \_//____/
	
	https://www.roblox.com/groups/6769995
	
	TireFX
	
	@SW_TK

]]

--[[

    Big TODO:
        - Implement a better structure to encompass all types of effects
            - Make sure to include physical objects for tangibility
            - Module scripts with nested particle effects?
        - Implement the skidmarks from AC6 1.6+
        - Dirtkick?

        Effects list:
            - Dust
            - Rain
            - Snow

        
    - Server needs to duplicate effects to the wheels + setup
    - Client just needs to do calculations and tell server what to update

]]

local TickRate = 1/60
local ServerTickRate = 1/20

local car = script.Parent.Car.Value :: Model
local remote = car:FindFirstChild("TireFX_Remote") :: RemoteEvent
local effects = script:FindFirstChild("Effects"):GetChildren() :: {ModuleScript}

local rayDistance = 0.05
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {car}

while task.wait(TickRate) do
    for _, wheel: BasePart in pairs(car.Wheels:GetChildren()) do
        local wheelRadius = wheel.Size.X / 2
        local rayDirection = wheel.Arm.CFrame.UpVector * -(wheelRadius + rayDistance)
        local rayResult = workspace:Raycast(wheel.Position, rayDirection, rayParams)

        for _, effectModule in pairs(effects) do
            -- effectModule.Update(wheel, rayResult)
        end
    end
end