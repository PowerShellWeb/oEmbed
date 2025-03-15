#requires -Module PSDevOps
Import-BuildStep -SourcePath (
    Join-Path $PSScriptRoot 'GitHub'
) -BuildSystem GitHubWorkflow

Push-Location ($PSScriptRoot | Split-Path)
New-GitHubWorkflow -Name "oEmbed Module Build" -On Push,
    PullRequest, 
    Demand -Job  TestPowerShellOnLinux, 
    TagReleaseAndPublish, oEmbed -OutputPath .\.github\workflows\oEmbed-Build.yml

Pop-Location