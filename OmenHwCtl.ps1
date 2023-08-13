# OmenHwCtl.ps1

# Adjust HP Omen hardware settings with no
# need for HP Omen Game Hub (Command Center)

# Suppress console output if running in silent mode
param ([Switch] $Silent = $False)
If(!$Silent) { $InformationPreference = 'Continue' }

$MyVersion = '2023-08-14'

# Start a CIM session
$Session = New-CimSession -Name 'hpq' -SkipTestConnection

# Send-OmenBiosWmi()
# Makes a WMI call to send a BIOS query:
# this is where all the magic happens
Function Send-OmenBiosWmi {

    # Parameters & validation
    param (

         # Mostly constant identifier (observed: 1, 131080 or 131081)
         [ValidateNotNullOrEmpty()] [UInt32] $Command = 0x20008,

         # The actual operation to perform
         [Parameter(Mandatory)] [UInt32] $CommandType,

         # Optional data payload to be transmitted
         [Byte[]] $Data = $Null,

         # Pre-defined shared secret for authorization (observed: 83, 69, 67, 85)
         [ValidateNotNullOrEmpty()] [Byte[]] $Sign = @(0x53, 0x45, 0x43, 0x55),

         # Method choice depends on the amount of data to be returned
         [ValidateSet('0', '4', '128', '1024', '4096')] [String] $OutputSize = '0'
    )

    # Ensure no usage information is displayed later if an attempt was made to run an operation
    Set-Variable -Name OperationAttempted -Scope Global -Value $True

    # Prepare the request, whether with or without data to be sent
    if($Data -eq $Null) {
        $BiosDataIn = New-CimInstance -ClassName 'hpqBDataIn' -ClientOnly -Namespace 'root\wmi' -Property @{
            Command = $Command;
            CommandType = $CommandType;
            Size = [UInt32] 0;
            Sign = $Sign;
        }
    } else {
        $BiosDataIn = New-CimInstance -ClassName 'hpqBDataIn' -ClientOnly -Namespace 'root\wmi' -Property @{
            Command = $Command;
            CommandType = $CommandType;
            hpqBData = $Data;
            Size = [UInt32] $Data.Length;
            Sign = $Sign;
        }
    }

    # Obtain BIOS method class instance
    $BiosMethods = Get-CimInstance -ClassName 'hpqBIntM' -CimSession $Session -Namespace 'root\wmi'

    # Make a call to write to the BIOS
    $Result = Invoke-CimMethod -InputObject $BiosMethods -MethodName ('hpqBIOSInt' + $OutputSize) -Arguments @{InData = [CimInstance] $BiosDataIn}

    # If operation completed succesfully
    if($Result.OutData.rwReturnCode -eq 0) {

        # Show output data if available
        if($OutputSize -ne '0') {
            Write-Information $('+ OK: ' + $(($Result.OutData.Data | Format-Hex | Select-Object -Expand Bytes | ForEach-Object { '{0:x2}' -f $_ }) -Join ''))

        # Or just show confirmation if no data
        } else {
            Write-Information '+ OK'
        }

    # If an error occured
    } else {
        Write-Information $('- Failed: Error ' + $Result.OutData.rwReturnCode + $(switch($Result.OutData.rwReturnCode) {

            # Provide a description for known error codes
            0x03 { ' - Command Not Available' }
            0x05 { ' - Output Size Too Small' }
        } ))
    }
}

# Iterate through arguments and perform operations accordingly
$NextArg = 0
ForEach($Arg in $Args) {
    $NextArg++
    Switch($Arg) { 
        '-BacklightOff' {
            Write-Information 'Set Backlight Off'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x05 -Data 0x64
            # Byte #0: 0x64 == 0b01100100 - Keyboard Backlight Off
        }
        '-BacklightOn' {
            Write-Information 'Set Backlight On'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x05 -Data 0xE4
            # Byte #0: 0xE4 == 0b11100100 - Keyboard Backlight On
        }
        '-GetBacklight' {
            Write-Information 'Get Backlight Status'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x04 -Data 0x00 -OutputSize 128
            # Byte #0: 0x64 == 0b01100100 - Keyboard Backlight Off,
            #          0xE4 == 0b11100100 - Keyboard Backlight On
        }
        '-GetBiosUndervoltSupport' {
            Write-Information 'Get BIOS Undervolting Support'
            Send-OmenBiosWmi -CommandType 0x35 -Data @(0x00,0x00,0x00,0x00) -OutputSize 128
            # Byte #2: 0x01 == BIOS Undervolting Support (Observed 0x03)
        }
        '-GetBacklightSupport' {
            Write-Information 'Get Backlight Support'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x01 -Data 0x00 -OutputSize 4
            # Byte #0 Bit #0: 0b0 - No Backlight Support, 0b1 - Backlight Support
            # Byte #0 == 0x07, Byte #1 == 0x21 [Description Pending]
        }
        '-GetBornOnDate' {
            Write-Information 'Get Born on Date'
            Send-OmenBiosWmi -Command 0x01 -CommandType 0x10 -OutputSize 128
            # Bytes #0-#7: ASCII String "YYYYMMDD"
        }
        '-GetColorTable' {
            Write-Information 'Get Color Table'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x02 -Data 0x00 -OutputSize 128
            # Byte #00: 0x03 - Number of Color Zones (4)
            # Bytes #25, #26 & #27: Red, Green & Blue Values for Zone #0 (Right)
            # Bytes #28, #29 & #30: Red, Green & Blue Values for Zone #1 (Middle)
            # Bytes #31, #32 & #33: Red, Green & Blue Values for Zone #2 (Left)
            # Bytes #34, #35 & #36: Red, Green & Blue Values for Zone #3 (WASD)
        }
        '-GetFanCount' {
            Write-Information 'Get Fan Count'
            Send-OmenBiosWmi -CommandType 0x10 -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: 0x02 - Number of Fans
        }
        '-GetFanLevel' {
            Write-Information 'Get Fan Level'
            Send-OmenBiosWmi -CommandType 0x2D -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 128
            # Bytes #0 & #1: Observed 0x37 & 0x39 - Max Speed, 0x15 & 0x00 - Min Speed [Each Fan]
        }
        '-GetFanTable' {
            Write-Information 'Get Fan Table'
            Send-OmenBiosWmi -CommandType 0x2F -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 128
            # Byte #0: 0x02 Number of Fans
            # Byte #1: 0x0E == 14 Number of Entries
            # Byte #2 & Onward: Entry #0: (Fan #1 Speed, Fan #2 Speed) @ Temperature Threshold
            # Bytes #02-#04: Entry #01: (0x00, 0x00) @ 0x0F
            # Bytes #05-#07: Entry #02: (0x15, 0x00) @ 0x15
            # Bytes #08-#10: Entry #03: (0x16, 0x14) @ 0x17
            # Bytes #11-#13: Entry #04: (0x18, 0x16) @ 0x19
            # Bytes #14-#16: Entry #05: (0x1A, 0x18) @ 0x1C
            # Bytes #17-#19: Entry #06: (0x1B, 0x19) @ 0x1E
            # Bytes #20-#22: Entry #07: (0x1C, 0x1A) @ 0x1F
            # Bytes #23-#25: Entry #08: (0x1D, 0x1F) @ 0x21
            # Bytes #26-#28: Entry #09: (0x20, 0x23) @ 0x24
            # Bytes #29-#31: Entry #10: (0x25, 0x27) @ 0x28
            # Bytes #32-#34: Entry #11: (0x28, 0x2A) @ 0x2A
            # Bytes #35-#37: Entry #12: (0x2D, 0x2F) @ 0x2D
            # Bytes #38-#40: Entry #13: (0x32, 0x34) @ 0x30
            # Bytes #41-#43: Entry #14: (0x37, 0x39) @ 0x32
            # Bytes #44-#127: 0x00
        }
        '-GetFanType' {
            Write-Information 'Get Fan Type'
            Send-OmenBiosWmi -CommandType 0x2C -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 128
            # Byte #0: 0x21 == 0b00100001
            # (1) Bitwise conjunction with 15 == 0x0F == 0b00001111 results in 0x01
            # (2) Bitwise conjunction with 240 == 0xF0 == 0b11110000
            # and shifted right by 4 bits also results in 0x01
            # (3) These are then added to the fan list
        }
        '-GetGfxMode' {
            Write-Information 'Get Graphics Mode'
            Send-OmenBiosWmi -Command 0x01 -CommandType 0x52 -OutputSize 4
            # Byte #0: 0x00 - Hybrid, 0x01 - Discrete, 0x02 - Optimus
        }
        '-GetGpuStatus' {
            Write-Information 'Get GPU Status'
            Send-OmenBiosWmi -CommandType 0x21 -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: 0x00 - Custom TGP Off, 0x01 - Custom TGP On
            # Byte #1: 0x00 - PPAB Off, 0x01 - PPAB On
            # Byte #2: 0x01 - Current DState
            # Byte #3: 0x00 - GPU Peak Temperature Sensor Threshold Off, 0x4B - 75°C, 0x57 - 87°C
         }
        '-GetKbdType' {
            Write-Information 'Get Keyboard Type'
            Send-OmenBiosWmi -CommandType 0x2B -Data 0x00 -OutputSize 4
            # Byte #0: 0x00 - Standard, 0x01 - w/Numpad, 0x02 - Tenkeyless w/o Numpad, 0x03 - Per-Key RGB (?)
        }
        '-GetLedAnim' {
            Write-Information 'Get LED Animation'
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x06 -Data 0x00 -OutputSize 128
            # All Bytes: 0x00
        }
        '-GetMaxFanStatus' {
            Write-Information 'Get Max Fan Status'
            Send-OmenBiosWmi -CommandType 0x26 -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: 0x00 - Max Fan Speed Off, 0x01 - Max Fan Speed On
         }
        '-GetMemOcSupport' {
            Write-Information 'Get Memory Overclocking Support'
            Send-OmenBiosWmi -CommandType 0x18 -Data 0x00 -OutputSize 128
            # Byte #2: 0x01 == Memory Overclocking Support (Observed 0x00)
        }
        '-GetOcSupport' {
            Write-Information 'Get Overclocking Support'
            Send-OmenBiosWmi -CommandType 0x35 -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 128
            # Byte #2: 0x03 (0x00 - No Support)
         }
        '-GetSmartAdapterStatus' {
            Write-Information 'Get Smart Adapter Status'
            Send-OmenBiosWmi -Command 0x01 -CommandType 0x0F -OutputSize 4
            # Byte #0: 0x01
        }
        '-GetSysDesignData' {
            Write-Information 'Get System Design Data'
            Send-OmenBiosWmi -CommandType 0x28 -OutputSize 128
            # Bytes #1 & #0:       0x00 0xE6 = 0b011100110
            #                   >= 0x01 0x18 = 0b100011000 - TGP PPAB Enabled
            #                            
            # Byte #2: 0x01 - Thermal Policy Version
            # Byte #4: 0x01 - Software Fan Control Support
            # Byte #5: 0xD7 == 215 [W] - Default Power Limit 4 Value
        }
        '-GetTemp' {
            Write-Information 'Get Temperature'
            Send-OmenBiosWmi -CommandType 0x23 -Data @(0x01, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: Observed 0x1D - Lowest, 0x31 - Highest
            # Variant Where Input Data Byte #1: 0x01 - Same Result
        }
        '-GetThermalThrottlingStatus' {
            Write-Information 'Get Thermal Throttling Status'
            Send-OmenBiosWmi -CommandType 0x35 -Data @(0x00, 0x04, 0x00, 0x00) -OutputSize 128
            # Byte #1 == 0x04 (0x01 - Thermal Throttling On)
         }
        '-MaxFanSpeedOff' {
            Write-Information 'Set Maximum Fan Speed Off'
            Send-OmenBiosWmi -CommandType 0x27 -Data 0x00
            # Byte #0: 0x01 - Maximum Fan Speed Off
        }
        '-MaxFanSpeedOn' {
            Write-Information 'Set Maximum Fan Speed On'
            Send-OmenBiosWmi -CommandType 0x27 -Data 0x01
            # Byte #0: 0x01 - Maximum Fan Speed On
        }
        '-MaxGpuPower' {
            Write-Information 'Set Maximum GPU Power'
            Send-OmenBiosWmi -CommandType 0x22 -Data @(0x01, 0x01, 0x01, 0x00)
            # Byte #0: 0x01 - Custom TGP On
            # Byte #1: 0x01 - PPAB On
            # Byte #2: 0x01 - DState
            # Byte #3: 0x00 - GPU Peak Temperature Sensor Threshold Off (0x4B - 75°C, 0x57 - 87°C)
        }
        '-MinGpuPower' {
            Write-Information 'Set Minimum GPU Power'
            Send-OmenBiosWmi -CommandType 0x22 -Data @(0x00, 0x00, 0x01, 0x00)
            # Byte #0: 0x00 - Custom TGP Off
            # Byte #1: 0x00 - PPAB Off
            # Byte #2: 0x01 - DState
            # Byte #3: 0x00 - GPU Peak Temperature Sensor Threshold Off
        }
        '-OmenKeyOff' {
            Write-Information 'Set Omen Key Off'
            Set-Variable -Name OperationAttempted -Scope Global -Value $True
            Get-CimInstance -CimSession $Session -ClassName '__EventFilter' -Namespace 'root\subscription' `
                -Filter "Name='OmenKeyFilter'" | Remove-CimInstance
            Get-CimInstance -CimSession $Session -ClassName 'CommandLineEventConsumer' -Namespace 'root\subscription' `
                -Filter "Name='OmenKeyConsumer'" | Remove-CimInstance
            Get-CimInstance -CimSession $Session -ClassName '__FilterToConsumerBinding' -Namespace 'root\subscription' `
                -Filter "Filter = ""__EventFilter.Name='OmenKeyFilter'""" | Remove-CimInstance
        }
        '-OmenKeyOn' {
            Write-Information 'Set Omen Key On'
            Set-Variable -Name OperationAttempted -Scope Global -Value $True
            $OmenKeyConsumer = New-CimInstance -CimSession $Session -ClassName 'CommandLineEventConsumer' `
                -Namespace 'root\subscription' -Property  @{`
                    CommandLineTemplate = 'C:\Windows\System32\schtasks.exe /run /tn "Omen Key"';
                    ExecutablePath = 'C:\Windows\System32\schtasks.exe';
                    Name = 'OmenKeyConsumer';
                }
            $OmenKeyFilter = New-CimInstance -CimSession $Session -ClassName '__EventFilter' `
                -Namespace 'root\subscription' -Property @{`
                    EventNameSpace = 'root\wmi';
                    Name = 'OmenKeyFilter';
                    Query = 'SELECT * FROM hpqBEvnt WHERE eventData = 8613 AND eventId = 29';
                    QueryLanguage = 'WQL';
                }
            $OmenKeyBinding = New-CimInstance -CimSession $Session -ClassName '__FilterToConsumerBinding' `
                    -Namespace 'root\subscription' -Property @{`
                        Consumer = [Ref] $OmenKeyConsumer
                        Filter = [Ref] $OmenKeyFilter;
                }
        }
        '-SetColor4' {
            Write-Information 'Set Color (4-Zone)'
            [Byte[]] $ColorTable = @(
                [Byte[]] @(,[Byte] 0x03) `
                + [Byte[]] @($(New-Object Byte[] 24)) `
                + [Byte[]] @($Args[$NextArg] `
                    -Replace '[^a-fA-F0-9]+', '' `
                    -Replace '..', '0x$& ' `
                    -Replace ' $', '' -Split ' ' `
                    | ForEach-Object { $_ }) `
                + [Byte[]] @($(New-Object Byte[] 91))
            )
            Send-OmenBiosWmi -Command 0x20009 -CommandType 0x03 -Data $ColorTable
            # Byte #00: 0x03 - Number of Color Zones (4)
            # Bytes #01-#24 (24) & #37-#127 (91): 0x00
            # Bytes #25, #26 & #27: Red, Green & Blue Values for Zone #0 (Right)
            # Bytes #28, #29 & #30: Red, Green & Blue Values for Zone #1 (Middle)
            # Bytes #31, #32 & #33: Red, Green & Blue Values for Zone #2 (Left)
            # Bytes #34, #35 & #36: Red, Green & Blue Values for Zone #2 (WASD)
        }
        '-SetConcurrentCpuPower' {
            $Value = [Byte] $Args[$NextArg]
            Write-Information $('Set Concurrent CPU Power Limit to: ' + $Value + 'W')
            Send-OmenBiosWmi -CommandType 0x29 -Data @(0xFF, 0xFF, 0xFF, $Value)
            # Bytes #0 & #1: 0xFF - Do Not Set Power Limit 1
            # Byte #2: 0xFF - Do Not Set Power Limit 4
            # Byte #3: Concurrent CPU Power Limit
        }
        '-SetCpuPower' {
            $Value = [Byte] $Args[$NextArg]
            Write-Information $('Set CPU Power Limit (PL1) to: ' + $Value + 'W')
            Send-OmenBiosWmi -CommandType 0x29 -Data @($Value, $Value, 0xFF, 0xFF)
            # Bytes #0 & #1: CPU Power Limit 1
            # Byte #2: 0xFF - Do Not Set Power Limit 4
            # Byte #3: 0xFF - Do Not Set Concurrent CPU Power Limit
        }
        '-SetCpuPowerMax' {
            $Value = [Byte] $Args[$NextArg]
            Write-Information $('Set Max CPU Power Limit (PL4) to: ' + $Value + 'W')
            Send-OmenBiosWmi -CommandType 0x29 -Data @(0xFF, 0xFF, $Value, 0xFF)
            # Bytes #0 & #1: 0xFF - Do Not Set CPU Power Limit 1
            # Byte #2: Power Limit 4
            # Byte #3: 0xFF - Do Not Set Concurrent CPU Power Limit
        }
        '-SetFanLevel' {
            [Byte[]] $FanLevel = [Byte[]] @($Args[$NextArg] `
                    -Replace '[^a-fA-F0-9]+', '' `
                    -Replace '..', '0x$& ' `
                    -Replace ' $', '' -Split ' ' `
                    | ForEach-Object { $_ })
            Write-Information $('Set Fan Level to: ' + $FanLevel[0] * 100 + ' & ' + $FanLevel[1] * 100 + ' rpm')
            Send-OmenBiosWmi -CommandType 0x2E -Data $FanLevel
            # Bytes #0 & #1: CPU & GPU Fan Level
        }
        '-SetFanMode' {
            $Value = [Byte] $Args[$NextArg]
            Write-Information $('Set Fan Mode to: ' + $Value)
            Send-OmenBiosWmi -CommandType 0x1A -Data @(0xFF, $Value)
            # Byte #0: 0xFF - Constant (?)
            # Byte #1: Default/Eco → L2, Cool → L4, Performance → L7
            # 0x00 - Default/Eco, 0x01 - Performance, 0x02 - Cool, 0x03 - Quiet, 0x04 - Extreme (L8)
            # 0x10 - L0, 0x20 - L1, 0x30 - L2, 0x40 - L3, 0x50 - L4, 0x11 - L5, 0x21 - L6, 0x31 - L7
        }
        '-SetFanTable' {
            Write-Information 'Set Fan Table'
            [Byte[]] $FanTableData = [Byte[]] @($Args[$NextArg] `
                    -Replace '[^a-fA-F0-9]+', '' `
                    -Replace '..', '0x$& ' `
                    -Replace ' $', '' -Split ' ' `
                    | ForEach-Object { $_ })
            [Byte[]] $FanTable = @(
                [Byte[]] $FanTableData `
                + [Byte[]] @($(New-Object Byte[] $(128 - $FanTableData.Length)))
            )
            Send-OmenBiosWmi -CommandType 0x32 -Data $FanTable
            # [Description Pending]
        }
        '-SetIdleOff' {
            Write-Information 'Set Idle Off'
            Send-OmenBiosWmi -CommandType 0x31 -Data @(0x00, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: 0x00 - Idle Off
        }
        '-SetIdleOn' {
            Write-Information 'Set Idle On'
            Send-OmenBiosWmi -CommandType 0x31 -Data @(0x01, 0x00, 0x00, 0x00) -OutputSize 4
            # Byte #0: 0x01 - Idle On
        }
        '-SetLedAnim' {
            Write-Information 'Set LED Animation'
            Write-Information '- Not Implemented'
            #Send-OmenBiosWmi -Command 0x20009 -CommandType 0x07 -Data $LedAnimTable
            # [Description Pending]
        }
        '-SetMemXmp' {
            Write-Information 'Set Memory to XMP Profile'
            Send-OmenBiosWmi -CommandType 0x19 -Data @(0x01, 0x00, 0x00, 0x00)
            # Byte #0: 0x01 - Idle On
        }
    }
}

# Terminate the CIM session
Remove-CimSession -CimSession $Session

# If not a single operation was attempted, display usage prompt
if(!$OperationAttempted) {
    Write-Host 'Omen Hardware Control Script - Version' $MyVersion
    Write-Host 'Usage:' $MyInvocation.MyCommand.Name`r`n `
' [-GetBornOnDate] [-GetOcSupport] [-GetSmartAdapterStatus] [-GetSysDesignData]'`r`n `
' [-GetFanCount] [-GetFanLevel] [-GetFanTable] [-GetFanType] [-GetMaxFanStatus]'`r`n `
' [-GetGfxMode] [-GetGpuStatus] [-GetTemp] [-GetThermalThrottlingStatus]'`r`n `
' [-GetBacklight] [-GetBacklightSupport] [-GetColorTable] [-GetKbdType] [-GetLedAnim]'`r`n `
' [-GetBiosUndervoltSupport] [-GetMemOcSupport] [-SetMemXmp] [-OmenKeyOff|-OmenKeyOn]'`r`n `
' [-BacklightOff|-BacklightOn] [-SetColor4 <RGB0:RGB1:RGB2:RGB3> (RGB#: 000000-FFFFFF)]'`r`n `
' [-MaxGpuPower|-MinGpuPower] [-MaxFanSpeedOff|-MaxFanSpeedOn] [-SetIdleOff|-SetIdleOn]'`r`n `
' [-SetFanLevel <00-FF:00-FF>] [-SetFanMode <00-FF>] [-SetFanTable <00-FF>+ (# < 128)]'`r`n `
' [-SetConcurrentCpuPower <0-254>] [-SetCpuPower <0-254>] [-SetCpuPowerMax <0-254>]'`r`n `
' [-SetLedAnim] [-Silent]'
}
