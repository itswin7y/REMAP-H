local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer
local hs   = cloneref(game:GetService("HttpService"))
local uis  = cloneref(game:GetService("UserInputService"))

pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Bypass.lua"
    ))()
end)

local Seraph = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/53845052/roblox-uis/refs/heads/main/SeraphLib.lua"
))()
Seraph:SetWindowKeybind(Enum.KeyCode.RightShift)

local Themes = hs:JSONDecode(game:HttpGet(
    "https://raw.githubusercontent.com/53845052/roblox-uis/refs/heads/main/themes/Seraph.json"
))
local ThemeList, ThemeNames = {}, {"Default"} do
    ThemeList.Default = Seraph:GetTheme()
    for Theme, Data in Themes do
        ThemeNames[#ThemeNames+1] = Theme
        ThemeList[Theme] = {}
        for Property, Color in Data do
            ThemeList[Theme][Property] = Color3.fromRGB(unpack(Color:split(",")))
        end
    end
end

if not isfolder("remaph") then makefolder("remaph") end

if uis.TouchEnabled and not uis.KeyboardEnabled then
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn = "", false
    gui.ZIndexBehavior, gui.DisplayOrder = Enum.ZIndexBehavior.Sibling, 999
    gui.Parent = gethui()

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.fromOffset(48, 48)
    btn.Position         = UDim2.new(0, 20, 0.5, -24)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    btn.BorderSizePixel  = 0
    btn.Text             = "R-H"
    btn.TextColor3       = Color3.fromRGB(220, 210, 255)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.AutoButtonColor  = false
    btn.Active           = true
    btn.Parent           = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent       = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color     = Color3.fromRGB(120, 100, 200)
    stroke.Thickness = 1.5
    stroke.Parent    = btn

    local dragging, drag_start, start_pos = false, nil, nil

    btn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging, drag_start, start_pos = true, i.Position, btn.Position
    end)

    uis.InputChanged:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - drag_start
        btn.Position = UDim2.new(
            start_pos.X.Scale, start_pos.X.Offset + d.X,
            start_pos.Y.Scale, start_pos.Y.Offset + d.Y
        )
    end)

    uis.InputEnded:Connect(function(i)
        if not dragging or i.UserInputType ~= Enum.UserInputType.Touch then return end
        local tap = (i.Position - drag_start).Magnitude < 6
        dragging = false
        if not tap then return end
        firesignal(uis.InputBegan, {
            KeyCode        = Enum.KeyCode.RightShift,
            UserInputType  = Enum.UserInputType.Keyboard,
            UserInputState = Enum.UserInputState.Begin,
        }, false)
    end)
end

local URLS = {
    ReachSize    = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Reach(SIZE).lua",
    ReachHRP     = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Reach(HRP).lua",
    ReachFTI     = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Reach(FTI).lua",
    AirHelper    = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/AirHelper.lua",
    BallSize     = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Ball%20size.lua",
    BallSkin     = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Ball%20skin%20changer.lua",
    AvatarStolen = "https://raw.githubusercontent.com/itswin7y/REMAP-H/refs/heads/main/Tps/Modules/Avatarstolen.lua",
}

local loaded = {}

local function load_once(key)
    if loaded[key] then return true end
    local ok = pcall(function() loadstring(game:HttpGet(URLS[key]))() end)
    if ok then loaded[key] = true end
    return ok
end

local function get_skin_ref()
    if getgenv()._skin_ref and getgenv()._skin_ref.Parent then
        return getgenv()._skin_ref
    end
    for _, v in workspace:GetChildren() do
        if v:IsA("MeshPart") and v.Anchored and not v.CanCollide and v.Massless and v.Name == "" then
            getgenv()._skin_ref = v
            return v
        end
    end
end

local Window = Seraph:Window("REMAP-H") do

    local MainTab = Window:AddTab({"rbxassetid://16095745392"}) do

        local ReachCat = MainTab:AddCategory("REACH") do

            local SubSize = ReachCat:AddSubCategory("Reach Size") do
                local Sec = SubSize:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "Reach Size",
                        Placeholder = "5",
                        Default     = "5",
                        Flag        = "ReachSize_Val",
                        Callback    = function(val)
                            local n = tonumber(val) or 5
                            getgenv().reach_size = Vector3.new(n, 2, n)
                        end,
                    })
                    Sec:Toggle({
                        Title    = "Enable",
                        Flag     = "ReachSize_On",
                        Callback = function(state)
                            local n = tonumber(Seraph.Flags.ReachSize_Val:GetValue()) or 5
                            if state then
                                getgenv().reach_size = Vector3.new(n, 2, n)
                                load_once("ReachSize")
                            else
                                getgenv().reach_size = Vector3.new(2, 2, 2)
                            end
                        end,
                    })
                end
            end

            local SubFTI = ReachCat:AddSubCategory("Reach Firetouch") do
                local Sec = SubFTI:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "Reach size(fti)",
                        Placeholder = "5",
                        Default     = "5",
                        Flag        = "ReachFTI_Val",
                        Callback    = function(val)
                            local n = tonumber(val) or 5
                            if getgenv().ReachFTI then
                                getgenv().ReachFTI.setStuds(n)
                            end
                        end,
                    })
                    Sec:Toggle({
                        Title    = "Enable",
                        Flag     = "ReachFTI_On",
                        Callback = function(state)
                            local n = tonumber(Seraph.Flags.ReachFTI_Val:GetValue()) or 5
                            if state then
                                load_once("ReachFTI")
                                if getgenv().ReachFTI then
                                    getgenv().ReachFTI.setStuds(n)
                                    getgenv().ReachFTI.enable()
                                end
                            else
                                if getgenv().ReachFTI then
                                    getgenv().ReachFTI.destroy()
                                    loaded.ReachFTI = nil
                                end
                            end
                        end,
                    })
                end
            end

            local SubHRP = ReachCat:AddSubCategory("Reach Humanoid") do
                local Sec = SubHRP:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "reach Size(hrp)",
                        Placeholder = "5",
                        Default     = "5",
                        Flag        = "ReachHRP_Val",
                        Callback    = function(val)
                            local n = tonumber(val) or 5
                            if getgenv().ReachHRP then
                                getgenv().ReachHRP.size = Vector3.new(n, 2, n)
                            end
                        end,
                    })
                    Sec:Toggle({
                        Title    = "Enable",
                        Flag     = "ReachHRP_On",
                        Callback = function(state)
                            local n = tonumber(Seraph.Flags.ReachHRP_Val:GetValue()) or 5
                            if state then
                                load_once("ReachHRP")
                                if getgenv().ReachHRP then
                                    getgenv().ReachHRP.size = Vector3.new(n, 2, n)
                                    getgenv().ReachHRP.enable()
                                end
                            else
                                if getgenv().ReachHRP then
                                    getgenv().ReachHRP.destroy()
                                    loaded.ReachHRP = nil
                                end
                            end
                        end,
                    })
                end
            end

        end

        local HelpersCat = MainTab:AddCategory("Helpers") do

            local SubAir = HelpersCat:AddSubCategory("Air Helper") do
                local Sec = SubAir:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "Airhelper Size",
                        Placeholder = "5",
                        Default     = "5",
                        Flag        = "Air_Val",
                        Callback    = function(val)
                            local n = tonumber(val) or 5
                            if getgenv().AirHelper then
                                getgenv().AirHelper.setSize(n)
                            end
                        end,
                    })
                    Sec:Toggle({
                        Title    = "Enable",
                        Flag     = "Air_On",
                        Callback = function(state)
                            local n = tonumber(Seraph.Flags.Air_Val:GetValue()) or 5
                            if state then
                                load_once("AirHelper")
                                if getgenv().AirHelper then
                                    getgenv().AirHelper.setSize(n)
                                end
                            else
                                if getgenv().AirHelper then
                                    getgenv().AirHelper.destroy()
                                    loaded.AirHelper = nil
                                end
                            end
                        end,
                    })
                end
            end

        end

    end

    local BallTab = Window:AddTab({"rbxassetid://110086064629710"}) do

        local BallModCat = BallTab:AddCategory("Ball Modifications") do

            local SubSizer = BallModCat:AddSubCategory("Ball Sizer") do
                local Sec = SubSizer:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "Ball Size",
                        Placeholder = "5",
                        Default     = "5",
                        Flag        = "BallSize_Val",
                    })
                    Sec:Button({
                        Title    = "Apply",
                        Callback = function()
                            local n = tonumber(Seraph.Flags.BallSize_Val:GetValue()) or 5
                            load_once("BallSize")
                            if getgenv().BallSize then
                                getgenv().BallSize.set(n, n, n)
                            end
                        end,
                    }):Button({
                        Title    = "Reset",
                        Callback = function()
                            if getgenv().BallSize then
                                getgenv().BallSize.reset()
                            end
                        end,
                    })
                end
            end

            local SubSkin = BallModCat:AddSubCategory("Ball Skin Changer") do
                local SecPresets = SubSkin:AddSection("Presets") do
                    SecPresets:Dropdown({
                        Title    = "Preset Skin",
                        Options  = {"None", "Maxwell", "Foxy", "Reimu"},
                        Default  = "None",
                        Flag     = "BallSkin_Preset",
                        Callback = function(opt)
                            load_once("BallSkin")
                            if not getgenv().BallSkin then return end
                            if opt == "None" then
                                getgenv().BallSkin.reset()
                            else
                                getgenv().BallSkin.set(opt:lower())
                            end
                        end,
                    })
                end
                local SecCustom = SubSkin:AddSection("Custom") do
                    SecCustom:Textbox({
                        Title       = "Mesh ID",
                        Placeholder = "rbxassetid://...",
                        Flag        = "BallSkin_Mesh",
                    })
                    SecCustom:Textbox({
                        Title       = "Texture ID",
                        Placeholder = "rbxassetid://...",
                        Flag        = "BallSkin_Texture",
                    })
                    SecCustom:Button({
                        Title    = "Apply",
                        Callback = function()
                            load_once("BallSkin")
                            task.wait(0.1)
                            local ref = get_skin_ref()
                            if not ref then return end
                            ref.MeshId       = Seraph.Flags.BallSkin_Mesh:GetValue()    or ""
                            ref.TextureID    = Seraph.Flags.BallSkin_Texture:GetValue() or ""
                            ref.Transparency = 0
                        end,
                    }):Button({
                        Title    = "Reset",
                        Callback = function()
                            if getgenv().BallSkin then
                                getgenv().BallSkin.reset()
                            end
                        end,
                    })
                end
            end

        end

        local MiscCat = BallTab:AddCategory("Account & Misc") do

            local SubAvatar = MiscCat:AddSubCategory("Avatar Stolen") do
                local Sec = SubAvatar:AddSection("Main") do
                    Sec:Textbox({
                        Title       = "Username",
                        Placeholder = "Player name",
                        Flag        = "Avatar_User",
                    })
                    Sec:Button({
                        Title    = "Steal avatar",
                        Callback = function()
                            local username = Seraph.Flags.Avatar_User:GetValue()
                            if not username or username == "" then return end
                            load_once("AvatarStolen")
                            if getgenv().AvatarStolen then
                                getgenv().AvatarStolen.steal(username)
                            end
                        end,
                    }):Button({
                        Title    = "Reset avatar",
                        Callback = function()
                            if getgenv().AvatarStolen then
                                getgenv().AvatarStolen.destroy()
                            end
                            task.spawn(function()
                                local char = lp.Character
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if not hum then return end
                                local ok, desc = pcall(function()
                                    local uid = plrs:GetUserIdFromNameAsync(lp.Name)
                                    return plrs:GetHumanoidDescriptionFromUserId(uid)
                                end)
                                if ok and desc then
                                    hum:ApplyDescriptionClientServer(desc)
                                end
                            end)
                        end,
                    })
                end
            end

        end

    end

    local ConfigTab = Window:AddTab({"rbxassetid://10734941499"}) do
        local Saves = ConfigTab:AddCategory("Saves") do
            local Config = Saves:AddSubCategory("Config") do
                local Main = Config:AddSection("Main") do
                    Main:Textbox({Title = "Config Name", Placeholder = "meuconfig", Flag = "Config_TextBox"})
                    Main:Button({Title = "Save Config", Callback = function()
                        local name = Seraph.Flags.Config_TextBox:GetValue()
                        if not name or name == "" then return end
                        local out = {}
                        for flag, comp in Seraph.Flags do
                            if flag:find("Config_") or flag:find("Theme_") then continue end
                            local v = comp:GetValue()
                            if typeof(v) == "EnumItem" then v = v.Name end
                            if typeof(v) == "Color3"   then v = `{v.R},{v.G},{v.B}` end
                            out[flag] = v
                        end
                        writefile(`remaph/{name}.json`, hs:JSONEncode(out))
                    end})
                    Main:Dropdown({Title = "Configs", Options = {}, Flag = "Config_ConfigList"})
                    Main:Button({Title = "Load Config", Callback = function()
                        local name = Seraph.Flags.Config_ConfigList:GetValue()
                        if not name then return end
                        local function GetEnum(n)
                            for _, v in Enum.KeyCode:GetEnumItems()       do if v.Name == n then return v end end
                            for _, v in Enum.UserInputType:GetEnumItems() do if v.Name == n then return v end end
                        end
                        for flag, value in hs:JSONDecode(readfile(`remaph/{name}.json`)) do
                            if typeof(value) == "string" then
                                if GetEnum(value) then
                                    value = GetEnum(value)
                                elseif #value:split(",") == 3 then
                                    value = Color3.new(unpack(value:split(",")))
                                end
                            end
                            if Seraph.Flags[flag] then Seraph.Flags[flag]:SetValue(value) end
                        end
                    end})
                    Main:Button({Title = "Refresh Configs", Callback = function()
                        local list = {}
                        for _, f in listfiles("remaph/") do
                            list[#list+1] = f:gsub("remaph/", ""):gsub(".json", "")
                        end
                        Seraph.Flags.Config_ConfigList:SetOptions(list)
                    end})
                end
            end
            local Interface = Saves:AddSubCategory("Interface") do
                local Win = Interface:AddSection("Window") do
                    Win:Label({Title = "Interface Toggle"}):Bind({
                        Default  = Seraph.WindowKeybind,
                        Flag     = "WindowBind",
                        Callback = function(bind) Seraph:SetWindowKeybind(bind) end,
                    })
                end
                local Colors = Interface:AddSection("Colors") do
                    for i, v in Seraph:GetTheme() do
                        Colors:Label({Title = i}):Colorpicker({Default = v, Flag = `Theme_{i}`, Callback = function(c)
                            local t = Seraph:GetTheme(); t[i] = c; Seraph:SetTheme(t)
                        end})
                    end
                    Colors:Dropdown({Title = "Themes", Options = ThemeNames, Default = "Default", Callback = function(opt)
                        for prop, val in ThemeList[opt] do
                            if Seraph.Flags[`Theme_{prop}`] then Seraph.Flags[`Theme_{prop}`]:SetValue(val) end
                        end
                        Seraph:SetTheme(ThemeList[opt])
                    end})
                    Colors:Slider({Title = "Animation Speed", ZeroValue = 1, Default = 1, Min = 0.25, Max = 2, Decimal = 2, Callback = function(v)
                        Seraph:SetAnimationSpeed(v)
                    end})
                end
            end
        end
    end

end
