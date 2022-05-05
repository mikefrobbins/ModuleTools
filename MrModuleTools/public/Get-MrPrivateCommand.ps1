﻿#Requires -Version 3.0
function Get-MrPrivateCommand {

<#
.SYNOPSIS
    Returns a list of private (unexported) commands from the specified module or snap-in.
 
.DESCRIPTION
    Get-MrPrivateFunction is an advanced function that returns a list of private commands
    that are not exported from the specified module or snap-in.
 
.PARAMETER Module
    Specify the name of a module. Enter the name of a module or snap-in, or a snap-in or module
    object. This parameter takes string values, but the value of this parameter can also be a
    PSModuleInfo or PSSnapinInfo object, such as the objects that the Get-Module, Get-PSSnapin,
    and Import-PSSession cmdlets return.
 
.EXAMPLE
     Get-MrPrivateCommand -Module Pester
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('PSSnapin')]
        [string]$Module
    )

    if (-not((Get-Module -Name $Module -OutVariable ModuleInfo))){
        try {
            $ModuleInfo = Import-Module -Name $Module -Force -PassThru -ErrorAction Stop
        }
        catch {
            Write-Warning -Message "$_.Exception.Message"
            Break
        }
    }

    $Global:ModuleName = $Module

    $All = $ModuleInfo.Invoke({Get-Command -Module $ModuleName -All})
    
    $Exported = (Get-Module -Name $Module -All).ExportedCommands |
                Select-Object -ExpandProperty Values

    if ($All -and $Exported) {
        Compare-Object -ReferenceObject $All -DifferenceObject $Exported |
        Select-Object -ExpandProperty InputObject |
        Add-Member -MemberType NoteProperty -Name Visibility -Value Private -Force -PassThru
    }    
}