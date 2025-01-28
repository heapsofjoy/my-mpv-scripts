-- Initial subtitle position and font scale values in floating-point (set default values)
local subtitle_position = 100
local subtitle_scale = mp.get_property_number("sub-scale", 1.0)

-- Increment steps to try: 0.025, 0.5, and 1.0
local increment_steps = {0.025, 0.5, 1.0}
local current_step_index = 1  -- Start with the smallest increment

-- Function to update subtitle position
local function update_subtitle_position(offset)
    -- Update the stored floating-point position
    subtitle_position = subtitle_position + offset

    -- Apply the integer part to `sub-pos`
    local integer_position = math.floor(subtitle_position + 0.5)
    mp.set_property("sub-pos", tostring(integer_position))

    -- Display the adjusted position
    mp.osd_message("Subtitle height: " .. string.format("%.2f", subtitle_position), 1)
end

-- Function to update subtitle font scale using specific increments
local function update_subtitle_scale(offset)
    local success = false

    -- Try applying each specified increment step until one is accepted by `mpv`
    for i = current_step_index, #increment_steps do
        local step = increment_steps[i]

        -- Temporarily update subtitle_scale with this step size
        local new_scale = subtitle_scale + offset * step
        mp.set_property("sub-scale", tostring(new_scale))

        -- Check if `mpv` accepted the change by comparing actual vs intended value
        local applied_scale = mp.get_property_number("sub-scale")
        
        -- If the applied scale matches the intended scale, use this step going forward
        if math.abs(applied_scale - new_scale) < 0.001 then
            subtitle_scale = new_scale
            current_step_index = i  -- Remember this working step
            success = true
            break
        end
    end

    -- Fallback: if none of the increments worked, set it to whole numbers
    if not success then
        current_step_index = #increment_steps
        subtitle_scale = math.floor(subtitle_scale + offset + 0.5)
        mp.set_property("sub-scale", tostring(subtitle_scale))
    end

    -- Display the adjusted font scale
    mp.osd_message("Subtitle scale: " .. string.format("%.3f", subtitle_scale), 1)
end

-- Key bindings for increasing and decreasing subtitle height
-- mp.add_key_binding("r", "sub-pos-decrease", function() update_subtitle_position(-1) end)
-- mp.add_key_binding("t", "sub-pos-increase", function() update_subtitle_position(1) end)

-- Key bindings for increasing and decreasing subtitle scale with specific increments
mp.add_key_binding("Alt+g", "sub-scale-increase", function() update_subtitle_scale(1) end)
mp.add_key_binding("Alt+f", "sub-scale-decrease", function() update_subtitle_scale(-1) end)
