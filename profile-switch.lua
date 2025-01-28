local current_profile = "main"  -- Initial profile

-- Function to switch between "main" and "light" profiles
function toggle_profile()
    if current_profile == "main" then
        mp.commandv("set", "profile", "light")
        mp.osd_message("Switched to 'light' profile")
        current_profile = "light"
    else
        mp.commandv("set", "profile", "main")
        mp.osd_message("Switched to 'main' profile")
        current_profile = "main"
    end
end

-- Function to display the current profile and active hwdec setting for 2.5 seconds
function show_current_profile()
    local hwdec = mp.get_property("hwdec-current") or "Software decoding"
    mp.osd_message("Current profile: " .. current_profile .. "\nHWDec in use: " .. hwdec, 2.5)
end

-- Bind the toggle function to Ctrl+Shift+p
mp.add_key_binding("Ctrl+Shift+p", "toggle-profile", toggle_profile)

-- Bind the display profile function to Ctrl+p
mp.add_key_binding("Ctrl+p", "show-current-profile", show_current_profile)
