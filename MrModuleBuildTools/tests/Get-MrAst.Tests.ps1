$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'tests', 'public'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
if (-not (Test-Path -Path "$here\$sut" -PathType Leaf)) {
    $here -replace 'public', 'private'
}
. "$here\$sut"

Import-Module ..\MrModuleBuildTools.psd1 -Force

InModuleScope MrModuleBuildTools {
    $Files = '..\private\Get-MrAstType.ps1', '..\private\Get-MrFunctionRequirement.ps1'
    $Directory = '..\private'
    $FilesByName = $Files | ForEach-Object {New-Object -TypeName PSObject -Property @{'Path' = $_}}
    $DirectoryByName = New-Object -TypeName PSObject -Property @{'Path' = $Directory}

    $Code = Get-Content -Path $Files -Raw
    $CodeByName = $Code | ForEach-Object {New-Object -TypeName PSObject -Property @{'Code' = $_}}

    $ScriptBlock = ConvertTo-MrScriptBlock -Path $Files
    $ScriptBlockByName = $ScriptBlock | ForEach-Object {New-Object -TypeName PSObject -Property @{'ScriptBlock' = $_}}

    Describe 'the existence of the Get-MrAst private function dependency' {
        It 'Tests the Get-MrAstType Private function' {
            Get-MrAstType | Should -Not -BeNullOrEmpty
        }
    }

    Describe 'the Path parameter' {

        Context 'Testing via parameter input' {

            It 'Works with a single file' {
                (Get-MrAst -Path $Files[0]).ScriptRequirements.RequiredPSVersion.Major |
                Should -BeGreaterThan 2
            }
            It 'Works with multiple files' {
                (Get-MrAst -Path $Files).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with a directory' {
                (Get-MrAst -Path $Directory).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                (Get-MrAst -Path $Files[0] -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }
            It 'Does not work with the Code parameter' {
                {Get-MrAst -Path $Files -Code $Code} |
                Should -Throw
            }
            It 'Does not work with the ScriptBlock parameter' {
                {Get-MrAst -Path $Files -ScriptBlock $ScriptBlock} |
                Should -Throw
            }

        }

        Context 'Testing via pipeline input by value (by type)' {

            It 'Accepts a single file' {
                ($Files[0] | Get-MrAst).ScriptRequirements.RequiredPSVersion.Major |
                Should -BeGreaterThan 2
            }
            It 'Accepts multiple files' {
                ($Files | Get-MrAst).Count |
                Should -Be 2
            }
            It 'Accepts a directory' {
                ($Directory | Get-MrAst).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                ($Files[0] | Get-MrAst -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }

        }

        Context 'Testing via pipeline input by property name' {

            It 'Accepts a single file' {
                ($FilesByName[0] | Get-MrAst).ScriptRequirements.RequiredPSVersion.Major |
                Should -BeGreaterThan 2
            }
            It 'Accepts multiple files' {
                ($FilesByName | Get-MrAst).Count |
                Should -BeGreaterThan 1
            }
            It 'Accepts a directory via pipeline input' {
                ($DirectoryByName | Get-MrAst).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                ($FilesByName | Get-MrAst -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }

        }

    }

    Describe "the Code Parameter" {

        Context 'Testing via parameter input' {

            It 'Works with a single block of code' {
                (Get-MrAst -Code $Code[0]).ScriptRequirements.RequiredPSVersion.Major | Should -BeGreaterThan 2
            }
            It 'Works with multiple blocks of code' {
                (Get-MrAst -Code $Code).Count | Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                (Get-MrAst -Code $Code[0] -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }
            It 'Does not work with the Path parameter' {
                {Get-MrAst -Code $Code -Path $Files} |
                Should -Throw
            }
            It 'Does not work with the ScriptBlock parameter' {
                {Get-MrAst -Code $Code -ScriptBlock $ScriptBlock} |
                Should -Throw
            }
        }

        Context 'Testing via pipeline input by property name' {

            It 'Works accepts multiple blocks of code' {
                ($CodeByName | Get-MrAst).Count | Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                ($CodeByName | Get-MrAst -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }

        }

    }

    Describe 'the ScriptBlock Parameter' {

        Context 'Testing via parameter input' {

            It 'Works with a single block of code' {
                (Get-MrAst -ScriptBlock $ScriptBlock[0]).ScriptRequirements.RequiredPSVersion.Major |
                Should -BeGreaterThan 2
            }
            It 'Works with multiple blocks of code' {
                (Get-MrAst -ScriptBlock $ScriptBlock).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                (Get-MrAst -ScriptBlock $ScriptBlock -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }
            It 'Does not work with the Path parameter' {
                {Get-MrAst -ScriptBlock $ScriptBlock -Path $Files} |
                Should -Throw
            }
            It 'Does not work with the ScriptBlock parameter' {
                {Get-MrAst -ScriptBlock $ScriptBlock -Code $Code} |
                Should -Throw
            }
            It 'Does not work with input type other than script block' {
                {Get-MrAst -ScriptBlock $Code} |
                Should -Throw
            }

        }

        Context 'Testing via pipeline input by property name' {

            It 'Works accepts multiple script blocks' {
                ($ScriptBlockByName | Get-MrAst).Count |
                Should -BeGreaterThan 1
            }
            It 'Works with the AstType parameter' {
                ($ScriptBlockByName | Get-MrAst -AstType FunctionDefinition).Extent.Text |
                Should -Not -BeNullOrEmpty
            }

        }
        
    }

}
