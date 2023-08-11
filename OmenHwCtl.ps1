
# OmenHwCtl.ps1

# Adjust HP Omen hardware settings with no
# need for HP Omen Game Hub (Command Center)

# Suppress console output if running in silent mode
param ([Switch] $Silent = $False)
If(!$Silent) { $InformationPreference = 'Continue' }

$MyVersion = '2023-08-11'

# Set-OmenBiosWmi()
# Makes a WMI call to set BIOS data:
# this is where all the magic happens
Function Set-OmenBiosWmi {

    # Parameters & validation
    param (

         # Mostly constant identifier (observed: 131080 or 131081)
         [ValidateNotNullOrEmpty()] [UInt32] $Command = 0x20008,

         # The actual operation to perform
         [Parameter(Mandatory)] [UInt32] $CommandType,

         # Data payload to be transmitted
         [Parameter(Mandatory)] [Byte[]] $Data,

         # Pre-defined shared secret for authorization (observed: 83, 69, 67, 85)
         [ValidateNotNullOrEmpty()] [Byte[]] $Sign = @(0x53, 0x45, 0x43, 0x55),

         # Method choice depends on the amount of data to be returned
         [ValidateSet('0', '4', '128', '1024', '4096')] [String] $OutputSize = '0'
    )

    # Prepare the data to be written
    $BiosDataIn = New-CimInstance -ClassName 'hpqBDataIn' -ClientOnly -Namespace 'root\wmi' -Property @{
        Command = $Command;
        CommandType = $CommandType;
        hpqBData = $Data;
        Size = [UInt32] $Data.Length;
        Sign = $Sign;
    }

    # Start a CIM session and obtain BIOS method class instance
    $Session = New-CimSession -Name 'hpq' -SkipTestConnection
    $BiosMethods = Get-CimInstance -ClassName 'hpqBIntM' -CimSession $Session -Namespace 'root\wmi'

    # Make a call to write to the BIOS
    $Result = Invoke-CimMethod -InputObject $BiosMethods -MethodName ('hpqBIOSInt' + $OutputSize) -Arguments @{InData = [CimInstance] $BiosDataIn}

    # Terminate the session
    Remove-CimSession -CimSession $Session

    # Return true if successful, false otherwise
    Return $(If($Result.ReturnValue -and $Result.OutData.rwReturnCode -eq 0) { $True } Else { $False })
}

# Show-OmenHwCtlResult()
# Display whether the operation succeeded or failed
# (unless running in silent mode)
Function Show-OmenHwCtlResult {
    param ([Parameter(ValueFromPipeline = $True)] [ValidateNotNullOrEmpty()] [Switch] $Result)
    Set-Variable -Name OperationAttempted -Scope Global -Value $True
    Write-Information $(If($Result) { '+ OK' } Else { '- Failed' })
}

# Iterate through arguments and perform operations accordingly
$NextArg = 0
ForEach($Arg in $Args) {
    $NextArg++
    Switch($Arg) { 
        '-MaxFanSpeedOff' {
            Write-Information 'Set Maximum Fan Speed Off'
            Set-OmenBiosWmi -CommandType 0x27 -Data 0x00 | Show-OmenHwCtlResult
        }
        '-MaxFanSpeedOn' {
            Write-Information 'Set Maximum Fan Speed On'
            Set-OmenBiosWmi -CommandType 0x27 -Data 0x01 | Show-OmenHwCtlResult
        }
        '-MaxGpuPower' {
            Write-Information 'Set Maximum GPU Power'
            Set-OmenBiosWmi -CommandType 0x22 -Data @(0x01, 0x01, 0x01, 0x57) | Show-OmenHwCtlResult
        }
        '-MinGpuPower' {
            Write-Information 'Set Minimum GPU Power'
            Set-OmenBiosWmi -CommandType 0x22 -Data @(0x00, 0x00, 0x01, 0x00) | Show-OmenHwCtlResult
        }
        '-SetConcurrentCpuPower' {
            $Value = [byte] $Args[$NextArg]
            Write-Information $('Set Concurrent CPU Power Limit to: ' + $Value + 'W')
            Set-OmenBiosWmi -CommandType 0x29 -Data @(0xFF, 0xFF, 0xFF, $Value) | Show-OmenHwCtlResult
        }
        '-SetCpuPower' {
            $Value = [byte] $Args[$NextArg]
            Write-Information $('Set CPU Power Limit to: ' + $Value + 'W')
            Set-OmenBiosWmi -CommandType 0x29 -Data @($Value, $Value, 0xFF, 0xFF) | Show-OmenHwCtlResult
        }
    } 
}

# If not a single operation was attempted, display usage prompt
if(!$OperationAttempted) {
    Write-Host 'Omen Hardware Control Script - Version' $MyVersion
    Write-Host 'Usage:' $MyInvocation.MyCommand.Name`r`n' [-MaxFanSpeedOff|-MaxFanSpeedOn]'`r`n' [-MaxGpuPower|-MinGpuPower]' `r`n '[-SetConcurrentCpuPower <0-255>] [-SetCpuPower <0-255>]'`r`n' [-Silent]'
}
