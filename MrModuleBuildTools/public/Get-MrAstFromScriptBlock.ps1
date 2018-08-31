#Requires -Version 3.0
function Get-MrAstFromScriptBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments)]
        [Alias('Script', 'Code')]
        [scriptblock[]]$ScriptBlock
    )

    DynamicParam {
        $ParameterName = 'AstType'
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Position = 0
        $AttributeCollection.Add($ParameterAttribute) 
        $ValidationValues = Get-MrAstType -Simple
        $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute($ValidationValues)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        $RuntimeParameterDictionary
    }
    
    BEGIN {
        $AstType = $PsBoundParameters[$ParameterName]
    }

    PROCESS {        
        if ($PsBoundParameters.AstType) {
            Write-Output $ScriptBlock.Ast.FindAll({$args[0].GetType().Name -like "*$ASTType*Ast"}, $true)
        }
        else {
            Write-Output $ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $false)
        }
    }
}