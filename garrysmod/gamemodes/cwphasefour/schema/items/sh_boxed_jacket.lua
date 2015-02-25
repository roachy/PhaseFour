--[[
	� 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local ITEM = Clockwork.item:New();
ITEM.name = "Boxed Jacket";
ITEM.cost = 125;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.weight = 0.5;
ITEM.useText = "Open";
ITEM.category = "Storage";
ITEM.business = true;
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItemByID("jacket") and table.Count(player:GetItemsByID("jacket")) >= 1) then
		Clockwork.player:Notify(player, "You've hit the jackets limit!");
			
		return false;
	end;
	
	player:GiveItem(Clockwork.item:CreateInstance("jacket"));
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

ITEM:Register();