local key_bindings = {}
local file_to_delete = nil
local confirm_timeout = nil
local confirm_key = nil

-- Check if a file exists
function file_exists(name)
    if not name or name == '' then return false end
    local f = io.open(name, "r")
    if f then io.close(f); return true else return false end
end

-- Check if the path is a protocol (e.g., http:// or file://)
function is_protocol(path)
    return type(path) == 'string' and (path:match('^%a[%a%d_-]+://'))
end

-- Delete file based on operating system
function delete_file(path, permanent)
    local is_windows = package.config:sub(1, 1) == "\\"

    if is_protocol(path) or not file_exists(path) then return end

    if is_windows then
        if permanent then
            local ps_code = string.format([[
                Remove-Item -Path '%s' -Force
            ]], path)
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command', ps_code },
            })
        else
            local ps_code = string.format([[
                Add-Type -AssemblyName Microsoft.VisualBasic
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('%s', 'OnlyErrorDialogs', 'SendToRecycleBin')
            ]], path)
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                detach = true,
                args = { 'powershell', '-NoProfile', '-Command', ps_code },
            })
        end
    else
        if permanent then
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                args = { 'rm', '-f', path },
            })
        else
            mp.command_native({
                name = "subprocess",
                playback_only = false,
                args = { 'trash', path },
            })
        end
    end
end

-- Remove the current file from the playlist
function remove_current_file()
    local pos = mp.get_property_number("playlist-pos", -1)
    if pos > -1 then
        mp.command("playlist-remove " .. pos)
    end
end

-- Show a styled OSD message
function show_colored_message(message, color)
    local ass_message = string.format("{\\1c&H%s&}%s", color, message)
    mp.set_osd_ass(0, 0, ass_message)
end

-- Show notification for file deletion
function notify_deletion(path)
    if path and not file_exists(path) then
        show_colored_message("File successfully deleted.", "341fba") -- Red
    else
        show_colored_message("Failed to delete file: " .. path, "341fba") -- Red
    end
end

-- Handle confirmation key press
function handle_confirm_key(permanent)
    local path = mp.get_property("path")
    if file_to_delete == path then
        delete_file(path, permanent)
        remove_current_file()
        notify_deletion(path)
        cleanup()
    end
end

-- Cleanup and remove bindings after timeout
function cleanup()
    if confirm_timeout then
        confirm_timeout:kill()
        confirm_timeout = nil
    end

    for _, name in ipairs(key_bindings) do
        mp.remove_key_binding(name)
    end
    mp.remove_key_binding("cancel_delete")
    key_bindings = {}
    file_to_delete = nil
    mp.set_osd_ass(0, 0, "") -- Clear OSD
end

-- Show countdown timer with ASS styling
function show_countdown_timer(duration, interval, permanent)
    local time_left = duration
    local delete_type = permanent and "Permanently" or "To Trash"
    local color = permanent and "341fba" or "41b541" -- Red for permanent, green otherwise

    confirm_timeout = mp.add_periodic_timer(interval, function()
        time_left = time_left - interval
        if time_left <= 0 then
            show_colored_message("File deletion cancelled (timeout).", "341fba") -- Red
            cleanup()
        else
            local message = string.format(
                "Press [%s] to delete file %s.\nTime left: %ds",
                confirm_key or "Alt+d",
                delete_type,
                math.ceil(time_left)
            )
            show_colored_message(message, color)
        end
    end)
end

-- Bind keys for confirmation
function add_bindings(permanent)
    if #key_bindings > 0 then return end -- Prevent rebinding

    confirm_key = confirm_key or "Alt+d"
    local confirm_binding_name = mp.get_script_name() .. "_confirm"
    key_bindings = { confirm_binding_name }

    mp.add_forced_key_binding(confirm_key, confirm_binding_name, function()
        handle_confirm_key(permanent)
    end)

    mp.add_forced_key_binding("Esc", "cancel_delete", function()
        show_colored_message("File deletion cancelled.", "341fba") -- Red
        cleanup()
    end)

    show_countdown_timer(10, 1, permanent)
end

-- Client message handler
function client_message(event)
    local path = mp.get_property("path")
    if not path then return end

    local permanent = false

    for _, arg in ipairs(event.args) do
        if arg == "permanent" then
            permanent = true
        end
    end

    if event.args[1] == "delete-file" and #event.args >= 3 and #key_bindings == 0 then
        file_to_delete = path
        confirm_key = event.args[2]
        show_colored_message(event.args[3], permanent and "341fba" or "41b541")
        add_bindings(permanent)
    end
end

mp.register_event("client-message", client_message)

