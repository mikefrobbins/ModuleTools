#Requires -Version 3.0
function Out-MrCsv {
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
        $Results += foreach ($i in $InputObject) {
            "'{0}'" -f $i
        }
    }

    END {
        Write-Output "$($Results -join ',')"
    }

}