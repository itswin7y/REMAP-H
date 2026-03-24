local rs  = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

local skins = {
    maxwell = { mesh = "rbxassetid://12303996327", text = "rbxassetid://12303996609" },
    foxy    = { mesh = "rbxassetid://511716418",   text = "rbxassetid://511716563"   },
    reimu   = { mesh = "rbxassetid://13889657422", text = "rbxassetid://13889657608" },
}

local skin = Instance.new("MeshPart")
skin.CanCollide   = false
skin.Anchored     = true
skin.Massless     = true
skin.Transparency = 1
skin.Parent       = workspace

local ball        = nil
local conn        = nil
local _decal_conn = nil
local _trans_conn = nil
local _snap_trans = nil

local function get_decals(b)
    local decals = {}
    for _, v in ipairs(b:GetChildren()) do
        if v:IsA("Decal") then
            decals[#decals + 1] = v
        end
    end
    return decals
end

local function hide(b)
    b.Transparency = 1

    for _, v in ipairs(get_decals(b)) do
        v.Transparency = 1
    end

    if _decal_conn then _decal_conn:Disconnect() end
    _decal_conn = b.ChildAdded:Connect(function(v)
        if v:IsA("Decal") then v.Transparency = 1 end
    end)

    if _trans_conn then _trans_conn:Disconnect() end
    _trans_conn = b:GetPropertyChangedSignal("Transparency"):Connect(function()
        if b.Transparency ~= 1 then b.Transparency = 1 end
    end)
end

local function swap(b)
    _snap_trans = b.Transparency
    ball = b
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
    if not ball or not ball.Parent then return end
    skin.CFrame = ball.CFrame
    if skin.Size ~= ball.Size then skin.Size = ball.Size end
end)

getgenv().BallSkin = {
    set = function(name)
        local s = skins[name]
        if not s then warn("BallSkin: '" .. name .. "'It doesn't exist") return end
        skin.MeshId       = s.mesh
        skin.TextureID    = s.text
        skin.Transparency = 0
    end,

    reset = function()
        if _decal_conn then _decal_conn:Disconnect(); _decal_conn = nil end
        if _trans_conn  then _trans_conn:Disconnect(); _trans_conn  = nil end

        skin.Transparency = 1
        skin.MeshId       = ""
        skin.TextureID    = ""

        if ball and ball.Parent then
            ball.Transparency = _snap_trans or 0
            for _, v in ipairs(get_decals(ball)) do
                v.Transparency = 0
            end
        end

        _snap_trans = nil
        ball        = nil
    end,

    destroy = function()
        getgenv().BallSkin.reset()
        if conn then conn:Disconnect(); conn = nil end
        if skin and skin.Parent then skin:Destroy() end
        getgenv().BallSkin = nil
    end,
}
