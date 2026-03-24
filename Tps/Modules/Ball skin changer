local rs  = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

local skins = {
    maxwell = { mesh = "rbxassetid://12303996327", text = "rbxassetid://12303996609" },
    foxy    = { mesh = "rbxassetid://511716418",   text = "rbxassetid://511716563"   },
    reimu   = { mesh = "rbxassetid://13889657422",  text = "rbxassetid://13889657608"  },
}

local skin = Instance.new("MeshPart")
skin.CanCollide  = false
skin.Anchored    = true
skin.Massless    = true
skin.Transparency = 1
skin.Parent      = workspace

local ball, conn

local function hide(b)
    b.Transparency = 1
    for _, v in ipairs(b:GetChildren()) do
        if v:IsA("Decal") then v:Destroy() end
    end
    b.ChildAdded:Connect(function(v)
        if v:IsA("Decal") then v:Destroy() end
    end)
    b:GetPropertyChangedSignal("Transparency"):Connect(function()
        if b.Transparency ~= 1 then b.Transparency = 1 end
    end)
end

local function swap(b)
    ball = b
    skin.Size = b.Size
    hide(b)
end

local existing = sys:FindFirstChild("TPS")
if existing then swap(existing) end

sys.ChildAdded:Connect(function(v)
    if v.Name == "TPS" and v:IsA("BasePart") then
        task.wait()
        swap(v)
    end
end)

conn = rs.RenderStepped:Connect(function()
    if ball and ball.Parent then
        skin.CFrame = ball.CFrame
    end
end)

getgenv().BallSkin = {
    set = function(name)
        local s = skins[name]
        if not s then warn("BallSkin: '" .. name .. "' It doesn't exist") return end
        skin.MeshId      = s.mesh
        skin.TextureID   = s.text
        skin.Transparency = 0
    end,
    destroy = function()
        if conn then conn:Disconnect(); conn = nil end
        if skin and skin.Parent then skin:Destroy() end
        getgenv().BallSkin = nil
    end,
}
