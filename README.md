# My MPV Scripts

just some scripts I made for my mpv config 

mostly only made these so theyre cross compatible with windows and linux

---

## Installation

### Step 1: Locate Your MPV Scripts Folder

- **Linux/Mac**:  
  `~/.config/mpv/scripts/`
- **Windows**:  
  `%APPDATA%\mpv\scripts\`

### Step 2: Add the Scripts

1. Copy the desired script(s) into the `scripts` folder.
2. Restart MPV, and the script(s) will load automatically.

---

## Scripts

### 1. **`titles.lua`** - Custom Window Titles

- **Description**:  
  This script customizes the MPV window title based on the type of media being played (audio or video). The title dynamically updates to display metadata, including:
  - **Audio Files**: Artist, Album, Track Number, Year, Codec, Bitrate, etc.
  - **Video Files**: Filename and Chapter Title (if available).
- **Features**:  
  - Resets audio filters when playing audio files.
  - Periodic title updates every 10 seconds.
  - Metadata extraction for better organization.
- **Usage**:  
  Add the script to your `scripts` folder. The titles will update automatically when media is loaded.

---

### 2. **`sub_path.lua`** - Fixed sub-path on Linux.

- **Description**:  
  I made this to fix the sub-path not being found on Linux, I dont know if it's still an issue but I've kept this script
- **Features**:  
-  Makes a config file where you can make it search for whatever folder names in the same directory as the media for subtitles
- Automatically makes config folder

- **Usage**:  
  Go to your `script-opts` and open **sub_path_config.conf** and just put whatever folder names you want it to read, capitalization doesnt matter (Default: base_paths=Sub,Subs,Subtitles)

---

### 3. **`sub_scale.lua`** - tries different sub-scale & subtitle_position increments to fix only allowing full digits on Linux.

- **Description**:  
  I made this script because on builds of mpv on Linux it only allows to go up and down in 1.0 increments unlike in the windows build I use. so this just starts at 0.25 and then goes up to 0.5 then 1 if niether of those 2 work
- **Features**:  
- Press Alt+g to increase subtitle size and Alt+f to decrease
- Press r to lower subtitles and t to make them higher

---

## Contribution

Feel free to contribute by submitting pull requests or suggesting new features. If you encounter any issues, open a GitHub issue to report them.

---

## License

This repository is licensed under the [MIT License](LICENSE). Feel free to modify and distribute these scripts.
