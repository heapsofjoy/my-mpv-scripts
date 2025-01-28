local options = require 'mp.options'
local utils = require 'mp.utils'

-- Default configuration
local config = {
    base_paths = "Sub,Subs,Subtitles", -- Comma-separated base paths
    use_filename = yes,              -- Whether to add filename-based paths
    debug = no                     -- Enable debug logging
}

-- Load options from script-opts
options.read_options(config, "sub_path_config")

-- Split a comma-separated string into a table
local function split_string(input, delimiter)
    local result = {}
    for str in string.gmatch(input, "([^" .. delimiter .. "]+)") do
        table.insert(result, str:match("^%s*(.-)%s*$")) -- Trim whitespace
    end
    return result
end

-- Add unique paths to the list
local function add_unique_path(path, unique_set, paths)
    local normalized = path:lower()
    if not unique_set[normalized] then
        table.insert(paths, path)
        unique_set[normalized] = true
    end
end

-- Main hook function
mp.add_hook("on_load", 10, function ()
    local base_paths = split_string(config.base_paths, ",")
    local unique_set = {}
    local sub_paths = {}

    -- Add base paths
    for _, path in ipairs(base_paths) do
        add_unique_path(path, unique_set, sub_paths)
    end

    -- Optionally add filename-based paths
    if config.use_filename then
        local filename_no_ext = mp.get_property("filename/no-ext")
        if filename_no_ext and filename_no_ext ~= "" then
            add_unique_path("Subs/" .. filename_no_ext, unique_set, sub_paths)
        else
            mp.msg.warn("Filename without extension is not available!")
        end
    end

    -- Set subtitle paths in MPV
    mp.set_property_native("sub-file-paths", sub_paths)

    -- Debugging: Log paths if debug mode is enabled
    if config.debug then
        for _, path in ipairs(sub_paths) do
            mp.msg.info("Added subtitle path: " .. path)
        end
    end
end)

-- Generate default config file if it doesn't exist
local function generate_config_file()
    local config_dir = mp.command_native({"expand-path", "~~/script-opts"})
    local config_path = utils.join_path(config_dir, "sub_path_config.conf")
    
    if not utils.file_info(config_path) then
        local file = io.open(config_path, "w")
        if file then
            file:write("# Subtitle path configuration for MPV\n")
            file:write("# Comma-separated list of base paths (e.g., Sub,Subs,Subtitles)\n")
            file:write("base_paths=" .. config.base_paths .. "\n")
            file:write("\n# Whether to add filename-based paths (true or false)\n")
            file:write("use_filename=" .. tostring(config.use_filename) .. "\n")
            file:write("\n# Enable debug logging (true or false)\n")
            file:write("debug=" .. tostring(config.debug) .. "\n")
            file:close()
            mp.msg.info("Generated default config file: " .. config_path)
        else
            mp.msg.error("Failed to create config file: " .. config_path)
        end
    end
end

-- Call the config file generator
generate_config_file()
