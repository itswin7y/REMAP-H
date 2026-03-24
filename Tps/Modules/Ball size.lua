local rs  = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

local _target    = nil
local _orig_size = nil
local _conn_hb   = nil
local _conn_add  = nil

local function find_tps()
    return sys:FindFirstChild("TPS")
end

local function ensure_orig()
    if _orig_size then return end
    local tps = find_tps()
    if tps then _orig_size = tps.Size end
end

getgenv().BallSize = {
    set = function(sx, sy, sz)
        ensure_orig()
        _target = Vector3.new(sx, sy, sz)

        local tps = find_tps()
        if tps then tps.Size = _target end

        if _conn_hb then _conn_hb:Disconnect() end
        _conn_hb = rs.Heartbeat:Connect(function()
            local b = find_tps()
            if not b then return end
            ensure_orig()
            if b.Size ~= _target then b.Size = _target end
        end)

        if _conn_add then _conn_add:Disconnect() end
        _conn_add = sys.ChildAdded:Connect(function(v)
            if v.Name ~= "TPS" or not v:IsA("BasePart") then return end
            task.wait()
            if not _orig_size then _orig_size = v.Size end
            if _target then v.Size = _target end
        end)
    end,

    reset = function()
        if _conn_hb  then _conn_hb:Disconnect();  _conn_hb  = nil end
        if _conn_add then _conn_add:Disconnect(); _conn_add = nil end

        local tps = find_tps()
        if tps and _orig_size then tps.Size = _orig_size end

        _target = nil
    end,

    destroy = function()
        getgenv().BallSize.reset()
        _orig_size = nil
        getgenv().BallSize = nil
    end,
}
