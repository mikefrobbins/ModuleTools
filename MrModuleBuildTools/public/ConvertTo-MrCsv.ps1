#Requires -Version 3.0
function ConvertTo-MrCsv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$InputObject
    )

    BEGIN {
        $Results = @()
    }

    PROCESS {
        $Results += foreach ($Input in $InputObject) {
            "'{0}'" -f $Input
        }
    }

    END {
        Write-Output "$($Results -join ',')"
    }

}