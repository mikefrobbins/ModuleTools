#Requires -Version 3.0
function Get-MrAstType {
    [CmdletBinding()]
    param ()

    ([System.Management.Automation.Language.ArrayExpressionAst].Assembly.GetTypes() |
    Where-Object {$_.Name.EndsWith('Ast') -and $_.Name -ne 'Ast'}).Name -replace 'Ast$' |
    Sort-Object -Unique

}