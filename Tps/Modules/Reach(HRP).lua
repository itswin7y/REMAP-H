local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer

local _orig_size    = nil
local _orig_collide = nil
local _char_conn    = nil
local _prop_conn    = nil

getgenv().ReachHRP = {}
getgenv().ReachHRP.size = Vector3.new(15, 2, 15)

local function apply(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    task.wait(0.1)

    if not _orig_size    then _orig_size    = hrp.Size       end
    if _orig_collide == nil then _orig_collide = hrp.CanCollide end

    local function set()
        local s = getgenv().ReachHRP and getgenv().ReachHRP.size or Vector3.new(15, 2, 15)
        hrp.Size       = Vector3.new(s.X, 2, s.Z)
        hrp.CanCollide = false
    end

    set()

    if _prop_conn then _prop_conn:Disconnect() end
    _prop_conn = hrp:GetPropertyChangedSignal("Size"):Connect(function()
        local s   = getgenv().ReachHRP and getgenv().ReachHRP.size or Vector3.new(15, 2, 15)
        local want = Vector3.new(s.X, 2, s.Z)
        if hrp.Size ~= want then hrp.Size = want end
    end)
end

getgenv().ReachHRP.enable = function()
    local char = lp.Character
    if char then apply(char) end
    _char_conn = lp.CharacterAdded:Connect(apply)
end

getgenv().ReachHRP.destroy = function()
    if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
    if _prop_conn then _prop_conn:Disconnect(); _prop_conn = nil end

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if _orig_size       then hrp.Size       = _orig_size    end
            if _orig_collide ~= nil then hrp.CanCollide = _orig_collide end
        end
    end

    _orig_size    = nil
    _orig_collide = nil
    getgenv().ReachHRP = nil
end
