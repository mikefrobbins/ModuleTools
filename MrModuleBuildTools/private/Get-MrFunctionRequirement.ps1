function Get-MrFunctionRequirement {
    [CmdletBinding(DefaultParameterSetName='File')]
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'File',
                   Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('FilePath')]
        [string[]]$Path = ('.\*.ps1', '.\*.psm1'),

        [Parameter(ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'Code',
                   Position = 0)]
        [ValidateNotNull()]
        [Alias('ScriptBlock')]
        [string[]]$Code
    )

    PROCESS {
        if ($PSBoundParameters.Path) {
            Write-Verbose 'Path'
            $Results = Get-MrAST -Path $Path
        }
        elseif ($PSBoundParameters.Code) {
            Write-Verbose 'Code'
            $Results = Get-MrAST -Code $Code
        }
        else {
            Write-Verbose -Message 'Valid input not received.'
        }
        
        $Results | Select-Object -ExpandProperty ScriptRequirements | Sort-Object -Property * -Unique
    }

}