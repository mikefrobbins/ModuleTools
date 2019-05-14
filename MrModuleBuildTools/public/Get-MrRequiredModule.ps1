function Get-MrRequiredModule {
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
        [string[]]$Code,

        [switch]$Detailed
    )
    
    PROCESS{
        if (-not($PSBoundParameters.Detailed)) {
            (Get-MrFunctionRequirement -Path $Path |
             Select-Object -ExpandProperty RequiredModules -Unique).Name
        }
        else {
            $PSBoundParameters.Remove('Detailed')
            $AllAST = Get-MrAst @PSBoundParameters
            
            foreach ($AST in $AllAST){
                $FunctionDefinition = $AST.FindAll({$args[0].GetType().Name -like 'FunctionDefinitionAst'}, $true)
                $Commands = $AST.FindAll({$args[0].GetType().Name -like 'CommandAst'}, $true) | ForEach-Object {$_.CommandElements[0].Value} | Select-Object -Unique
                
                foreach ($Command in $Commands){
                    [pscustomobject]@{
                        Function = $FunctionDefinition.Name
                        Dependency = $Command
                        Module = (Get-Command -Name $Command -ErrorAction SilentlyContinue).Source
                    }
                }               
               
            }

        }
    }
}