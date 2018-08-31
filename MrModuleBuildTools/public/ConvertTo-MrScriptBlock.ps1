#Requires -Version 3.0
function ConvertTo-MrScriptBlock {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [ValidateScript({
            If (Test-Path -Path $_) {
                $true
            }
            else {
                Throw "'$_' is not valid."
            }
        })]
        [Alias('FilePath', 'FileName')]
        [string[]]$Path = ('.\*.ps1', '.\*.psm1')
    )

    PROCESS {
        $Files = Get-ChildItem -Path $Path -Exclude *tests.ps1, *profile.ps1 |
                 Select-Object -ExpandProperty FullName
        foreach ($File in $Files) {
            $Content = Get-Content -Path $File | Out-String
            try {
                [scriptblock]::Create($Content)
            }
            catch {
                Write-Warning -Message 'An error occurred'
            }
               
        }               
    }
}

