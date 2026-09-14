-- Prefer user commands when Hyprland launches the native Omarchy screensaver.
-- Preserve every other PATH entry and avoid duplication on reload.
local user_bin = os.getenv("HOME") .. "/.local/bin"
local entries = { user_bin }
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= user_bin then table.insert(entries, entry) end
end
hl.env("PATH", table.concat(entries, ":"))
