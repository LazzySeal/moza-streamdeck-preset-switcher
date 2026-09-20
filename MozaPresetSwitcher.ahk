#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode 2
CoordMode "Mouse", "Client"
SendMode "Input"


; ============================================================
; MOZA PRESET SWITCHER
; Production v1.1
; ============================================================


; ------------------------------------------------------------
; PIT HOUSE
; ------------------------------------------------------------

PitHouse := "ahk_exe MOZA Pit House.exe"


; ------------------------------------------------------------
; PRESETS
; ------------------------------------------------------------

Presets := Map(
    "RBR RSF",               "C:\Users\LazzySeal\Documents\Moza_Presets\RBR.mzpreset",
    "Assetto Corsa Rally",   "C:\Users\LazzySeal\Documents\Moza_Presets\ACR.mzpreset",
    "EA WRC",                "C:\Users\LazzySeal\Documents\Moza_Presets\EAWRC.mzpreset",
    "iRacing",               "C:\Users\LazzySeal\Documents\Moza_Presets\iRacing.mzpreset",
    "Trucks",                "C:\Users\LazzySeal\Documents\Moza_Presets\ETS2.mzpreset"
)


; ------------------------------------------------------------
; REQUIRED PIT HOUSE CLIENT SIZE
; ------------------------------------------------------------

ExpectedClientW := 1440
ExpectedClientH := 990

SizeTolerance := 2


; ------------------------------------------------------------
; PIT HOUSE CLIENT-RELATIVE CLICK POSITIONS
; ------------------------------------------------------------

; Left-side Wheelbase tab
WheelbaseTabX := 34
WheelbaseTabY := 115

; Top-right ... menu
MenuX := 1401
MenuY := 23

; Import Preset
ImportX := 1357
ImportY := 86

; Conflict dialog: Overwrite
OverwriteX := 853
OverwriteY := 584


; ------------------------------------------------------------
; STATE
; ------------------------------------------------------------

Busy := false


; ============================================================
; HOTKEYS
; ============================================================

F13::ApplyPreset("RBR RSF")
F14::ApplyPreset("Assetto Corsa Rally")
F15::ApplyPreset("EA WRC")
F16::ApplyPreset("iRacing")
F17::ApplyPreset("Trucks")


; ============================================================
; APPLY PRESET
; ============================================================

ApplyPreset(PresetName)
{
    global Presets
    global PitHouse
    global Busy

    global ExpectedClientW
    global ExpectedClientH
    global SizeTolerance

    global WheelbaseTabX
    global WheelbaseTabY
    global MenuX
    global MenuY
    global ImportX
    global ImportY
    global OverwriteX
    global OverwriteY


    ; --------------------------------------------------------
    ; Prevent simultaneous preset switches
    ; --------------------------------------------------------

    if Busy
        return

    Busy := true


    ; --------------------------------------------------------
    ; Remember application that currently has focus
    ; --------------------------------------------------------

    PreviousWindow := WinExist("A")


    ; --------------------------------------------------------
    ; Validate preset name
    ; --------------------------------------------------------

    if !Presets.Has(PresetName)
    {
        ShowError(
            "Unknown preset: " PresetName,
            PreviousWindow
        )

        Busy := false
        return
    }

    PresetFile := Presets[PresetName]


    ; --------------------------------------------------------
    ; Validate preset file
    ; --------------------------------------------------------

    if !FileExist(PresetFile)
    {
        ShowError(
            "Preset file not found:`n`n" PresetFile,
            PreviousWindow
        )

        Busy := false
        return
    }


    ; --------------------------------------------------------
    ; Check that Pit House is running
    ; --------------------------------------------------------

    if !WinExist(PitHouse)
    {
        ShowError(
            "MOZA Pit House is not running.",
            PreviousWindow
        )

        Busy := false
        return
    }


    PitHouseHwnd := WinExist(PitHouse)
    PitHouseID := "ahk_id " PitHouseHwnd


    ; --------------------------------------------------------
    ; Restore and activate Pit House
    ; --------------------------------------------------------

    WinRestore PitHouseID
    Sleep 150

    WinActivate PitHouseID

    if !WinWaitActive(PitHouseID,, 3)
    {
        ShowError(
            "Could not activate MOZA Pit House.",
            PreviousWindow
        )

        Busy := false
        return
    }

    Sleep 200


    ; --------------------------------------------------------
    ; FORCE CLIENT SIZE TO 1440 x 990
    ;
    ; WinMove works with the OUTER window size.
    ; So we measure the current difference between:
    ;
    ;     outer window
    ;     client area
    ;
    ; and calculate the correct outer dimensions required
    ; to produce our desired client dimensions.
    ; --------------------------------------------------------

    WinGetPos &OuterX, &OuterY, &OuterW, &OuterH, PitHouseID
    WinGetClientPos , , &CurrentClientW, &CurrentClientH, PitHouseID

    FrameW := OuterW - CurrentClientW
    FrameH := OuterH - CurrentClientH

    RequiredOuterW := ExpectedClientW + FrameW
    RequiredOuterH := ExpectedClientH + FrameH

    try
    {
        WinMove(
            OuterX,
            OuterY,
            RequiredOuterW,
            RequiredOuterH,
            PitHouseID
        )
    }
    catch as err
    {
        ShowError(
            "Could not resize MOZA Pit House.`n`n"
            . "Windows returned: " err.Message
            . "`n`n"
            . "Pit House may be running as Administrator while "
            . "this script is not.",
            PreviousWindow
        )

        Busy := false
        return
    }

    Sleep 350


    ; --------------------------------------------------------
    ; Verify that resize actually worked
    ; --------------------------------------------------------

    WinGetClientPos , , &ClientW, &ClientH, PitHouseID

    WidthDifference := Abs(ClientW - ExpectedClientW)
    HeightDifference := Abs(ClientH - ExpectedClientH)

    if (
        WidthDifference > SizeTolerance
        || HeightDifference > SizeTolerance
    )
    {
        ShowError(
            "Could not resize Pit House correctly.`n`n"
            . "Required client size: "
            . ExpectedClientW
            . " x "
            . ExpectedClientH
            . "`n"
            . "Actual client size: "
            . ClientW
            . " x "
            . ClientH
            . "`n`n"
            . "Preset switch cancelled.",
            PreviousWindow
        )

        Busy := false
        return
    }


    ; --------------------------------------------------------
    ; ENSURE WHEELBASE TAB IS OPEN
    ;
    ; Pit House normally starts on Home.
    ; Clicking Wheelbase every time is intentional.
    ; --------------------------------------------------------

    Click WheelbaseTabX, WheelbaseTabY

    ; Give Pit House enough time to render the wheelbase page.
    Sleep 1000


    ; --------------------------------------------------------
    ; Open ... menu
    ; --------------------------------------------------------

    Click MenuX, MenuY
    Sleep 250


    ; --------------------------------------------------------
    ; Click Import Preset
    ; --------------------------------------------------------

    Click ImportX, ImportY


    ; --------------------------------------------------------
    ; Wait for Windows Open dialog
    ; --------------------------------------------------------

    FileDialog := "ahk_class #32770"

    if !WinWaitActive(FileDialog,, 3)
    {
        ShowError(
            "Preset file picker did not appear.",
            PreviousWindow
        )

        Busy := false
        return
    }


    ; Remember this exact instance of the picker.
    FileDialogHwnd := WinExist("A")
    FileDialogID := "ahk_id " FileDialogHwnd

    Sleep 150


    ; --------------------------------------------------------
    ; ENTER AND VERIFY EXACT PRESET PATH
    ; --------------------------------------------------------

    PathEntered := false

    Loop 20
    {
        ControlSetText PresetFile, "Edit1", FileDialogID

        Sleep 100

        CurrentText := ControlGetText("Edit1", FileDialogID)

        if (CurrentText = PresetFile)
        {
            PathEntered := true
            break
        }

        Sleep 100
    }


    ; --------------------------------------------------------
    ; Abort if Windows did not accept the complete path
    ; --------------------------------------------------------

    if !PathEntered
    {
        WinClose FileDialogID

        ShowError(
            "Windows file picker did not accept the complete preset path.`n`n"
            . "Expected:`n"
            . PresetFile
            . "`n`n"
            . "Last value read from the file picker:`n"
            . CurrentText,
            PreviousWindow
        )

        Busy := false
        return
    }


    ; --------------------------------------------------------
    ; SUBMIT PRESET FILE
    ; --------------------------------------------------------

    ControlFocus "Edit1", FileDialogID
    Sleep 100

    ControlSend "{Enter}", "Edit1", FileDialogID


    ; --------------------------------------------------------
    ; Allow Pit House to process imported preset
    ; --------------------------------------------------------

    Sleep 1500


    ; --------------------------------------------------------
    ; Pit House may leave the Windows picker visible even
    ; though the conflict dialog already exists behind it.
    ;
    ; Close only the exact picker opened by this operation.
    ; --------------------------------------------------------

    if WinExist(FileDialogID)
    {
        WinClose FileDialogID
        WinWaitClose FileDialogID,, 2
    }


    ; --------------------------------------------------------
    ; Bring Pit House conflict dialog to foreground
    ; --------------------------------------------------------

    WinActivate PitHouseID

    if !WinWaitActive(PitHouseID,, 2)
    {
        ShowError(
            "Could not return to MOZA Pit House.",
            PreviousWindow
        )

        Busy := false
        return
    }

    Sleep 250


    ; --------------------------------------------------------
    ; Click Overwrite
    ; --------------------------------------------------------

    Click OverwriteX, OverwriteY


    ; Give Pit House time to apply the complete preset.
    Sleep 800


    ; --------------------------------------------------------
    ; Restore application that was active beforehand
    ; --------------------------------------------------------

    if (
        PreviousWindow
        && PreviousWindow != PitHouseHwnd
        && WinExist("ahk_id " PreviousWindow)
    )
    {
        WinActivate "ahk_id " PreviousWindow
    }


    ; --------------------------------------------------------
    ; Confirmation
    ; --------------------------------------------------------

    TrayTip(
        "Applied: " PresetName,
        "MOZA Preset"
    )


    Busy := false
}


; ============================================================
; ERROR HANDLING
; ============================================================

ShowError(Message, PreviousWindow)
{
    if (
        PreviousWindow
        && WinExist("ahk_id " PreviousWindow)
    )
    {
        WinActivate "ahk_id " PreviousWindow
    }

    MsgBox(
        Message,
        "MOZA Preset Switcher",
        "Icon!"
    )
}