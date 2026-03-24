local rs   = cloneref(game:GetService("RunService"))
local cfg  = { size = 20 }
local tps  = workspace.TPSSystem.TPS

local platform        = Instance.new("Part")
platform.Name         = ""
platform.Anchored     = true
platform.CanCollide   = true
platform.Transparency = 1
platform.CastShadow   = false
platform.Size         = Vector3.new(cfg.size, 0.1, cfg.size)
platform.Material     = Enum.Material.SmoothPlastic
platform.Parent       = workspace.TPSSystem
platform.CFrame       = CFrame.new(tps.Position.X, tps.Position.Y - 1.5, tps.Position.Z)

local conn
conn = rs.Heartbeat:Connect(function()
    platform.CFrame = CFrame.new(tps.Position.X, tps.Position.Y - 1.5, tps.Position.Z)
end)

getgenv().AirHelper = {
    destroy = function()
        if conn then conn:Disconnect(); conn = nil end
        if platform and platform.Parent then platform:Destroy() end
        getgenv().AirHelper = nil
    end,
    setSize = function(s)
        cfg.size      = s
        platform.Size = Vector3.new(s, 0.1, s)
    end,
}
