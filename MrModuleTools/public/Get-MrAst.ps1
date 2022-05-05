﻿#Requires -Version 3.0
function Get-MrAst {

<#
.SYNOPSIS
    Explores the Abstract Syntax Tree (AST).
 
.DESCRIPTION
    Get-MrAST is an advanced function that provides a mechanism for exploring the Abstract Syntax Tree (AST).
 
 .PARAMETER Path
    Specifies a path to one or more locations. Wildcards are permitted. The default location is the current directory.

.PARAMETER Code
    The code to view the AST for. If Get-Content is being used to obtain the code, use its -Raw parameter otherwise
    the formating of the code will be lost.

.PARAMETER ScriptBlock
    An instance of System.Management.Automation.ScriptBlock Microsoft .NET Framework type to view the AST for.

.PARAMETER AstType
    The type of object to view the AST for. If this parameter is ommited, only the top level ScriptBlockAst is returned.
 
.EXAMPLE
     Get-MrAST -Path 'C:\Scripts' -AstType FunctionDefinition

.EXAMPLE
     Get-MrAST -Code 'function Get-PowerShellProcess {Get-Process -Name PowerShell}'

.EXAMPLE
     Get-MrAST -ScriptBlock ([scriptblock]::Create('function Get-PowerShellProcess {Get-Process -Name PowerShell}'))
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'Path',
                   Position = 1)]
        [ValidateNotNull()]
        [Alias('FilePath')]
        [string[]]$Path = ('.\*.ps1', '.\*.psm1'),

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'Code')]
        [string[]]$Code,

        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments,
                   ParameterSetName = 'ScriptBlock')]
        [scriptblock[]]$ScriptBlock
    )
 
    DynamicParam {
        $ParameterAttribute = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Position = 0

        $ValidationValues = Get-MrAstType
        $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute($ValidationValues)

        $AttributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollection.Add($ParameterAttribute)
        $AttributeCollection.Add($ValidateSetAttribute)

        $ParameterName = 'AstType'
        $RuntimeParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)            
            
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary            
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        $RuntimeParameterDictionary
    }

    BEGIN {
        $AstType = $PsBoundParameters[$ParameterName]
    }

    PROCESS {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                Write-Verbose -Message 'Path Parameter Set Selected'
                Write-Verbose "Path contains $Path"
                
                $Files = Get-ChildItem -Path $Path -Exclude *tests.ps1, *profile.ps1 |
                         Select-Object -ExpandProperty FullName
                
                if (-not ($Files)) {
                    Write-Warning -Message 'No valid files found.'
                    Return
                }

                $AST = foreach ($File in $Files) {
                    [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$null, [ref]$null)
                }

                break
            }
            'Code' {
                Write-Verbose -Message 'Code Parameter Set Selected'

                $AST = foreach ($c in $Code) {
                    [System.Management.Automation.Language.Parser]::ParseInput($c, [ref]$null, [ref]$null)
                }

                break
            }
            'ScriptBlock' {
                Write-Verbose -Message 'ScriptBlock Parameter Set Selected'
                
                $AST = $ScriptBlock.Ast
                
                break
            }
            default {
                Write-Warning -Message 'An unexpected error has occurred'
            }
        }

        if ($PsBoundParameters.AstType) {
            Write-Verbose -Message 'AstType Parameter Entered'
            
            $AST = $AST.FindAll({$args[0].GetType().Name -like "$($ASTType)Ast"}, $true)
        }

        Write-Output $AST
    }

}