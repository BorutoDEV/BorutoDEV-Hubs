do
	local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))();
	local Players = game:GetService("Players");
	local RunService = game:GetService("RunService");
	local ReplicatedStorage = game:GetService("ReplicatedStorage");
	local Workspace = game:GetService("Workspace");
	local CurrentCamera = Workspace.CurrentCamera;
	local LocalPlayer = Players.LocalPlayer;
	local CoreGui = game:GetService("CoreGui");
	local UserInputService = game:GetService("UserInputService");
	local HttpService = game:GetService("HttpService");
	local TeleportService = game:GetService("TeleportService");
	
	-- ==========================================
	-- CONNECTION TRACKING FOR TOGGLE SYSTEM
	-- ==========================================
	local ActiveConnections = {
		RenderStepped = {},
		Stepped = nil,
		Heartbeat = nil,
		PlayerRemoving = nil,
		ChildAdded = {},
		OnTeleport = nil
	}
	local ScriptEnabled = true
	local GUIVisible = true
	local CtrlPressed = false
	
	-- Silent Aimbot Variables
	local SilentAimbot = {
		Enabled = false,
		TargetPart = "Head",
		FOV = 100,
		WallCheck = true,
		TeamCheck = false,
		Prediction = 0.165,
		CircleVisible = true,
		CircleColor = Color3.fromRGB(255, 255, 255),
		CircleRadius = 100,
		SelectedTarget = nil,
		Connection = nil
	}
	
	function gradient(text, startColor, endColor)
		local result = "";
		local length = #text;
		for i = 1, length do
			local t = (i - 1) / math.max(length - 1 , 1) ;
			local r = math.floor((startColor.R + ((endColor.R - startColor.R) * t)) * 255 );
			local g = math.floor((startColor.G + ((endColor.G - startColor.G) * t)) * 255 );
			local b = math.floor((startColor.B + ((endColor.B - startColor.B) * t)) * 255 );
			local char = text:sub(i, i);
			result = result   .. '<font color=\"rgb('   .. r   .. ", "   .. g   .. ", "   .. b   .. ')\">'   .. char   .. "</font>" ;
		end
		return result;
	end
	
	local Confirmed = false;
	WindUI:Popup({
		Title = gradient("Murder Mystery 2", Color3.fromHex("#eb1010"), Color3.fromHex("#1023eb")),
		Icon = "rbxassetid://72462144048455",
		Content = gradient("This script made by", Color3.fromHex("#10eb3c"), Color3.fromHex("#67c97a"))   .. gradient(" BorutoDEV", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9")) ,
		Buttons = {
			{
				Title = gradient("Cancel", Color3.fromHex("#e80909"), Color3.fromHex("#630404")),
				Callback = function()
				end,
				Variant = "Tertiary"
			},
			{
				Title = gradient("Load", Color3.fromHex("#90f09e"), Color3.fromHex("#13ed34")),
				Callback = function()
					Confirmed = true;
				end,
				Variant = "Secondary"
			}
		}
	});
	repeat
		task.wait();
	until Confirmed
	
	WindUI:Notify({
		Title = gradient("Murder Mystery 2", Color3.fromHex("#eb1010"), Color3.fromHex("#1023eb")),
		Content = "Script successfully loaded! Press Ctrl+M to toggle",
		Icon = "check-circle",
		Duration = 5
	});
	
	local Window = WindUI:CreateWindow({
		Title = gradient("Murder Mystery 2 [SUMMER UPDATE]", Color3.fromHex("#001e80"), Color3.fromHex("#ffea00")),
		Icon = "rbxassetid://72462144048455",
		Author = gradient("BorutoDEV", Color3.fromHex("#1bf2b2"), Color3.fromHex("#1bcbf2")),
		Folder = "MM2WindUI",
		Size = UDim2.fromOffset(350, 400),
		Transparent = true,
		Theme = "Dark",
		SideBarWidth = 200,
		UserEnabled = true,
		HasOutline = true
	});
	
	Window:EditOpenButton({
		Title = "Open Daddy's UI",
		Icon = "rbxassetid://72462144048455",
		CornerRadius = UDim.new(2, 6),
		StrokeThickness = 2,
		Color = ColorSequence.new(Color3.fromHex("1E213D"), Color3.fromHex("1F75FE")),
		Draggable = true
	});
	
	local Tabs = {
		MainTab = Window:Tab({
			Title = gradient("MAIN", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "terminal",
			Desc = "Quick access and information"
		}),
		CharacterTab = Window:Tab({
			Title = gradient("CHARACTER", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "file-cog"
		}),
		TeleportTab = Window:Tab({
			Title = gradient("TELEPORT", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "user"
		}),
		EspTab = Window:Tab({
			Title = gradient("ESP", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "eye"
		}),
		AimbotTab = Window:Tab({
			Title = gradient("AIMBOT", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "arrow-right"
		}),
		AutoFarm = Window:Tab({
			Title = gradient("AUTOFARM", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "user"
		}),
		bs = Window:Divider(),
		InnocentTab = Window:Tab({
			Title = gradient("INNOCENT", Color3.fromHex("#0ff707"), Color3.fromHex("#1e690c")),
			Icon = "circle"
		}),
		MurderTab = Window:Tab({
			Title = gradient("MURDER", Color3.fromHex("#e80909"), Color3.fromHex("#630404")),
			Icon = "circle"
		}),
		SheriffTab = Window:Tab({
			Title = gradient("SHERIFF", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9")),
			Icon = "circle"
		}),
		gh = Window:Divider(),
		ServerTab = Window:Tab({
			Title = gradient("SERVER", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "atom",
			Desc = "Server management tools"
		}),
		SettingsTab = Window:Tab({
			Title = gradient("SETTINGS", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "code"
		}),
		ChangelogsTab = Window:Tab({
			Title = gradient("CHANGELOGS", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "info",
			Desc = "Update history and future plans"
		}),
		SocialsTab = Window:Tab({
			Title = gradient("SOCIALS", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "star",
			Desc = "Connect with the developer"
		}),
		b = Window:Divider(),
		WindowTab = Window:Tab({
			Title = gradient("CONFIGURATION", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "settings",
			Desc = "Manage window settings and file configurations."
		}),
		CreateThemeTab = Window:Tab({
			Title = gradient("THEMES", Color3.fromHex("#ffffff"), Color3.fromHex("#636363")),
			Icon = "palette",
			Desc = "Design and apply custom themes."
		})
	};
	
	-- ==========================================
	-- MAIN TAB CONTENT
	-- ==========================================
	Tabs.MainTab:Section({
		Title = gradient("Welcome", Color3.fromHex("#FFD700"), Color3.fromHex("#FFA500"))
	});
	
	Tabs.MainTab:Paragraph({
		Title = "MM2 Script v1.0",
		Desc = "Welcome to BorutoDEV's Murder Mystery 2 Script!\n\nPress Ctrl+M to toggle the script on/off.\nAll features are organized by role tabs.",
		Image = "rbxassetid://72462144048455",
		ImageSize = 48
	});
	
	Tabs.MainTab:Section({
		Title = gradient("Quick Actions", Color3.fromHex("#00ff40"), Color3.fromHex("#008f11"))
	});
	
	Tabs.MainTab:Button({
		Title = "Teleport to Lobby",
		Callback = function()
			local lobby = workspace:FindFirstChild("Lobby");
			if lobby then
				local spawnPoint = lobby:FindFirstChild("SpawnPoint") or lobby:FindFirstChildOfClass("SpawnLocation");
				if not spawnPoint then
					spawnPoint = lobby:FindFirstChildWhichIsA("BasePart") or lobby;
				end
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 3, 0));
					WindUI:Notify({
						Title = "Teleport",
						Content = "Teleported to Lobby!",
						Icon = "check-circle",
						Duration = 2
					});
				end
			else
				WindUI:Notify({
					Title = "Error",
					Content = "Lobby not found!",
					Icon = "x-circle",
					Duration = 2
				});
			end
		end
	});
	
	Tabs.MainTab:Button({
		Title = "Grab Gun (If Available)",
		Callback = function()
			WindUI:Notify({
				Title = "Info",
				Content = "Use Innocent tab for Gun features!",
				Icon = "info",
				Duration = 3
			});
		end
	});
	
	Tabs.MainTab:Section({
		Title = gradient("Controls", Color3.fromHex("#00eaff"), Color3.fromHex("#002a2e"))
	});
	
	Tabs.MainTab:Code({
		Title = "Keybinds:",
		Code = [[• Ctrl + M - Toggle Script On/Off
• Right Click (Hold) - Activate Silent Aimbot
• GUI Tabs - Access all features

Tips:
• Use ESP to find Murderer/Sheriff
• Silent Aimbot works when holding right-click
• Shot Button appears for Sheriff]]
	});
	
	Tabs.MainTab:Section({
		Title = gradient("Status", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2"))
	});
	
	local statusParagraph = Tabs.MainTab:Paragraph({
		Title = "Current Status",
		Desc = "Role: Checking...\nAlive: Yes\nScript: Active",
		Image = "activity",
		ImageSize = 32
	});
	
	task.spawn(function()
		while task.wait(2) do
			local success, roles = pcall(function()
				return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer();
			end);
			local roleText = "Unknown";
			local isAlive = "Yes";
			if success and roles and roles[LocalPlayer.Name] then
				roleText = roles[LocalPlayer.Name].Role or "Unknown";
				if roles[LocalPlayer.Name].Dead or roles[LocalPlayer.Name].Killed then
					isAlive = "No";
				end
			end
			statusParagraph:SetDesc("Role: " .. roleText .. "\nAlive: " .. isAlive .. "\nScript: Active | Toggle: Ctrl+M");
		end
	end);
	
	-- ==========================================
	-- CHARACTER TAB
	-- ==========================================
	local CharacterSettings = {
		WalkSpeed = {
			Value = 16,
			Default = 16,
			Locked = false
		},
		JumpPower = {
			Value = 50,
			Default = 50,
			Locked = false
		}
	};
	
	local function updateCharacter()
		local character = LocalPlayer.Character;
		local humanoid = character:FindFirstChildOfClass("Humanoid");
		if humanoid then
			if not CharacterSettings.WalkSpeed.Locked then
				humanoid.WalkSpeed = CharacterSettings.WalkSpeed.Value;
			end
			if not CharacterSettings.JumpPower.Locked then
				humanoid.JumpPower = CharacterSettings.JumpPower.Value;
			end
		end
	end
	
	Tabs.CharacterTab:Section({
		Title = gradient("Walkspeed", Color3.fromHex("#ff0000"), Color3.fromHex("#300000"))
	});
	
	Tabs.CharacterTab:Slider({
		Title = "Walkspeed",
		Value = {
			Min = 0,
			Max = 200,
			Default = 16
		},
		Callback = function(value)
			CharacterSettings.WalkSpeed.Value = value;
			updateCharacter();
		end
	});
	
	Tabs.CharacterTab:Button({
		Title = "Reset walkspeed",
		Callback = function()
			CharacterSettings.WalkSpeed.Value = CharacterSettings.WalkSpeed.Default;
			updateCharacter();
		end
	});
	
	Tabs.CharacterTab:Toggle({
		Title = "Block walkspeed",
		Default = false,
		Callback = function(state)
			CharacterSettings.WalkSpeed.Locked = state;
			updateCharacter();
		end
	});
	
	Tabs.CharacterTab:Section({
		Title = gradient("JumpPower", Color3.fromHex("#001aff"), Color3.fromHex("#020524"))
	});
	
	Tabs.CharacterTab:Slider({
		Title = "Jumppower",
		Value = {
			Min = 0,
			Max = 200,
			Default = 50
		},
		Callback = function(value)
			CharacterSettings.JumpPower.Value = value;
			updateCharacter();
		end
	});
	
	Tabs.CharacterTab:Button({
		Title = "Reset jumppower",
		Callback = function()
			CharacterSettings.JumpPower.Value = CharacterSettings.JumpPower.Default;
			updateCharacter();
		end
	});
	
	Tabs.CharacterTab:Toggle({
		Title = "Block jumppower",
		Default = false,
		Callback = function(state)
			CharacterSettings.JumpPower.Locked = state;
			updateCharacter();
		end
	});
	
	-- ==========================================
	-- ESP TAB
	-- ==========================================
	local LP = Players.LocalPlayer;
	local ESPConfig = {
		HighlightMurderer = false,
		HighlightInnocent = false,
		HighlightSheriff = false
	};
	local Murder, Sheriff, Hero;
	local roles = {};
	
	function CreateHighlight(player)
		if ((player ~= LP) and player.Character and not player.Character:FindFirstChild("Highlight")) then
			local highlight = Instance.new("Highlight");
			highlight.Parent = player.Character;
			highlight.Adornee = player.Character;
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
			return highlight;
		end
		return player.Character and player.Character:FindFirstChild("Highlight");
	end
	
	function RemoveAllHighlights()
		for _, player in pairs(Players:GetPlayers()) do
			if (player.Character and player.Character:FindFirstChild("Highlight")) then
				player.Character.Highlight:Destroy();
			end
		end
	end
	
	function UpdateHighlights()
		for _, player in pairs(Players:GetPlayers()) do
			if ((player ~= LP) and player.Character) then
				local highlight = player.Character:FindFirstChild("Highlight");
				if not (ESPConfig.HighlightMurderer or ESPConfig.HighlightInnocent or ESPConfig.HighlightSheriff) then
					if highlight then
						highlight:Destroy();
					end
					return;
				end
				local shouldHighlight = false;
				local color = Color3.new(0, 1, 0);
				if ((player.Name == Murder) and IsAlive(player) and ESPConfig.HighlightMurderer) then
					color = Color3.fromRGB(255, 0, 0);
					shouldHighlight = true;
				elseif ((player.Name == Sheriff) and IsAlive(player) and ESPConfig.HighlightSheriff) then
					color = Color3.fromRGB(0, 0, 255);
					shouldHighlight = true;
				elseif (ESPConfig.HighlightInnocent and IsAlive(player) and (player.Name ~= Murder) and (player.Name ~= Sheriff) and (player.Name ~= Hero)) then
					color = Color3.fromRGB(0, 255, 0);
					shouldHighlight = true;
				elseif ((player.Name == Hero) and IsAlive(player) and not IsAlive(game.Players[Sheriff]) and ESPConfig.HighlightSheriff) then
					color = Color3.fromRGB(255, 250, 0);
					shouldHighlight = true;
				end
				if shouldHighlight then
					highlight = CreateHighlight(player);
					if highlight then
						highlight.FillColor = color;
						highlight.OutlineColor = color;
						highlight.Enabled = true;
					end
				elseif highlight then
					highlight.Enabled = false;
				end
			end
		end
	end
	
	function IsAlive(player)
		for name, data in pairs(roles) do
			if (player.Name == name) then
				return not data.Killed and not data.Dead;
			end
		end
		return false;
	end
	
	local function UpdateRoles()
		local success, result = pcall(function()
			return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer();
		end);
		if success then
			roles = result or {};
			for name, data in pairs(roles) do
				if (data.Role == "Murderer") then
					Murder = name;
				elseif (data.Role == "Sheriff") then
					Sheriff = name;
				elseif (data.Role == "Hero") then
					Hero = name;
				end
			end
		end
	end
	
	Tabs.EspTab:Section({
		Title = gradient("Player ESP", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2"))
	});
	
	Tabs.EspTab:Toggle({
		Title = gradient("Highlight Murder", Color3.fromHex("#e80909"), Color3.fromHex("#630404")),
		Default = false,
		Callback = function(state)
			ESPConfig.HighlightMurderer = state;
			if not state then
				UpdateHighlights();
			end
		end
	});
	
	Tabs.EspTab:Toggle({
		Title = gradient("Highlight Innocent", Color3.fromHex("#0ff707"), Color3.fromHex("#1e690c")),
		Default = false,
		Callback = function(state)
			ESPConfig.HighlightInnocent = state;
			if not state then
				UpdateHighlights();
			end
		end
	});
	
	Tabs.EspTab:Toggle({
		Title = gradient("Highlight Sheriff", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9")),
		Default = false,
		Callback = function(state)
			ESPConfig.HighlightSheriff = state;
			if not state then
				UpdateHighlights();
			end
		end
	});
	
	local gunDropESPEnabled = false;
	local mapPaths = {
		"ResearchFacility",
		"Hospital3",
		"MilBase",
		"House2",
		"Workplace",
		"Mansion2",
		"BioLab",
		"Hotel",
		"Factory",
		"Bank2",
		"PoliceStation"
	};
	
	local function createGunDropHighlight(gunDrop)
		if (gunDropESPEnabled and gunDrop and not gunDrop:FindFirstChild("GunDropHighlight")) then
			local highlight = Instance.new("Highlight");
			highlight.Name = "GunDropHighlight";
			highlight.FillColor = Color3.fromRGB(255, 215, 0);
			highlight.OutlineColor = Color3.fromRGB(255, 165, 0);
			highlight.Adornee = gunDrop;
			highlight.Parent = gunDrop;
		end
	end
	
	local function updateGunDropESP()
		for _, mapName in pairs(mapPaths) do
			local map = workspace:FindFirstChild(mapName);
			if map then
				local gunDrop = map:FindFirstChild("GunDrop");
				if (gunDrop and gunDrop:FindFirstChild("GunDropHighlight")) then
					gunDrop.GunDropHighlight:Destroy();
				end
			end
		end
		if gunDropESPEnabled then
			for _, mapName in pairs(mapPaths) do
				local map = workspace:FindFirstChild(mapName);
				if map then
					local gunDrop = map:FindFirstChild("GunDrop");
					if gunDrop then
						createGunDropHighlight(gunDrop);
					end
				end
			end
		end
	end
	
	local function monitorGunDrops()
		for _, mapName in pairs(mapPaths) do
			local map = workspace:FindFirstChild(mapName);
			if map then
				local conn = map.ChildAdded:Connect(function(child)
					if (child.Name == "GunDrop") then
						createGunDropHighlight(child);
					end
				end);
				table.insert(ActiveConnections.ChildAdded, conn);
			end
		end
	end
	monitorGunDrops();
	
	Tabs.EspTab:Toggle({
		Title = gradient("GunDrop Highlight", Color3.fromHex("#ffff00"), Color3.fromHex("#4f4f00")),
		Default = false,
		Callback = function(state)
			gunDropESPEnabled = state;
			updateGunDropESP();
		end
	});
	
	local workspaceChildConn = workspace.ChildAdded:Connect(function(child)
		if table.find(mapPaths, child.Name) then
			task.wait(2);
			updateGunDropESP();
		end
	end);
	table.insert(ActiveConnections.ChildAdded, workspaceChildConn);
	
	local espRenderConn = RunService.RenderStepped:Connect(function()
		UpdateRoles();
		if (ESPConfig.HighlightMurderer or ESPConfig.HighlightInnocent or ESPConfig.HighlightSheriff) then
			UpdateHighlights();
		end
	end);
	table.insert(ActiveConnections.RenderStepped, espRenderConn);
	
	local playerRemoveConn = Players.PlayerRemoving:Connect(function(player)
		if (player == LP) then
			RemoveAllHighlights();
		end
	end);
	ActiveConnections.PlayerRemoving = playerRemoveConn;
	
	-- ==========================================
	-- TELEPORT TAB
	-- ==========================================
	Tabs.TeleportTab:Section({
		Title = gradient("Default TP", Color3.fromHex("#00448c"), Color3.fromHex("#0affd6"))
	});
	
	local teleportTarget = nil;
	local teleportDropdown = nil;
	
	local function updateTeleportPlayers()
		local playersList = {
			"Select Player"
		};
		for _, player in pairs(Players:GetPlayers()) do
			if (player ~= LocalPlayer) then
				table.insert(playersList, player.Name);
			end
		end
		return playersList;
	end
	
	local function initializeTeleportDropdown()
		teleportDropdown = Tabs.TeleportTab:Dropdown({
			Title = "Players",
			Values = updateTeleportPlayers(),
			Value = "Select Player",
			Callback = function(selected)
				if (selected ~= "Select Player") then
					teleportTarget = Players:FindFirstChild(selected);
				else
					teleportTarget = nil;
				end
			end
		});
	end
	initializeTeleportDropdown();
	
	local playerAddedConn = Players.PlayerAdded:Connect(function(player)
		task.wait(1);
		if teleportDropdown then
			teleportDropdown:Refresh(updateTeleportPlayers());
		end
	end);
	table.insert(ActiveConnections.ChildAdded, playerAddedConn);
	
	local playerRemoveConn2 = Players.PlayerRemoving:Connect(function(player)
		if teleportDropdown then
			teleportDropdown:Refresh(updateTeleportPlayers());
		end
	end);
	table.insert(ActiveConnections.ChildAdded, playerRemoveConn2);
	
	local function teleportToPlayer()
		if (teleportTarget and teleportTarget.Character) then
			local targetRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart");
			local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			if (targetRoot and localRoot) then
				localRoot.CFrame = targetRoot.CFrame;
				WindUI:Notify({
					Title = "Teleport",
					Content = "Successfully teleported to " .. teleportTarget.Name,
					Icon = "check-circle",
					Duration = 3
				});
			end
		else
			WindUI:Notify({
				Title = "Error",
				Content = "Target not found or unavailable",
				Icon = "x-circle",
				Duration = 3
			});
		end
	end
	
	Tabs.TeleportTab:Button({
		Title = "Teleport to player",
		Callback = teleportToPlayer
	});
	
	Tabs.TeleportTab:Button({
		Title = "Update players list",
		Callback = function()
			teleportDropdown:Refresh(updateTeleportPlayers());
		end
	});
	
	Tabs.TeleportTab:Section({
		Title = gradient("Special TP", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2"))
	});
	
	Tabs.TeleportTab:Button({
		Title = "Teleport to Lobby",
		Callback = function()
			local lobby = workspace:FindFirstChild("Lobby");
			if not lobby then
				WindUI:Notify({
					Title = "Teleport",
					Content = "Lobby not found!",
					Icon = "x-circle",
					Duration = 2
				});
				return;
			end
			local spawnPoint = lobby:FindFirstChild("SpawnPoint") or lobby:FindFirstChildOfClass("SpawnLocation");
			if not spawnPoint then
				spawnPoint = lobby:FindFirstChildWhichIsA("BasePart") or lobby;
			end
			if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 3, 0));
				WindUI:Notify({
					Title = "Teleport",
					Content = "Teleported to Lobby!",
					Icon = "check-circle",
					Duration = 2
				});
			end
		end
	});
	
	Tabs.TeleportTab:Button({
		Title = "Teleport to Sheriff",
		Callback = function()
			UpdateRoles();
			if Sheriff then
				local sheriffPlayer = Players:FindFirstChild(Sheriff);
				if (sheriffPlayer and sheriffPlayer.Character) then
					local targetRoot = sheriffPlayer.Character:FindFirstChild("HumanoidRootPart");
					local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
					if (targetRoot and localRoot) then
						localRoot.CFrame = targetRoot.CFrame;
						WindUI:Notify({
							Title = "Teleport",
							Content = "Successfully teleported to the Sheriff " .. Sheriff,
							Icon = "check-circle",
							Duration = 3
						});
					end
				else
					WindUI:Notify({
						Title = "Error",
						Content = "Sheriff not found or unavailable",
						Icon = "x-circle",
						Duration = 3
					});
				end
			else
				WindUI:Notify({
					Title = "Error",
					Content = "Sheriff not defined in the current match",
					Icon = "x-circle",
					Duration = 3
				});
			end
		end
	});
	
	Tabs.TeleportTab:Button({
		Title = "Teleport to Murderer",
		Callback = function()
			UpdateRoles();
			if Murder then
				local murderPlayer = Players:FindFirstChild(Murder);
				if (murderPlayer and murderPlayer.Character) then
					local targetRoot = murderPlayer.Character:FindFirstChild("HumanoidRootPart");
					local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
					if (targetRoot and localRoot) then
						localRoot.CFrame = targetRoot.CFrame;
						WindUI:Notify({
							Title = "Teleport",
							Content = "Successfully teleported to the Murderer " .. Murder,
							Icon = "check-circle",
							Duration = 3
						});
					end
				else
					WindUI:Notify({
						Title = "Error",
						Content = "Murderer not found or unavailable",
						Icon = "x-circle",
						Duration = 3
					});
				end
			else
				WindUI:Notify({
					Title = "Error",
					Content = "Murderer not defined in the current match",
					Icon = "x-circle",
					Duration = 3
				});
			end
		end
	});
	
	-- ==========================================
	-- AIMBOT TAB
	-- ==========================================
	Tabs.AimbotTab:Section({
		Title = gradient("Camera Aimbot", Color3.fromHex("#00448c"), Color3.fromHex("#0affd6"))
	});
	
	local isCameraLocked = false;
	local isSpectating = false;
	local lockedRole = nil;
	local cameraConnection = nil;
	local originalCameraType = Enum.CameraType.Custom;
	local originalCameraSubject = nil;
	
	Tabs.AimbotTab:Dropdown({
		Title = "Target Role",
		Values = {
			"None",
			"Sheriff",
			"Murderer"
		},
		Value = "None",
		Callback = function(selected)
			lockedRole = ((selected ~= "None") and selected) or nil;
		end
	});
	
	Tabs.AimbotTab:Toggle({
		Title = "Spectate Mode",
		Default = false,
		Callback = function(state)
			isSpectating = state;
			if state then
				originalCameraType = CurrentCamera.CameraType;
				originalCameraSubject = CurrentCamera.CameraSubject;
				CurrentCamera.CameraType = Enum.CameraType.Scriptable;
			else
				CurrentCamera.CameraType = originalCameraType;
				CurrentCamera.CameraSubject = originalCameraSubject;
			end
		end
	});
	
	Tabs.AimbotTab:Toggle({
		Title = "Lock Camera",
		Default = false,
		Callback = function(state)
			isCameraLocked = state;
			if (not state and not isSpectating) then
				CurrentCamera.CameraType = originalCameraType;
				CurrentCamera.CameraSubject = originalCameraSubject;
			end
		end
	});
	
	local function GetTargetPosition()
		if not lockedRole then
			return nil;
		end
		local targetName = ((lockedRole == "Sheriff") and Sheriff) or Murder;
		if not targetName then
			return nil;
		end
		local player = Players:FindFirstChild(targetName);
		if (not player or not IsAlive(player)) then
			return nil;
		end
		local character = player.Character;
		if not character then
			return nil;
		end
		local head = character:FindFirstChild("Head");
		return (head and head.Position) or nil;
	end
	
	local function UpdateSpectate()
		if (not isSpectating or not lockedRole) then
			return;
		end
		local targetPos = GetTargetPosition();
		if not targetPos then
			return;
		end
		local offset = CFrame.new(0, 2, 8);
		local targetChar = Players:FindFirstChild(((lockedRole == "Sheriff") and Sheriff) or Murder).Character;
		if targetChar then
			local root = targetChar:FindFirstChild("HumanoidRootPart");
			if root then
				CurrentCamera.CFrame = root.CFrame * offset;
			end
		end
	end
	
	local function UpdateLockCamera()
		if (not isCameraLocked or not lockedRole) then
			return;
		end
		local targetPos = GetTargetPosition();
		if not targetPos then
			return;
		end
		local currentPos = CurrentCamera.CFrame.Position;
		CurrentCamera.CFrame = CFrame.new(currentPos, targetPos);
	end
	
	local function Update()
		if isSpectating then
			UpdateSpectate();
		elseif isCameraLocked then
			UpdateLockCamera();
		end
	end
	
	cameraConnection = RunService.RenderStepped:Connect(Update);
	table.insert(ActiveConnections.RenderStepped, cameraConnection);

	-- ==========================================
	-- SILENT AIMBOT
	-- ==========================================
	Tabs.AimbotTab:Section({
		Title = gradient("Silent Aimbot", Color3.fromHex("#ff0000"), Color3.fromHex("#ff6600"))
	});
	
	-- FOV Circle Drawing
	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Visible = false
	FOVCircle.Thickness = 1.5
	FOVCircle.NumSides = 64
	FOVCircle.Radius = 100
	FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	FOVCircle.Filled = false
	
	-- Get Closest Murderer to Mouse (Only targets the Murderer)
	local function GetClosestTargetToMouse()
		local closestPlayer = nil
		local shortestDistance = SilentAimbot.FOV
		
		for _, player in pairs(Players:GetPlayers()) do
			-- Check if the player is the active Murderer
			if player ~= LocalPlayer and player.Character and player.Name == Murder then
				local targetPart = player.Character:FindFirstChild(SilentAimbot.TargetPart)
				if targetPart then
					local pos, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)
					if onScreen then
						local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
						-- Detect if they are inside the adjustable FOV circle
						if distance <= SilentAimbot.FOV then
							if IsAlive(player) then
								if SilentAimbot.WallCheck then
									local ray = Ray.new(CurrentCamera.CFrame.Position, (targetPart.Position - CurrentCamera.CFrame.Position).Unit * 1000)
									local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
									if not hit or hit:IsDescendantOf(player.Character) then
										closestPlayer = player
										shortestDistance = distance
									end
								else
									closestPlayer = player
									shortestDistance = distance
								end
							end
						end
					end
				end
			end
		end
		
		return closestPlayer
	end
	
	local lastAutoShoot = 0
	local autoShootCooldown = 1.2 -- Prevents remote event spamming/crashing
	
	Tabs.AimbotTab:Toggle({
		Title = "Enable Silent Auto-Shoot",
		Default = false,
		Callback = function(state)
			SilentAimbot.Enabled = state
			FOVCircle.Visible = state and SilentAimbot.CircleVisible
			
			if state then
				WindUI:Notify({
					Title = "Silent Aimbot",
					Content = "Enabled! Murderers in the FOV get shot automatically.",
					Icon = "check-circle",
					Duration = 3
				})
				
				SilentAimbot.Connection = RunService.RenderStepped:Connect(function()
					FOVCircle.Position = UserInputService:GetMouseLocation()
					FOVCircle.Radius = SilentAimbot.FOV
					FOVCircle.Color = SilentAimbot.CircleColor
					FOVCircle.Visible = SilentAimbot.CircleVisible and SilentAimbot.Enabled
					
					-- No activation key required; runs autonomously when toggled ON
					if SilentAimbot.Enabled then
						local target = GetClosestTargetToMouse()
						if target and target.Character then
							local targetPart = target.Character:FindFirstChild(SilentAimbot.TargetPart)
							if targetPart then
								local targetVelocity = target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Velocity or Vector3.new(0, 0, 0)
								local predictedPosition = targetPart.Position + (targetVelocity * SilentAimbot.Prediction)
								
								-- Camera is NOT snapped here, making it a true silent aimbot.
								
								local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
								if gun and gun:FindFirstChild("KnifeLocal") then
									-- Cooldown check so we don't spam the server remote 60 times a second
									if tick() - lastAutoShoot >= autoShootCooldown then
										pcall(function()
											gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, predictedPosition, "AH2")
											lastAutoShoot = tick()
										end)
									end
								end
							end
						end
					end
				end)
				table.insert(ActiveConnections.RenderStepped, SilentAimbot.Connection)
			else
				if SilentAimbot.Connection then
					SilentAimbot.Connection:Disconnect()
					SilentAimbot.Connection = nil
				end
				FOVCircle.Visible = false
			end
		end
	});
	
	Tabs.AimbotTab:Dropdown({
		Title = "Target Part",
		Values = {"Head", "HumanoidRootPart", "Torso"},
		Value = "Head",
		Callback = function(selected)
			SilentAimbot.TargetPart = selected
		end
	});
	
	Tabs.AimbotTab:Slider({
		Title = "FOV Radius",
		Value = {
			Min = 50,
			Max = 500,
			Default = 100
		},
		Callback = function(value)
			SilentAimbot.FOV = value
		end
	});
	
	Tabs.AimbotTab:Slider({
		Title = "Prediction",
		Step = 0.01,
		Value = {
			Min = 0,
			Max = 0.5,
			Default = 0.165
		},
		Callback = function(value)
			SilentAimbot.Prediction = value
		end
	});
	
	Tabs.AimbotTab:Toggle({
		Title = "Show FOV Circle",
		Default = true,
		Callback = function(state)
			SilentAimbot.CircleVisible = state
			if SilentAimbot.Enabled then
				FOVCircle.Visible = state
			end
		end
	});
	
	Tabs.AimbotTab:Colorpicker({
		Title = "FOV Circle Color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			SilentAimbot.CircleColor = color
		end
	});
	
	Tabs.AimbotTab:Toggle({
		Title = "Wall Check",
		Default = true,
		Callback = function(state)
			SilentAimbot.WallCheck = state
		end
	});
	
	Tabs.AimbotTab:Code({
		Title = "How to use:",
		Code = [[Silent Auto-Shoot Instructions:
1. Enable Silent Auto-Shoot.
2. Hold your Gun out.
3. Keep the FOV circle near doorways or paths.
4. If the Murderer enters your circle, the script shoots them automatically!

Tips:
• The camera will not snap (True Silent Aim).
• Adjust FOV to make the detection circle wider or smaller.
• Prediction adjusts automatically to the target.
• Target Part: Head = Best chance of bypassing hit-reg delays.]]
	});
	
	-- ==========================================
	-- AUTOFARM TAB
	-- ==========================================
	local AutoFarm = {
		Enabled = false,
		Mode = "Teleport",
		TeleportDelay = 0,
		MoveSpeed = 50,
		WalkSpeed = 32,
		Connection = nil,
		CoinCheckInterval = 0.5,
		CoinContainers = {
			"Factory",
			"Hospital3",
			"MilBase",
			"House2",
			"Workplace",
			"Mansion2",
			"BioLab",
			"Hotel",
			"Bank2",
			"PoliceStation",
			"ResearchFacility",
			"Lobby"
		}
	};
	
	local function findNearestCoin()
		local closestCoin = nil;
		local shortestDistance = math.huge;
		local character = LocalPlayer.Character;
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart");
		if not humanoidRootPart then
			return nil;
		end
		
		for _, containerName in ipairs(AutoFarm.CoinContainers) do
			local container = workspace:FindFirstChild(containerName);
			if container then
				local coinContainer = ((containerName == "Lobby") and container) or container:FindFirstChild("CoinContainer");
				if coinContainer then
					for _, coin in ipairs(coinContainer:GetChildren()) do
						if coin:IsA("BasePart") then
							local distance = (humanoidRootPart.Position - coin.Position).Magnitude;
							if distance < shortestDistance then
								shortestDistance = distance;
								closestCoin = coin;
							end
						end
					end
				end
			end
		end
		return closestCoin;
	end
	
	local function teleportToCoin(coin)
		if (not coin or not LocalPlayer.Character) then
			return;
		end
		local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if not humanoidRootPart then
			return;
		end
		humanoidRootPart.CFrame = CFrame.new(coin.Position + Vector3.new(0, 3, 0));
		task.wait(AutoFarm.TeleportDelay);
	end
	
	local function smoothMoveToCoin(coin)
		if (not coin or not LocalPlayer.Character) then
			return;
		end
		local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if not humanoidRootPart then
			return;
		end
		
		local startTime = tick();
		local startPos = humanoidRootPart.Position;
		local endPos = coin.Position + Vector3.new(0, 3, 0);
		local distance = (startPos - endPos).Magnitude;
		local duration = distance / AutoFarm.MoveSpeed;
		
		while (tick() - startTime) < duration and AutoFarm.Enabled do
			if (not coin or not coin.Parent) then
				break;
			end
			local progress = math.min((tick() - startTime) / duration, 1);
			humanoidRootPart.CFrame = CFrame.new(startPos:Lerp(endPos, progress));
			task.wait();
		end
	end
	
	local function walkToCoin(coin)
		if (not coin or not LocalPlayer.Character) then
			return;
		end
		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid");
		if not humanoid then
			return;
		end
		
		humanoid.WalkSpeed = AutoFarm.WalkSpeed;
		humanoid:MoveTo(coin.Position + Vector3.new(0, 0, 3));
		local startTime = tick();
		while AutoFarm.Enabled and (humanoid.MoveDirection.Magnitude > 0) and (tick() - startTime) < 10 do
			task.wait(0.5);
		end
	end
	
	local function collectCoin(coin)
		if (not coin or not LocalPlayer.Character) then
			return;
		end
		local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if not humanoidRootPart then
			return;
		end
		
		firetouchinterest(humanoidRootPart, coin, 0);
		firetouchinterest(humanoidRootPart, coin, 1);
	end
	
	local function farmLoop()
		while AutoFarm.Enabled do
			local coin = findNearestCoin();
			if coin then
				if AutoFarm.Mode == "Teleport" then
					teleportToCoin(coin);
				elseif AutoFarm.Mode == "Smooth" then
					smoothMoveToCoin(coin);
				else
					walkToCoin(coin);
				end
				collectCoin(coin);
			else
				task.wait(2);
			end
			task.wait(AutoFarm.CoinCheckInterval);
		end
	end
	
	Tabs.AutoFarm:Section({
		Title = gradient("Coin Farming", Color3.fromHex("#FFD700"), Color3.fromHex("#ADD8E6"))
	});
	
	Tabs.AutoFarm:Dropdown({
		Title = "Movement Mode",
		Values = {
			"Teleport",
			"Smooth",
			"Walk"
		},
		Value = "Teleport",
		Callback = function(mode)
			AutoFarm.Mode = mode;
		end
	});
	
	Tabs.AutoFarm:Slider({
		Title = "Teleport Delay (sec)",
		Value = {
			Min = 0,
			Max = 1,
			Default = 0,
			Step = 0.1
		},
		Callback = function(value)
			AutoFarm.TeleportDelay = value;
		end
	});
	
	Tabs.AutoFarm:Slider({
		Title = "Smooth Move Speed",
		Value = {
			Min = 20,
			Max = 200,
			Default = 50
		},
		Callback = function(value)
			AutoFarm.MoveSpeed = value;
		end
	});
	
	Tabs.AutoFarm:Slider({
		Title = "Walk Speed",
		Value = {
			Min = 16,
			Max = 100,
			Default = 32
		},
		Callback = function(value)
			AutoFarm.WalkSpeed = value;
		end
	});
	
	Tabs.AutoFarm:Slider({
		Title = "Check Interval (sec)",
		Step = 0.1,
		Value = {
			Min = 0.1,
			Max = 2,
			Default = 0.5
		},
		Callback = function(value)
			AutoFarm.CoinCheckInterval = value;
		end
	});
	
	Tabs.AutoFarm:Toggle({
		Title = "Enable AutoFarm",
		Default = false,
		Callback = function(state)
			AutoFarm.Enabled = state;
			if state then
				AutoFarm.Connection = task.spawn(farmLoop);
				WindUI:Notify({
					Title = "AutoFarm",
					Content = "Started!",
					Icon = "check-circle",
					Duration = 2
				});
			else
				if AutoFarm.Connection then
					task.cancel(AutoFarm.Connection);
					AutoFarm.Connection = nil;
				end
				WindUI:Notify({
					Title = "AutoFarm",
					Content = "Stopped!",
					Icon = "x-circle",
					Duration = 2
				});
			end
		end
	});
	
	Tabs.AutoFarm:Toggle({
		Title = "Enable Beach Ball AutoFarm",
		Default = false,
		Callback = function(state)
			if state then
				task.spawn(function()
					loadstring(game:HttpGet("https://raw.githubusercontent.com/NoovaScripts/roblox/refs/heads/main/beachballfarm"))()
				end);
				WindUI:Notify({
					Title = "AutoFarm",
					Content = "Beach Ball farm started!",
					Icon = "check-circle",
					Duration = 2
				});
			end
		end
	});
	
	-- ==========================================
	-- INNOCENT TAB
	-- ==========================================
	local GunSystem = {
		AutoGrabEnabled = false,
		NotifyGunDrop = true,
		GunDropCheckInterval = 1,
		ActiveGunDrops = {},
	};
	
	local function ScanForGunDrops()
		GunSystem.ActiveGunDrops = {};
		for _, mapName in ipairs(mapPaths) do
			local map = workspace:FindFirstChild(mapName);
			if map then
				local gunDrop = map:FindFirstChild("GunDrop");
				if gunDrop then
					table.insert(GunSystem.ActiveGunDrops, gunDrop);
				end
			end
		end
	end
	
	local function EquipGun()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
			return true;
		end
		local gun = LocalPlayer.Backpack:FindFirstChild("Gun");
		if gun then
			gun.Parent = LocalPlayer.Character;
			task.wait(0.1);
			return LocalPlayer.Character:FindFirstChild("Gun") ~= nil;
		end
		return false;
	end
	
	local function GrabGun(gunDrop)
		if not gunDrop then
			ScanForGunDrops();
			if #GunSystem.ActiveGunDrops == 0 then
				WindUI:Notify({
					Title = "Gun System",
					Content = "No guns available!",
					Icon = "x-circle",
					Duration = 3
				});
				return false;
			end
			local nearestGun = nil;
			local minDistance = math.huge;
			local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			if humanoidRootPart then
				for _, drop in ipairs(GunSystem.ActiveGunDrops) do
					local distance = (humanoidRootPart.Position - drop.Position).Magnitude;
					if distance < minDistance then
						minDistance = distance;
						nearestGun = drop;
					end
				end
			end
			gunDrop = nearestGun;
		end
		
		if gunDrop and LocalPlayer.Character then
			local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			if humanoidRootPart then
				humanoidRootPart.CFrame = gunDrop.CFrame;
				task.wait(0.3);
				local prompt = gunDrop:FindFirstChildOfClass("ProximityPrompt");
				if prompt then
					fireproximityprompt(prompt);
					WindUI:Notify({
						Title = "Gun System",
						Content = "Gun grabbed!",
						Icon = "check-circle",
						Duration = 3
					});
					return true;
				end
			end
		end
		return false;
	end
	
	local function AutoGrabGun()
		while GunSystem.AutoGrabEnabled do
			ScanForGunDrops();
			if #GunSystem.ActiveGunDrops > 0 and LocalPlayer.Character then
				local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
				if humanoidRootPart then
					local nearestGun = nil;
					local minDistance = math.huge;
					for _, gunDrop in ipairs(GunSystem.ActiveGunDrops) do
						local distance = (humanoidRootPart.Position - gunDrop.Position).Magnitude;
						if distance < minDistance then
							nearestGun = gunDrop;
							minDistance = distance;
						end
					end
					if nearestGun then
						humanoidRootPart.CFrame = nearestGun.CFrame;
						task.wait(0.3);
						local prompt = nearestGun:FindFirstChildOfClass("ProximityPrompt");
						if prompt then
							fireproximityprompt(prompt);
							task.wait(1);
						end
					end
				end
			end
			task.wait(GunSystem.GunDropCheckInterval);
		end
	end
	
	Tabs.InnocentTab:Section({
		Title = gradient("Gun Functions", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9"))
	});
	
	Tabs.InnocentTab:Toggle({
		Title = "Notify GunDrop",
		Default = true,
		Callback = function(state)
			gunDropESPEnabled = state;
		end
	});
	
	Tabs.InnocentTab:Button({
		Title = "Grab Gun",
		Callback = function()
			GrabGun();
		end
	});
	
	Tabs.InnocentTab:Toggle({
		Title = "Auto Grab Gun",
		Default = false,
		Callback = function(state)
			GunSystem.AutoGrabEnabled = state;
			if state then
				coroutine.wrap(AutoGrabGun)();
			end
		end
	});
	
	Tabs.InnocentTab:Button({
		Title = "Grab Gun & Shoot Murderer",
		Callback = function()
			if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then
				if not GrabGun() then
					return;
				end
				task.wait(0.1);
			end
			if not EquipGun() then
				return;
			end
			
			local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer();
			local murderer = nil;
			for name, data in pairs(roles) do
				if data.Role == "Murderer" then
					murderer = Players:FindFirstChild(name);
					break;
				end
			end
			
			if not murderer or not murderer.Character then
				WindUI:Notify({
					Title = "Gun System",
					Content = "Murderer not found!",
					Icon = "x-circle",
					Duration = 3
				});
				return;
			end
			
			local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart");
			local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
			if targetRoot and localRoot then
				localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4);
				task.wait(0.1);
			end
			
			local gun = LocalPlayer.Character:FindFirstChild("Gun");
			if gun and gun:FindFirstChild("KnifeLocal") then
				local args = {[1] = 1, [2] = targetRoot.Position, [3] = "AH2"};
				gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args));
				WindUI:Notify({
					Title = "Gun System",
					Content = "Murderer shot!",
					Icon = "check-circle",
					Duration = 3
				});
			end
		end
	});
	
	-- ==========================================
	-- MURDER TAB
	-- ==========================================
	local killActive = false;
	local attackDelay = 0.5;
	
	local function equipKnife()
		local character = LocalPlayer.Character;
		if not character then
			return false;
		end
		if character:FindFirstChild("Knife") then
			return true;
		end
		local knife = LocalPlayer.Backpack:FindFirstChild("Knife");
		if knife then
			knife.Parent = character;
			return true;
		end
		return false;
	end
	
	local function getNearestTarget()
		local targets = {};
		local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer();
		local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if not localRoot then
			return nil;
		end
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local role = nil;
				if roles and roles[player.Name] then
					role = roles[player.Name].Role;
				end
				local humanoid = player.Character:FindFirstChild("Humanoid");
				local targetRoot = player.Character:FindFirstChild("HumanoidRootPart");
				if role and humanoid and humanoid.Health > 0 and targetRoot then
					if role ~= "Murderer" then
						table.insert(targets, {
							Player = player,
							Distance = (localRoot.Position - targetRoot.Position).Magnitude
						});
					end
				end
			end
		end
		table.sort(targets, function(a, b)
			return a.Distance < b.Distance;
		end);
		return targets[1] and targets[1].Player or nil;
	end
	
	local function attackTarget(target)
		if not target or not target.Character then
			return false;
		end
		local humanoid = target.Character:FindFirstChild("Humanoid");
		if not humanoid or humanoid.Health <= 0 then
			return false;
		end
		if not equipKnife() then
			return false;
		end
		
		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart");
		local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if targetRoot and localRoot then
			localRoot.CFrame = CFrame.new(targetRoot.Position + ((localRoot.Position - targetRoot.Position).Unit * 2), targetRoot.Position);
		end
		
		local knife = LocalPlayer.Character:FindFirstChild("Knife");
		if knife and knife:FindFirstChild("Stab") then
			for i = 1, 3 do
				knife.Stab:FireServer("Down");
			end
			return true;
		end
		return false;
	end
	
	local function killTargets()
		if killActive then
			return;
		end
		killActive = true;
		WindUI:Notify({
			Title = "Kill Targets",
			Content = "Starting...",
			Icon = "alert-circle",
			Duration = 2
		});
		
		task.spawn(function()
			while killActive do
				local target = getNearestTarget();
				if not target then
					killActive = false;
					WindUI:Notify({
						Title = "Kill Targets",
						Content = "No targets!",
						Icon = "x-circle",
						Duration = 3
					});
					break;
				end
				attackTarget(target);
				task.wait(attackDelay);
			end
		end);
	end
	
	local function stopKilling()
		killActive = false;
		WindUI:Notify({
			Title = "Kill Targets",
			Content = "Stopped",
			Icon = "x-circle",
			Duration = 2
		});
	end
	
	Tabs.MurderTab:Section({
		Title = gradient("Kill Functions", Color3.fromHex("#e80909"), Color3.fromHex("#630404"))
	});
	
	Tabs.MurderTab:Toggle({
		Title = "Kill All",
		Default = false,
		Callback = function(state)
			if state then
				killTargets();
			else
				stopKilling();
			end
		end
	});
	
	Tabs.MurderTab:Slider({
		Title = "Attack Delay",
		Step = 0.1,
		Value = {
			Min = 0.1,
			Max = 2,
			Default = 0.5
		},
		Callback = function(value)
			attackDelay = value;
		end
	});
	
	Tabs.MurderTab:Button({
		Title = "Equip Knife",
		Callback = function()
			if equipKnife() then
				WindUI:Notify({
					Title = "Knife",
					Content = "Equipped!",
					Icon = "check-circle",
					Duration = 2
				});
			else
				WindUI:Notify({
					Title = "Knife",
					Content = "Not found!",
					Icon = "x-circle",
					Duration = 2
				});
			end
		end
	});
	
	-- ==========================================
	-- SHERIFF TAB
	-- ==========================================
	local shotButton = nil;
	local shotButtonFrame = nil;
	local shotButtonActive = false;
	local shotType = "Default";
	local buttonSize = 50;
	
	local function RemoveShotButton()
		if shotButton then
			shotButton:Destroy();
			shotButton = nil;
		end
		if shotButtonFrame then
			shotButtonFrame:Destroy();
			shotButtonFrame = nil;
		end
		local screenGui = CoreGui:FindFirstChild("WindUI_SheriffGui");
		if screenGui then
			screenGui:Destroy();
		end
		shotButtonActive = false;
	end
	
	local function CreateShotButton()
		if shotButton then
			return;
		end
		local screenGui = Instance.new("ScreenGui");
		screenGui.Name = "WindUI_SheriffGui";
		screenGui.Parent = CoreGui;
		screenGui.ResetOnSpawn = false;
		screenGui.DisplayOrder = 999;
		
		shotButtonFrame = Instance.new("Frame");
		shotButtonFrame.Size = UDim2.new(0, buttonSize, 0, buttonSize);
		shotButtonFrame.Position = UDim2.new(1, -buttonSize - 20, 0.5, -buttonSize / 2);
		shotButtonFrame.AnchorPoint = Vector2.new(1, 0.5);
		shotButtonFrame.BackgroundTransparency = 1;
		shotButtonFrame.ZIndex = 100;
		
		shotButton = Instance.new("TextButton");
		shotButton.Size = UDim2.new(1, 0, 1, 0);
		shotButton.BackgroundColor3 = Color3.fromRGB(0, 100, 255);
		shotButton.Text = "SHOT";
		shotButton.TextSize = 14;
		shotButton.Font = Enum.Font.GothamBold;
		shotButton.TextColor3 = Color3.fromRGB(255, 255, 255);
		shotButton.ZIndex = 101;
		
		local corner = Instance.new("UICorner");
		corner.CornerRadius = UDim.new(0.3, 0);
		corner.Parent = shotButton;
		
		shotButton.MouseButton1Click:Connect(function()
			if not LocalPlayer.Character then
				return;
			end
			local roles = ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer();
			local murderer = nil;
			for name, data in pairs(roles) do
				if data.Role == "Murderer" then
					murderer = Players:FindFirstChild(name);
					break;
				end
			end
			if not murderer or not murderer.Character then
				return;
			end
			
			local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun");
			if gun and not LocalPlayer.Character:FindFirstChild("Gun") then
				gun.Parent = LocalPlayer.Character;
			end
			
			if shotType == "Teleport" then
				local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart");
				local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
				if targetRoot and localRoot then
					localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -4);
				end
			end
			
			gun = LocalPlayer.Character:FindFirstChild("Gun");
			if gun and gun:FindFirstChild("KnifeLocal") then
				local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart");
				if targetPart then
					local args = {[1] = 10, [2] = targetPart.Position, [3] = "AH2"};
					gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args));
				end
			end
		end);
		
		shotButton.Parent = shotButtonFrame;
		shotButtonFrame.Parent = screenGui;
		shotButtonActive = true;
	end
	
	Tabs.SheriffTab:Section({
		Title = gradient("Shot Functions", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9"))
	});
	
	Tabs.SheriffTab:Dropdown({
		Title = "Shot Type",
		Values = {"Default", "Teleport"},
		Value = "Default",
		Callback = function(selected)
			shotType = selected;
		end
	});
	
	Tabs.SheriffTab:Section({
		Title = gradient("Shot Button", Color3.fromHex("#001e80"), Color3.fromHex("#16f2d9"))
	});
	
	Tabs.SheriffTab:Button({
		Title = "Toggle Shot Button",
		Callback = function()
			if shotButtonActive then
				RemoveShotButton();
			else
				CreateShotButton();
			end
		end
	});
	
	Tabs.SheriffTab:Slider({
		Title = "Button Size",
		Step = 1,
		Value = {
			Min = 10,
			Max = 100,
			Default = 50
		},
		Callback = function(size)
			buttonSize = size;
			if shotButtonActive then
				RemoveShotButton();
				CreateShotButton();
			end
		end
	});
	
	-- ==========================================
	-- SERVER TAB
	-- ==========================================
	Tabs.ServerTab:Section({
		Title = gradient("Server Management", Color3.fromHex("#ff6600"), Color3.fromHex("#ff9900"))
	});
	
	Tabs.ServerTab:Button({
		Title = "Rejoin Server",
		Desc = "Rejoin the current server",
		Callback = function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer);
		end
	});
	
	Tabs.ServerTab:Button({
		Title = "Server Hop",
		Desc = "Join a different server",
		Callback = function()
			local success, result = pcall(function()
				return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"));
			end);
			if success and result and result.data then
				local servers = {};
				for _, server in ipairs(result.data) do
					if server.id ~= game.JobId then
						table.insert(servers, server);
					end
				end
				if #servers > 0 then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(#servers)].id);
				else
					TeleportService:Teleport(game.PlaceId);
				end
			else
				TeleportService:Teleport(game.PlaceId);
			end
		end
	});
	
	Tabs.ServerTab:Button({
		Title = "Join Low Server",
		Desc = "Join server with fewer players",
		Callback = function()
			local success, result = pcall(function()
				return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"));
			end);
			if success and result and result.data then
				local servers = {};
				for _, server in ipairs(result.data) do
					if server.id ~= game.JobId and server.playing < server.maxPlayers then
						table.insert(servers, server);
					end
				end
				table.sort(servers, function(a, b)
					return a.playing < b.playing;
				end);
				if #servers > 0 then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id);
				else
					TeleportService:Teleport(game.PlaceId);
				end
			else
				TeleportService:Teleport(game.PlaceId);
			end
		end
	});
	
	Tabs.ServerTab:Section({
		Title = gradient("Server Info", Color3.fromHex("#00eaff"), Color3.fromHex("#002a2e"))
	});
	
	local serverInfo = Tabs.ServerTab:Paragraph({
		Title = "Server Details",
		Desc = "Loading...",
		Image = "server",
		ImageSize = 32
	});
	
	task.spawn(function()
		while task.wait(5) do
			local success, result = pcall(function()
				return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"));
			end);
			if success and result and result.data then
				for _, server in ipairs(result.data) do
					if server.id == game.JobId then
						local ping = "N/A";
						pcall(function()
							ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString();
						end);
						serverInfo:SetDesc("Server: " .. string.sub(game.JobId, 1, 8) .. "...\nPlayers: " .. server.playing .. "/" .. server.maxPlayers .. "\nPing: " .. ping);
						break;
					end
				end
			end
		end
	end);
	
	-- ==========================================
	-- SETTINGS TAB
	-- ==========================================
	local Settings = {
		Hitbox = {
			Enabled = false,
			Size = 5,
			Color = Color3.new(1, 0, 0),
			Adornments = {}
		},
		Noclip = {
			Enabled = false,
			Connection = nil
		},
		AntiAFK = {
			Enabled = false,
			Connection = nil
		}
	};
	
	local function ToggleNoclip(state)
		if state then
			Settings.Noclip.Connection = RunService.Stepped:Connect(function()
				if LocalPlayer.Character then
					for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false;
						end
					end
				end
			end);
		elseif Settings.Noclip.Connection then
			Settings.Noclip.Connection:Disconnect();
		end
	end
	
	local function UpdateHitboxes()
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local chr = plr.Character;
				local box = Settings.Hitbox.Adornments[plr];
				if chr and Settings.Hitbox.Enabled then
					local root = chr:FindFirstChild("HumanoidRootPart");
					if root then
						if not box then
							box = Instance.new("BoxHandleAdornment");
							box.Adornee = root;
							box.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size);
							box.Color3 = Settings.Hitbox.Color;
							box.Transparency = 0.4;
							box.ZIndex = 10;
							box.Parent = root;
							Settings.Hitbox.Adornments[plr] = box;
						end
					end
				elseif box then
					box:Destroy();
					Settings.Hitbox.Adornments[plr] = nil;
				end
			end
		end
	end
	
	local function ToggleAntiAFK(state)
		if state then
			Settings.AntiAFK.Connection = RunService.Heartbeat:Connect(function()
				pcall(function()
					game:GetService("VirtualUser"):CaptureController();
					game:GetService("VirtualUser"):ClickButton2(Vector2.new());
				end);
			end);
		elseif Settings.AntiAFK.Connection then
			Settings.AntiAFK.Connection:Disconnect();
		end
	end
	
	Tabs.SettingsTab:Section({
		Title = gradient("Hitboxes", Color3.fromHex("#ff0000"), Color3.fromHex("#ff8800"))
	});
	
	Tabs.SettingsTab:Toggle({
		Title = "Hitboxes",
		Callback = function(state)
			Settings.Hitbox.Enabled = state;
			if state then
				local conn = RunService.Heartbeat:Connect(UpdateHitboxes);
				table.insert(ActiveConnections.RenderStepped, conn);
			else
				for _, box in pairs(Settings.Hitbox.Adornments) do
					if box then
						box:Destroy();
					end
				end
				Settings.Hitbox.Adornments = {};
			end
		end
	});
	
	Tabs.SettingsTab:Slider({
		Title = "Hitbox Size",
		Value = {
			Min = 1,
			Max = 20,
			Default = 5
		},
		Callback = function(val)
			Settings.Hitbox.Size = val;
		end
	});
	
	Tabs.SettingsTab:Colorpicker({
		Title = "Hitbox Color",
		Default = Color3.new(1, 0, 0),
		Callback = function(col)
			Settings.Hitbox.Color = col;
		end
	});
	
	Tabs.SettingsTab:Section({
		Title = gradient("Character", Color3.fromHex("#00eaff"), Color3.fromHex("#002a2e"))
	});
	
	Tabs.SettingsTab:Toggle({
		Title = "Anti-AFK",
		Callback = function(state)
			Settings.AntiAFK.Enabled = state;
			ToggleAntiAFK(state);
		end
	});
	
	Tabs.SettingsTab:Toggle({
		Title = "NoClip",
		Callback = function(state)
			Settings.Noclip.Enabled = state;
			ToggleNoclip(state);
		end
	});
	
	-- ==========================================
	-- CHANGELOGS TAB
	-- ==========================================
	Tabs.ChangelogsTab:Section({
		Title = gradient("Current Version", Color3.fromHex("#00ff40"), Color3.fromHex("#008f11"))
	});
	
	Tabs.ChangelogsTab:Code({
		Title = "v1.0 - Current Release",
		Code = [[
Features:
• Full ESP (Murderer, Sheriff, Innocent, GunDrop)
• Silent Aimbot (Hold Right Click)
• Camera Aimbot (Spectate & Lock)
• AutoFarm (Coins & Beach Balls)
• Teleport System
• Kill All (Murderer)
• Auto Grab Gun & Shoot
• Shot Button for Mobile
• Character Mods
• Hitbox Expander
• Anti-AFK & NoClip
• Server Management
• Theme Customization
• Ctrl+M Toggle System
]]
	});
	
	Tabs.ChangelogsTab:Section({
		Title = gradient("Coming Soon", Color3.fromHex("#b914fa"), Color3.fromHex("#7023c2"))
	});
	
	Tabs.ChangelogsTab:Code({
		Title = "v1.1 - Planned",
		Code = [[
• Tracer ESP
• Name ESP
• Box ESP
• Auto Farm Rare Eggs
• Murderer Detection Alerts
• Smooth Aimbot
• Auto Report
]]
	});
	
	-- ==========================================
	-- SOCIALS TAB
	-- ==========================================
	Tabs.SocialsTab:Section({
		Title = gradient("Developer", Color3.fromHex("#FFD700"), Color3.fromHex("#FFA500"))
	});
	
	Tabs.SocialsTab:Paragraph({
		Title = "BorutoDEV",
		Desc = "Creator of this MM2 Script\nThanks for using my script!",
		Image = "rbxassetid://72462144048455",
		ImageSize = 64
	});
	
	Tabs.SocialsTab:Section({
		Title = gradient("Links", Color3.fromHex("#00eaff"), Color3.fromHex("#002a2e"))
	});
	
	Tabs.SocialsTab:Button({
		Title = "Copy YouTube",
		Callback = function()
			if pcall(setclipboard, "https://www.youtube.com/@bxrutodev") then
				WindUI:Notify({
					Title = "Copied!",
					Content = "YouTube link copied!",
					Icon = "check-circle",
					Duration = 3
				});
			end
		end
	});
	
	Tabs.SocialsTab:Button({
		Title = "Copy Roblox",
		Callback = function()
			if pcall(setclipboard, "https://www.roblox.com/users/3814718003/profile") then
				WindUI:Notify({
					Title = "Copied!",
					Content = "Roblox profile copied!",
					Icon = "check-circle",
					Duration = 3
				});
			end
		end
	});
	
	-- ==========================================
	-- CONFIGURATION TAB
	-- ==========================================
	Tabs.WindowTab:Section({
		Title = "Window Settings"
	});
	
	local themeValues = {};
	for name, _ in pairs(WindUI:GetThemes()) do
		table.insert(themeValues, name);
	end
	
	Tabs.WindowTab:Dropdown({
		Title = "Select Theme",
		Values = themeValues,
		Callback = function(theme)
			WindUI:SetTheme(theme);
		end
	});
	
	Tabs.WindowTab:Toggle({
		Title = "Toggle Transparency",
		Callback = function(e)
			Window:ToggleTransparency(e);
		end,
		Value = WindUI:GetTransparency()
	});
	
	Tabs.WindowTab:Section({
		Title = "Save/Load"
	});
	
	local fileNameInput = "";
	Tabs.WindowTab:Input({
		Title = "File Name",
		PlaceholderText = "Enter file name",
		Callback = function(text)
			fileNameInput = text;
		end
	});
	
	Tabs.WindowTab:Button({
		Title = "Save Configuration",
		Callback = function()
			if fileNameInput ~= "" then
				makefolder("MM2Script");
				writefile("MM2Script/" .. fileNameInput .. ".json", HttpService:JSONEncode({
					Theme = WindUI:GetCurrentTheme(),
					Transparent = WindUI:GetTransparency()
				}));
				WindUI:Notify({
					Title = "Saved!",
					Content = "Configuration saved!",
					Icon = "check-circle",
					Duration = 2
				});
			end
		end
	});
	
	Tabs.WindowTab:Button({
		Title = "Load Configuration",
		Callback = function()
			if fileNameInput ~= "" and isfile("MM2Script/" .. fileNameInput .. ".json") then
				local data = HttpService:JSONDecode(readfile("MM2Script/" .. fileNameInput .. ".json"));
				if data.Theme then
					WindUI:SetTheme(data.Theme);
				end
				if data.Transparent then
					Window:ToggleTransparency(data.Transparent);
				end
				WindUI:Notify({
					Title = "Loaded!",
					Content = "Configuration loaded!",
					Icon = "check-circle",
					Duration = 2
				});
			end
		end
	});
	
	-- ==========================================
	-- THEMES TAB
	-- ==========================================
	Tabs.CreateThemeTab:Section({
		Title = "Custom Theme"
	});
	
	local newThemeName = "";
	Tabs.CreateThemeTab:Input({
		Title = "Theme Name",
		PlaceholderText = "Enter theme name",
		Callback = function(text)
			newThemeName = text;
		end
	});
	
	local customColors = {
		Accent = Color3.fromHex("#18181b"),
		Outline = Color3.fromHex("#FFFFFF"),
		Text = Color3.fromHex("#FFFFFF"),
		Background = Color3.fromHex("#0e0e10")
	};
	
	Tabs.CreateThemeTab:Colorpicker({
		Title = "Accent Color",
		Default = customColors.Accent,
		Callback = function(color)
			customColors.Accent = color;
		end
	});
	
	Tabs.CreateThemeTab:Colorpicker({
		Title = "Outline Color",
		Default = customColors.Outline,
		Callback = function(color)
			customColors.Outline = color;
		end
	});
	
	Tabs.CreateThemeTab:Colorpicker({
		Title = "Text Color",
		Default = customColors.Text,
		Callback = function(color)
			customColors.Text = color;
		end
	});
	
	Tabs.CreateThemeTab:Colorpicker({
		Title = "Background Color",
		Default = customColors.Background,
		Callback = function(color)
			customColors.Background = color;
		end
	});
	
	Tabs.CreateThemeTab:Button({
		Title = "Create Theme",
		Callback = function()
			if newThemeName ~= "" then
				WindUI:AddTheme({
					Name = newThemeName,
					Accent = tostring(customColors.Accent),
					Outline = tostring(customColors.Outline),
					Text = tostring(customColors.Text),
					Background = tostring(customColors.Background)
				});
				WindUI:SetTheme(newThemeName);
				WindUI:Notify({
					Title = "Theme Created!",
					Content = "Theme " .. newThemeName .. " applied!",
					Icon = "check-circle",
					Duration = 3
				});
			end
		end
	});
	
	-- ==========================================
	-- CTRL + M TOGGLE SYSTEM
	-- ==========================================
	local function DisconnectAll()
		for _, conn in ipairs(ActiveConnections.RenderStepped) do
			if conn then
				pcall(function()
					conn:Disconnect()
				end)
			end
		end
		ActiveConnections.RenderStepped = {}
		
		if ActiveConnections.PlayerRemoving then
			pcall(function()
				ActiveConnections.PlayerRemoving:Disconnect()
			end)
		end
		
		for _, conn in ipairs(ActiveConnections.ChildAdded) do
			if conn then
				pcall(function()
					conn:Disconnect()
				end)
			end
		end
		ActiveConnections.ChildAdded = {}
		
		killActive = false;
		AutoFarm.Enabled = false;
		if AutoFarm.Connection then
			pcall(function()
				task.cancel(AutoFarm.Connection)
			end)
		end
		
		if Settings.Noclip.Connection then
			Settings.Noclip.Connection:Disconnect();
		end
		if Settings.AntiAFK.Connection then
			Settings.AntiAFK.Connection:Disconnect();
		end
		
		Settings.Hitbox.Enabled = false;
		for _, box in pairs(Settings.Hitbox.Adornments) do
			if box then
				box:Destroy()
			end
		end
		
		if SilentAimbot.Connection then
			SilentAimbot.Connection:Disconnect();
			SilentAimbot.Connection = nil
		end
		FOVCircle.Visible = false
		
		if shotButtonActive then
			RemoveShotButton();
		end
		RemoveAllHighlights();
	end
	
	local function KillScript()
		ScriptEnabled = false;
		DisconnectAll();
		pcall(function()
			Window:Hide()
		end);
		WindUI:Notify({
			Title = "SCRIPT DISABLED",
			Content = "Press Ctrl+M to restore",
			Duration = 3,
			Icon = "power-off",
			Color = "Red"
		});
		print("[MM2] Script Disabled - Press Ctrl+M to enable");
	end
	
	local function EnableScript()
		ScriptEnabled = true;
		GUIVisible = true;
		pcall(function()
			Window:Show()
		end);
		WindUI:Notify({
			Title = "Script Enabled",
			Content = "GUI restored!",
			Duration = 3,
			Icon = "power",
			Color = "Green"
		});
		print("[MM2] Script Enabled");
	end
	
	getgenv().ToggleMM2Script = function()
		if ScriptEnabled then
			KillScript()
		else
			EnableScript()
		end
		return ScriptEnabled
	end
	
	-- Ctrl + M Detection
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			CtrlPressed = true;
		end
		
		if CtrlPressed and input.KeyCode == Enum.KeyCode.M then
			getgenv().ToggleMM2Script();
		end
	end);
	
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
			CtrlPressed = false;
		end
	end);
	
	-- Add toggle button to Settings
	Tabs.SettingsTab:Section({
		Title = gradient("Script Toggle", Color3.fromHex("#ff0000"), Color3.fromHex("#ff6600"))
	});
	
	Tabs.SettingsTab:Button({
		Title = "Toggle Script (Ctrl + M)",
		Desc = "Press Ctrl+M to toggle on/off",
		Callback = function()
			getgenv().ToggleMM2Script();
		end
	});
	
	print("MM2 Script Loaded - Press Ctrl+M to toggle script");
end
