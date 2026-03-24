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
skin.Size         = Vector3.new(3, 3, 3)
skin.Parent       = workspace

local smesh    = Instance.new("SpecialMesh")
smesh.MeshType = Enum.MeshType.FileMesh
smesh.Scale    = Vector3.new(1, 1, 1)
smesh.Parent   = skin

local ball        = nil
local conn        = nil
local _active     = false
local _decal_conn = nil
local _trans_conn = nil

local saved = { transparency = nil, decals = {} }

local function get_decals(b)
    local t = {}
    if not b or not b.Parent then return t end
    for _, v in ipairs(b:GetChildren()) do
        if v:IsA("Decal") then t[#t+1] = v end
    end
    return t
end

local function disconnect_all()
    if _decal_conn then _decal_conn:Disconnect(); _decal_conn = nil end
    if _trans_conn  then _trans_conn:Disconnect();  _trans_conn  = nil end
end

local function save_state(b)
    if not b or not b.Parent then return end
    saved.transparency = b.Transparency
    saved.decals = {}
    for _, v in ipairs(get_decals(b)) do
        saved.decals[v.Name] = v.Transparency
    end
end

local function hide(b)
    if not b or not b.Parent then return end

    disconnect_all()

    b.Transparency = 1
    for _, v in ipairs(get_decals(b)) do v.Transparency = 1 end

    _decal_conn = b.ChildAdded:Connect(function(v)
        if not b.Parent then disconnect_all() return end
        if v:IsA("Decal") then
            if saved.decals[v.Name] == nil then
                saved.decals[v.Name] = v.Transparency
            end
            v.Transparency = 1
        end
    end)

    _trans_conn = b:GetPropertyChangedSignal("Transparency"):Connect(function()
        if not b.Parent then disconnect_all() return end
        if b.Transparency ~= 1 then b.Transparency = 1 end
    end)
end

local function swap(b)
    disconnect_all()
    ball = b
    if _active then hide(b) end
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
        if not s then warn("BallSkin: '" .. name .. "' doesn't exist") return end

        if not _active and ball and ball.Parent then
            save_state(ball)
        end

        _active = true

        if ball and ball.Parent then hide(ball) end

        smesh.MeshId      = s.mesh
        smesh.TextureId   = s.text
        smesh.Scale       = Vector3.new(1, 1, 1) * (s.scale or 1)
        skin.Transparency = 0
    end,

    reset = function()
        _active = false
        disconnect_all()

        if ball and ball.Parent then
            ball.Transparency = saved.transparency ~= nil and saved.transparency or 0
            for _, v in ipairs(get_decals(ball)) do
                local t = saved.decals[v.Name]
                v.Transparency = t ~= nil and t or 0
            end
        end

        skin.Transparency = 1
        smesh.MeshId      = ""
        smesh.TextureId   = ""

        saved.transparency = nil
        saved.decals       = {}
    end,

    destroy = function()
        getgenv().BallSkin.reset()
        if conn then conn:Disconnect(); conn = nil end
        if skin and skin.Parent then skin:Destroy() end
        getgenv().BallSkin = nil
    end,
}
