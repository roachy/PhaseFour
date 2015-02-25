--[[
	© 2013 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]
--[[
	© Songbird aka Alko -  do not re-distribute without permission of its author (ael9000 gmail.com).
--]]

local Clockwork = Clockwork;
local pairs = pairs;
local RunConsoleCommand = RunConsoleCommand;
local SysTime = SysTime;
local ScrH = ScrH;
local ScrW = ScrW;
local table = table;
local string = string;
local vgui = vgui;
local math = math;

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	if (!Clockwork.theme:Call("PreCharacterMenuInit", self)) then
		local smallTextFont = Clockwork.option:GetFont("menu_text_small");
		local tinyTextFont = Clockwork.option:GetFont("menu_text_tiny");
		local hugeTextFont = Clockwork.option:GetFont("menu_text_huge");
		local scrH = ScrH();
		local scrW = ScrW();
		
		self:SetPos(0, 0);
		self:SetSize(scrW, scrH);
		self:SetDrawOnTop(false);
		self:SetPaintBackground(false);
		self:SetMouseInputEnabled(true);
		
		self.titleLabel = vgui.Create("cwLabelButton", self);
		self.titleLabel:SetDisabled(true);
		self.titleLabel:SetFont(hugeTextFont);
		self.titleLabel:SetText(string.upper(Schema:GetName()));
		
		local schemaLogo = Clockwork.option:GetKey("schema_logo");
	
		
		if (schemaLogo == "") then
			self.titleLabel:SetVisible(true);
			self.titleLabel:SizeToContents();
			self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.3);
		else
			self.titleLabel:SetVisible(false);
			self.titleLabel:SetSize(512, 256);
			self.titleLabel:SetPos((scrW / 2) - (self.titleLabel:GetWide() / 2), scrH * 0.3 - 128);
		end;
		

		self.createButton = vgui.Create("cwLabelButton", self);
		self.createButton:SetFont(smallTextFont);
		self.createButton:SetText("NEW STORY");
		self.createButton:FadeIn(0.5);
		self.createButton:SetCallback(function(panel)
			if (table.Count(Clockwork.character:GetAll()) >= Clockwork.player:GetMaximumCharacters()) then
				return Clockwork.character:SetFault("You cannot create any more characters!");
			end;
			
			Clockwork.character:ResetCreationInfo();
			Clockwork.character:OpenNextCreationPanel();
		end);
		self.createButton:SizeToContents();
		self.createButton:SetMouseInputEnabled(true);
		self.createButton:SetPos(ScrW() * 0.1, ScrH() * 0.6);
		
		self.loadButton = vgui.Create("cwLabelButton", self);
		self.loadButton:SetFont(smallTextFont);
		self.loadButton:SetText("CONTINUE STORY");
		self.loadButton:FadeIn(0.5);
		self.loadButton:SetCallback(function(panel)
			self:OpenPanel("cwCharacterList", nil, function(panel)
				Clockwork.character:RefreshPanelList();
			end);
		end);
		self.loadButton:SizeToContents();
		self.loadButton:SetMouseInputEnabled(true);
		self.loadButton:SetPos(ScrW() * 0.1, ScrH() * 0.65);
		
	
		
		self.disconnectButton = vgui.Create("cwLabelButton", self);
		self.disconnectButton:SetFont(smallTextFont);
		self.disconnectButton:SetText("QUIT");
		self.disconnectButton:FadeIn(0.5);
		self.disconnectButton:SetCallback(function(panel)
			if (Clockwork.Client:HasInitialized() and !Clockwork.character:IsMenuReset()) then
				Clockwork.character:SetPanelMainMenu();
				Clockwork.character:SetPanelOpen(false);
			else
				RunConsoleCommand("disconnect");
			end;
		end);
		self.disconnectButton:SizeToContents();
		self.disconnectButton:SetPos(ScrW() * 0.1, ScrH() * 0.75);
		self.disconnectButton:SetMouseInputEnabled(true);
		
		self.previousButton = vgui.Create("cwLabelButton", self);
		self.previousButton:SetFont(tinyTextFont);
		self.previousButton:SetText("BACK");
		self.previousButton:SetCallback(function(panel)
			if (!Clockwork.character:IsCreationProcessActive()) then
				local activePanel = Clockwork.character:GetActivePanel();
				
				if (activePanel and activePanel.OnPrevious) then
					activePanel:OnPrevious();
				end;
			else
				Clockwork.character:OpenPreviousCreationPanel()
			end;
		end);
		self.previousButton:SizeToContents();
		self.previousButton:SetMouseInputEnabled(true);
		self.previousButton:SetPos((scrW * 0.2) - (self.previousButton:GetWide() / 2), scrH * 0.9);
		
		self.nextButton = vgui.Create("cwLabelButton", self);
		self.nextButton:SetFont(tinyTextFont);
		self.nextButton:SetText("NEXT");
		self.nextButton:SetCallback(function(panel)
			if (!Clockwork.character:IsCreationProcessActive()) then
				local activePanel = Clockwork.character:GetActivePanel();
				
				if (activePanel and activePanel.OnNext) then
					activePanel:OnNext();
				end;
			else
				Clockwork.character:OpenNextCreationPanel()
			end;
		end);
		self.nextButton:SizeToContents();
		self.nextButton:SetMouseInputEnabled(true);
		self.nextButton:SetPos((scrW * 0.8) - (self.nextButton:GetWide() / 2), scrH * 0.9);
		
		self.cancelButton = vgui.Create("cwLabelButton", self);
		self.cancelButton:SetFont(tinyTextFont);
		self.cancelButton:SetText("CANCEL");
		self.cancelButton:SetCallback(function(panel)
			self:ReturnToMainMenu();
		end);
		self.cancelButton:SizeToContents();
		self.cancelButton:SetMouseInputEnabled(true);
		self.cancelButton:SetPos((scrW * 0.5) - (self.cancelButton:GetWide() / 2), scrH * 0.9);
		
		self.characterModel = vgui.Create("cwCharacterModel", self);
		self.characterModel:SetSize(512, 512);
		self.characterModel:SetAlpha(0);
		self.characterModel:SetModel("models/error.mdl");
		self.createTime = SysTime();
		
		Clockwork.theme:Call("PostCharacterMenuInit", self)
	end;
end;

-- A function to fade in the model panel.
function PANEL:FadeInModelPanel(model)
	if (ScrH() < 768) then
		return true;
	end;

	local panel = Clockwork.character:GetActivePanel();
	local x, y = ScrW() - self.characterModel:GetWide() - 8, 16;
	
	if (panel) then
		x, y = panel.x + panel:GetWide() - 16, panel.y - 80;
	end;
	
	self.characterModel:SetPos(x, y);
	
	if (self.characterModel:FadeIn(0.5)) then
		self:SetModelPanelModel(model);
		return true;
	else
		return false;
	end;
end;

-- A function to fade out the model panel.
function PANEL:FadeOutModelPanel()
	self.characterModel:FadeOut(0.5);
end;

-- A function to set the model panel's model.
function PANEL:SetModelPanelModel(model)
	if (self.characterModel.currentModel != model) then
		self.characterModel.currentModel = model;
		self.characterModel:SetModel(model);
	end;
	
	local modelPanel = self.characterModel:GetModelPanel();
	local weaponModel = Clockwork.plugin:Call(
		"GetModelSelectWeaponModel", model
	);
	local sequence = Clockwork.plugin:Call(
		"GetModelSelectSequence", modelPanel.Entity, model
	);
	
	if (weaponModel) then
		self.characterModel:SetWeaponModel(weaponModel);
	else
		self.characterModel:SetWeaponModel(false);
	end;
	
	if (sequence) then
		modelPanel.Entity:ResetSequence(sequence);
	end;
end;

-- A function to return to the main menu.
function PANEL:ReturnToMainMenu()
	local panel = Clockwork.character:GetActivePanel();
	
	if (panel) then
		panel:FadeOut(0.5, function()
			Clockwork.character.activePanel = nil;
				panel:Remove();
			self:FadeInTitle();
		end);
	else
		self:FadeInTitle();
	end;
	
	self:FadeOutModelPanel();
	self:FadeOutNavigation();
end;

-- A function to fade out the navigation.
function PANEL:FadeOutNavigation()
	self.previousButton:FadeOut(0.5);
	self.cancelButton:FadeOut(0.5);
	self.nextButton:FadeOut(0.5);
end;

-- A function to fade in the navigation.
function PANEL:FadeInNavigation()
	self.previousButton:FadeIn(0.5);
	self.cancelButton:FadeIn(0.5);
	self.nextButton:FadeIn(0.5);
end;

-- A function to fade out the title.
function PANEL:FadeOutTitle()
	self.titleLabel:FadeOut(0.5);
	self.createButton:FadeOut(0.5)
	self.loadButton:FadeOut(0.5)
	self.disconnectButton:FadeOut(0.5)
end;

-- A function to fade in the title.
function PANEL:FadeInTitle()
	self.createButton:FadeIn(0.5)
	self.loadButton:FadeIn(0.5)
	self.disconnectButton:FadeIn(0.5)
	self.titleLabel:FadeIn(0.5);
end;

-- A function to open a panel.
function PANEL:OpenPanel(vguiName, childData, Callback)
	if (!Clockwork.theme:Call("PreCharacterMenuOpenPanel", self, vguiName, childData, Callback)) then
		local panel = Clockwork.character:GetActivePanel();
		
		if (panel) then
			panel:FadeOut(0.5, function()
				panel:Remove(); self.childData = childData;
				
				Clockwork.character.activePanel = vgui.Create(vguiName, self);
				Clockwork.character.activePanel:SetAlpha(0);
				Clockwork.character.activePanel:FadeIn(0.5);
				Clockwork.character.activePanel:MakePopup();
				Clockwork.character.activePanel:SetPos(ScrW() * 0.2, ScrH() * 0.275);
				
				if (Callback) then
					Callback(Clockwork.character.activePanel);
				end;
				
				if (childData) then
					Clockwork.character.activePanel.bIsCreationProcess = true;
					Clockwork.character:FadeInNavigation();
				end;
			end);
		else
			self.childData = childData;
			self:FadeOutTitle();
			
			Clockwork.character.activePanel = vgui.Create(vguiName, self);
			Clockwork.character.activePanel:SetAlpha(0);
			Clockwork.character.activePanel:FadeIn(0.5);
			Clockwork.character.activePanel:MakePopup();
			Clockwork.character.activePanel:SetPos(ScrW() * 0.2, ScrH() * 0.275);
			
			if (Callback) then
				Callback(Clockwork.character.activePanel);
			end;
			
			if (childData) then
				Clockwork.character.activePanel.bIsCreationProcess = true;
				Clockwork.character:FadeInNavigation();
			end;
		end;
		
		--[[ Fade out the model panel, we probably don't need it now! --]]
		self:FadeOutModelPanel();
		
		Clockwork.theme:Call("PostCharacterMenuOpenPanel", self);
	end;
end;

-- Called when the panel is painted.
function PANEL:Paint(w, h)

	if (!Clockwork.theme:Call("PreCharacterMenuPaint", self)) then
		local schemaLogo = Clockwork.option:GetKey("schema_logo");
		
		if (schemaLogo != "") then
			if (!self.logoTextureID) then
				self.logoTextureID = Material(schemaLogo..".png");
			end;
			
			
			surface.SetDrawColor(255, 255, 255, 255);
			surface.SetMaterial(self.logoTextureID);
			surface.DrawTexturedRect(15, 260, 512, 256);
		end;
		
		Clockwork.theme:Call("PostCharacterMenuPaint", self)
	end;
end;


-- Called each frame.
function PANEL:Think()
	if (!Clockwork.theme:Call("PreCharacterMenuThink", self)) then
		local characters = table.Count(Clockwork.character:GetAll());
		local bIsLoading = Clockwork.character:IsPanelLoading();
		local schemaLogo = Clockwork.option:GetKey("schema_logo");
		local activePanel = Clockwork.character:GetActivePanel();
		local fault = Clockwork.character:GetFault();
		
		if (Clockwork.plugin:Call("ShouldDrawCharacterBackgroundBlur")) then
			Clockwork.kernel:RegisterBackgroundBlur(self, self.createTime);
		else
			Clockwork.kernel:RemoveBackgroundBlur(self);
		end;
		
		if (self.characterModel) then
			if (!self.characterModel.currentModel
			or self.characterModel.currentModel == "models/error.mdl") then
				self.characterModel:SetAlpha(0);
			end;
		end;
		
		if (!Clockwork.character:IsCreationProcessActive()) then
			if (activePanel) then
				if (activePanel.GetNextDisabled
				and activePanel:GetNextDisabled()) then
					self.nextButton:SetDisabled(true);
				else
					self.nextButton:SetDisabled(false);
				end;
				
				if (activePanel.GetPreviousDisabled
				and activePanel:GetPreviousDisabled()) then
					self.previousButton:SetDisabled(true);
				else
					self.previousButton:SetDisabled(false);
				end;
			end;
		else
			local previousPanelInfo = Clockwork.character:GetPreviousCreationPanel();
			
			if (previousPanelInfo) then
				self.previousButton:SetDisabled(false);
			else
				self.previousButton:SetDisabled(true);
			end;
			
			self.nextButton:SetDisabled(false);
		end;
		
		if (schemaLogo == "") then
			self.titleLabel:SetVisible(true);
		else
			self.titleLabel:SetVisible(false);
		end;
		
		if (characters == 0 or bIsLoading) then
			self.loadButton:SetDisabled(true);
		else
			self.loadButton:SetDisabled(false);
		end;
		
		if (characters >= Clockwork.player:GetMaximumCharacters()
		or Clockwork.character:IsPanelLoading()) then
			self.createButton:SetDisabled(true);
		else
			self.createButton:SetDisabled(false);
		end;
		
		if (Clockwork.Client:HasInitialized() and !Clockwork.character:IsMenuReset()) then
			self.disconnectButton:SetText("RETURN TO GAME");
			self.disconnectButton:SizeToContents();
		else
			self.disconnectButton:SetText("QUIT");
			self.disconnectButton:SizeToContents();
			self.disconnectButton:SetPos(ScrW() * 0.1, ScrH() * 0.75);
		end;
		
		if (self.animation) then
			self.animation:Run();
		end;
		
		self:SetSize(ScrW(), ScrH());
		
		Clockwork.theme:Call("PostCharacterMenuThink", self)
	end;
end;

vgui.Register("cwCharacterMenu", PANEL, "DPanel");



