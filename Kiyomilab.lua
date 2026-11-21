-- KiyomilabWindUI.lua (Base UI Paten - Upload ke GitHub Kiyomilab/RobloxSC)
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WindUI
local urls = {
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
}

for _, url in ipairs(urls) do
    local okHttp, raw = pcall(function() return game:HttpGet(url) end)
    if okHttp and type(raw) == "string" and #raw > 500 then
        local fn = loadstring(raw)
        if fn then
            local okExec, lib = pcall(fn)
            if okExec and type(lib) == "table" then
                WindUI = lib
                break
            end
        end
    end
end

if not WindUI then
    warn("[Kiyomilab] Gagal memuat WindUI.")
    return nil
end

-- Tema Paten Kiyomilab Crimson
WindUI:AddTheme({
    Name = "KiyomilabCrimson",
    Accent = Color3.fromHex("#DC183A"),
    Dialog = Color3.fromHex("#0F0B13"),
    Outline = Color3.fromHex("#5F162A"),
    Text = Color3.fromHex("#F6F2F8"),
    Placeholder = Color3.fromHex("#A596AA"),
    Background = Color3.fromHex("#0A080D"),
    Button = Color3.fromHex("#16101B"),
    Icon = Color3.fromHex("#E8C37D"),
})

-- Ambil Nama Game Otomatis dari PlaceId (Anti-Error)
local GameName = "Place ID: " .. tostring(game.PlaceId)
if game.PlaceId and game.PlaceId > 0 then
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if ok and type(info) == "table" and info.Name then
        GameName = info.Name
    end
end

-- Deteksi Keanggotaan Pemain untuk Subtitle User Panel
local membershipType = "Player"
if LocalPlayer.MembershipType == Enum.MembershipType.Premium then
    membershipType = "Premium"
end

local LOGO_ID = "rbxthumb://type=Asset&id=127057318506760&w=150&h=150"

-- Konfigurasi Window Dikunci 100%
local Window = WindUI:CreateWindow({
    Title = "Kiyomilab",
    Icon = LOGO_ID,
    Author = GameName,
    Folder = "KiyomilabHub",
    Size = UDim2.fromOffset(580, 420),
    Transparent = true,
    Theme = "KiyomilabCrimson",
    SideBarWidth = 175,
    HasOutline = true,
    User = {
        Enabled = true,
        Title = LocalPlayer.DisplayName or LocalPlayer.Name,
        Subtitle = "@" .. LocalPlayer.Name .. " (" .. membershipType .. ")",
        Icon = "http://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(LocalPlayer.UserId) .. "&width=150&height=150&format=png",
    },
})

Window:EditOpenButton({
    Title = "Kiyomilab",
    Icon = LOGO_ID,
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 1.5,
    Color = ColorSequence.new(
        Color3.fromHex("DC183A"),
        Color3.fromHex("7D0E24")
    ),
    Draggable = true,
})

return {
    WindUI = WindUI,
    Window = Window,
    GameName = GameName,
}