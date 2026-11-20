--[[
  KIYOMILAB — UI library ringan buatan sendiri
]]

local Kiyomilab = {}
getgenv().Kiyomilab = Kiyomilab

local UIS = game:GetService("UserInputService")

local THEME = {
    bg = Color3.fromRGB(17, 17, 21),
    panel = Color3.fromRGB(28, 28, 34),
    panel2 = Color3.fromRGB(36, 36, 44),
    accent = Color3.fromRGB(130, 100, 255),
    text = Color3.fromRGB(238, 238, 244),
    sub = Color3.fromRGB(150, 150, 165),
    line = Color3.fromRGB(55, 55, 68),
}

local function guiParent()
    -- Taruh di PlayerGui supaya urutannya bisa diatur relatif terhadap
    -- cursor game (CursorGui DisplayOrder = 9999).
    local ok, p = pcall(function()
        return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end)
    if ok and p then return p end
    return game:GetService("CoreGui")
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    if parent then o.Parent = parent end
    return o
end

local function corner(parent, radius)
    new("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, parent)
end

function Kiyomilab:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.name or "Kiyomilab"
    local subtitle = cfg.subtitle or ""

    local screen = new("ScreenGui", {
        Name = title,
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        DisplayOrder = cfg.displayOrder or 5000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, guiParent())

    local main = new("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 620, 0, 430),
        Position = UDim2.new(0.5, -310, 0.5, -215),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
    }, screen)
    corner(main, 10)

    -- Title bar (drag handle)
    local bar = new("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
    }, main)
    corner(bar, 10)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
    }, bar)

    new("TextLabel", {
        Size = UDim2.new(1, -100, 0, 26),
        Position = UDim2.new(0, 18, 0, 9),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = THEME.text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, bar)
    new("TextLabel", {
        Size = UDim2.new(1, -100, 0, 18),
        Position = UDim2.new(0, 19, 0, 34),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = THEME.sub,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, bar)

    local hideBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -42, 0, 15),
        BackgroundColor3 = THEME.panel2,
        Text = "-",
        TextColor3 = THEME.text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
    }, bar)
    corner(hideBtn, 6)
    local closeBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -76, 0, 15),
        BackgroundColor3 = THEME.panel2,
        Text = "x",
        TextColor3 = THEME.text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
    }, bar)
    corner(closeBtn, 6)

    -- Sidebar
    local side = new("Frame", {
        Size = UDim2.new(0, 158, 1, -58),
        Position = UDim2.new(0, 0, 0, 58),
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
    }, main)
    local sideList = new("UIListLayout", {
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, side)
    new("UIPadding", { PaddingTop = UDim.new(0, 12) }, side)

    -- Content
    local content = new("ScrollingFrame", {
        Size = UDim2.new(1, -158, 1, -58),
        Position = UDim2.new(0, 158, 0, 58),
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, main)
    -- TIDAK pakai UIListLayout di content: semua halaman ditaruh di (0,0)
    -- dan cuma satu yang Visible. Ini mencegah ScrollingFrame salah menghitung
    -- canvas saat halaman lain disembunyikan.
    new("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, content)

    local window = {
        Gui = screen,
        Main = main,
        Flags = {},
        Tabs = {},
        _conns = {},
        _hidden = false,
    }

    function window:CreateTab(opts)
        opts = opts or {}
        local tabName = opts.name or "Tab"
        local btn = new("TextButton", {
            Size = UDim2.new(1, -16, 0, 36),
            BackgroundColor3 = THEME.panel2,
            Text = tabName,
            TextColor3 = THEME.text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
        }, side)
        corner(btn, 6)

        local page = new("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, -- ikut tinggi isi, jangan collapse
            BackgroundTransparency = 1,
            Visible = false,
        }, content)
        local pageList = new("UIListLayout", {
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }, page)
        new("UIPadding", { PaddingBottom = UDim.new(0, 4) }, page)

        local tab = { Name = tabName, Button = btn, Page = page }

        function tab:CreateText(o)
            o = o or {}
            local frame = new("Frame", {
                Size = UDim2.new(1, 0, 0, o.text and 66 or 40),
                BackgroundColor3 = THEME.panel,
                BorderSizePixel = 0,
            }, page)
            corner(frame, 6)
            local title = new("TextLabel", {
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 7),
                BackgroundTransparency = 1,
                Text = o.name or "",
                TextColor3 = THEME.text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, frame)
            local body = new("TextLabel", {
                Size = UDim2.new(1, -20, 1, -28),
                Position = UDim2.new(0, 10, 0, 28),
                BackgroundTransparency = 1,
                Text = o.text or "",
                TextColor3 = THEME.sub,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
            }, frame)
            return {
                Frame = frame,
                Set = function(_, t) body.Text = tostring(t) end,
                SetTitle = function(_, t) title.Text = tostring(t) end,
                Get = function() return body.Text end,
            }
        end

        function tab:CreateToggle(o)
            o = o or {}
            local value = o.value == true
            local flag = o.flag
            if flag and window.Flags[flag] ~= nil then value = window.Flags[flag] end
            local frame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = THEME.panel,
                BorderSizePixel = 0,
            }, page)
            corner(frame, 6)
            new("TextLabel", {
                Size = UDim2.new(1, -76, 0, 20),
                Position = UDim2.new(0, 10, 0, 7),
                BackgroundTransparency = 1,
                Text = o.name or "Toggle",
                TextColor3 = THEME.text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, frame)
            if o.description then
                new("TextLabel", {
                    Size = UDim2.new(1, -76, 0, 16),
                    Position = UDim2.new(0, 10, 0, 28),
                    BackgroundTransparency = 1,
                    Text = o.description,
                    TextColor3 = THEME.sub,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }, frame)
            end
            local dot = new("Frame", {
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = value and THEME.accent or THEME.line,
                BorderSizePixel = 0,
            }, frame)
            corner(dot, 11)
            local knob = new("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = value and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
            }, dot)
            corner(knob, 8)

            local handle = { value = value, Frame = frame }
            function handle:Set(v, skip)
                v = v == true
                self.value = v
                dot.BackgroundColor3 = v and THEME.accent or THEME.line
                knob.Position = v and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                if flag then window.Flags[flag] = v end
                if not skip and o.callback then pcall(o.callback, v) end
            end
            local hit = new("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
            }, frame)
            hit.MouseButton1Click:Connect(function() handle:Set(not handle.value) end)
            handle:Set(value, true)
            if flag then window.Flags[flag] = value end
            return handle
        end

        function tab:CreateButton(o)
            o = o or {}
            local btn = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = THEME.panel2,
                Text = o.name or "Button",
                TextColor3 = THEME.text,
                TextSize = 13,
                Font = Enum.Font.GothamMedium,
            }, page)
            corner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                if o.callback then pcall(o.callback) end
            end)
            return btn
        end

        function tab:CreateKeybind(o)
            o = o or {}
            local key = o.value or Enum.KeyCode.K
            local frame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = THEME.panel,
                BorderSizePixel = 0,
            }, page)
            corner(frame, 6)
            new("TextLabel", {
                Size = UDim2.new(1, -104, 0, 20),
                Position = UDim2.new(0, 10, 0, 7),
                BackgroundTransparency = 1,
                Text = o.name or "Keybind",
                TextColor3 = THEME.text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, frame)
            if o.description then
                new("TextLabel", {
                    Size = UDim2.new(1, -104, 0, 16),
                    Position = UDim2.new(0, 10, 0, 28),
                    BackgroundTransparency = 1,
                    Text = o.description,
                    TextColor3 = THEME.sub,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }, frame)
            end
            local keyBtn = new("TextButton", {
                Size = UDim2.new(0, 82, 0, 28),
                Position = UDim2.new(1, -92, 0.5, -14),
                BackgroundColor3 = THEME.panel2,
                Text = tostring(key.Name),
                TextColor3 = THEME.text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
            }, frame)
            corner(keyBtn, 6)
            local handle = { key = key, Frame = frame }
            local conn = UIS.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.UserInputType == Enum.UserInputType.Keyboard
                    and input.KeyCode == handle.key then
                    if o.callback then pcall(o.callback, handle.key) end
                end
            end)
            window._conns[#window._conns + 1] = conn
            return handle
        end

        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window.Tabs) do
                t.Page.Visible = (t == tab)
                t.Button.BackgroundColor3 = (t == tab) and THEME.accent or THEME.panel2
            end
            -- Paksa hitung ulang tinggi halaman & canvas setelah ganti tab,
            -- supaya halaman yang baru dibuka tidak langsung mengecil.
            task.defer(function()
                pcall(function()
                    tab.Page.Size = UDim2.new(1, 0, 0, 0)
                    content.AutomaticCanvasSize = Enum.AutomaticSize.None
                    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
                end)
            end)
        end)
        window.Tabs[#window.Tabs + 1] = tab
        if #window.Tabs == 1 then
            page.Visible = true
            btn.BackgroundColor3 = THEME.accent
        end
        return tab
    end

    function window:Show()
        window._hidden = false
        main.Visible = true
    end
    function window:Hide()
        window._hidden = true
        main.Visible = false
    end
    function window:Toggle()
        if window._hidden then self:Show() else self:Hide() end
    end
    function window:Unload()
        for _, c in ipairs(window._conns) do
            pcall(function() c:Disconnect() end)
        end
        window._conns = {}
        screen:Destroy()
    end

    hideBtn.MouseButton1Click:Connect(function() window:Hide() end)
    closeBtn.MouseButton1Click:Connect(function() window:Unload() end)

    -- Drag window
    local dragging, dragStart, startPos = false, nil, nil
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return window
end

return Kiyomilab
