local rs  = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

local skins = {
    maxwell = { mesh = "rbxassetid://12303996327", text = "rbxassetid://12303996609", scale = 1 },
    foxy    = { mesh = "rbxassetid://511716418",   text = "rbxassetid://511716563",   scale = 1 },
    reimu   = { mesh = "rbxassetid://13889657422", text = "rbxassetid://13889657608", scale = 1 },
}

local skin = Instance.new("Part")
skin.CanCollide   = false
skin.Anchored     = true
skin.Massless     = true
skin.Transparency = 1
skin.Size         = Vector3.new(2,2,2)
skin.Parent       = workspace

local smesh       = Instance.new("SpecialMesh")
smesh.MeshType    = Enum.MeshType.FileMesh
smesh.Scale       = Vector3.new(1,1,1)
smesh.Parent      = skin

local ball        = nil
local conn        = nil
local _decal_conn = nil
local _trans_conn = nil
local _snap_trans = nil

local function get_decals(b)
    local decals = {}
    if not b or not b.Parent then return decals end
    for _, v in ipairs(b:GetChildren()) do
        if v:IsA("Decal") then decals[#decals + 1] = v end
    end
    return decals
end

local function disconnect_all()
    if _decal_conn then _decal_conn:Disconnect(); _decal_conn = nil end
    if _trans_conn  then _trans_conn:Disconnect();  _trans_conn  = nil end
end

local function hide(b)
    if not b or not b.Parent then return end
    b.Transparency = 1
    for _, v in ipairs(get_decals(b)) do v.Transparency = 1 end

    disconnect_all()

    _decal_conn = b.ChildAdded:Connect(function(v)
        if not b.Parent then disconnect_all() return end
        if v:IsA("Decal") then v.Transparency = 1 end
    end)

    _trans_conn = b:GetPropertyChangedSignal("Transparency"):Connect(function()
        if not b.Parent then disconnect_all() return end
        if b.Transparency ~= 1 then b.Transparency = 1 end
    end)
end

local function swap(b)
    _snap_trans = b.Transparency
    ball = b
    hide(b)
end

local function find_ball()
    return sys:FindFirstChild("TPS")
end

local existing = find_ball()
if existing then swap(existing) end

sys.ChildAdded:Connect(function(v)
    if v.Name == "TPS" and v:IsA("BasePart") then
        task.wait()
        swap(v)
    end
end)

conn = rs.RenderStepped:Connect(function()
    if not ball or not ball.Parent then
        local new = find_ball()
        if new then swap(new) end
        return
    end

    skin.CFrame = ball.CFrame
end)

getgenv().BallSkin = {
    set = function(name)
        local s = skins[name]
        if not s then warn("BallSkin: '" .. name .. "' doesn't exist") return end

        smesh.MeshId    = s.mesh
        smesh.TextureId = s.text

        -- escala estável (não explode)
        smesh.Scale = Vector3.new(1,1,1) * (s.scale or 1)

        skin.Transparency = 0
    end,

    reset = function()
        disconnect_all()

        skin.Transparency = 1
        smesh.MeshId    = ""
        smesh.TextureId = ""

        if ball and ball.Parent then
            ball.Transparency = _snap_trans or 0
            for _, v in ipairs(get_decals(ball)) do v.Transparency = 0 end
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
