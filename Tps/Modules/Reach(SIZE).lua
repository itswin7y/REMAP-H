local plrs = cloneref(game:GetService("Players"))
local lp   = plrs.LocalPlayer

getgenv().reach_size = getgenv().reach_size or Vector3.new(25, 2, 25)

local function apply(char)
    local lighting = cloneref(game:GetService("Lighting"))
    local foot     = lighting[lp.Name].PreferredFoot

    local is_r15   = char:FindFirstChild("RightLowerLeg") ~= nil
    local leg_name

    if is_r15 then
        leg_name = foot == 2 and "LeftLowerLeg" or "RightLowerLeg"
    else
        leg_name = foot == 2 and "Left Leg" or "Right Leg"
    end

    local original = char:WaitForChild(leg_name, 5)
    if not original then return end

    task.wait(0.1)

    local orig_size = original.Size

    local clone = original:Clone()
    clone.Name = leg_name
    clone.Size         = orig_size
    clone.Transparency = 0
    clone.Massless     = true
    clone.CanCollide   = false
    clone.Anchored     = false

    local weld  = Instance.new("WeldConstraint")
    weld.Part0  = original
    weld.Part1  = clone
    weld.Parent = original

    clone.Parent = char
    clone.CFrame = original.CFrame

    original.Transparency = 1
    original.Size         = getgenv().reach_size
    original.Massless     = true

    local last = getgenv().reach_size
    task.spawn(function()
        while original and original.Parent do
            local cur = getgenv().reach_size
            if cur ~= last then
                original.Size = cur
                last = cur
            end
            task.wait(0.1)
        end
    end)
end

local char = lp.Character
if char then apply(char) end

lp.CharacterAdded:Connect(apply)
