local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer

local _username  = nil
local _char_conn = nil
local _self_desc = nil

local function uri(id)
    return "rbxassetid://" .. tostring(id)
end

local function clean(char)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Shirt") or v:IsA("Pants")
        or v:IsA("BodyColors") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end
    local hd = char:FindFirstChild("Head")
    if hd then
        for _, v in ipairs(hd:GetChildren()) do
            if v:IsA("Decal") or v.Name == "__dyn_head" then v:Destroy() end
        end
    end
end

local function weld_acc(char, hum, acc)
    local h = acc:FindFirstChild("Handle")
    if not h or not h:IsA("BasePart") then
        acc.Parent = game
        if hum then pcall(function() hum:AddAccessory(acc) end) end
        if acc.Parent ~= char then acc.Parent = char end
        return
    end
    acc.Parent = char
    for _, v in ipairs(h:GetChildren()) do
        if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then v:Destroy() end
    end
    local a = h:FindFirstChildOfClass("Attachment")
    local b = a and char:FindFirstChild(a.Name, true)
    if not b then
        local at = ""
        pcall(function() at = tostring(acc.AccessoryType) end)
        local pref = {"HatAttachment", "HairAttachment", "FaceFrontAttachment", "FaceCenterAttachment",
            "NeckAttachment", "BodyFrontAttachment", "BodyBackAttachment", "WaistCenterAttachment"}
        if at:find("Hair") then pref = {"HairAttachment", "HatAttachment", "FaceCenterAttachment"}
        elseif at:find("Face") then pref = {"FaceFrontAttachment", "FaceCenterAttachment", "HatAttachment"}
        elseif at:find("Back") then pref = {"BodyBackAttachment", "WaistBackAttachment"}
        elseif at:find("Waist") then pref = {"WaistCenterAttachment", "WaistFrontAttachment"}
        elseif at:find("Neck") then pref = {"NeckAttachment"} end
        for _, n in ipairs(pref) do
            b = char:FindFirstChild(n, true)
            if b then break end
        end
    end
    local w = Instance.new("Weld")
    w.Name = "AccessoryWeld"
    if b and b.Parent and b.Parent:IsA("BasePart") then
        w.Part0 = b.Parent
        w.Part1 = h
        w.C0 = b.CFrame
        w.C1 = a and a.CFrame or CFrame.new()
    else
        local hd = char:FindFirstChild("Head")
        if hd then
            w.Part0 = hd
            w.Part1 = h
            w.C0 = CFrame.new(0, 0.6, 0)
        end
    end
    w.Parent = h
end

local function head_from_model(m, char)
    local s = m:FindFirstChild("Head")
    local d = char:FindFirstChild("Head")
    if not s or not d then return end
    local dyn = s:FindFirstChildOfClass("SpecialMesh")
    local mp = s:IsA("MeshPart") and s.MeshId ~= ""
    if not dyn and not mp and not s:FindFirstChildOfClass("FaceControls") then return end
    if dyn then
        local mesh = dyn:Clone()
        mesh.Name = "__dyn_head"
        mesh.Parent = d
    elseif mp then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = s.MeshId
        mesh.TextureId = s.TextureID or ""
        mesh.Name = "__dyn_head"
        mesh.Parent = d
    end
    for _, v in ipairs(s:GetChildren()) do
        if not v:IsA("Attachment") and not v:IsA("SpecialMesh") and not d:FindFirstChild(v.Name) then
            pcall(function() v:Clone().Parent = d end)
        end
    end
    local f = d:FindFirstChildOfClass("Decal")
    if f then f:Destroy() end
end

local function acc_ids(desc)
    local ids, seen = {}, {}
    local function push(v)
        local id = math.floor(tonumber(v) or 0)
        if id > 0 and not seen[id] then seen[id] = true; ids[#ids+1] = id end
    end
    pcall(function()
        for _, e in ipairs(desc:GetAccessories(true)) do
            if type(e) == "table" then push(e.AssetId or e.assetId)
            elseif typeof(e) == "Instance" then push(e.AssetId) end
        end
    end)
    for _, f in ipairs({ desc.HatAccessory, desc.HairAccessory, desc.FaceAccessory, desc.NeckAccessory,
        desc.ShouldersAccessory, desc.FrontAccessory, desc.BackAccessory, desc.WaistAccessory }) do
        for p in string.gmatch(tostring(f or ""), "[^,]+") do push(p) end
    end
    return ids
end

local function objs(id)
    local out = {}
    pcall(function()
        for _, v in ipairs(game:GetObjects(uri(id))) do out[#out+1] = v end
    end)
    if #out == 0 then
        pcall(function() out[1] = game:GetService("InsertService"):LoadLocalAsset(uri(id)) end)
    end
    return out
end

local function extract(root)
    if root:IsA("Accessory") or root:IsA("Hat") then return {root} end
    local list = {}
    for _, v in ipairs(root:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") then list[#list+1] = v end
    end
    if #list == 0 then
        for _, v in ipairs(root:GetDescendants()) do
            if v:IsA("Accessory") or v:IsA("Hat") then list[#list+1] = v end
        end
    end
    return list
end

local function apply_desc(char, desc)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local m
    pcall(function() m = plrs:CreateHumanoidModelFromDescription(desc, hum.RigType) end)
    clean(char)
    if m then
        local hd = char:FindFirstChild("Head")
        for _, v in ipairs(m:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic")
            or v:IsA("BodyColors") or v:IsA("CharacterMesh") then
                v:Clone().Parent = char
            elseif v.Name == "Head" and hd then
                local f = v:FindFirstChildOfClass("Decal")
                if f then f:Clone().Parent = hd end
            end
        end
        head_from_model(m, char)
    end
    local seen = {}
    local function attach(acc)
        if seen[acc.Name] then return end
        seen[acc.Name] = true
        weld_acc(char, hum, acc:Clone())
    end
    if m then
        for _, v in ipairs(extract(m)) do attach(v) end
    end
    for _, id in ipairs(acc_ids(desc)) do
        for _, o in ipairs(objs(id)) do
            for _, acc in ipairs(extract(o)) do attach(acc) end
        end
    end
    if m then pcall(function() m:Destroy() end) end
    if not char:FindFirstChildOfClass("Shirt") and desc.Shirt and desc.Shirt > 0 then
        local s = Instance.new("Shirt")
        s.ShirtTemplate = uri(desc.Shirt)
        s.Parent = char
    end
    if not char:FindFirstChildOfClass("Pants") and desc.Pants and desc.Pants > 0 then
        local p = Instance.new("Pants")
        p.PantsTemplate = uri(desc.Pants)
        p.Parent = char
    end
    if not char:FindFirstChildOfClass("BodyColors") then
        local bc = Instance.new("BodyColors")
        bc.HeadColor3 = desc.HeadColor
        bc.TorsoColor3 = desc.TorsoColor
        bc.LeftArmColor3 = desc.LeftArmColor
        bc.RightArmColor3 = desc.RightArmColor
        bc.LeftLegColor3 = desc.LeftLegColor
        bc.RightLegColor3 = desc.RightLegColor
        bc.Parent = char
    end
    local hd = char:FindFirstChild("Head")
    if hd and not hd:FindFirstChildOfClass("Decal") and not hd:FindFirstChild("__dyn_head") then
        local f = Instance.new("Decal")
        f.Name = "face"
        f.Face = Enum.NormalId.Front
        f.Texture = (desc.Face and desc.Face > 0) and uri(desc.Face) or "rbxasset://textures/face.png"
        f.Parent = hd
    end
end

local function save_self()
    if _self_desc then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local ok, d = pcall(function() return hum:GetAppliedDescription() end)
        if ok and d then _self_desc = d:Clone() return end
    end
    pcall(function()
        local uid = plrs:GetUserIdFromNameAsync(lp.Name)
        _self_desc = plrs:GetHumanoidDescriptionFromUserId(uid)
    end)
end

local function apply(char)
    if not char or not _username then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        task.delay(0.5, function() apply(char) end)
        return
    end
    save_self()
    local ok, err = pcall(function()
        local uid = plrs:GetUserIdFromNameAsync(_username)
        local desc = plrs:GetHumanoidDescriptionFromUserId(uid)
        apply_desc(char, desc)
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

    reset = function()
        save_self()
        if not _self_desc then return end
        _username = nil
        if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
        local char = lp.Character
        if not char then return end
        pcall(function() apply_desc(char, _self_desc) end)
    end,

    destroy = function()
        if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
        _username = nil
        getgenv().AvatarStolen = nil
    end,
}
