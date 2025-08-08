function Get-MrModuleStatusFromVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version,

        [string]$ModuleName
    )

    try {
        # Try to parse the version string using the [semver] type
        $semver = [semver]$Version
    } catch {
        # Return 'Unknown' if the version string is not a valid SemVer
        return 'Unknown'
    }

    # Get the prerelease label (null if not present)
    $label = $semver.PreReleaseLabel

    # Determine if the module is an Az module (Az, AzPreview, or Az.*)
    $isAzModule = $ModuleName -and (
        $ModuleName -eq 'Az' -or
        $ModuleName -eq 'AzPreview' -or
        $ModuleName -like 'Az.*'
    )

    # If a prerelease label exists, classify it
    if ($label) {
        switch -Regex ($label) {
            '^preview[\d\.]*$' {
                # For Az modules version >= 1.0.0 with preview label, return 'FeaturePreview'
                return ($isAzModule -and $semver.Major -ge 1) ? 'FeaturePreview' : 'Preview'
            }
            '^alpha[\d\.]*$' {return 'Alpha'}
            '^beta[\d\.]*$'  {return 'Beta'}
            '^rc[\d\.]*$'    {return 'ReleaseCandidate'}
            default          {return $label}
        }
    }

    # If no prerelease and version is < 1.0.0, consider it a preview
    if ($semver.Major -eq 0) {
        return 'Preview'
    }

    # Otherwise, it's a general availability (GA) release
    return 'GA'
}
