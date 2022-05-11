#Requires -Version 4.0
function Get-MrVariableType {

<#
.SYNOPSIS
    List variables and whether they're defined as parameters or in the body of a function.

.DESCRIPTION
    Get-MrVariableType is an advanced function that returns a list of variables defined in a
    function and whether they are parameters or user defined within the body of the function.

 .PARAMETER Ast
    Provide a ScriptBlockAst object via parameter or pipeline input. Use Get-MrAst to create this
    object.

.EXAMPLE
     Get-MrAST -Path 'C:\Scripts' | Get-MrVariableType

.EXAMPLE
     Get-MrVariableType -Ast (Get-MrAST -Path 'C:\Scripts')

.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline)]
        [System.Management.Automation.Language.ScriptBlockAst]$Ast
    )

    PROCESS {

        $variables = $Ast.FindAll({$args[0].GetType().Name -like 'VariableExpressionAst'}, $true).Where({$_.VariablePath.UserPath -ne '_'})

        $parameters = $Ast.FindAll({$args[0].GetType().Name -like 'ParameterAst'}, $true)

        $diff = Compare-Object -ReferenceObject $parameters.Name.VariablePath.UserPath -DifferenceObject $variables.VariablePath.UserPath -IncludeEqual

        foreach ($variable in $variables) {

            [pscustomobject]@{
                Name = $variable.VariablePath.UserPath
                Type = if ($variable.VariablePath.UserPath -in $diff.Where({$_.SideIndicator -eq '=='}).InputObject) {
                           'Parameter'
                       } else {
                           'UserDefined'
                       }
                LineNumber = $variable.Extent.StartLineNumber
                Column = $variable.Extent.StartColumnNumber
            }

        }

    }

}