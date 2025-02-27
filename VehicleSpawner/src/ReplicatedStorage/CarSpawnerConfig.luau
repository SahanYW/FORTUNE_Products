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

local TYPECHECKING = require(script.Typechecks)
local CONFIG: TYPECHECKING.CONFIG = {
	Client = {

		CategoryOrder = {
			-- Use category attribute IDs

			-- Example:
			-- "Category1";
			-- "Category2";
			-- "Category3";
		};
		
		ListPadding = 25;			-- Pixel spacing between buttons in list view
		GridColumns = 4;			-- Button columns in grid view (warning: more columns lowers framerate)
		GridPadding = 15;			-- Pixel spacing between buttons in grid view
		
		ViewportCameraAngle = 225;	-- Camera angle, in degrees, when viewing cars in gui
		RotationTime = 5;			-- Time, in seconds, for the car to make a full rotation when hovering over its button
		ReturnTime = 2.5;			-- Time, in seconds, for the car to rotate back to its original orientation when the mouse leaves its button
		DefaultFov = 30;			-- Field of view of the viewport frame of a car button
		HoverFov = 25;				-- Field of view of the viewport frame when hovering over a car button
		
	};
	
	Server = {
		
		SpawnerCooldown = 10;		-- Time, in seconds, before a player can spawn another car
		MaxCarsPerPlayer = 1;		-- Maximum amount of cars that can be spawned at once by each player
		SpawnerDistance = 15;		-- Distance, in studs, where the car gets spawned in front of the player
		
		--Viewport vehicle optimization
		TransparencyLimit = 0.8;	-- Any cars containing parts with transparency above this limit will be removed
		AutoDeleteObjects = {		-- Any objects in the ROOT DIRECTORY of the car model to be deleted instantly
			"A-Chassis Tune";
			"Tuner";
		};
		ObjectExceptions = {		-- Object classes that will not be deleted
			"CylinderMesh";
			"Decal";
			"Texture";
			"SurfaceAppearance";
		}
		
	};
}

return CONFIG
