if (CLIENT) then return; end;

local PLUGIN = PLUGIN;
local Clockwork = Clockwork;

-- Called at an interval while a player is connected.
function PLUGIN:PlayerThink(player)
	local raised = Clockwork.player:GetWeaponRaised(player);

	if (!raised) then
		player:DrawViewModel(false);
	else
		player:DrawViewModel(true);
	end;
end;