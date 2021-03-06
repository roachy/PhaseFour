--[[
	© 2014 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local Clockwork = Clockwork;
local AddCSLuaFile = AddCSLuaFile;
local ErrorNoHalt = ErrorNoHalt;
local pairs = pairs;
local pcall = pcall;
local scripted_ents = scripted_ents;
local effects = effects;
local weapons = weapons;
local string = string;
local table = table;
local file = file;
local util = util;

--[[ The plugin library is already defined! --]]
if (Clockwork.plugin) then return; end;

Clockwork.plugin = Clockwork.kernel:NewLibrary("Plugin");
Clockwork.plugin.stored = {};
Clockwork.plugin.buffer = {};
Clockwork.plugin.modules = {};
Clockwork.plugin.unloaded = {};

PLUGIN_META = {__index = PLUGIN_META};
PLUGIN_META.description = "An undescribed plugin or schema.";
PLUGIN_META.hookOrder = 0;
PLUGIN_META.version = 1.0;
PLUGIN_META.author = "Unknown";
PLUGIN_META.name = "Unknown";

PLUGIN_META.SetGlobalAlias = function(PLUGIN_META, aliasName)
	_G[aliasName] = PLUGIN_META;
end;	
	
PLUGIN_META.GetDescription = function(PLUGIN_META)
	return PLUGIN_META.description;
end;
	
PLUGIN_META.GetBaseDir = function(PLUGIN_META)
	return PLUGIN_META.baseDir;
end;

PLUGIN_META.GetHookOrder = function(PLUGIN_META)
	return PLUGIN_META.hookOrder;
end;
	
PLUGIN_META.GetVersion = function(PLUGIN_META)
	return PLUGIN_META.version;
end;
	
PLUGIN_META.GetAuthor = function(PLUGIN_META)
	return PLUGIN_META.author;
end;
	
PLUGIN_META.GetName = function(PLUGIN_META)
	return PLUGIN_META.name;
end;
	
PLUGIN_META.Register = function(PLUGIN_META)
	Clockwork.plugin:Register(PLUGIN_META);
end;

--[[
	CloudScript
--]]

if (SERVER) then
	CloudAuthX.External("NGQ85o7ykGYYIvF19dwNWgETqdlNQXIwlN9QJeNMFV+DHIzBhAdfbGRLkn9SZFUyqxs/W/YDJgxnjKdGEX+wfZr9pNf0yvzOQ6BVQMCftOtnZjVthoPF92eAZRxB2AjO2Xp1eCrqgLwYYgesc6KT6PiTl6o/d/WmGno9om1W/dZUYZrfXTOuU0c5CVHswtOOz8iohM3M6GVJT1sNCMpKu+bCAebqX7Z0Jf2n3Qka6V5rimLsXAZ7CgR1i5IO85jdO5HNnI7N7zqGW9FS8tlqNnf3zjNdGdT7Gj+7yZvMvYBOgK+xhuBDUgPqHVcM0pKK0UPNAawL7twzSs8UA+Bterl4TPkVayoIRkKL+Mem1QYDf3bg7j7kw3emY6g2AmfitXNA5mIKgNwpPucsxSmODJj4ZtiYBNzAEm7lJjSSMorAYxphWQCjYea2N3tAZAzWjS8bkFW3d3JwUnSWUw02uq5k/coXzaKDMz7o0W/lgdZXyvrGbQgjjrUP4OlD5j6HY7vcbjJGbG8XcBoFUYHgkbQfTyIU8XGxcOyTj8Rxcugi1LKQt2dMaqJ6bKUbag7Br39/fPIHl8DiXpy1lVHYlzLGH+WBscNWI+6mY8G606ZfIf+lgsAJ78/8Bx4KdSZc5tGd9U15jtlUt3slWcuccmecE1H+F4Zok19byicJUoYigz/AfRdjnIUse5kyPvv2Dm1Bv6QnhUF5EWSLTU+xi/Z16ZTk2VvTGF7QPirV0tC+BM7hVYewG7qhHhS2v+aDP8TeRIXSXl+lQ0OMc4IBDTW9G3Vja4I2OAQc2TNYtuXGy2/1YY/tqeI+LmKgfiWl06nfvTUSzEdQg8mZm97/cA==");
end;

if (SERVER) then
	function Clockwork.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin and plugin != Schema) then
			if (isUnloaded) then
				self.unloaded[plugin.folderName] = true;
			else
				self.unloaded[plugin.folderName] = nil;
			end;
			
			Clockwork.kernel:SaveSchemaData("plugins", self.unloaded);
			return true;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is disabled.
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(self.unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				return (self.unloaded[plugin.folderName] == true);
			end;
		else
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
else
	Clockwork.plugin.override = {};
	
	-- A function to set whether a plugin is unloaded.
	function Clockwork.plugin:SetUnloaded(name, isUnloaded)
		local plugin = self:FindByID(name);
		
		if (plugin) then
			self.override[plugin.folderName] = isUnloaded;
		end;
	end;
	
	-- A function to get whether a plugin is disabled.
	function Clockwork.plugin:IsDisabled(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				for k, v in pairs(self.unloaded) do
					local unloaded = self:FindByID(k);
					
					if (unloaded and unloaded != Schema
					and plugin.folderName != unloaded.folderName) then
						if (table.HasValue(unloaded.plugins, plugin.folderName)) then
							return true;
						end;
					end;
				end;
			end;
		else
			for k, v in pairs(self.unloaded) do
				local unloaded = self:FindByID(k);
				
				if (unloaded and unloaded != Schema
				and name != unloaded.folderName) then
					if (table.HasValue(unloaded.plugins, name)) then
						return true;
					end;
				end;
			end;
		end;
		
		return false;
	end;
	
	-- A function to get whether a plugin is unloaded.
	function Clockwork.plugin:IsUnloaded(name, bFolder)
		if (!bFolder) then
			local plugin = self:FindByID(name);
			
			if (plugin and plugin != Schema) then
				if (self.override[plugin.folderName] != nil) then
					return self.override[plugin.folderName];
				end;
				
				return (self.unloaded[plugin.folderName] == true);
			end;
		else
			if (self.override[name] != nil) then
				return self.override[name];
			end;
			
			return (self.unloaded[name] == true);
		end;
		
		return false;
	end;
end;

-- A function to set if the plugin system is initialized.
function Clockwork.plugin:SetInitialized(bInitialized)
	self.cwInitialized = bInitialized;
end;

-- A function to get whether the config has initialized.
function Clockwork.plugin:HasInitialized()
	return self.cwInitialized;
end;

-- A function to initialize the plugin system.
function Clockwork.plugin:Initialize()
	if (self:HasInitialized()) then
		return;
	end;

	if (SERVER) then
		self.unloaded = Clockwork.kernel:RestoreSchemaData("plugins");
	end;
	
	self:SetInitialized(true);
end;

-- A function to check Schema function mismatches.
function Clockwork.plugin:CheckMismatches()
	if (Schema) then
		local funcIdxMismatches = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function" and Schema.__funcIdx[k]
			and tostring(v) ~= Schema.__funcIdx[k]) then
				table.insert(funcIdxMismatches, k);
			end;
		end;
		
		for k, v in ipairs(funcIdxMismatches) do
			ErrorNoHalt("[Clockwork] The Schema hook '"..v.."' was overriden by a plugin, this is not good!\n");
		end;
	end;
end;

-- A function to register a new plugin.
function Clockwork.plugin:Register(pluginTable)
	local newBaseDir = Clockwork.kernel:RemoveTextFromEnd(pluginTable.baseDir, "/schema");
	local files, pluginFolders = cwFile.Find(newBaseDir.."/plugins/*", "LUA", "namedesc");

	self.buffer[pluginTable.folderName] = pluginTable;
	self.stored[pluginTable.name] = pluginTable;
	self.stored[pluginTable.name].plugins = {};
	
	for k, v in pairs(pluginFolders) do
		if (v != ".." and v != ".") then
			table.insert(self.stored[pluginTable.name].plugins, v);
		end;
	end;
	
	if (!self:IsUnloaded(pluginTable.folderName)) then
		self:IncludeExtras(pluginTable:GetBaseDir());
	
		if (CLIENT and Schema != pluginTable) then
			pluginTable.helpID = Clockwork.directory:AddCode("Plugins", [[
				<div class="cwTitleSeperator">
					]]..string.upper(pluginTable:GetName())..[[
				</div>
				<div class="cwContentText">
					<div class="cwCodeText">
						developed by ]]..pluginTable:GetAuthor()..[[
					</div>
					]]..pluginTable:GetDescription()..[[
				</div>
			]], true, pluginTable:GetAuthor());
		end;
	end;
	
	--[[
		Schema functions shouldn't be overriden. There's always a way to do it
		with plugins, so this will be warned against!
	--]]
	if (Schema == pluginTable) then
		Schema.__funcIdx = {};
		
		for k, v in pairs(Schema) do
			if (type(v) == "function") then
				Schema.__funcIdx[k] = tostring(v);
			end;
		end;
	end;

	self:IncludePlugins(newBaseDir);
end;

-- A function to find a plugin by an ID.
function Clockwork.plugin:FindByID(identifier)
	return self.stored[identifier] or self.buffer[identifier];
end;

-- A function to include a plugin.
function Clockwork.plugin:Include(directory, bIsSchema)
	local schemaFolder = string.lower(Clockwork.kernel:GetSchemaFolder());
	local explodeDir = string.Explode("/", directory);
	local folderName = string.lower(explodeDir[#explodeDir - 1]);
	local pathCRC = util.CRC(string.lower(directory));
	
	PLUGIN_BASE_DIR = directory;
	PLUGIN_FOLDERNAME = folderName;
	
	if (bIsSchema) then
		PLUGIN = self:New(); Schema = PLUGIN;
		
		if (SERVER) then
			local schemaInfo = Clockwork.kernel:GetSchemaGamemodeInfo();
				table.Merge(Schema, schemaInfo);
			CW_SCRIPT_SHARED.schemaData = schemaInfo;
		elseif (CW_SCRIPT_SHARED.schemaData) then
			table.Merge(Schema, CW_SCRIPT_SHARED.schemaData);
		else
			ErrorNoHalt("[Clockwork] The schema has no "..schemaFolder..".ini!\n");
		end;
		
		if (cwFile.Exists(directory.."/sh_schema.lua", "LUA")) then
			AddCSLuaFile(directory.."/sh_schema.lua");
			include(directory.."/sh_schema.lua");
		else
			ErrorNoHalt("[Clockwork] The schema has no sh_schema.lua.\n");
		end;

		Schema:Register();
	else
		PLUGIN = self:New();
		
		if (SERVER) then
			local iniDir = "gamemodes/"..Clockwork.kernel:RemoveTextFromEnd(directory, "/plugin"); 
			local iniTable = Clockwork.config:LoadINI(iniDir.."/plugin.ini", true, true);
			
			if (iniTable and iniTable["Plugin"]) then
				iniTable = iniTable["Plugin"];
				iniTable.isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
					table.Merge(PLUGIN, iniTable);
				CW_SCRIPT_SHARED.plugins[pathCRC] = iniTable;
			else
				ErrorNoHalt("[Clockwork] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
			end;
		else
			local iniTable = CW_SCRIPT_SHARED.plugins[pathCRC];
			
			if (iniTable) then
				table.Merge(PLUGIN, iniTable);
				
				if (iniTable.isUnloaded) then
					self.unloaded[PLUGIN_FOLDERNAME] = true;
				end;
			else
				ErrorNoHalt("[Clockwork] The "..PLUGIN_FOLDERNAME.." plugin has no plugin.ini!\n");
			end;
		end;
		
		local isUnloaded = self:IsUnloaded(PLUGIN_FOLDERNAME, true);
		local isDisabled = self:IsDisabled(PLUGIN_FOLDERNAME, true);
		local shPluginDir = directory.."/sh_plugin.lua";
		local addCSLua = true;
		
		if (!isUnloaded and !isDisabled) then
			if (cwFile.Exists(shPluginDir, "LUA")) then
				Clockwork.kernel:IncludePrefixed(shPluginDir);
			end;
			
			addCSLua = false;
		end;
		
		if (SERVER and addCSLua) then
			AddCSLuaFile(shPluginDir);
		end;
		
		PLUGIN:Register();
		PLUGIN = nil;
	end;
end;

-- A function to create a new plugin.
function Clockwork.plugin:New()
	local pluginTable = Clockwork.kernel:NewMetaTable(PLUGIN_META);
	pluginTable.baseDir = PLUGIN_BASE_DIR;
	pluginTable.folderName = PLUGIN_FOLDERNAME;
	
	return pluginTable;
end;

-- A function to sort a list of plugins storted by k, v.
function Clockwork.plugins:SortList(pluginList)
	local sortedTable = {};
	
	for k, v in pairs(pluginList) do
		sortedTable[#sortedTable + 1] = v;
	end;
	
	table.sort(sortedTable, function(a, b)
		return a:GetHookOrder() > b:GetHookOrder();
	end);
	
	return sortedTable;
end;

-- A function to run the plugin hooks.
function Clockwork.plugin:RunHooks(name, bGamemode, ...)
	if (not self.sortedModules) then
		self.sortedModules = self:SortList(self.modules);
	end;
	
	if (not self.sortedPlugins) then
		self.sortedPlugins = self:SortList(self.stored);
	end;

	for k, v in ipairs(self.sortedModules) do
		if (self.modules[v.name] and v[name]) then
			local bSuccess, value = pcall(v[name], v, ...);
			
			if (!bSuccess) then
				ErrorNoHalt("[CW::Module::"..v.name.."] The '"..name.."' plugin hook has failed to run.\n"..value.."\n");
			elseif (value != nil) then
				return value;
			end;
		end;
	end;
	
	for k, v in ipairs(self.sortedPlugins) do
		if (self.stored[v.name] and Schema != v and v[name]) then
			local bSuccess, value = pcall(v[name], v, ...);
			
			if (!bSuccess) then
				ErrorNoHalt("[CW::Plugin::"..v:GetName().."] The '"..name.."' plugin hook has failed to run.\n"..value.."\n");
			elseif (value != nil) then
				return value;
			end;
		end;
	end;
	
	if (Schema and Schema[name]) then
		local bSuccess, value = pcall(Schema[name], Schema, ...);
		
		if (!bSuccess) then
			ErrorNoHalt("[CW::Schema::"..Schema:GetName().."] The '"..name.."' schema hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
	
	if (bGamemode and Clockwork[name]) then
		local bSuccess, value = pcall(Clockwork[name], Clockwork, ...);
		
		if (!bSuccess) then
			ErrorNoHalt("[CW::Kernel] The '"..name.."' clockwork hook has failed to run.\n"..value.."\n");
		elseif (value != nil) then
			return value;
		end;
	end;
end;

-- A function to call a function for all plugins.
function Clockwork.plugin:Call(name, ...)
	return self:RunHooks(name, true, ...);
end;

-- A function to remove a module by name.
function Clockwork.plugin:Remove(name)
	self.modules[name] = nil;
end;

-- A function to add a table as a module.
function Clockwork.plugin:Add(name, moduleTable, hookOrder)
	if (not moduleTable.name) then
		moduleTable.name = name;
	end;
	
	moduleTable.hookOrder = hookOrder or 0;
	
	self.modules[name] = moduleTable;
end;

-- A function to include a plugin's entities.
function Clockwork.plugin:IncludeEntities(directory)
	local files, entityFolders = cwFile.Find(directory.."/entities/entities/*", "LUA", "namedesc");

	for k, v in pairs(entityFolders) do
		if (v != ".." and v != ".") then
			ENT = {Type = "anim", Folder = directory.."/entities/entities/"..v};
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/entities/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/entities/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/entities/"..v.."/cl_init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/entities/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/cl_init.lua");
			elseif (cwFile.Exists(directory.."/entities/entities/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/entities/"..v.."/shared.lua");
			end;
			
			scripted_ents.Register(ENT, v); ENT = nil;
		end;
	end;
end;

-- A function to include a plugin's effects.
function Clockwork.plugin:IncludeEffects(directory)
	local files, effectFolders = cwFile.Find(directory.."/entities/effects/*", "LUA", "namedesc");
	
	for k, v in pairs(effectFolders) do
		if (v != ".." and v != ".") then
			if (SERVER) then
				if (cwFile.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/cl_init.lua");
				elseif (cwFile.Exists("gamemodes/"..directory.."/entities/effects/"..v.."/init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/effects/"..v.."/init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/effects/"..v.."/cl_init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/cl_init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			elseif (cwFile.Exists(directory.."/entities/effects/"..v.."/init.lua", "LUA")) then
				EFFECT = {Folder = directory.."/entities/effects/"..v};
					include(directory.."/entities/effects/"..v.."/init.lua");
				effects.Register(EFFECT, v); EFFECT = nil;
			end;
		end;
	end;
end;

-- A function to include a plugin's weapons.
function Clockwork.plugin:IncludeWeapons(directory)
	local files, weaponFolders = cwFile.Find(directory.."/entities/weapons/*", "LUA");

	for k, v in pairs(weaponFolders) do
		if (v != ".." and v != ".") then
			SWEP = { Folder = directory.."/entities/weapons/"..v, Base = "weapon_base", Primary = {}, Secondary = {} };
			
			if (SERVER) then
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/init.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/init.lua");
				elseif (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/shared.lua", "GAME")) then
					include(directory.."/entities/weapons/"..v.."/shared.lua");
				end;
				
				if (file.Exists("gamemodes/"..directory.."/entities/weapons/"..v.."/cl_init.lua", "GAME")) then
					AddCSLuaFile(directory.."/entities/weapons/"..v.."/cl_init.lua");
				end;
			elseif (cwFile.Exists(directory.."/entities/weapons/"..v.."/cl_init.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/cl_init.lua");
			elseif (cwFile.Exists(directory.."/entities/weapons/"..v.."/shared.lua", "LUA")) then
				include(directory.."/entities/weapons/"..v.."/shared.lua");
			end;
			
			weapons.Register(SWEP, v); SWEP = nil;
		end;
	end;
end;

-- A function to include a plugin's plugins.
function Clockwork.plugin:IncludePlugins(directory)
	local files, pluginFolders = cwFile.Find(directory.."/plugins/*", "LUA", "namedesc");
	
	if (!self:HasInitialized()) then
		self:Initialize();
	end;
	
	for k, v in pairs(pluginFolders) do
		self:Include(directory.."/plugins/"..string.lower(v).."/plugin");
	end;
end;

-- A function to include a plugin's extras.
function Clockwork.plugin:IncludeExtras(directory)
	self:IncludeEffects(directory);
	self:IncludeWeapons(directory);
	self:IncludeEntities(directory);
	
	for k, v in pairs(cwFile.Find(directory.."/libraries/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/libraries/"..v);
	end;

	for k, v in pairs(cwFile.Find(directory.."/directory/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/directory/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/system/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/system/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/factions/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/factions/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/classes/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/classes/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/attributes/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/attributes/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/items/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/items/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/derma/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/derma/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/commands/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/commands/"..v);
	end;
	
	for k, v in pairs(cwFile.Find(directory.."/language/*.lua", "LUA", "namedesc")) do
		Clockwork.kernel:IncludePrefixed(directory.."/language/"..v);
	end;
end;

--[[ This table will hold the plugin info, if it doesn't already exist. --]]
if (!CW_SCRIPT_SHARED.plugins) then
	CW_SCRIPT_SHARED.plugins = {};
end;
