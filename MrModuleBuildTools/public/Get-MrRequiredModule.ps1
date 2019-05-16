#Requires -Version 3.0
function Get-MrRequiredModule {

<#
.SYNOPSIS
    Gets a list of the required modules.
 
.DESCRIPTION
    Get-MrRequiredModule is an advanced function that returns a list of the required module dependencies from one or more
    PS1 and/or PSM1 files.
 
 .PARAMETER Path
    Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory.

.PARAMETER Code
    The code to get the required modules for. If Get-Content is being used to obtain the code, use its -Raw parameter
    otherwise the formating of the code will be lost.

.PARAMETER Detailed
    Return a detailed list of all of the modules including built-in modules that are required. This option does not
    reply on a Requires statement.
 
.EXAMPLE
     Get-MrRequiredModule -Path 'C:\Scripts'

.EXAMPLE
     Get-MrRequiredModule -Code 'function Get-PowerShellProcess {Get-Process -Name PowerShell}' -Detailed
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>    

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
            $PSBoundParameters.Remove('Detailed') | Out-Null
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