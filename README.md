# MOZA Pit House Preset Switcher for Stream Deck

Switch MOZA Pit House presets from an Elgato Stream Deck using AutoHotkey.

This project is intended for users who want quick access to multiple MOZA wheelbase presets without manually navigating through Pit House every time.

The script automates the normal Pit House preset import workflow:

```text
Stream Deck button
→ F13/F14/F15/etc.
→ AutoHotkey
→ MOZA Pit House
→ Import Preset
→ Overwrite existing preset
→ Preset applied
→ Previous application restored
```

## Why this exists

MOZA currently does not provide a public API command for directly selecting or loading a Pit House preset.

There are projects that recreate presets by reading the preset file and applying individual FFB parameters through the MOZA SDK, but not every Pit House parameter is exposed through that SDK.

This project uses a different approach: **it makes Pit House itself import the preset.**

That means the preset is applied using MOZA's own preset handling rather than recreating only the SDK-accessible parameters.

## Important limitation

This is UI automation.

Pit House does not expose most of its interface through normal Windows UI Automation, so several steps use mouse coordinates relative to the Pit House window.

The script therefore:

- activates Pit House
- forces a known window size
- opens the Wheelbase page
- clicks the preset menu
- selects Import Preset
- enters the preset file path
- confirms Overwrite
- restores the previously active application

It is not as elegant as a native MOZA preset API would be, but it works reliably with the tested Pit House layout.

## Requirements

- Windows
- MOZA Pit House
- AutoHotkey v2
- Elgato Stream Deck
- One or more exported `.mzpreset` files

Developed using:

```text
MOZA Pit House 1.4.1.13
AutoHotkey v2
Stream Deck MK.2
GPT-6
```

Other Stream Deck models should also work as long as they can send hotkeys.

## How it works

Each preset is assigned to an extended function key (In current version of script I use hotkeys starting from F13, but you can use any key you want):

```text
F13 → RBR RSF
F14 → Assetto Corsa Rally
F15 → EA WRC
F16 → iRacing
F17 → Trucks
```

The Stream Deck sends one of those keys.

AutoHotkey detects the key and runs:

```ahk
ApplyPreset("Preset Name")
```

The script then performs the Pit House import sequence automatically.

## Installation

### 1. Install AutoHotkey v2 https://www.autohotkey.com/

Install AutoHotkey v2.

This script is written for AutoHotkey v2 and will not work correctly with AutoHotkey v1.

### 2. Export your MOZA presets

Create and configure your presets normally in MOZA Pit House.

Export each preset as a `.mzpreset` file.

It is recommended to keep all preset files in one folder, for example:

```text
C:\Users\YourName\Documents\Moza_Presets\
```

Example:

```text
RBR.mzpreset
ACR.mzpreset
EAWRC.mzpreset
iRacing.mzpreset
ETS2.mzpreset
```

In current script my paths to presets directories are used.

### 3. Configure the preset list

Edit the `Presets := Map(...)` section of the script.

Example:

```ahk
Presets := Map(
    "RBR RSF",               "C:\Users\YourName\Documents\Moza_Presets\RBR.mzpreset",
    "Assetto Corsa Rally",   "C:\Users\YourName\Documents\Moza_Presets\ACR.mzpreset",
    "EA WRC",                "C:\Users\YourName\Documents\Moza_Presets\EAWRC.mzpreset",
    "iRacing",               "C:\Users\YourName\Documents\Moza_Presets\iRacing.mzpreset",
    "Trucks",                "C:\Users\YourName\Documents\Moza_Presets\ETS2.mzpreset"
)
```

Change the paths to match your system.

## Adding a new preset

Adding a preset requires two changes.

### Step 1 — Add it to the preset map

For example:

```ahk
"BeamNG", "C:\Users\YourName\Documents\Moza_Presets\BeamNG.mzpreset"
```

Remember to add a comma after the previous last entry.

### Step 2 — Assign a hotkey

Add another hotkey:

```ahk
F18::ApplyPreset("BeamNG")
```

You can use F13 through F24. Or the other keys you wish but edit accordingly.

## Stream Deck setup

For each preset:

1. Open the Stream Deck application.
2. Add a **System → Hotkey** action.
3. Open the hotkey selector.
4. Choose one of the extended function keys, such as F13, F14, F15, etc.
5. Name the Stream Deck button after the preset.

Example:

```text
RBR RSF              → F13
Assetto Corsa Rally  → F14
EA WRC               → F15
iRacing              → F16
Trucks               → F17
```

You do not need a physical keyboard that has F13-F24 keys.

## Running the script

Launch the `.ahk` file once.

The script remains running in the background and waits for the configured hotkeys.

You should see the AutoHotkey icon in the Windows system tray.

To stop it, right-click the AutoHotkey tray icon and choose **Exit**.

After editing the script, right-click the tray icon and choose **Reload Script**, or exit and launch it again.

## Automatic startup with Windows

If you want the preset switcher to always be available, place a shortcut to the script in the Windows Startup folder.

Press `Win + R` and enter:

```text
shell:startup
```

Then place a shortcut to your `.ahk` script in that folder.

## Pit House window handling

The script uses client-relative coordinates.

The tested Pit House client size is:

```text
1440 × 990
```

Before attempting the preset switch, the script resizes Pit House to the expected size.

This is important because Pit House changes its UI layout depending on window size.

The script also intentionally clicks the Wheelbase tab before starting the import process because Pit House normally opens on the Home page, where the preset menu is not available.

Bear in mind here that if your monitor has less than 1440 height there may be a snag, so you may need to edit related script part.

## Current UI coordinates

The current tested coordinates are:

```text
Wheelbase tab:
X = 34
Y = 115

Preset menu (...):
X = 1401
Y = 23

Import Preset:
X = 1357
Y = 86

Overwrite:
X = 853
Y = 584
```

These coordinates are relative to the Pit House client area.

If a future Pit House update changes the UI layout, these values may need to be adjusted.

AutoHotkey's Window Spy can be used to find the new client-relative coordinates.

## Preset import conflict

When the same preset is imported again, Pit House shows:

```text
Import Preset Conflict

Skip
Save As
Overwrite
```

The script intentionally chooses **Overwrite**.

This avoids creating duplicate presets and causes Pit House to apply the imported preset.

## What happens when a preset is selected

```text
1. Stream Deck sends F13-F24
2. AutoHotkey receives the hotkey
3. Current foreground application is remembered
4. Pit House is activated
5. Pit House is resized
6. Wheelbase page is opened
7. Preset menu is opened
8. Import Preset is selected
9. Windows file picker opens
10. Preset path is entered
11. Preset is submitted
12. Pit House detects the existing preset
13. Overwrite is clicked
14. Preset is applied
15. Previous application is restored
16. Confirmation notification is shown
```

## Safety / failure handling

The script checks several conditions before continuing.

It stops instead of blindly clicking if:

- the preset file does not exist
- MOZA Pit House is not running
- Pit House cannot be activated
- Pit House cannot be resized correctly
- the Windows preset file dialog does not appear

The script also prevents multiple preset-switch operations from running at the same time.

## Known limitations

### Pit House UI automation

Pit House uses a custom-rendered interface. Most of its controls are not exposed through standard Windows UI Automation tools.

Because of that, some parts of the script rely on mouse coordinates. A major Pit House UI redesign may therefore require coordinate changes.

### Pit House version changes

This project was tested with:

```text
MOZA Pit House 1.4.1.13
```

Future versions may move UI elements or change the preset import workflow.

### Switching during a race

The script temporarily brings Pit House to the foreground.

It restores the previously focused application afterward, but switching presets during active driving is not recommended.

The intended use is before entering a session, race, stage, or vehicle.

### No native preset API

This project does not use a native MOZA command for selecting presets because such an API is not currently available.

It automates Pit House's own preset import workflow instead.

## Why not just use the MOZA SDK?

The MOZA SDK can modify many FFB parameters individually.

However, not every Pit House preset parameter has a corresponding public SDK setter.

That means an SDK-based preset loader may reproduce only part of a preset.

This project instead asks Pit House itself to import the `.mzpreset` file, allowing Pit House to handle the complete preset.

## Recommended folder structure

```text
MozaPresetSwitcher/
│
├── MozaPresetSwitcher.ahk
├── README.md
│
└── Presets/
    ├── RBR.mzpreset
    ├── ACR.mzpreset
    ├── EAWRC.mzpreset
    ├── iRacing.mzpreset
    └── ETS2.mzpreset
```

You can also keep the presets anywhere else on the system and use absolute paths.

## Troubleshooting

### Stream Deck button does nothing

Check that:

- the AutoHotkey script is running
- the correct F13-F24 key is assigned
- the Stream Deck button uses a Hotkey action
- no other software is intercepting the same key

### Pit House opens but nothing else happens

Check the Pit House version and window layout.

The UI coordinates may no longer match.

Use Window Spy and verify the client-relative positions.

### Preset file picker opens but does not continue

Verify that the preset file path is valid.

Example:

```text
C:\Users\YourName\Documents\Moza_Presets\EAWRC.mzpreset
```

### Wrong button is clicked

This usually means Pit House changed layout.

Check that the client size is `1440 × 990` and verify the coordinate values using Window Spy.

### Preset does not exist

The script shows an error if the configured `.mzpreset` file cannot be found.

Check the path in:

```ahk
Presets := Map(...)
```

## Disclaimer

This project is an unofficial community tool.

It is not affiliated with or endorsed by MOZA Racing or Elgato.

The script interacts with MOZA Pit House through UI automation, so future Pit House updates may require changes.

Use it at your own risk.

## Possible future improvements

- automatic detection of Pit House layout changes
- configurable preset definitions outside the `.ahk` file
- Stream Deck icons/status feedback
- active-preset indication
- automatic game detection
- automatic preset selection based on the running simulator
- more robust Pit House UI detection
- optional logging
- packaged executable version
