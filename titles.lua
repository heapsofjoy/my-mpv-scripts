-- titles.lua
-- Custom window title for audio and video files with track-list parsing and periodic updates.

mp = require 'mp'

-- Toggle for showing warnings about unknown file extensions
local show_unknown_extension_warnings = false

-- Define file extensions for audio and video
local media_exts = {
    video = { mp4 = true, mkv = true, avi = true, flv = true, mov = true },
    audio = { mp3 = true, m4a = true, flac = true, wav = true, wma = true, aac = true, dsd = true, dsf = true, mqa = true }
}
local reset_audio_filters = true -- Reset audio filters for audio files.
local is_initial_load = true -- Used to minimize debug logging

-- Get playlist position and count
local function get_playlist_info()
    return tonumber(mp.get_property("playlist-pos-1") or "1"),
           tonumber(mp.get_property("playlist-count") or "1")
end

-- Format playlist position
local function format_playlist_position(pos, count)
    return string.format("(%02d/%02d)", pos, count)
end

-- Format optional metadata (e.g., album, year, bitrate)
local function format_optional_parts(...)
    local parts = {}
    for _, part in ipairs({...}) do
        if part and part ~= "" then table.insert(parts, part) end
    end
    return table.concat(parts, ", ")
end

-- Extract file extension
local function get_file_extension(path)
    local ext = string.match(path, "%.([^.]+)$")
    return ext and string.lower(ext) or ""
end

-- Fetch audio details from track-list
local function get_audio_track_details()
    local codec_map = {
        -- Lossy Formats
        mp3 = "MPEG", aac = "AAC", vorbis = "Vorbis", opus = "Opus",
        wma = "WMA", ac3 = "AC-3", eac3 = "E-AC-3", dts = "DTS",
        atrac = "ATRAC", mp2 = "MPEG Layer II",

        -- Lossless Formats
        flac = "FLAC", alac = "ALAC", wav = "WAV", ape = "Monkey's Audio",
        tak = "TAK", tta = "TTA", dsd = "DSD", mlp = "MLP",
        truehd = "Dolby TrueHD",

        -- Other Formats
        atrac3 = "ATRAC3", atrac9 = "ATRAC9", wv = "WavPack", shn = "Shorten",
        caf = "CAF", amr_nb = "AMR (Narrowband)", amr_wb = "AMR (Wideband)",

        -- Fallback
        unknown = "Unknown Format"
    }

    local track_list = mp.get_property_native("track-list") or {}
    for _, track in ipairs(track_list) do
        if track.type == "audio" and track.selected then
            local codec = track.codec or "unknown"

            -- Handle PCM variants
            if codec:match("^pcm_") then
                codec = codec:gsub("pcm_", "PCM ("):gsub("_", " "):gsub("le$", "LE)"):gsub("be$", "BE)")
            elseif codec:match("^dsd_") then
                codec = "DSD"
            else
                codec = codec_map[codec] or codec
            end

            local formatted_bitrate
            if codec == "FLAC" then
                local samplerate = mp.get_property_number("audio-params/samplerate")
                local bits_per_sample = tonumber(string.match(mp.get_property("audio-params/format") or "", "%d+"))
                local channel_count = mp.get_property_number("audio-params/channel-count")
                if samplerate and bits_per_sample and channel_count then
                    local bitrate = samplerate * bits_per_sample * channel_count
                    formatted_bitrate = string.format("%.0f kbps", bitrate / 1000)
                else
                    formatted_bitrate = "unknown bitrate (FLAC)"
                end
            else
                local bitrate = track["demux-bitrate"] or track["audio-bitrate"]
                if bitrate then
                    formatted_bitrate = bitrate > 1000000 and
                        string.format("%.3f Mbps", bitrate / 1000000):gsub("%.0$", "") or
                        string.format("%.0f kbps", bitrate / 1000)
                else
                    formatted_bitrate = "unknown bitrate"
                end
            end

            if is_initial_load then
                mp.msg.info(string.format("Debug: Detected Audio Details: %s", codec))
            end

            return string.format("%s, %s", codec, formatted_bitrate)
        end
    end
    return nil
end

-- Set title for audio files
local function set_audio_title(playlist_pos, playlist_count)
    local track = mp.get_property("metadata/by-key/track") or ""
    local media_title = mp.get_property("media-title") or ""
    local artist = mp.get_property("metadata/by-key/artist") or ""
    local album = mp.get_property("metadata/by-key/album") or ""
    local date = mp.get_property("metadata/by-key/date") or ""
    local path = mp.get_property("path") or ""
    local ext = get_file_extension(path)
    local audio_details = get_audio_track_details()

    local track_number = tonumber(track) and string.format("%02d", tonumber(track)) or track
    local optional_info = format_optional_parts(album, date, audio_details, ext)

    local title = string.format("%s %s - %s [%s] - mpv",
        format_playlist_position(playlist_pos, playlist_count),
        artist ~= "" and artist or "",
        media_title,
        optional_info)

    mp.set_property("title", title)

    if reset_audio_filters then
        mp.set_property("af", "")
    end
end

-- Set title for video files
local function set_video_title(playlist_pos, playlist_count)
    local media_title = mp.get_property("media-title") or "" -- Retrieve metadata title
    local filename_no_ext = mp.get_property("filename/no-ext") or ""
    local ext = get_file_extension(mp.get_property("path") or "")
    local chapter_title = mp.get_property("chapter-metadata/by-key/title") or ""

    -- Use metadata title if available; fallback to filename with extension
    local base_title = media_title ~= "" and media_title or filename_no_ext .. (ext ~= "" and "." .. ext or "")

    -- Include chapter title if present
    local title = string.format("%s %s %s - mpv",
        format_playlist_position(playlist_pos, playlist_count),
        base_title,
        chapter_title ~= "" and "[" .. chapter_title .. "]" or "")

    mp.set_property("title", title)
end

-- Determine media type and set appropriate title
local function set_title()
    local path = mp.get_property("path", "")
    local ext = get_file_extension(path)

    if not ext then
        if show_unknown_extension_warnings then
            mp.msg.warn("Unable to determine file extension for path: " .. path)
        end
        return
    end

    local playlist_pos, playlist_count = get_playlist_info()

    if media_exts.video[ext] then
        set_video_title(playlist_pos, playlist_count)
    elseif media_exts.audio[ext] then
        set_audio_title(playlist_pos, playlist_count)
    else
        if show_unknown_extension_warnings then
            mp.msg.warn("Unknown file extension: " .. ext)
        end
    end
end


-- Periodic title updates every 10 seconds
local function periodic_update()
    set_title()
    is_initial_load = false -- Disable initial-load specific actions
    mp.add_timeout(10, periodic_update)
end

-- Register events
mp.register_event("file-loaded", function()
    set_title()
    periodic_update()
end)

