local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer

local _username  = nil
local _char_conn = nil

local function clean(char)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants")
        or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then
            v:Destroy()
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local empty = Instance.new("HumanoidDescription")
        hum:ApplyDescriptionClientServer(empty)
    end
end

local function apply(char)
    if not char or not _username then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        task.delay(0.5, function() apply(char) end)
        return
    end

    clean(char)

    local ok, err = pcall(function()
        local uid  = plrs:GetUserIdFromNameAsync(_username)
        local desc = plrs:GetHumanoidDescriptionFromUserId(uid)
        char:FindFirstChildOfClass("Humanoid"):ApplyDescriptionClientServer(desc)
    end)

    if not ok then
        warn("AvatarStolen:", err)
        task.delay(1, function() apply(char) end)
    end
end

getgenv().AvatarStolen = {
    steal = function(username)
        _username = username

        if _char_conn then _char_conn:Disconnect() end
        _char_conn = lp.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid")
            task.wait(0.2)
            apply(char)
        end)

        local char = lp.Character
        if char then apply(char) end
    end,

    destroy = function()
        if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
        _username = nil
        getgenv().AvatarStolen = nil
    end,
}
