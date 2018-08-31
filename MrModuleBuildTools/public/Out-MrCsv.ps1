#Requires -Version 3.0
function Out-MrCsv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [string[]]$Input
    )

    BEGIN {
        $Results = @()
    }

    PROCESS {
        $Results += foreach ($i in $Input) {
            "'{0}'" -f $i
        }
    }

    END {
        Write-Output "$($Results -join ',')"
    }

}