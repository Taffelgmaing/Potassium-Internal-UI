return function(Potassium_Internal)


	local ScreenGui = Potassium_Internal
	local IntroFrame = ScreenGui.Intro
	local InfoText = IntroFrame.InfoText
	local WaterDrop = ScreenGui.WaterDrop
	local MainFrame = ScreenGui.MainFrame
	local CodingHolder = MainFrame.CodingHolder
	local SettingsFrame = MainFrame.Settings



	-- // Services
	local TweenService = game:GetService("TweenService")

	--task.wait(1)
	local DoneInitializing = false
	local function IntroSequenze() -- // Create Intro Sequnze
		local EndPos = UDim2.new(0.5,0,0.4,0)
		local EndSize = UDim2.new(0, 587,0, 352)
		-- // Default Values
		IntroFrame.Visible = true
		--IntroFrame.UIScale.Scale = 0.001
		IntroFrame.UICorner.CornerRadius = UDim.new(1,0)
		IntroFrame.Position = UDim2.new(0.5,0,0.126,0)
		IntroFrame.ImageTransparency = 1
		IntroFrame.BackgroundTransparency = 1
		IntroFrame.Size = UDim2.new(0.021, 0,0.043, 0)
		InfoText.TextTransparency = 1
		WaterDrop.ImageTransparency = 1
		WaterDrop.Position = UDim2.new(0.5, 0, 0.063, 0)
		WaterDrop.UIScale.Scale = 0.001

		MainFrame.Position = EndPos
		MainFrame.Size = UDim2.new(0.109, 0, 0.219, 0)
		MainFrame.ImageTransparency = 1
		MainFrame.UICorner.CornerRadius = UDim.new(1,0)
		MainFrame.Visible = false

		CodingHolder.Visible = false

		-- // Settings
		local DELAY = 0
		local CONSOLE_ON_OPEN = true

		task.wait(0.5)


		-- // Sequnze 1 - Drop In

		print("Starting Sequnze 1 - Drop In")
		TweenService:Create(
			IntroFrame,
			TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
			{ImageTransparency = 0}
		):Play()

		TweenService:Create(
			IntroFrame,
			TweenInfo.new(0.4 + DELAY, Enum.EasingStyle.Quad),
			{Position = EndPos}
		):Play()

		--local IntroSize = TweenService:Create(
		--	IntroFrame.UIScale,
		--	TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
		--	{Scale = 1}
		--)

		local IntroSize = TweenService:Create(
			IntroFrame,
			TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
			{Size = UDim2.new(0.109, 0, 0.219, 0)}
		)

		IntroSize:Play()
		IntroSize.Completed:Wait()

		-- // Sequnze 2 - Information / Rotation

		print("Starting Sequnze 2 - Information / Rotation")
		task.wait(0.3)
		TweenService:Create(
			InfoText,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{TextTransparency = 0}
		):Play()
		--task.wait(2 + DELAY)

		local TransText = TweenService:Create(
			InfoText,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{TextTransparency = 1}
		)

		TransText:Play()
		TransText.Completed:Wait()

		-- // Sequnze 3 - Drop Dissband
		print("Starting Sequnze 3 - Drop Dissband")
		task.wait(0.3)

		local WaterDropping = TweenService:Create(
			WaterDrop.UIScale,
			TweenInfo.new(0.2 + DELAY, Enum.EasingStyle.Linear),
			{Scale = 0.8}
		)

		WaterDropping:Play()

		TweenService:Create(
			WaterDrop,
			TweenInfo.new(0.2 + DELAY, Enum.EasingStyle.Quad),
			{ImageTransparency = 0}
		):Play()

		TweenService:Create(
			WaterDrop,
			TweenInfo.new(0.1 + DELAY, Enum.EasingStyle.Quad),
			{Size = UDim2.new(0, 23,0, 26)}
		):Play()

		local WaterDropper = TweenService:Create(
			WaterDrop,
			TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
			{Position = EndPos}
		)
		WaterDropper:Play()

		--WaterDropping.Completed:Wait()
		WaterDropper.Completed:Wait()
		WaterDrop.Visible = false

		-- // Sequnze 4 - Transform
		print("Starting Sequnze 4 - Transform")

		--IntroFrame.UIScale.Scale = 1
		--IntroFrame.UIScale:Destroy()

		if not CONSOLE_ON_OPEN then
			MainFrame.Visible = false
		else
			MainFrame.Visible = true
		end

		TweenService:Create(
			IntroFrame.UICorner,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{CornerRadius = UDim.new(0, 8)}
		):Play()

		TweenService:Create(
			MainFrame.UICorner,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{CornerRadius = UDim.new(0, 8)}
		):Play()

		TweenService:Create(
			IntroFrame,
			TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
			{Size = EndSize}
		):Play()

		TweenService:Create(
			MainFrame,
			TweenInfo.new(0.5 + DELAY, Enum.EasingStyle.Quad),
			{Size = EndSize}
		):Play()


		TweenService:Create(
			IntroFrame,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{ImageTransparency = 1}
		):Play()

		task.wait(0.1)
		local AllDone = TweenService:Create(
			MainFrame,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{ImageTransparency = 0}
		)
		AllDone:Play()

		CodingHolder.Visible = true
		SettingsFrame.Visible = true
		SettingsFrame.Size = UDim2.new(1, 0, 0, 0)
		SettingsFrame.Position = UDim2.new(0, 0, 0, 0)

		AllDone.Completed:Wait()
		TweenService:Create(
			MainFrame,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{AnchorPoint = Vector2.new(0, 0)}
		):Play()

		TweenService:Create(
			MainFrame,
			TweenInfo.new(0.3 + DELAY, Enum.EasingStyle.Quad),
			{Position = UDim2.new(0.5, -295, 0.4, -175)}
		):Play()

		DoneInitializing = true
	end


	IntroSequenze()


	repeat task.wait() until DoneInitializing


end
