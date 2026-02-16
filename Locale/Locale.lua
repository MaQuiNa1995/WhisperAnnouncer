local _, addon = ...
addon.L = addon.L or {}
local L = addon.L

if GetLocale() == "esES" or GetLocale() == "esMX" then
    L.WHISPER_FROM = "Susurro de: %s"
else
    L.WHISPER_FROM = "Whisper from: %s"
end
