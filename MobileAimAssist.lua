-- Mobile Aim Assist
-- For use in your own Roblox experience.
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local AIM_ENABLED = false
local FOV_RADIUS = 150
local SMOOTHNESS = 0.15

local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "AimToggle"
button.Size = UDim2.fromOffset(140, 55)
button.Position = UDim2.new(1, -160, 1, -100)
button.Text = "AIM: OFF"
button.TextSize = 20
button.BackgroundTransparency = 0.15
button.Parent = gui

button.Activated:Connect(function()
    AIM_ENABLED = not AIM_ENABLED
    button.Text = AIM_ENABLED and "AIM: ON" or "AIM: OFF"
end)

local function getTarget()
    local closest = nil
    local closestDistance = FOV_RADIUS

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and target.Character then
            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
            local head = target.Character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local screenPos, visible =
                    camera:WorldToViewportPoint(head.Position)

                if visible and screenPos.Z > 0 then
                    local center = camera.ViewportSize / 2
                    local distance = (
                        Vector2.new(screenPos.X, screenPos.Y) - center
                    ).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closest = head
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if not AIM_ENABLED then
        return
    end

    local target = getTarget()

    if target then
        local targetCFrame =
            CFrame.lookAt(camera.CFrame.Position, target.Position)

        camera.CFrame = camera.CFrame:Lerp(
            targetCFrame,
            math.clamp(SMOOTHNESS, 0, 1)
        )
    end
end)
