-- Bone Grove: visual-only overrides layered after Omarchy defaults.
local active_border_color = { colors = { "rgba(789775ee)", "rgba(b4bcaecc)" }, angle = 35 }
local inactive_border_color = "rgba(65706055)"

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    rounding = 16,
    rounding_power = 3,
    shadow = {
      enabled = true,
      range = 28,
      render_power = 3,
      color = "rgba(00000077)",
      color_inactive = "rgba(00000044)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      vibrancy = 0.10,
      vibrancy_darkness = 0.16,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },
})

-- Blur only Omarchy's translucent UI layers.
hl.layer_rule({
  name = "boneGrove-minimal-glass",
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel|omarchy-notifications|omarchy-osd|omarchy-polkit|omarchy-reminders)$" },
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.10,
})

-- Grove motion: quick feedback, soft arrival, shorter departure.
local marker = io.open(os.getenv("HOME") .. "/.local/state/omarchy/bone-grove/reduced-motion", "r")
local reduce = marker ~= nil
if marker then marker:close() end
hl.config({ animations = { enabled = not reduce } })
hl.curve("groveArrive", { type = "bezier", points = { { 0.16, 1.00 }, { 0.30, 1.00 } } })
hl.curve("groveTravel", { type = "bezier", points = { { 0.22, 0.75 }, { 0.20, 1.00 } } })
hl.curve("groveLeave", { type = "bezier", points = { { 0.40, 0.00 }, { 0.80, 0.45 } } })
local function motion(leaf, speed, curve, style)
  local rule = { leaf = leaf, enabled = not reduce, speed = speed, bezier = curve }
  if style then rule.style = style end
  hl.animation(rule)
end
motion("global", 3.2, "groveArrive")
motion("windows", 3.0, "groveArrive")
motion("windowsIn", 3.0, "groveArrive", "popin 97%")
motion("windowsOut", 2.0, "groveLeave", "popin 98%")
motion("windowsMove", 3.2, "groveTravel")
motion("layers", 3.0, "groveArrive", "fade")
motion("layersIn", 2.4, "groveArrive", "fade")
motion("layersOut", 1.8, "groveLeave", "fade")
motion("fade", 2.2, "groveArrive")
motion("fadeIn", 2.4, "groveArrive")
motion("fadeOut", 1.6, "groveLeave")
motion("fadeSwitch", 2.0, "groveTravel")
motion("fadeShadow", 2.6, "groveTravel")
motion("fadeDim", 2.0, "groveTravel")
motion("fadeLayers", 2.4, "groveArrive")
motion("fadeLayersIn", 2.4, "groveArrive")
motion("fadeLayersOut", 1.6, "groveLeave")
motion("fadePopups", 2.2, "groveArrive")
motion("fadePopupsIn", 2.2, "groveArrive")
motion("fadePopupsOut", 1.5, "groveLeave")
motion("border", 3.2, "groveTravel")
motion("workspaces", 3.4, "groveTravel", "slidefade 7%")
motion("workspacesIn", 3.4, "groveTravel", "slidefade 7%")
motion("workspacesOut", 3.0, "groveTravel", "slidefade 7%")
motion("specialWorkspace", 3.4, "groveArrive", "slidefadevert 8%")
motion("specialWorkspaceIn", 3.4, "groveArrive", "slidefadevert 8%")
motion("specialWorkspaceOut", 2.2, "groveLeave", "slidefadevert 8%")
