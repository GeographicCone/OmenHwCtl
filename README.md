# OmenHwCtl: HP Omen Hardware Control

Version: 2023-08-22

## What It Does

### Set

* CPU Power Limits (PL1 and PL4)
* CPU Power Limit in a concurrent usage scenario
* Total Graphics Power (TGP): enable or disable Custom TGP (cTGP) and PPAB
* Fan mode, speed, the dynamic fan table, maximum fan speed on/off
* Custom task to be run when Omen Key is pressed
* Backlight color and turn backlight on/off
* Memory to XMP mode
* Idle mode on/off

### Query

* Current temperature and whether the system is thermal throttling
* Fan number and type, speed reading, the dynamic fan table, and whether maximum speed mode is enabled
* Graphics mode (hybrid, discrete or Optimus) and GPU power features state
* Backlight color table, LED animation table, whether backlight is supported and if it is on or off
* Other system features and settings exposed by the BIOS:
  * Born On Date (BOD)
  * Keyboard type
  * Overclocking and memory overclocking support status
  * Smart Adapter status
  * System Design Data
  * Undervolting support

## How to Use It

### Command Line

The script can be used directly from the command line by calling:

````
OmenHwCtl
 [-GetBornOnDate] [-GetOcSupport] [-GetSmartAdapterStatus] [-GetSysDesignData]
 [-GetFanCount] [-GetFanLevel] [-GetFanTable] [-GetFanType] [-GetMaxFanStatus]
 [-GetGfxMode] [-GetGpuStatus] [-GetTemp] [-GetThermalThrottlingStatus]
 [-GetBacklight] [-GetBacklightSupport] [-GetColorTable] [-GetKbdType] [-GetLedAnim]
 [-GetBiosUndervoltSupport] [-GetMemOcSupport] [-SetMemXmp] [-OmenKeyOff|-OmenKeyOn]
 [-BacklightOff|-BacklightOn] [-SetColor4 <RGB0:RGB1:RGB2:RGB3> (RGB#: 000000-FFFFFF)]
 [-MaxGpuPower|-MedGpuPower|-MinGpuPower] [-MaxFanSpeedOff|-MaxFanSpeedOn] [-SetIdleOff|-SetIdleOn]
 [-SetFanLevel <00-FF:00-FF>] [-SetFanMode <0x00-0xFF>] [-SetFanTable <00-FF>+ (# < 128)]
 [-SetConcurrentCpuPower <0-254>] [-SetCpuPower <0-254>] [-SetCpuPowerMax <0-254>]
 [-MuxFix] [-MuxFixOff|-MuxFixOn] [-SetGfxMode <0x00-0xFF>] [-SetLedAnim] [-Silent]
````

![OmenHwCtl Screenshot (from an older version)](https://raw.githubusercontent.com/GeographicCone/OmenHwCtl/master/OmenHwCtl.png)

Where the parameters are:
* `-BacklightOff` and `-BacklightOn` Disable or enable keyboard backlight
* `-GetBacklight` Report backlight status
* `-GetBacklightSupport` Check for backlight support
* `-GetBiosUndervoltSupport` Check for undervolting support in BIOS
* `-GetBornOnDate` Output system manufacturing date ("born-on date", BOD)
* `-GetColorTable` Retrieve current backlight color information
* `-GetFanCount` Report number of fans
* `-GetFanLevel` Check current fan speeds
* `-GetFanTable` Retrieve dynamic fan table
* `-GetFanType` Report system fan types
* `-GetGfxMode` Check current graphics mode (hybrid, discrete, or Optimus)
* `-GetGpuStatus` Retrieve GPU power feature settings (cTGP, PPAB, DState and thermal threshold)
* `-GetKbdType` Check keyboard type
* `-GetLedAnim` Retrieve LED animation table
* `-GetMaxFanStatus` Check if fans are operating in maximum-speed mode
* `-GetMemOcSupport` Check memory overclocking support
* `-GetOcSupport` Check for overclocking support as reported by the BIOS
* `-GetSmartAdapterStatus` Check Smart Adapter status ([reference](https://github.com/GeographicCone/OmenHwCtl/blob/master/Reference/Data%20Common.cs#L104-L108))
* `-GetSysDesignData` Retrieve system design data, including Thermal Policy Version and default PL4
* `-GetTemp` Show current temperature sensor reading
* `-GetThermalThrottlingStatus` Check if system is currently thermal throttling
* `-MaxFanSpeedOff` and `-MaxFanSpeedOn` Disable or enable maximum fan speed mode
* `-MaxGpuPower`, `-MedGpuPower` and `-MinGpuPower` Adjust Total Graphics Power (TGP) by enabling or disabling custom TGP (cTGP) and PPAB
* `-MuxFix` Apply a fix for screen stutter and color profile not applied in Advanced Optimus discrete GPU-only mode (generally supposed to be run from the task)
* `-MuxFixOff` Remove the WMI event filter to apply Advanced Optimus fix whenever discrete GPU-only mode is set
* `-MuxFixOn` Set a task to run whenever DGPU-only mode is enabled to fix screen stuttering and color profile not being applied (see [Omen Mux Task.cmd](https://github.com/GeographicCone/OmenHwCtl/blob/master/Omen%20Mux%20Task.cmd) and [.xml](https://github.com/GeographicCone/OmenHwCtl/blob/master/Omen%20Mux%20Task.xml))
* `-OmenKeyOff` Remove the WMI event filter triggering a task whenever the Omen Key is pressed
* `-OmenKeyOn` Run a custom task whenever the Omen Key is pressed (see [Omen Key Task.cmd](https://github.com/GeographicCone/OmenHwCtl/blob/master/Omen%20Key%20Task.cmd) and [.xml](https://github.com/GeographicCone/OmenHwCtl/blob/master/Omen%20Key%20Task.xml))
* `-SetColor4 <RGB0:RGB1:RGB2:RGB3> (RGB#: 000000-FFFFFF)` Set backlight color for a 4-zone keyboard
* `-SetConcurrentCpuPower <0-254>` Set CPU Power Limit in a concurrent usage scenario to a specified value
* `-SetCpuPower <0-254>` Set CPU Power Limit (PL1) to a specified value
* `-SetCpuPowerMax <0-254>` Set maximum CPU Power Limit (PL1) to a specified value
* `-SetFanLevel <00-FF:00-FF>` Manually set the speed of each fan ([reference](https://github.com/GeographicCone/OmenHwCtl/blob/master/Reference/Data%20Platform.cs#L90-L93))
* `-SetFanMode <0x00-0xFF>` Change fan operating mode ([reference](https://github.com/GeographicCone/OmenHwCtl/blob/master/Reference/Data%20Common.cs#L209-L223))
* `-SetFanTable <00-FF>+ (# < 128)` Set the dynamic fan table (fan mode-dependent)
* `-SetGfxMode <0x00-0xFF>` Change discrete graphics mode ([reference](https://github.com/GeographicCone/OmenHwCtl/blob/master/Reference/Data%20Common.cs#L258-L260))
* `-SetIdleOff` `-SetIdleOn` Disable or enable idle mode
* `-SetLedAnim` Set LED animation table, reserved but not implemented
* `-SetMemXmp` Set memory to XMP mode (following reboot)
* `-Silent` Suppress all text output (except usage note if called with no suitable parameters)

#### Examples

* `-MaxGpuPower` makes the GPU run at maximum power, enabling custom TGP (cTGP) and PPAB - the original reason why this script was written
* `-SetColor4 00FF00:00FF00:0080FF:FFFFFFF` sets right and middle zones to green, left to sky blue, and the WASD keys to white
* `-GetTemp -GetFanLevel` reports temperature and current fan speed (multiple operations can be performed in one go)
* `-SetFanMode 49 -SetFanLevel 37:39` sets fan mode to Performance and fan speeds to 5,500 and 5,700 rpm respectively for the next 2 minutes, at which point they will revert to the automatic defaults
* `-OmenKeyOn` sets up a custom WMI event filter so that the task "Omen Key" will run whenever the Omen Key is pressed (this only has to be done once, as it persists across reboots; to remove, use `-OmenKeyOff`)

#### Notes

The actual script is `OmenHwCtl.ps1`. The file `OmenHwCtl.cmd` is provided as a wrapper to bypass the [execution policy settings](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy) that prevent PowerShell scripts from running by default. All it does is launching the actual script, passing all the command-line arguments (parameters) to it, and bypassing the default execution policy.

There is currently no parameter validation. It's on you to make sure the values you specify are correct.

The script has to run as an administrator.

### Scheduled Tasks

#### Applying the Settings on Boot

The settings need to be reapplied after a system reboot or shutdown. Thus, for further convenience, a script is provided to add a scheduled task that will run on every startup, setting the Total Graphics Power (TGP) to the maximum.

To install the task, run the script `Omen Boot Task.cmd` as an administrator. `OmenHwCtl.{cmd,ps1}` will be copied to the Windows system folder `%SystemRoot%\System32`, and a task will be installed to run `OmenHwCtl.cmd -MaxGpuPower -Silent` upon every startup as per the `Omen Boot Task.xml` file.

Once installed, the task will be visible in the _Task Scheduler_ (`Win-R`, type: `mmc taskschd.msc`, `Enter`). It can be further edited or deleted from there.

<ins>Note</ins>: The XML file to set up the task is required to ensure that the task runs even if the system is booted when on battery power. This is not possible if adding a task with only the command-line options of `schtasks.exe`.

#### Omen Key Action

To use the Omen Key, run `Omen Key Task.cmd` (as an administrator) to add a task that will run whenever the Omen Key is pressed. You might want to edit the `Omen Key Task.xml` file beforehand: by default it is set to power the screen (and keyboard backlight) off while the laptop keeps running.

#### Workaround Advanced Optimus Screen Stutter

Yet another task has the purpose of triggering a screen refresh rate change when switching to discrete GPU-only mode in Advanced Optimus to workaround a bug that causes the screen to stutter in said mode. It also resolves another bug where the existing color profile is not applied to the newly-enabled screen. To install, run `Omen Mux Task.cmd` as an administrator. If you do not suffer from these issues (which might be Windows version-dependent), there is no need to use this feature.

## What It Needs to Work

### Requirements

* A suitable device exposing the `hpqBIntM` interface via WMI
  * It is more than sufficient to install the following drivers:
    * `hpcustomcapdriver.inf` (for `ACPI\HPIC0003`)
    * `hpomencustomcapdriver.inf` (for `ACPI\HPIC0004`)
    * `hpomencustomcapext.inf` (ditto)
  * It is specifically <ins>**neither necessary not recommended**</ins> to install the following driver, as it includes a lot of bloatware running in the background:
    * ~~`hpomencustomcapcomp.inf`~~
  * Other HP laptops, not just from the _Omen_ series, might work as well
* Windows PowerShell 5.1
  * Included with any recent Windows version
* Administrator access to the device

### Compatibility

Tested to work on my **HP Omen 16-b1xxx (2022)** (Intel/nVidia version), where it also addresses the issue (an `F.15` BIOS bug?) when the TGP is set to lowest after resuming from hibernation, with the additional benefit that once the script is added to the _Task Scheduler_ to run on boot, it does not have to be re-run when coming back from hibernation.

For reference, with a 3070Ti, the default TGP is 105W, goes up to 115W when set to highest, and drops down to 80W when set to lowest (or after hibernation, if not set manually, due to the aforementioned bug). The default PL1 is 45W, and PL4 is 215W.

The script reproduces the entire scope of WMI calls made by the Omen Gaming Hub. Not all operations will work with all hardware. Please report compatibility [in the relevant issue](https://github.com/GeographicCone/OmenHwCtl/issues/1).

## More to Know

### Customization

#### How to Send Data

The script uses PowerShell's [CimCmdlets](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/) to access the WMI interface exposed by the HP BIOS. It is short and should be self-explanatory. Please just have a look at the source, there are extensive comments inline.

The main function can be used to send any data to the BIOS:

`Send-OmenBiosWmi -CommandType <OPERATION> -Data <DATA> -OutputSize <0|4|128|1024|4096>`

Where:
* `-Command` is the command identifier, observed to be mostly constant: `0x20008` (131080), although `0x01` and `0x20009` (131081) are also used. Defaults to the former if omitted.
* `-CommandType` is the actual operation to be performed, for example `0x22` (34) or `0x27` (39).
* `-Data` is the data to be passed to BIOS, for example `0x01` or `@(0x01, 0x00, 0x01, 0x00)` if passing an array. The parameter is optional.
* `-OutputSize` determines the WMI method used to transmit data: `hpqBIOSInt{0,4,128,1024,4096}`, depending on how much data is expected to be returned. If the size is insufficient, the call will fail with error 5, "output size too small."
* `-Sign` is a shared secret, which appears to be constant, and is thus also embedded in the routine. If the default `@(0x53, 0x45, 0x43, 0x55)` (83, 69, 67, 85) does not work for you, you can pass a different one the same way as you would with `-Data`.

#### Knowing What to Send

All the relevant commands and data are stored within the Omen Gaming Hub application, which is a real treasure trove to explore as inspiration. The workflow:

* Download the _Omen Gaming Hub_ application. The resulting file should be something like: `AD2F1837.OMENCommandCenter_1101.2307.3.0_x64__v10z8vjag6ke6.msix`.
* The MSIX file is just a `.zip` archive, which can be unpacked with, for example, [7-Zip](https://www.7-zip.org/).
* Once unpacked, a free utility such as [JetBrains DotPeek](https://www.jetbrains.com/decompiler/) can be used to learn how the sausage is made.
* Happy hacking, and please share your results!

### Why

#### Overview

[**Omen**](https://www.omen.com/) are a series of performance-oriented (gaming) laptops from [HP](https://www.hp.com/), all of which come equipped with a discrete GPU.

Obtaining optimal performance from such hardware usually involves the tweaking of their power and thermal settings, which, as a rule, are not exposed to the user through any of the common Windows interfaces.

HP provides a utility that enables the user to adjust some of these settings. Unfortunately, the [Omen Gaming Hub](https://apps.microsoft.com/store/detail/omen-gaming-hub/9NQDW009T0T5) comes in the form of a 300MB-heavy UWP application that takes longer than many games to load, and occupies 1.5GB RAM once it does even when idle, while most of its functionality is at best tangential to its primary purpose.

Within the _Omen Gaming Hub_, the applet allowing power and fan control cannot be easily separated from the rest of the application, which also includes a store, a social network client, and numerous telemetry-collecting services running in the background, nor can any of the redundant functionality be uninstalled or opted out of.

#### Purpose

The purpose of **OmenHwCtl** is to recreate the useful functionality exposed by the HP BIOS and available for customization through the _Omen Gaming Hub_, without the need to run or actually even install the application itself, or any of its associated services.

Further, the goal is to keep the replacement as compact as possible, and readily available to use with no prerequisites, which is why it comes in the form of a shell script compatible with _Windows PowerShell 5.1_, commonly bundled with any Windows version.

### Links

#### Projects

* [Omen-CLI](https://github.com/thebongy/omen-cli/) by **@thebongy**: keyboard LED light control via the command line using the same WMI interface
* [Omen Hub Light](https://github.com/determ1ne/OmenHubLight/) by **@determ1ne**: keyboard LED light control via a GUI, also fan control for pre-2021 Omen models, written in .NET 5
* [Thermal Control](https://github.com/prajaybasu/ThermalControl/) by **@prajaybasu**: CLI or background service to set fan parameters at regular intervals, written in .NET 6, work in progress

#### Reading

* Check out the [Reference](https://github.com/GeographicCone/OmenHwCtl/tree/master/Reference) directory in this repository for some hopefully useful information
* [Reverse Engineering HP Omen 15 Keyboard Driver: Part 2 - Decompiling .NET applications](https://dev.to/rishit/reverse-engineering-keyboard-driver-part-2-decompiling-net-applications-44l2)
* [Omen Hub Light: Feature Discussion](https://github.com/determ1ne/OmenHubLight/issues/1) (closed GitHub issue)

### Disclaimer

This script comes as-is. All I know is that it works for me, for my specific use case. Feel free to use it however you like but if anything goes wrong, don't blame me. 
Experimenting with these routines and sending random data can potentially be dangerous or destructive. You assume all responsibility for your own actions.
