@{
    RootModule = 'oEmbed.psm1'
    ModuleVersion = '0.0.1'
    GUID = 'dc68bf0c-b8b5-4f3d-9fc4-b6779f7e7d6a'
    Author = 'JamesBrundage'
    CompanyName = 'Start-Automating'
    Copyright = '(c) 2025 Start-Automating.'
    Description = 'Open Embeddings in PowerShell'
    FunctionsToExport = 'Get-oEmbed'
    AliasesToExport = 'oEmbed'
    TypesToProcess = 'oEmbed.types.ps1xml'    
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('oEmbed','Embedding','Web','PowerShellWeb')
            # A URL to the license for this module.
            ProjectURI = 'https://github.com/PowerShellWeb/oEmbed'
            LicenseURI = 'https://github.com/PowerShellWeb/oEmbed/blob/main/LICENSE'
            ReleaseNotes = @'

> Like It? [Star It](https://github.com/PowerShellWeb/oEmbed)
> Love It? [Support It](https://github.com/sponsors/StartAutomating)

Embed content from anywhere on the internet

## oEmbed 0.0.1

* Initial Release of oEmbed Module (#1)
  * `Get-oEmbed` gets embed content (#2)
  * `Get-oEmbed` is aliased to `oEmbed`
'@
        }
    }
    
}

