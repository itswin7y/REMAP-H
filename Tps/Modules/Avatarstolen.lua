local plrs = cloneref(game:GetService("Players"))
local insert = cloneref(game:GetService("InsertService"))
local lp = plrs.LocalPlayer

local _user = nil
local _conn = nil
local _self = nil

local HINT = {
    [Enum.AccessoryType.Hat] = "HatAttachment",
    [Enum.AccessoryType.Hair] = "HairAttachment",
    [Enum.AccessoryType.Face] = "FaceCenterAttachment",
    [Enum.AccessoryType.Neck] = "NeckAttachment",
    [Enum.AccessoryType.Front] = "BodyFrontAttachment",
    [Enum.AccessoryType.Back] = "BodyBackAttachment",
    [Enum.AccessoryType.Waist] = "WaistCenterAttachment",
    [Enum.AccessoryType.Shoulder] = "BodyFrontAttachment",
}

local function uri(id)
    return "rbxassetid://" .. tostring(id)
end

local function uid(q)
    q = tostring(q or ""):match("^%s*(.-)%s*$")
    if q:match("^@") then q = q:sub(2) end
    local n = tonumber(q)
    if n and n == math.floor(n) and n > 0 and not q:match("%a") then return n end
    local ok, id = pcall(plrs.GetUserIdFromNameAsync, plrs, q)
    if ok and type(id) == "number" and id > 0 then return id end
    return nil
end

local function clean(char)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Shirt") or v:IsA("Pants")
        or v:IsA("ShirtGraphic") or v:IsA("BodyColors") or v:IsA("CharacterMesh") then v:Destroy() end
    end
    local hd = char:FindFirstChild("Head")
    if hd then
        for _, v in ipairs(hd:GetChildren()) do
            if v:IsA("Decal") or v.Name == "_dyn" then v:Destroy() end
        end
    end
end

local function objs(id)
    local out = {}
    pcall(function() for _, v in ipairs(game:GetObjects(uri(id))) do out[#out+1] = v end end)
    if #out == 0 then pcall(function() out[1] = insert:LoadLocalAsset(uri(id)) end) end
    return out
end

local function extract(r)
    if r:IsA("Accessory") or r:IsA("Hat") then return {r} end
    local l = {}
    for _, v in ipairs(r:GetDescendants()) do
        if v:IsA("Accessory") or v:IsA("Hat") then l[#l+1] = v end
    end
    return l
end

-- id -> AccessoryType direto do catalogo; CSV só se a API vier vazia
local function amap(d)
    local out, seen = {}, {}
    local function push(id, at)
        id = math.floor(tonumber(id) or 0)
        if id > 0 and not seen[id] then seen[id] = true; out[#out+1] = {id, at} end
    end
    pcall(function()
        for _, e in ipairs(d:GetAccessories(true)) do
            if type(e) == "table" then push(e.AssetId or e.assetId, e.AccessoryType) end
        end
    end)
    if #out == 0 then
        local csv = {
            {d.HatAccessory, Enum.AccessoryType.Hat},
            {d.HairAccessory, Enum.AccessoryType.Hair},
            {d.FaceAccessory, Enum.AccessoryType.Face},
            {d.NeckAccessory, Enum.AccessoryType.Neck},
            {d.FrontAccessory, Enum.AccessoryType.Front},
            {d.BackAccessory, Enum.AccessoryType.Back},
            {d.WaistAccessory, Enum.AccessoryType.Waist},
            {d.ShouldersAccessory, Enum.AccessoryType.Shoulder},
        }
        for _, row in ipairs(csv) do
            for p in string.gmatch(tostring(row[1] or ""), "[^,]+") do push(p, row[2]) end
        end
    end
    return out
end

local function weld(char, acc, at)
    local h = acc:FindFirstChild("Handle")
    if not h or not h:IsA("BasePart") then
        acc.Parent = game
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:AddAccessory(acc) end) end
        if acc.Parent ~= char then acc.Parent = char end
        return
    end
    h.Anchored = false; h.CanCollide = false; h.CanTouch = false; h.CanQuery = false; h.Massless = true
    for _, j in ipairs(h:GetChildren()) do
        if j:IsA("Weld") or j:IsA("WeldConstraint") or j:IsA("Motor6D") then j:Destroy() end
    end
    acc.Parent = char
    local a = h:FindFirstChildOfClass("Attachment")
    local b = a and char:FindFirstChild(a.Name, true)
    if not b and at then b = char:FindFirstChild(HINT[at], true) end
    local w = Instance.new("Weld")
    if b and b.Parent and b.Parent:IsA("BasePart") then
        w.Part0 = b.Parent; w.Part1 = h
        w.C0 = b.CFrame; w.C1 = a and a.CFrame or CFrame.new()
    else
        local hd = char:FindFirstChild("Head")
        if hd then w.Part0 = hd; w.Part1 = h; w.C0 = CFrame.new(0, 0.6, 0) end
    end
    w.Parent = h
end

local function head_dyn(m, char)
    local s = m:FindFirstChild("Head")
    local d = char:FindFirstChild("Head")
    if not s or not d then return end
    local mesh = s:FindFirstChildOfClass("SpecialMesh")
    local mp = s:IsA("MeshPart") and s.MeshId ~= ""
    if not mesh and not mp and not s:FindFirstChildOfClass("FaceControls") then return end
    if mesh then
        local c = mesh:Clone(); c.Name = "_dyn"; c.Parent = d
    elseif mp then
        local c = Instance.new("SpecialMesh")
        c.MeshType = Enum.MeshType.FileMesh; c.MeshId = s.MeshId; c.TextureId = s.TextureID or ""
        c.Name = "_dyn"; c.Parent = d
    end
    for _, v in ipairs(s:GetChildren()) do
        if not v:IsA("Attachment") and not v:IsA("SpecialMesh") and not d:FindFirstChild(v.Name) then
            pcall(function() v:Clone().Parent = d end)
        end
    end
    local f = d:FindFirstChildOfClass("Decal")
    if f then f:Destroy() end
end

local function reinforce(char, d)
    if not char:FindFirstChildOfClass("Shirt") and d.Shirt and d.Shirt > 0 then
        local s = Instance.new("Shirt"); s.ShirtTemplate = uri(d.Shirt); s.Parent = char
    end
    if not char:FindFirstChildOfClass("Pants") and d.Pants and d.Pants > 0 then
        local p = Instance.new("Pants"); p.PantsTemplate = uri(d.Pants); p.Parent = char
    end
    if not char:FindFirstChildOfClass("BodyColors") then
        local bc = Instance.new("BodyColors")
        bc.HeadColor3 = d.HeadColor; bc.TorsoColor3 = d.TorsoColor
        bc.LeftArmColor3 = d.LeftArmColor; bc.RightArmColor3 = d.RightArmColor
        bc.LeftLegColor3 = d.LeftLegColor; bc.RightLegColor3 = d.RightLegColor
        bc.Parent = char
    end
    local hd = char:FindFirstChild("Head")
    if hd and not hd:FindFirstChildOfClass("Decal") and not hd:FindFirstChild("_dyn") then
        local f = Instance.new("Decal"); f.Name = "face"; f.Face = Enum.NormalId.Front
        f.Texture = (d.Face and d.Face > 0) and uri(d.Face) or "rbxasset://textures/face.png"
        f.Parent = hd
    end
end

local function bake(char, d)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local m
    pcall(function() m = plrs:CreateHumanoidModelFromDescription(d, hum.RigType) end)
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
        head_dyn(m, char)
    end
    for _, row in ipairs(amap(d)) do
        for _, o in ipairs(objs(row[1])) do
            for _, acc in ipairs(extract(o)) do weld(char, acc, row[2]) end
        end
    end
    if m then pcall(function() m:Destroy() end) end
    reinforce(char, d)
end

local function save_self()
    if _self then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local ok, d = pcall(function() return hum:GetAppliedDescription() end)
        if ok and d then _self = d:Clone(); return end
    end
    pcall(function() _self = plrs:GetHumanoidDescriptionFromUserId(lp.UserId) end)
end

local function apply(char)
    if not char or not _user then return end
    if not char:FindFirstChildOfClass("Humanoid") then
        task.delay(0.5, function() apply(char) end)
        return
    end
    save_self()
    local ok, err = pcall(function()
        local id = uid(_user)
        local d = plrs:GetHumanoidDescriptionFromUserId(id)
        bake(char, d)
    end)
    if not ok then
        warn("AvatarStolen:", err)
        task.delay(1, function() apply(char) end)
    end
end

getgenv().AvatarStolen = {
    steal = function(u)
        _user = u
        if _conn then _conn:Disconnect() end
        _conn = lp.CharacterAdded:Connect(function(c)
            c:WaitForChild("Humanoid")
            task.wait(0.2)
            apply(c)
        end)
        if lp.Character then apply(lp.Character) end
    end,

    reset = function()
        save_self()
        if not _self then return end
        _user = nil
        if _conn then _conn:Disconnect(); _conn = nil end
        local char = lp.Character
        if char then pcall(function() bake(char, _self) end) end
    end,

    destroy = function()
        if _conn then _conn:Disconnect(); _conn = nil end
        _user = nil
        getgenv().AvatarStolen = nil
    end,
}
