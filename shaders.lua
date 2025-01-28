-- mpv-lua-script.lua

local mp = require 'mp'

-- Detect OS type
local is_windows = package.config:sub(1,1) == '\\'
local separator = is_windows and ";" or ":"

-- Define shaders and messages
local shaders = {
    ["CTRL+1"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode A (HQ)"},
    ["CTRL+2"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode B (HQ)"},
    ["CTRL+3"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode C (HQ)"},
    ["CTRL+4"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_M.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode A+A (HQ)"},
    ["CTRL+5"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_Soft_M.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode B+B (HQ)"},
    ["CTRL+6"] = {paths = {
        "~~/shaders/Anime4K/Anime4K_Clamp_Highlights.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x2.glsl",
        "~~/shaders/Anime4K/Anime4K_AutoDownscalePre_x4.glsl",
        "~~/shaders/Anime4K/Anime4K_Restore_CNN_M.glsl",
        "~~/shaders/Anime4K/Anime4K_Upscale_CNN_x2_M.glsl"
    }, message = "Anime4K: Mode C+A (HQ)"},
    ["CTRL+7"] = {paths = {
        "~~/shaders/FSRCNNX/FSRCNNX_x2_8-0-4-1.glsl"
    }, message = "FSRCNNX x2 8-0-4-1"},
    ["CTRL+8"] = {paths = {
        "~~/shaders/FSRCNNX/FSRCNNX_x2_16-0-4-1.glsl"
    }, message = "FSRCNNX x2 16-0-4-1"},
}

-- Bind keys to apply shaders and show messages
for key, shader in pairs(shaders) do
    mp.add_key_binding(key, "apply_shader_"..key, function()
        local shader_path = table.concat(shader.paths, separator)
        mp.commandv("change-list", "glsl-shaders", "set", shader_path)
        mp.osd_message(shader.message)
    end)
end

