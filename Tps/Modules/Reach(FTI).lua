local plrs     = cloneref(game:GetService("Players"))
local rs       = cloneref(game:GetService("RunService"))
local lighting = cloneref(game:GetService("Lighting"))
local lp       = plrs.LocalPlayer
local sys      = workspace:WaitForChild("TPSSystem")

local _conn = nil

local function get_leg(char)
    if not char then return nil end

    local foot   = lighting[lp.Name].PreferredFoot
    local is_r15 = char:FindFirstChild("RightLowerLeg") ~= nil
    local name

    if is_r15 then
        name = foot == 2 and "LeftLowerLeg" or "RightLowerLeg"
    else
        name = foot == 2 and "Left Leg" or "Right Leg"
    end

    return char:FindFirstChild(name)
end

getgenv().ReachFTI = {}
getgenv().ReachFTI.studs = 10

getgenv().ReachFTI.enable = function()
    if _conn then return end

    _conn = rs.Heartbeat:Connect(function()
        local char = lp.Character
        local leg  = get_leg(char)
        local tps  = sys:FindFirstChild("TPS")
        if not leg or not tps then return end

        local dist = (leg.Position - tps.Position).Magnitude
        if dist > (getgenv().ReachFTI and getgenv().ReachFTI.studs or 10) then return end

        firetouchinterest(leg, tps, 0)
        firetouchinterest(leg, tps, 1)
    end)
end

getgenv().ReachFTI.setStuds = function(n)
    if not getgenv().ReachFTI then return end
    getgenv().ReachFTI.studs = n
end

getgenv().ReachFTI.destroy = function()
    if _conn then _conn:Disconnect(); _conn = nil end
    getgenv().ReachFTI = nil
end
