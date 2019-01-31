param (
    [string]$Module = 'MrModuleBuildTools'
)

$CommandName = $MyInvocation.MyCommand.Name.Replace('.Tests.ps1', '')
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'Tests', 'Public'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-MrPrivateCommand' {
    It "Doesn't return any public functions" {
        Get-MrPrivateCommand -Module $Module |
        ForEach-Object {
            Get-Command -Name $_.Name -ErrorAction SilentlyContinue -Module $_.Source
        } |
        Should -BeNullOrEmpty
    }
}
