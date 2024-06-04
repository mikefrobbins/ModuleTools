function Get-MrModuleDependency {

<#
.SYNOPSIS
    Retrieves the dependent modules of a specified PowerShell module(s).

.DESCRIPTION
    The Get-MrModuleDependency function retrieves the dependent modules for the specified
    PowerShell module(s). It fetches the module's dependency information from the hidden
    PSGetModuleInfo.xml file if available.

.PARAMETER Name
    The name of the module(s) to check for dependencies. Defaults to 'Az'.

.EXAMPLE
    Get-MrModuleDependency -Name Az, AzPreview

.EXAMPLE
    'Az', 'AzPreview' | Get-MrModuleDependency

.EXAMPLE
    Get-Module -Name Az, AzPreview -ListAvailable | Get-MrModuleDependency

.NOTES
    Author:  Mike F. Robbins
    Website: https://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ModuleName')]
        [string[]]$Name = 'Az'
    )

    PROCESS {

        foreach ($module in $Name) {

            Write-Verbose -Message "Attempting to locate module: '$module' on the local system."

            $modulePath = Get-Module -Name $module -ListAvailable |
            Sort-Object -Property Version -Descending |
            Select-Object -First 1 -ExpandProperty ModuleBase
        
            try {
                Write-Verbose -Message "Attempting to read the module's hidden xml file."

                $moduleInfo = Import-Clixml -Path (Join-Path -Path $modulePath -ChildPath PSGetModuleInfo.xml) -ErrorAction Stop
            } catch {
                Write-Warning -Message "Module: '$module' not found or wasn't installed with Install-Module or Install-PSResource."
            }
            
            foreach ($dependency in $moduleInfo.Dependencies){
                if ($null -ne $dependency.RequiredVersion) {
                    $moduleVersion = $dependency.RequiredVersion
                } elseif ($null -ne $dependency.MinimumVersion) {
                    $moduleVersion = $dependency.MinimumVersion
                } else {
                    $moduleVersion = $dependency.VersionRange.MinVersion.OriginalVersion
                }
                
                [pscustomobject]@{
                    Name = $moduleInfo.Name
                    Module = $dependency.Name
                    Version = $moduleVersion
                    Status = if ($moduleVersion -ge 1) {'GA'} else {'Preview'}
                }
            }
        
        }

    }

}
