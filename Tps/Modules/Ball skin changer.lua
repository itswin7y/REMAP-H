local rs  = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

local skins = {
    maxwell = { mesh = "rbxassetid://12303996327", text = "rbxassetid://12303996609", scale = 0.35 },
    foxy    = { mesh = "rbxassetid://511716418",   text = "rbxassetid://511716563",   scale = 0.4  },
    reimu   = { mesh = "rbxassetid://13889657422", text = "rbxassetid://13889657608", scale = 1    },
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

local saved = {
    transparency = nil,
    decals = {}
}

local function get_decals(b)
    local t = {}
    if not b or not b.Parent then return t end
    for _, v in ipairs(b:GetChildren()) do
        if v:IsA("Decal") then
            t[#t+1] = v
        end
    end
    return t
end

local function disconnect_all()
    if _decal_conn then _decal_conn:Disconnect(); _decal_conn = nil end
    if _trans_conn then _trans_conn:Disconnect(); _trans_conn = nil end
end

local function save_state(b)
    saved.transparency = b.Transparency
    saved.decals = {}

    for _, v in ipairs(get_decals(b)) do
        saved.decals[v] = v.Transparency
    end
end

local function restore_state(b)
    if not b or not b.Parent then return end

    disconnect_all()

    if saved.transparency ~= nil then
        b.Transparency = saved.transparency
    end

    for v, t in pairs(saved.decals) do
        if v and v.Parent then
            v.Transparency = t
        end
    end
end

local function hide(b)
    if not b or not b.Parent then return end

    save_state(b)

    b.Transparency = 1
    for _, v in ipairs(get_decals(b)) do
        v.Transparency = 1
    end

    disconnect_all()

    _decal_conn = b.ChildAdded:Connect(function(v)
        if v:IsA("Decal") then
            saved.decals[v] = v.Transparency
            v.Transparency = 1
        end
    end)

    _trans_conn = b:GetPropertyChangedSignal("Transparency"):Connect(function()
        if b.Transparency ~= 1 then
            b.Transparency = 1
        end
    end)
end

local function swap(b)
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
        smesh.Scale     = Vector3.new(1,1,1) * (s.scale or 1)

        skin.Transparency = 0
    end,

    reset = function()
        if ball then
            restore_state(ball)
        end

        skin.Transparency = 1
        smesh.MeshId    = ""
        smesh.TextureId = ""

        ball = nil
        saved.decals = {}
        saved.transparency = nil
    end,

    destroy = function()
        getgenv().BallSkin.reset()
        if conn then conn:Disconnect(); conn = nil end
        if skin and skin.Parent then skin:Destroy() end
        getgenv().BallSkin = nil
    end,
}
