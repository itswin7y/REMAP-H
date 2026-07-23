local plrs = cloneref(game:GetService("Players"))
local insert = cloneref(game:GetService("InsertService"))
local lp = plrs.LocalPlayer

local _username = nil
local _char_conn = nil

local function uri(id)
    return "rbxassetid://" .. tostring(id)
end

local function clean(char)
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants")
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
    local w = Instance.new("Weld")
    if b and b.Parent and b.Parent:IsA("BasePart") then
        w.Part0 = b.Parent
        w.Part1 = h
        w.C0 = b.CFrame
        w.C1 = a.CFrame
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
        mesh.TextureId = s.TextureId
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
        pcall(function() out[1] = insert:LoadLocalAsset(uri(id)) end)
    end
    return out
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
        local uid = plrs:GetUserIdFromNameAsync(_username)
        local d = plrs:GetHumanoidDescriptionFromUserId(uid)
        local m = plrs:CreateHumanoidModelFromDescription(d, hum.RigType)

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

        local seen = {}
        for _, v in ipairs(m:GetChildren()) do
            if (v:IsA("Accessory") or v:IsA("Hat")) and not seen[v.Name] then
                seen[v.Name] = true
                weld_acc(char, hum, v:Clone())
            end
        end

        for _, id in ipairs(acc_ids(d)) do
            for _, o in ipairs(objs(id)) do
                local accs = o:IsA("Accessory") and { o } or {}
                if not o:IsA("Accessory") then
                    for _, x in ipairs(o:GetDescendants()) do
                        if x:IsA("Accessory") then accs[#accs+1] = x end
                    end
                end
                for _, acc in ipairs(accs) do
                    if not seen[acc.Name] then
                        seen[acc.Name] = true
                        weld_acc(char, hum, acc)
                    end
                end
            end
        end

        m:Destroy()

        if not char:FindFirstChildOfClass("Shirt") and d.Shirt and d.Shirt > 0 then
            local s = Instance.new("Shirt")
            s.ShirtTemplate = uri(d.Shirt)
            s.Parent = char
        end
        if not char:FindFirstChildOfClass("Pants") and d.Pants and d.Pants > 0 then
            local p = Instance.new("Pants")
            p.PantsTemplate = uri(d.Pants)
            p.Parent = char
        end
        if not char:FindFirstChildOfClass("BodyColors") then
            local bc = Instance.new("BodyColors")
            bc.HeadColor3 = d.HeadColor
            bc.TorsoColor3 = d.TorsoColor
            bc.LeftArmColor3 = d.LeftArmColor
            bc.RightArmColor3 = d.RightArmColor
            bc.LeftLegColor3 = d.LeftLegColor
            bc.RightLegColor3 = d.RightLegColor
            bc.Parent = char
        end
        if hd and not hd:FindFirstChildOfClass("Decal") and not hd:FindFirstChild("__dyn_head") then
            local f = Instance.new("Decal")
            f.Name = "face"
            f.Face = Enum.NormalId.Front
            f.Texture = (d.Face and d.Face > 0) and uri(d.Face) or "rbxasset://textures/face.png"
            f.Parent = hd
        end
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
