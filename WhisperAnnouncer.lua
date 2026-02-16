local _, addon = ...
addon = addon or {}
local L = addon.L or { WHISPER_FROM = "Whisper from: %s" }

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("CHAT_MSG_BN_WHISPER")

local display = CreateFrame("Frame", "WhisperAnnouncerDisplay", UIParent)
display:SetSize(900, 80)
display:SetPoint("TOP", UIParent, "TOP", 0, -220)
display:Hide()

display.text = display:CreateFontString(nil, "OVERLAY", "ZoneTextFont")
display.text:SetPoint("CENTER")
display.text:SetTextColor(1, 0.82, 0)
display.text:SetShadowOffset(2, -2)
display.text:SetShadowColor(0, 0, 0, 1)
display.text:SetText("")

local showing = false
local timer = 0
local DURATION = 3.0
local FADE = 0.8
local soundPlayed = false

local function ShowWhisperAlert(from)
    display.text:SetText(string.format(L.WHISPER_FROM, from))
    display:SetAlpha(1)
    display:Show()
    showing = true
    timer = 0
    if not soundPlayed then
        PlaySound(SOUNDKIT.TELL_MESSAGE, "Master")
        soundPlayed = true
    end
end

display:SetScript("OnUpdate", function(self, elapsed)
    if not showing then return end
    timer = timer + elapsed

    if timer > DURATION then
        local fadeT = timer - DURATION
        local a = 1 - (fadeT / FADE)
        if a <= 0 then
            self:Hide()
            showing = false
            soundPlayed = false
        else
            self:SetAlpha(a)
        end
    end
end)

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "CHAT_MSG_WHISPER" then
        local author = select(2, ...)
        if author then
            local name = author:match("^[^-]+") or author
            ShowWhisperAlert(name)
        end
    elseif event == "CHAT_MSG_BN_WHISPER" then
        local author = select(2, ...)
        if type(author) == "string" and author ~= "" then
            ShowWhisperAlert(author)
        else
            local bnetIDAccount = select(13, ...)
            if type(bnetIDAccount) == "number" and BNGetFriendInfoByID then
                local accountName, _, battleTag = BNGetFriendInfoByID(bnetIDAccount)
                local from = accountName or battleTag
                if from and from ~= "" then
                    ShowWhisperAlert(from)
                end
            end
        end
    end
end)
