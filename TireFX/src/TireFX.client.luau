

local materials = Enum.Material

--- CONFIG

local Dust_Rate_Multiplier = 3			-- Arbitrary value multiplied by angular velocity of wheel to get particle emitter rate
local Dust_Minimum_Threshold = 30		-- Minimum angular velocity of wheel required to show particle emitter
local Dust_Maximum_Threshold = 50		-- Maximum angular velocity of wheel used to show particle emitter

local Skid_Minimum_Threshold = 25		-- Minimum difference in velocity and angular velocity of wheel used
local Skid_Maximum_Threshold = 50		-- Maximum difference in velocity and angular velocity of wheel used
local Skid_Mark_Threshold = 0.15			-- (0-1) Percentage strength of skid required to create tire marks


local Surfaces = {						-- Add/remove materials to change when particle emitter turns on
	["Dust"] = {
		materials.Grass;
		materials.Pebble;
		materials.Slate;
	};
	["Snow"] = {
		materials.Ice;
		materials.Glacier;
		materials.Snow;
	};
	
	-- Miscellaneous surfaces, add/delete if you want
	-- Make sure to create a corresponding particle emitter in ParticleEmitters folder
	-- Name must follow <surface>Emitter
	["Rain"] = {
		materials.Glass
	};
	["Sand"] = {
		materials.Sand
	};
	["Mud"] = {
		materials.Mud
	};
}

--- SETUP

local car = script.Parent.Car.Value
local wheels = car.Wheels:GetChildren()
local dustRemote = car:WaitForChild("Dust_Remote")
local smokeRemote = car:WaitForChild("Smoke_Remote")
local RunService = game:GetService("RunService")

local wheelInfo = {
	["FL"] = {
		--["Rate"] = 0;				-- Rate is used for all particle emitters in one wheel
		--["SkidValue"] = false;		-- Determines if the wheels will create tire marks, smoke, and squeal
		--["DustEnabled"] = false;
		--["SnowEnabled"] = false;
	};
	["FR"] = {}; --["Rate"] = 0; ["SkidValue"] = false; ["DustEnabled"] = false; ["SnowEnabled"] = false; };
	["RL"] = {}; --["Rate"] = 0; ["SkidValue"] = false; ["DustEnabled"] = false; ["SnowEnabled"] = false; };
	["RR"] = {}; --["Rate"] = 0; ["SkidValue"] = false; ["DustEnabled"] = false; ["SnowEnabled"] = false; };
}

-- Duplicate particle emitters to each wheel

for _, wheel in pairs(wheels) do
	
	--Create rate and skidding value for each wheel
	wheelInfo[wheel.Name]["Rate"] = 0
	wheelInfo[wheel.Name]["SkidValue"] = 0
	for SurfaceName, _ in pairs(Surfaces) do
		
		-- Create <surface>Enabled variable in wheelInfo table
		wheelInfo[wheel.Name][SurfaceName .. "Enabled"] = false
	end
end

-- Calculate rate, raycast, and update server
local os_clock = os.clock
local math_max = math.max
local math_min = math.min
local math_abs = math.abs

local rayDistance = 0.05									-- Distance of ray in studs extending outside of wheel radius
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {car}					-- Make sure ray ignores descendants of the car

--- UPDATE

local lastTime = os_clock()
RunService.Heartbeat:Connect(function()
	for _, wheel in pairs(wheels) do
		
		local wheelRadius = wheel.Size.X / 2
		local wheelSpeed = wheel.Velocity.Magnitude
		local wheelAngularSpeed = wheel.AssemblyAngularVelocity.Magnitude
		local outerWheelAngularSpeed = wheelAngularSpeed * wheelRadius
		
		-- Calculate rate
		local rate
		
			-- Rate is set to 0 when lower than minimum threshold speed
		if outerWheelAngularSpeed < Dust_Minimum_Threshold then
			rate = 0;
			
			-- Rate is set to maximum threshold if greater than maximum threshold speed
		elseif outerWheelAngularSpeed >= Dust_Maximum_Threshold then
			rate = Dust_Maximum_Threshold;
			
			-- Rate is set to outerWheelAngularSpeed
		else
			rate = outerWheelAngularSpeed
		end
		
		rate *= Dust_Rate_Multiplier
		wheelInfo[wheel.Name]["Rate"] = rate
		
		
		-- Skidding																-- wheel_velocity = angular_velocity * radius
		local rawSkidValue = math_abs(outerWheelAngularSpeed - wheelSpeed)		-- if wheel_velocity ~= angular_velocity then wheel is slipping
		rawSkidValue = math_max(rawSkidValue, Skid_Minimum_Threshold)
		rawSkidValue = math_min(rawSkidValue, Skid_Maximum_Threshold)
		
		-- Convert rawSkidValue into a percentage ranging from Skid_Minimum_Threshold to Skid_Maximum_Threshold
		wheelInfo[wheel.Name]["SkidValue"] = (rawSkidValue - Skid_Minimum_Threshold) / (Skid_Maximum_Threshold - Skid_Minimum_Threshold)
		
		-- Raycast
		local rayDirection = wheel.Arm.CFrame.UpVector * -(wheelRadius + rayDistance)		-- Bottom direction relative to car 
		local rayCastResult = workspace:Raycast(wheel.Position, rayDirection, rayParams)
		
		for surfaceName, surfaceMaterials in pairs(Surfaces) do
			
			-- Ray hit
			if rayCastResult then
				
				-- Check if material matches
				if table.find(surfaceMaterials, rayCastResult.Material) then
					wheelInfo[wheel.Name][surfaceName .. "Enabled"] = true
					wheelInfo[wheel.Name]["SkidValue"] = 0
				else
					wheelInfo[wheel.Name][surfaceName .. "Enabled"] = false
				end
				
			-- Ray did not hit
			else
				wheelInfo[wheel.Name][surfaceName .. "Enabled"] = false
				wheelInfo[wheel.Name]["SkidValue"] = 0
			end
		end
	end

	-- Rate limit
	if (os_clock() - lastTime) > 0.05 then
		
		-- Update server
		dustRemote:FireServer(Surfaces, wheelInfo)
		smokeRemote:FireServer(wheelInfo, Skid_Minimum_Threshold, Skid_Maximum_Threshold, Skid_Mark_Threshold)
		lastTime = os_clock()
	end
end)