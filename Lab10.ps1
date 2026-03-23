<#                                                                  
.SYNOPSIS
    Brief description of what the script does.

.DESCRIPTION
    Detailed explanation of the script's purpose, functionality, and any important notes.

.PARAMETER <ParameterName>
    Description of the parameter.

.EXAMPLE
    Example usage:
    PS> .\MyScript.ps1 -Param1 Value1

.NOTES
    Author: Elliot Burwood, Jackson Nguyen, Mohammmad Sharif
    Created: 3/17/2026
    Version: 1.0
    Last Modified: 3/17/2026

.LINK
    https://link-to-related-docs-or-repo
#>

Function Get-GPO {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$gpoName,

        [Parameter(Mandatory)]
        [String]$ouPath
    )

    Write-Host "Step 1"
    $gpo = New-GPO -Name $gpoName -Comment "Security settings for computer"

    Write-Host "Step 2"
    New-GPLink -Name $gpo.DisplayName -Target $ouPath -LinkEnabled Yes -Enforced $true

    Write-Host "Step 3"
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
        -ValueName "NoControlPanel" -Type DWord -Value 1

    Write-Host "Step 4"
    Set-GPRegistryValue -Name $gpoName `
        -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
        -ValueName "DisableCMD" -Type DWord -Value 1

    Write-Host "Step 5"
    Set-GPPermission -Name $gpoName -TargetName "Authenticated Users" `
        -TargetType Group -PermissionLevel None

    Write-Host "Step 6"
    Set-GPPermission -Name $gpoName -TargetName "CustSrv" `
        -TargetType Group -PermissionLevel GpoApply

    Write-Host "Step 7"
    Get-GPPermission -Name $gpoName -All |
        Format-Table Trustee, Permission -AutoSize

    Write-Host "Step 8:"
    $reportDir = "C:\GPO-Reports"
    New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

    Get-GPOReport -Name $gpoName -ReportType Html -Path "$reportDir\Secure-Computers.html"
    Get-GPOReport -Name $gpoName -ReportType Xml  -Path "$reportDir\Secure-Computers.xml"

    Write-Host "Reports saved to $reportDir"

    return $gpo
}
