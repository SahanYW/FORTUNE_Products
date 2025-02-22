local Category = {}

--[[ CONFIG ]]

Category.NAME = "ExampleName"            -- How the category will appear in the menu
Category.ATTRIBUTE = "ExampleCategory"   -- Attribute of car must be set to this

Category.ACCESS = "ALL"                  -- "ALL", "GAMEPASS", or "CUSTOM"
Category.GAMEPASS_ID = 0000000           -- Only necessary if category is set to gamepass access
Category.HIDDEN = false                  -- If player is not allowed to spawn category, can they still view it in the menu?

--[[ END CONFIG ]]

Category.CanPlayerSpawn = function(plr: Player): boolean
  if Category.ACCESS == "CUSTOM" then
    -- program custom behavior here
    -- TODO: provide some boilerplate for popular admin systems like kohls or HD admin
  end

  if Category.ACCESS == "GAMEPASS" then
    return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(plr.UserId, Category.GAMEPASS_ID)
  end

  -- ACCESS == "ALL"
  return true
end

return Category