local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

local fake = newproxy(true)
local fmt = getrawmetatable(fake)
fmt.__index = function(_, k)
    if k == "IsA" then return function(_, c) return c == "RemoteEvent" or c == "Instance" end end
    return function() end
end
fmt.__namecall = newcclosure(function(self, ...)
    local m = getnamecallmethod()
    if m == "IsA" then return select(1, ...) == "RemoteEvent" or select(1, ...) == "Instance" end
    return nil
end)
fmt.__newindex = function() end

local sys_mt = getrawmetatable(workspace.FE.System)
setreadonly(sys_mt, false)
local ri = sys_mt.__index
local rn = sys_mt.__namecall
sys_mt.__index = newcclosure(function(s, k)
    if k == "KeepYourHeadUp" then return fake end
    return ri(s, k)
end)
sys_mt.__namecall = newcclosure(function(s, ...)
    if getnamecallmethod() == "FindFirstChild" and select(1, ...) == "KeepYourHeadUp" then return fake end
    return rn(s, ...)
end)
setreadonly(sys_mt, true)

local lp_mt = getrawmetatable(lp)
setreadonly(lp_mt, false)
local lp_rn = lp_mt.__namecall
lp_mt.__namecall = newcclosure(function(s, ...)
    if getnamecallmethod() == "Kick" then return end
    return lp_rn(s, ...)
end)
setreadonly(lp_mt, true)

for _, s in ipairs(getrunningscripts()) do
    if s.Name == " " and s.Parent and s.Parent.Name == lp.Name then
        local ok, env = pcall(getsenv, s)
        if ok and env and type(env.Ban) == "function" then env.Ban = function() end end
    end
end


game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "REMAP-H",
    Text  = "bypass working",
    Duration = 5,
})


--[[ Bypass solara/xeno(If you need)

local lp = game:GetService("Players").LocalPlayer

local function RHP()
    local sys = workspace:FindFirstChild("FE") and workspace.FE:FindFirstChild("System")
    if not sys then return nil end

    local rem = sys:FindFirstChild("KeepYourHeadUp")
    if rem then
        rem:Destroy()
        local FH = Instance.new("RemoteEvent")
        FH.Name = "KeepYourHeadUp"
        FH.Parent = sys
        return true
    end

    return false
end

if not RHP() then
    lp:Kick("anticheat updated, Wait for the fix. --->REMAP-H<--")
    return
end

task.spawn(function()
    while true do
        task.wait(1)
        local sys = workspace:FindFirstChild("FE") and workspace.FE:FindFirstChild("System")
        if not sys then
            lp:Kick("anticheat updated, Wait for the fix. --->REMAP-H<--")
            return
        end
        local rem = sys:FindFirstChild("KeepYourHeadUp")
        if rem then
            RHP()
        end
    end
end)
--]]
