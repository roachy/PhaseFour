--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local COMMAND = Clockwork.command:New("AllyMakeLeader");
COMMAND.tip = "Make a character a leader of your alliance.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local alliance = player:GetAlliance();
	local target = Clockwork.player:Get(table.concat(arguments, " "));
	
	if (alliance) then
		if (player:IsLeader()) then
			if (target) then
				local targetAlliance = target:GetAlliance();
				
				if (targetAlliance == alliance) then
					player:SetRank(RANK_MAJ);
					
					Clockwork.player:Notify(player, "You have made "..target:Name().." a leader of the '"..alliance.."' alliance.");
					Clockwork.player:Notify(target, player:Name().." has made you a leader of the '"..alliance.."' alliance.");
				else
					Clockwork.player:Notify(player, target:Name().." is not in your alliance!");
				end;
			else
				Clockwork.player:Notify(player, arguments[1].." is not a valid character!");
			end;
		else
			Clockwork.player:Notify(player, "You are not a leader of this alliance!");
		end;
	else
		Clockwork.player:Notify(target, "You are not in an alliance!");
	end;
end;

COMMAND:Register();