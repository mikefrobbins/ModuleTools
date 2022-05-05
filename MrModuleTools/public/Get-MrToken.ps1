function Get-MrToken {
    [CmdletBinding(DefaultParameterSetName='File')]
    param (
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName = 'File',
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('FilePath', 'FileName')]
        [string[]]$Path = ('.\*.ps1', '.\*.psm1'),

        [Parameter(ValueFromPipelineByPropertyName,
                   ParameterSetName = 'Code',
                   Position = 0)]
        [ValidateNotNull()]
        [Alias('Script', 'ScriptBlock')]
        [string[]]$Code,

        [Parameter(Position=1)]
        [System.Management.Automation.Language.TokenKind]$Kind,

        [Parameter(Position=2)]
        [Alias('TokenFlag')]
        [System.Management.Automation.Language.TokenFlags]$Flag
    )

    BEGIN {        
        $Errors = $null
        $Token = $null
        $Tokens = $null
    }

    PROCESS {
        if ($PsBoundParameters.Code) {
            $null = [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$Tokens, [ref]$Errors)
        }
        else {
            $Files = Get-ChildItem -Path $Path | Select-Object -ExpandProperty FullName
            foreach ($File in $Files) {
                $null = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$Token, [ref]$Errors)
                $Tokens += $Token
            }
        }
        
        switch ($PsBoundParameters) {
            {$_.Keys -contains 'Kind'} {$Tokens = $Tokens |  Where-Object {$_.Kind -eq $Kind}}
            {$_.Keys -contains 'Flag'} {$Tokens = $Tokens | Where-Object {$_.TokenFlags -eq $Flag}}
        }

        Write-Output $Tokens

    }

}