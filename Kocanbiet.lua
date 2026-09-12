local COLOR_GREEN  = { r = 0, g = 255, b = 0, a = 255 }
local COLOR_RED    = { r = 255, g = 0, b = 0, a = 255 }
local COLOR_WHITE  = { r = 255, g = 255, b = 255, a = 255 }

local Render = _G.Render or {
    DrawLine = function(x1, y1, x2, y2, color, thickness) end,
    DrawRect = function(x, y, w, h, color, thickness) end,
    DrawText = function(text, x, y, size, color) end,
    GetScreenSize = function() return 1920, 1080 end,
    WorldToScreen = function(world_pos) return { x = 0, y = 0, z = 0 } end
}

local function CalculateDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    local dz = pos1.z - pos2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function OnRenderTick(LocalPlayer, EntityList)
    if not LocalPlayer or not EntityList then return end

    local screenWidth, screenHeight = Render.GetScreenSize()
    
    local TotalPlayers = 0
    local TotalAlive = 0
    local TotalDead = 0

    for _, Player in pairs(EntityList) do
        if Player ~= LocalPlayer then
            TotalPlayers = TotalPlayers + 1
            
            if Player.IsAlive then
                TotalAlive = TotalAlive + 1

                local headWorldPos = { x = Player.Position.x, y = Player.Position.y, z = Player.Position.z + 1.8 }
                local footWorldPos = Player.Position

                local headScreenPos = Render.WorldToScreen(headWorldPos)
                local footScreenPos = Render.WorldToScreen(footWorldPos)

                if headScreenPos and footScreenPos and headScreenPos.z > 0 and footScreenPos.z > 0 then
                    
                    local boxHeight = math.abs(footScreenPos.y - headScreenPos.y)
                    local boxWidth = boxHeight / 2
                    local boxX = footScreenPos.x - (boxWidth / 2)
                    local boxY = headScreenPos.y

                    Render.DrawRect(boxX, boxY, boxWidth, boxHeight, COLOR_GREEN, 1.5)

                    local distance = CalculateDistance(LocalPlayer.Position, Player.Position)

                    local distanceText = string.format("[ %.1fm ]", distance)
                    Render.DrawText(distanceText, footScreenPos.x, footScreenPos.y + 5, 14, COLOR_WHITE)

                    local usernameText = string.format("@%s", Player.Username or "unknown")
                    Render.DrawText(usernameText, footScreenPos.x, boxY - 15, 14, COLOR_WHITE)

                    local screenBottomX = screenWidth / 2
                    local screenBottomY = screenHeight
                    Render.DrawLine(screenBottomX, screenBottomY, footScreenPos.x, footScreenPos.y, COLOR_RED, 1.0)
                end
            else
                TotalDead = TotalDead + 1
            end
        end
    end

    local statsX = 20
    local statsY = 20
    Render.DrawText("=== THỐNG KÊ NGƯỜI CHƠI ===", statsX, statsY, 16, COLOR_GREEN)
    Render.DrawText(string.format("Tổng số mục tiêu: %d", TotalPlayers), statsX, statsY + 20, 14, COLOR_WHITE)
    Render.DrawText(string.format("Số lượng còn sống: %d", TotalAlive), statsX, statsY + 40, 14, COLOR_GREEN)
    Render.DrawText(string.format("Số lượng đã gục: %d", TotalDead), statsX, statsY + 60, 14, COLOR_RED)
end

return OnRenderTick
