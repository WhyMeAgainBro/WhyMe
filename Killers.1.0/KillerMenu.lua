--[[
  Roblox GUI with Close Button

  This script creates a GUI Frame with a draggable title bar, a "Fly" button,
  a text box for setting the player's walk speed, and new buttons to
  freeze and unfreeze all players on the server. A new "X" button
  has been added to the top-right corner to close the GUI.

  This script should be placed in 'StarterPlayer' -> 'StarterPlayerScripts'
  in Roblox Studio to run automatically for each player.
]]

-- A function to set up the GUI and its functionality
local function setupGUI()
	-- Get the player's GUI service and the local player
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Get the UserInputService to handle mouse and touch input
	local UserInputService = game:GetService("UserInputService")
	
	-- Get the RemoteEvent from ReplicatedStorage
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local adminEvent = replicatedStorage:WaitForChild("AdminEvent")
	
	-- Variables for the dragging functionality
	local isDragging = false
	local dragStartPosition
	local initialPosition

	-- Create a new ScreenGui and parent it to the player's GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ControlGUI"
	screenGui.Parent = playerGui

	-- Create the main Frame for the GUI
	-- We increase the size to 50x190 pixels to make room for all elements.
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "ControlFrame"
	
	-- Set the size of the frame to 50 pixels wide by 190 pixels tall.
	mainFrame.Size = UDim2.new(0, 50, 0, 190)

	-- Position the frame in the center of the screen
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Set a background color for the frame
	mainFrame.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8) -- A nice blue color
	mainFrame.Parent = screenGui

	-- Create the draggable title bar (10% of frame height)
	local titleBar = Instance.new("TextButton")
	titleBar.Name = "TitleBar"
	titleBar.Text = "Move"
	titleBar.Size = UDim2.new(1, 0, 0.15, 0)
	titleBar.Position = UDim2.new(0, 0, 0, 0)
	titleBar.BackgroundColor3 = Color3.new(0.15, 0.45, 0.6) -- Darker blue
	titleBar.TextColor3 = Color3.new(1, 1, 1)
	titleBar.TextScaled = true
	titleBar.Font = Enum.Font.SourceSansBold
	titleBar.Parent = mainFrame
	
	-- Create the Close button ("X")
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Text = "X"
	closeButton.Size = UDim2.new(0, 20, 0, 20) -- Small fixed size
	closeButton.Position = UDim2.new(1, -20, 0, 0) -- Position at top right
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.BackgroundColor3 = Color3.new(1, 0.3, 0.3) -- Red for close
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.Parent = mainFrame
	
	-- Create the fly button (25% of frame height)
	local flyButton = Instance.new("TextButton")
	flyButton.Name = "FlyButton"
	flyButton.Text = "Fly"
	flyButton.Size = UDim2.new(1, 0, 0.25, 0)
	flyButton.Position = UDim2.new(0, 0, 0.15, 0)
	flyButton.BackgroundColor3 = Color3.new(0.3, 0.7, 0.4) -- A green color
	flyButton.TextColor3 = Color3.new(1, 1, 1)
	flyButton.Font = Enum.Font.SourceSansBold
	flyButton.Parent = mainFrame

	-- Create the speed text box (25% of frame height)
	local speedTextBox = Instance.new("TextBox")
	speedTextBox.Name = "SpeedTextBox"
	speedTextBox.Size = UDim2.new(1, 0, 0.25, 0)
	speedTextBox.Position = UDim2.new(0, 0, 0.4, 0)
	speedTextBox.PlaceholderText = "Enter speed..."
	speedTextBox.Text = ""
	speedTextBox.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9) -- Light grey
	speedTextBox.TextColor3 = Color3.new(0, 0, 0)
	speedTextBox.Font = Enum.Font.SourceSans
	speedTextBox.TextScaled = true
	speedTextBox.Parent = mainFrame

	-- Create the freeze button (20% of frame height)
	local freezeButton = Instance.new("TextButton")
	freezeButton.Name = "FreezeButton"
	freezeButton.Text = "Freeze All"
	freezeButton.Size = UDim2.new(1, 0, 0.2, 0)
	freezeButton.Position = UDim2.new(0, 0, 0.65, 0)
	freezeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3) -- A red color
	freezeButton.TextColor3 = Color3.new(1, 1, 1)
	freezeButton.Font = Enum.Font.SourceSansBold
	freezeButton.Parent = mainFrame

	-- Create the unfreeze button (20% of frame height)
	local unfreezeButton = Instance.new("TextButton")
	unfreezeButton.Name = "UnfreezeButton"
	unfreezeButton.Text = "Unfreeze All"
	unfreezeButton.Size = UDim2.new(1, 0, 0.2, 0)
	unfreezeButton.Position = UDim2.new(0, 0, 0.85, 0)
	unfreezeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.8) -- A blue color
	unfreezeButton.TextColor3 = Color3.new(1, 1, 1)
	unfreezeButton.Font = Enum.Font.SourceSansBold
	unfreezeButton.Parent = mainFrame
	
	-- Function to handle the dragging logic
	local function onDrag(input)
		if isDragging and input.UserInputState == Enum.UserInputState.Change then
			local mouseDelta = input.Position - dragStartPosition
			mainFrame.Position = UDim2.new(
				mainFrame.Position.X.Scale,
				initialPosition.X.Offset + mouseDelta.X,
				mainFrame.Position.Y.Scale,
				initialPosition.Y.Offset + mouseDelta.Y
			)
		end
	end

	-- Connect the drag-related events
	titleBar.MouseButton1Down:Connect(function(x, y)
		isDragging = true
		dragStartPosition = UserInputService:GetMouseLocation()
		initialPosition = mainFrame.Position
	end)
	
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			onDrag(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	-- Function to handle the flying logic (same as before)
	local function onFlyButtonClicked()
		local success, result = pcall(function()
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and not humanoidRootPart:FindFirstChild("FlyBodyVelocity") then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "FlyBodyVelocity"
				bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
				bodyVelocity.Velocity = Vector3.new(0, 10, 0) -- Set upward velocity
				bodyVelocity.Parent = humanoidRootPart
				
				local bodyGyro = Instance.new("BodyGyro")
				bodyGyro.Name = "FlyBodyGyro"
				bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
				bodyGyro.CFrame = humanoidRootPart.CFrame
				bodyGyro.Parent = humanoidRootPart
			end
		end)

		if not success then
			warn("Failed to enable flying:", result)
		end
	end

	-- Function to handle speed changes from the textbox
	local function onSpeedChanged(enterPressed)
		-- Only change speed if the user presses the 'Enter' key
		if enterPressed then
			local newSpeed = tonumber(speedTextBox.Text)

			-- Check if the input is a valid number
			if newSpeed then
				local character = player.Character or player.CharacterAdded:Wait()
				local humanoid = character:FindFirstChild("Humanoid")
				
				if humanoid then
					-- Set the humanoid's walk speed to the new value
					humanoid.WalkSpeed = newSpeed
					speedTextBox.Text = "Speed set!"
					wait(1)
					speedTextBox.Text = "" -- Clear the text after a brief pause
				end
			else
				speedTextBox.Text = "Invalid speed!"
				wait(1)
				speedTextBox.Text = "" -- Clear the text after a brief pause
			end
		end
	end
	
	-- Connect the freeze and unfreeze buttons to fire the RemoteEvent
	freezeButton.MouseButton1Click:Connect(function()
		adminEvent:FireServer("freeze")
	end)

	unfreezeButton.MouseButton1Click:Connect(function()
		adminEvent:FireServer("unfreeze")
	end)

	-- Connect the close button to destroy the GUI
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	-- Connect the events for the buttons and textbox
	flyButton.MouseButton1Click:Connect(onFlyButtonClicked)
	speedTextBox.FocusLost:Connect(onSpeedChanged)
	
end

-- Run the setup function to create the GUI
setupGUI()