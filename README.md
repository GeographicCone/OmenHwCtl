# OmenHwCtl: HP Omen Hardware Control

Version: 2023-08-10

## Why

### Overview

[**Omen**](https://www.omen.com/) are a series of performance-oriented (gaming) laptops from [HP](https://www.hp.com/), all of which come equipped with a discrete GPU.

Obtaining optimal performance from such hardware usually involves the tweaking of their power and thermal settings, which, as a rule, are not exposed to the user through any of the common Windows interfaces.

HP provides a utility that enables the user to adjust some of these settings. Unfortunately, the [Omen Gaming Hub](https://apps.microsoft.com/store/detail/omen-gaming-hub/9NQDW009T0T5) comes in the form of a 300MB-heavy UWP application that takes longer than many games to load, and occupies 1.5GB RAM once it does even when idle, while most of its functionality is at best tangential to its primary purpose.

Within the _Omen Gaming Hub_, the applet allowing power and fan control cannot be easily separated from the rest of the application, which also includes a store, a social network client, and numerous telemetry-collecting services running in the background, nor can any of the redundant functionality be uninstalled or opted out of.

### Purpose

The purpose of **OmenHwCtl** is to recreate the useful functionality exposed by the HP BIOS and available for customization through the _Omen Gaming Hub_, without the need to run or actually even install the application itself, or any of its associated services.

Further, the goal is to keep the replacement as compact as possible, and readily available to use with no prerequisites, which is why it comes in the form of a shell script compatible with _Windows PowerShell 5.1_, commonly bundled with any Windows version.

## What It Does

### Now

* Set Total Graphics Power (TGP) to highest
* Set Total Graphics Power (TGP) to lowest
* Toggle maximum fan speed on/off

### Later

The script can be trivially expanded to adjust other HP BIOS WMI settings. More on that below.

## How to Use It

### Command Line

The script can be used directly from the command line by calling:

`OmenHwCtl [-MaxFanSpeedOff|-MaxFanSpeedOn] [-MaxGpuPower|-MinGpuPower] [-Silent]`

Where the parameters are:
* `-MaxFanSpeedOff` Disable maximum fan speed mode
* `-MaxFanSpeedOn` Enable maximum fan speed mode
* `-MaxGpuPower` Set Total Graphics Power (TGP) to highest
* `-MinGpuPower` Set Total Graphics Power (TGP) to lowest

* `-Silent` Suppress all text output (except usage note if called with no suitable parameters)

![OmenHwCtl Screenshot](https://raw.githubusercontent.com/GeographicCone/OmenHwCtl/master/OmenHwCtl.png)

The actual script is `OmenHwCtl.ps1`. The file `OmenHwCtl.cmd` is provided as a wrapper to bypass the [execution policy settings](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy) that prevent PowerShell scripts from running by default. All it does is launching the actual script, passing all the command-line arguments (parameters) to it, and bypassing the default execution policy.

Note: The script has to be run as an administrator.

### Scheduled Task

The settings need to be reapplied after a system reboot or shutdown. Thus, for further convenience, a script is provided to add a scheduled task that will run on every startup, setting the Total Graphics Power (TGP) to the maximum.

To install the task, run the script `Maximum GPU Power Task.cmd` as an administrator. `OmenHwCtl.{cmd,ps1}` will be copied to the Windows system folder `%SystemRoot%\System32`, and a task will be installed to run `OmenHwCtl.cmd -MaxGpuPower -Silent` upon every startup as per the `Maximum GPU Power Task.xml` file.

Once installed, the task will be visible in the _Task Scheduler_ (`Win-R`, type: `mmc taskschd.msc`, `Enter`). It can be further edited or deleted from there.

Note: The XML file to set up the task is required to ensure that the task runs even if the system is booted when on battery power. This is not possible if adding a task with only the command-line options of `schtasks.exe`.

## What It Needs to Work

### Requirements

* A suitable device exposing the `hpqBIntM` interface via WMI
  * It is more than sufficient to install the following drivers:
    * `hpcustomcapdriver.inf` (for `ACPI\HPIC0003`)
    * `hpomencustomcapdriver.inf` (for `ACPI\HPIC0004`)
    * `hpomencustomcapext.inf` (ditto)
  * It is specifically **neither necessary not recommended** to install the following driver, as it includes a lot of bloatware running in the background:
    * ~~`hpomencustomcapcomp.inf`~~
  * Other HP laptops, not just from the _Omen_ series, might work as well
* Windows PowerShell 5.1
  * Included with any recent Windows version
* Administrator access to the device

### Compatibility

Tested to work on my **HP Omen 16-b1xxx (2022)** (Intel/nVidia version), where it also addresses the issue (an `F.15` BIOS bug?) when the TGP is set to lowest after resuming from hibernation, with the additional benefit that once the script is added to the _Task Scheduler_ to run on boot, it does not have to be re-run when coming back from hibernation.

For reference, with a 3070Ti, the default TGP is 105W, goes up to 115W when set to highest, and drops down to 80W when set to lowest (or after hibernation, if not set manually, due to the aforementioned bug).

Please feel free to report compatibility with other devices in the relevant issue.

## More to Know

### Customization

#### How to Send Data

The script uses PowerShell's [CimCmdlets](https://learn.microsoft.com/en-us/powershell/module/cimcmdlets/) to access the WMI interface exposed by the HP BIOS. It is short and should be self-explanatory. Please just have a look at the source.

The main function can be used to send any data to the BIOS:

`Set-OmenBiosWmi -CommandType <OPERATION> -Data <DATA> -Size <0|4|128|1024|4096>`

Where:
* `-Command` is the command identifier, observed to be mostly constant: `0x20008` (131080) or `0x20009` (131081), defaults to the former if omitted.
* `-CommandType` is the actual operation to be performed, for example `0x22` (34) or `0x27` (39).
* `-Data` is the data to be passed to BIOS, for example `0x01` or `@(0x01, 0x00, 0x01, 0x00)` if passing an array.
* `-Size` is actually the choice of the WMI method that will be used to transmit data: `hpqBIOSInt{0,4,128,1024,4096}`. It should be larger than the length of the data.
* `-Sign` is a shared secret, which appears to be constant, and is thus also embedded in the routine. If the default `@(0x53, 0x45, 0x43, 0x55)` (83, 69, 67, 85) does not work for you, you can pass a different one the same way as you would with `-Data`.

#### Knowing What to Send

All the relevant commands and data are stored within the Omen Gaming Hub application, which is a real treasure trove to explore as inspiration. The workflow:

* Download the _Omen Gaming Hub_ application. The resulting file should be something like: `AD2F1837.OMENCommandCenter_1101.2307.3.0_x64__v10z8vjag6ke6.msix`.
* The MSIX file is just a `.zip` archive, which can be unpacked with, for example, [7-Zip](https://www.7-zip.org/).
* Once unpacked, a free utility such as [JetBrains DotPeek](https://www.jetbrains.com/decompiler/) can be used to learn how the sausage is made.
* Happy hacking, and please share your results!

### Links

#### Projects

* [Omen-CLI](https://github.com/thebongy/omen-cli/) by **@thebongy**: keyboard LED light control via the command line using the same WMI interface
* [Omen Hub Light](https://github.com/determ1ne/OmenHubLight/) by **@determ1ne**: keyboard LED light control via a GUI, also fan control for pre-2021 Omen models, written in .NET 5
* [Thermal Control](https://github.com/prajaybasu/ThermalControl/) by **@prajaybasu**: CLI or background service to set fan parameters at regular intervals, written in .NET 6, work in progress

#### Reading

* [Reverse Engineering HP Omen 15 Keyboard Driver: Part 2 - Decompiling .NET applications](https://dev.to/rishit/reverse-engineering-keyboard-driver-part-2-decompiling-net-applications-44l2)
* [Omen Hub Light: Feature Discussion](https://github.com/determ1ne/OmenHubLight/issues/1) (closed GitHub issue)

### Disclaimer

This script comes as-is. All I know is that it works for me, for my specific use case. Feel free to use it however you like but if anything goes wrong, don't blame me. 
Experimenting with these routines and sending random data can potentially be dangerous or destructive. You assume all responsibility for your own actions.

