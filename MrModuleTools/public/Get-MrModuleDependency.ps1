function Get-MrModuleDependency {

<#
.SYNOPSIS
    Retrieves the dependent modules of specified PowerShell module(s).

.DESCRIPTION
    Retrieves dependencies from the PSGetModuleInfo.xml file (created when a module is installed
    via Install-Module or Install-PSResource). Returns dependent module name, version, and status
    (GA, Preview, featurepreview, etc.), based on semantic versioning.

.PARAMETER Name
    One or more module names to inspect for dependencies. Defaults to 'Az'.

.EXAMPLE
    Get-MrModuleDependency -Name Az, AzPreview

.EXAMPLE
    'Az', 'AzPreview' | Get-MrModuleDependency

.EXAMPLE
    Get-Module -Name Az, AzPreview -ListAvailable | Get-MrModuleDependency

.NOTES
    Author:  Mike F. Robbins
    Website: https://mikefrobbins.com/
#>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ModuleName')]
        [string[]]$Name = 'Az'
    )

    process {
        foreach ($module in $Name) {

            Write-Verbose "Searching for module: '$module' on the local system."

            # Get the latest installed version of the module
            $modulePath = Get-Module -Name $module -ListAvailable |
                          Sort-Object -Property Version -Descending |
                          Select-Object -First 1 -ExpandProperty ModuleBase

            if (-not $modulePath) {
                Write-Warning -Message "Module '$module' not found on this system."
                continue
            }

            $moduleInfoPath = Join-Path -Path $modulePath -ChildPath 'PSGetModuleInfo.xml'

            if (-not (Test-Path -Path $moduleInfoPath -PathType Leaf)) {
                Write-Warning -Message "No 'PSGetModuleInfo.xml' found for module '$module'. Possibly not installed using 'Install-Module' or 'Install-PSResource'."
                continue
            }

            try {
                $moduleInfo = Import-Clixml -Path $moduleInfoPath -ErrorAction Stop
            } catch {
                Write-Warning -Message "Failed to read dependency info for module '$module': $_"
                continue
            }

            foreach ($dependency in $moduleInfo.Dependencies) {

                # Determine the version from the dependency metadata
                $moduleVersion =
                    $dependency.RequiredVersion ??
                    $dependency.MinimumVersion ??
                    $dependency.VersionRange.MinVersion.OriginalVersion

                # Output the dependency object with status info
                [pscustomobject]@{
                    Name    = $moduleInfo.Name
                    Module  = $dependency.Name
                    Version = $moduleVersion
                    Status  = Get-MrModuleStatusFromVersion -Version $moduleVersion -ModuleName $dependency.Name
                }
            }
        }
    }
}
