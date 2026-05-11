local services = require("./utilities/services")

local Players = services.Players
local UserInputService = services.UserInputService
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local functions = {}

function functions:GetTracerOrigin(root)
	local origin = root.Settings.Tracer.Origin
	if origin == 2 then
		return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
	elseif origin == 3 then
		return Vector2.new(Camera.ViewportSize.X / 2, 0)
	elseif origin == 4 then
		return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	elseif origin == 5 then
		return UserInputService:GetMouseLocation()
	elseif origin == 1 and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local v3 = Camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
		return Vector2.new(v3.X, v3.Y)
	else
		return Vector2.new(0, 0)
	end
end

function functions:GetPlayerType(Player)
	local teamType
	if Player.Neutral then
		teamType = "generic"
	else
		if Player.TeamColor == LocalPlayer.TeamColor then
			teamType = "friendly"
		else
			teamType = "enemy"
		end
	end

	if Player == LocalPlayer then
		teamType = "local"
	end
	return teamType
end

function functions:GetPlayerColor(root, Player, isVisible, part, additional)
	local teamType

	if Player.Neutral then
		teamType = "generic"
	else
		if Player.TeamColor == LocalPlayer.TeamColor then
			teamType = "friendly"
		else
			teamType = "enemy"
		end
	end

	if Player == LocalPlayer then
		teamType = "local"
	end

	-- Dynamic enemy team colors
	local teamColor
	local darkTeamColor

	if teamType == "enemy" and Player.Team then
		teamColor = Player.Team.TeamColor.Color

		darkTeamColor = Color3.new(
			teamColor.R * 0.5,
			teamColor.G * 0.5,
			teamColor.B * 0.5
		)
	end

	-- Health bar fill logic
	if part == "HealthBar" and additional == "Fill" then
		if not Player.Character then
			return
		end

		local currentHealth = root.Settings.HealthBar.Source(Player, "Health")
		local maxHealth = root.Settings.HealthBar.Source(Player, "MaxHealth")

		local currentStatus

		if currentHealth / maxHealth > 0.65 then
			currentStatus = "High"
		elseif currentHealth / maxHealth > 0.20 then
			currentStatus = "Medium"
		else
			currentStatus = "Low"
		end

		-- Use enemy team color for health fill
		if teamColor then
			return isVisible and teamColor or darkTeamColor
		end

		return root.Settings.currentColors[teamType].HealthBar
			and root.Settings.currentColors[teamType].HealthBar.Fills[currentStatus]
	end

	-- Text coloring
	if part == "Text" then
		if teamColor then
			return isVisible and teamColor or darkTeamColor
		end

		return root.Settings.currentColors[teamType][part]
	end

	-- Health outline
	if part == "HealthBar" and additional == "Outline" then
		if not Player.Character then
			return
		end

		if teamColor then
			return darkTeamColor
		end

		return root.Settings.currentColors[teamType].HealthBar
				and root.Settings.currentColors[teamType].HealthBar["Outline"]
			or Color3.new(0, 0, 0)
	end

	-- Visibility recolor logic
	if root.Settings.Checks.Visible.Enabled and not isVisible then
		if teamColor then
			return darkTeamColor
		end

		if additional then
			return root.Settings.currentColors[teamType][part][additional].Invisible
		else
			return root.Settings.currentColors[teamType][part].Invisible
		end
	else
		if teamColor then
			return teamColor
		end

		if additional then
			return root.Settings.currentColors[teamType][part][additional].Visible
		else
			return root.Settings.currentColors[teamType][part].Visible
		end
	end
end

function functions:GetBoxCorners(cf, size)
	local corners = {
		Vector3.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
		Vector3.new(-size.X / 2, -size.Y / 2, size.Z / 2),
		Vector3.new(-size.X / 2, size.Y / 2, -size.Z / 2),
		Vector3.new(-size.X / 2, size.Y / 2, size.Z / 2),
		Vector3.new(size.X / 2, -size.Y / 2, -size.Z / 2),
		Vector3.new(size.X / 2, -size.Y / 2, size.Z / 2),
		Vector3.new(size.X / 2, size.Y / 2, -size.Z / 2),
		Vector3.new(size.X / 2, size.Y / 2, size.Z / 2),
	}

	for i, corner in ipairs(corners) do
		corners[i] = cf:PointToWorldSpace(corner)
	end

	return corners
end

return functions
