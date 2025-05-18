local Category = {}

--[[ CONFIG ]]

Category.NAME = "ExampleName"			-- How the category will appear in the menu
Category.ATTRIBUTE = "ExampleCategory"	-- "CarCategory" attribute of car must be set to this

Category.ACCESS = "ALL"					-- "ALL", "GAMEPASS", or "CUSTOM"
Category.HIDDEN = false					-- If player is not allowed to spawn category, can they still view it in the menu?
Category.PRIORITY = 0					-- Determines display order in the menu (increase to show category lower than others)

Category.GAMEPASS_ID = 0000000			-- Only necessary if category is set to gamepass access
Category.PROMPT_GAMEPASS = true			-- Prompt player to purchase gamepass if they do not own it

--[[ END CONFIG ]]

Category.CanPlayerSpawn = function(plr: Player): boolean
	if Category.ACCESS == "CUSTOM" then
		-- Program custom behavior here
	end

	if Category.ACCESS == "GAMEPASS" then
		return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(plr.UserId, Category.GAMEPASS_ID)
	end

	return true
end

return Category