param (
    [string]$Module = 'MrModuleBuildTools'
)

$CommandName = $MyInvocation.MyCommand.Name.Replace('.Tests.ps1', '')
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path) -replace 'Tests', 'Public'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-MrPrivateCommand' {
    
    if (-not(Get-MrPrivateCommand -Module $Module -OutVariable PrivateCommands)){
        Write-Host -Object "Aborting tests! No private commands found for module '$Module'." -ForegroundColor Cyan
        Break
    }
    else {
        Write-Host -Object "Testing $($PrivateCommands.Count) private commands for module '$Module'." -ForegroundColor Cyan
    }

    Context "Testing module '$Module' with Get-Command" {
        $PrivateCommands |
        ForEach-Object {
            It "Doesn't export the $($_.Name) $($_.CommandType)" {
                Get-Command -Name $_.Name -Module $_.Source -ErrorAction SilentlyContinue |
                Should -BeNullOrEmpty
            } 
        }
    }
    
    Context "Testing module '$Module' with Get-Module" {
        $PrivateCommands |
        ForEach-Object {
            It "Doesn't export the $($_.Name) $($_.CommandType)" {
                (Get-Module -Name dbatools -All).ExportedCommands.Values |
                Where-Object Name -eq $_.Name |
                Should -BeNullOrEmpty
            }
        }
    }
    
}
