task.wait(2)

local Library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Taffelgmaing/Potassium-Internal-UI/refs/heads/main/UI.lua"))()

local Window = Library:Window(
    "Mango",
    "Iron Dungeon"
)


local AutofarmTab = Window:Tab("Autofarm")
local AutoSellTab = Window:Tab("Auto Sell")
local Configs = Window:Tab("Configs")

Library:ConfigTab(Configs)


local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Camera = workspace.CurrentCamera

local manager = game.Players.LocalPlayer.Character.LocalControlMgr
local ActionFolder = manager.Action

local ActionModules = {}

for _, module in ActionFolder:GetChildren() do
	if module:IsA("ModuleScript") then
		ActionModules[module.Name] = require(module)
	end
end

local Controller = require(manager.Controller)
local Framework = require(game:GetService("ReplicatedStorage").Framework)

local controller = Controller.new(
	character,
	ActionModules
)


function Attack(bool)
	bool = bool or false
	-- controller.WeaponDef.BaseAttack.InStage = false
	-- controller.WeaponDef.BaseAttack.Info.CD = 0

	controller:PerformAction("BaseAttack")
	task.wait()
	controller:StopAction("BaseAttack")

	if bool then
		task.spawn(function()
			for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenInput.PCInput.Skills:GetChildren()) do
				if v:IsA("ImageButton") and v:GetAttribute("OnCD") == false then
					if v:GetAttribute("FullCharge") == true then
						controller:PerformAction("SkillU")
						task.wait(0.1)
						return
					end
					controller:PerformAction("Skill1")
					task.wait(0.1)
					controller:PerformAction("Skill2")
				end
			end
		end)
	end
end

-- Framework.Modules.EquipmentUtil:ChangeWeaponSlot(game.Players.LocalPlayer)

AutofarmTab:Toggle("Autofarm", false, function(t)
    Autofarm = t
	if not Autofarm then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
	end
end)

AutofarmTab:Slider("Distance X", -20, 20, 0, function(t)
    Distance_X = t
end)

AutofarmTab:Slider("Distance Y", -20, 20, 0, function(t)
    Distance_Y = t
end)

AutofarmTab:Slider("Distance Z", -20, 20, 10, function(t)
    Distance_Z = t
end)

AutofarmTab:Slider("Pitch", -180, 180, 45, function(t)
    Pitch = t
end)

AutofarmTab:line()

AutofarmTab:Toggle("Allow Camera Change", false, function(t)
	CameraChange = t

	if CameraChange then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CameraSubject = nil
	else
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject =
			player.Character:FindFirstChildOfClass("Humanoid")
	end
end)

AutofarmTab:Slider("Camera Distance", 0, 100, 0, function(t)
    CameraDistance = t
end)

AutofarmTab:Toggle("Auto Use Skill", false, function(t)
    AutoUseSkill = t
end)

AutofarmTab:Toggle("BringMobs", false, function(t)
    BringMobs = t
end)

AutofarmTab:Toggle("Auto Collect Chests", false, function(t)
    AutoCollectChests = t
end)

AutofarmTab:Toggle("Auto Play Again", false, function(t)
	AutoPlayAgain = t
end)

local OldWalkSpeed = Controller.SetWalkSpeed

AutofarmTab:Toggle("Change WalkSpeed", false, function(t)
    WalkSpeed = t
	if not WalkSpeed then
		Controller.SetWalkSpeed = OldWalkSpeed
	end
end)

AutofarmTab:Slider("WalkSpeed", 1, 100, 16, function(t)
    WalkSpeed_Speed = t
end)

local CollectingEggs = false
local CollectingChests = false
spawn(function()
	while task.wait() do
		if AutoCollectChests then
			local success, err = pcall(function()
				for i,v in pairs(workspace:GetChildren()) do
					if v:IsA("Model") and string.find(v.Name, "Chest") and v:FindFirstChild("Root") and v:GetAttribute("HitCount") > 0 then
						CollectingChests = true
						repeat task.wait()
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Root.CFrame * CFrame.new(0,0,5)
						until not AutoCollectChests or not v or not v:FindFirstChild("Root") or v:GetAttribute("HitCount") == 0
					else
						CollectingChests = false
					end
				end
			end)
			if not success then
				warn(err)
			end
		end
	end
end)

spawn(function()
	while task.wait() do
		if AutoPlayAgain then
			local success, err = pcall(function()
				if game:GetService("Players").LocalPlayer.PlayerGui.ResultGui.ScreenSettlement.Visible then
					local GameRoundRE = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameRoundRE");
					GameRoundRE:FireServer("VotePlayAgain");
				end
			end)
			if not success then
				warn(err)
			end
		end
	end
end)

local TweenService = game:GetService("TweenService")
local CurrentEnemy = nil
local CurrentEnemyModel = nil


local TargetHighlight = Instance.new("Highlight")
TargetHighlight.Name = "AutofarmTarget"
TargetHighlight.Enabled = false
TargetHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
TargetHighlight.FillTransparency = 0.5
TargetHighlight.OutlineTransparency = 0
TargetHighlight.Parent = game.Players.LocalPlayer.PlayerGui

local function SetCurrentEnemy(enemy)
	CurrentEnemyModel = enemy

	TargetHighlight.Adornee = enemy
	TargetHighlight.Enabled = true
end

spawn(function()
	while task.wait() do
		if Autofarm then
			if game:GetService("Players").LocalPlayer.PlayerGui.ScreenDesign:FindFirstChild("WhiteEffect") then
				game:GetService("Players").LocalPlayer.PlayerGui.ScreenDesign.WhiteEffect:Destroy()
			end
			local success, err = pcall(function()
				if CollectingChests then return end
				if CollectingEggs then return end
				if not workspace.EnemyNpc:FindFirstChildOfClass("Model") then
					local OldCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
					for i,v in pairs(workspace.PlayerRespawn:GetChildren()) do
						if v:IsA("Part") then
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
							task.wait(1)
						end
					end
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = OldCFrame
				end
				for i,v in pairs(workspace.EnemyNpc:GetChildren()) do
					if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
						repeat task.wait()
							local FinalDistance = CFrame.new(Distance_X,Distance_Y,Distance_Z) * CFrame.Angles(math.rad(Pitch), math.rad(180), 0)
							if v:GetAttribute("LevelType") == "Boss" then
								FinalDistance = CFrame.new(Distance_X * 1.5,Distance_Y * 1.5,Distance_Z * 1.5) * CFrame.Angles(math.rad(Pitch), math.rad(180), 0)
							end

							if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude <= math.huge then
								CurrentEnemy = v.HumanoidRootPart
							end

							SetCurrentEnemy(CurrentEnemy.Parent)
							
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CurrentEnemy.CFrame * FinalDistance
						until not Autofarm or v.Humanoid.Health <= 0 or not v:FindFirstChild("HumanoidRootPart")
					elseif v and v:IsA("Model") and not v:FindFirstChild("HumanoidRootPart") then
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v:GetPivot()
					end
				end
			end)
			if not success then
				warn(err)
			end
		end
	end
end)



local CAMERA_BACK = 50

spawn(function()
	while task.wait() do
		if Autofarm then
			local success, err = pcall(function()
				spawn(function()
					for i,v in pairs(workspace.EnemyNpc:GetChildren()) do
						if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart")
						and (CurrentEnemy.Position - v.HumanoidRootPart.Position).Magnitude <= 100 then
							if BringMobs then
								task.wait()
								v.HumanoidRootPart.CFrame = CurrentEnemy.CFrame
							end
						end
					end
				end)
				spawn(function()
					for i,v in pairs(workspace:GetChildren()) do
						if v:FindFirstChild("DragonEgg") and v.DragonEgg:FindFirstChild("EggModel") and v.DragonEgg.EggModel:FindFirstChild("Root") and v:FindFirstChild("Root") and not v:GetAttribute("Active") then
							CollectingEggs = true
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.DragonEgg.EggModel:FindFirstChild("Root").CFrame
							task.wait(0.1)
							fireproximityprompt(v.Root.Interact_ProximityPrompt)
							CollectingEggs = false
						else
							-- CollectingEggs = false
						end
					end
				end)

				task.spawn(function()
					local success2, err2 = pcall(function()
						if not CameraChange then
							return
						end

						local character = player.Character
						if not character then
							return
						end

						local root = character:FindFirstChild("HumanoidRootPart")
						if not root then
							return
						end

						Camera.CameraType = Enum.CameraType.Scriptable
						Camera.CameraSubject = nil

						local targetPosition = root.Position

						local cameraPosition =
							targetPosition
							+ Vector3.new(
								0,
								CameraDistance,
								CAMERA_BACK
							)

						TweenService:Create(
							Camera,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad),
							{CFrame = CFrame.lookAt(
								cameraPosition,
								targetPosition
							)}
						):Play()

						Camera.Focus = CFrame.new(targetPosition)
					end)
					if not success2 then
						warn("Camera: ",err2)
					end
				end)
				task.spawn(function()
					Attack(AutoUseSkill)
				end)
			end)
			if not success then
				warn(err)
			end
		end
	end
end)

spawn(function()
	while task.wait() do
		if WalkSpeed then
			local success, err = pcall(function()
				Controller.SetWalkSpeed = function(p65, p66)
					p65.Humanoid.WalkSpeed = WalkSpeed_Speed
				end
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeed_Speed
			end)
			if not success then
				warn(err)
			end
		end
	end
end)

function GetCrystals()
	local Crystals_Table = {}
	for i,v in pairs(Framework.Modules.DataUtil:GetPlayerData(game.Players.LocalPlayer).Crystals) do
		table.insert(Crystals_Table, i)
	end
	return Crystals_Table
end

local Crystals_Check = AutoSellTab:Checklist("Crystals", "Crystals_key", GetCrystals(), function(t)
    Crystals = t
end)

function GetOres()
	local Ores_Table = {}
	for i,v in pairs(Framework.Modules.DataUtil:GetPlayerData(game.Players.LocalPlayer).Ores) do
		table.insert(Ores_Table, i)
	end
	return Ores_Table
end


local Ores_Check = AutoSellTab:Checklist("Ores", "Ores_Key", GetOres(), function(t)
    Ores = t
end)

function GetEquipment()
	local Equipment_Table = {}
	for i,v in pairs(Framework.Modules.DataUtil:GetPlayerData(game.Players.LocalPlayer).Equipment.Owned) do
		table.insert(Equipment_Table, v.ID)
	end
	return Equipment_Table
end

local Equipment_Check = AutoSellTab:Checklist("Equipment", "Equipment_key", GetEquipment(), function(t)
    Equipment = t
end)

AutoSellTab:Button("Refresh All", function()
	Equipment_Check:Refresh(GetEquipment())
	Ores_Check:Refresh(GetOres())
	Crystals_Check:Refresh(GetCrystals())
end)

AutoSellTab:Toggle("Auto Sell", false, function(t)
    AutoSell = t
end)


spawn(function()
	while task.wait() do
		if AutoSell then
			local success, err = pcall(function()
				local FinalLoop = {}
				if Crystals then
					for i,v in pairs(Crystals) do
						FinalLoop[v] = 1
					end
					local ohString1 = "Sell"
					local ohTable2 = FinalLoop
					local ohTable3 = {}
					
					game:GetService("ReplicatedStorage").Framework.Gameplay.EquipmentSystem.MaterialUtil.RemoteEvent:FireServer(ohString1, ohTable2, ohTable3)
				end

				local OresLoop = {}
				if Ores then
					for i,v in pairs(Ores) do
						OresLoop[v] = 1
					end
					
					local ohString1 = "Sell"
					local ohTable2 = OresLoop

					game:GetService("ReplicatedStorage").Framework.Gameplay.EquipmentSystem.ForgeRF:InvokeServer(ohString1, ohTable2)
				end

				if Equipment then
					for i,v in pairs(Framework.Modules.DataUtil:GetPlayerData(game.Players.LocalPlayer).Equipment.Owned) do
						if table.find(Equipment, v.ID) then
							local ohString1 = "Sell"
							local ohTable2 = {v.UUID}

							game:GetService("ReplicatedStorage").Framework.Gameplay.EquipmentSystem.EquipmentRE:FireServer(ohString1, ohTable2)
						end
					end
				end

			end)
			if not success then
				warn(err)
			end
		end
	end
end)
