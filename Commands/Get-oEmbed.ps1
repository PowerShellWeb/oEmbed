function Get-OEmbed {
    <#
    .SYNOPSIS
        Gets oEmbed data for a given URL.
    .DESCRIPTION
        Gets oEmbed data for a given URL.
        
        [oEmbed](https://oembed.com/) is a format for allowing an embedded representation of a URL on third party sites.

        Most social networks support oEmbed, so this little function lets you embed almost any social network post
    #>
    [Alias('oEmbed')]
    [CmdletBinding(PositionalBinding=$false,SupportsShouldProcess)]
    param(
    # The URL
    [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName,ParameterSetName='?url')]
    [Uri]
    $Url,
    
    # The maximum width of the returned image
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='?url')]
    [int]
    $MaxWidth,

    # The maximum height of the returned image
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='?url')]
    [int]
    $MaxHeight,    

    # The format of the returned image
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='?url')]
    [string]
    $Format,

    # Whether to force a refresh of the cached oEmbed data
    [Parameter(ValueFromPipelineByPropertyName,ParameterSetName='?url')]
    [switch]
    $Force,    

    [Parameter(Mandatory,ParameterSetName='ProviderByName')]
    [string]
    $ProviderName
    )

    begin  {
        # If we haven't yet cached the list of oEmbed providers, do so now.
        if (-not $script:cachedOmbedProviders) {
            $script:cachedOmbedProviders = Invoke-RestMethod "https://oembed.com/providers.json"
        }
        # If we haven't yet cached the list of oEmbed endpoints, do so now.
        if (-not $script:openEmbeddings) {
            $script:openEmbeddings = $script:cachedOmbedProviders.Endpoints.Url -as [uri[]]
        }
        # Create a cache to store the oEmbed data in, if we haven't already done so.
        if (-not $script:oEmbedUrlCache) {
            $script:oEmbedUrlCache = [Ordered]@{}
        }
    }
    
    process {
        # If we're asking for a Provider by Name
        if ($PSCmdlet.ParameterSetName -eq 'ProviderByName') {
            # filter the list of providers
            return $script:cachedOmbedProviders | 
                # and return the name
                Where-Object Provider_Name -like $ProviderName        
        }
        $topLevelDomain = $Url.DnsSafeHost.Split('.')[-2..-1] -join '.'
        $matchingEndpoint = 
            foreach ($endpoint in $script:openEmbeddings) {                
                if ($endpoint.DnsSafeHost -eq $topLevelDomain -or 
                    $endpoint.DnsSafeHost -like "*.$topLevelDomain") {
                    $endpoint
                    break
                }
            }
        
        if (-not $matchingEndpoint) { return }
        $oEmbedUrl = 
            "$($matchingEndpoint)?$(
                @(
                    "url=$([Web.HttpUtility]::UrlEncode($Url) -replace '\+','%20')"
                    if ($MaxWidth) {
                        "maxwidth=$MaxWidth"
                    }
                    if ($MaxHeight) {
                        "maxheight=$MaxHeight"
                    }                    
                    if ($Format) {
                        "format=$Format"
                    }
                ) -join '&'
            )"
        if (-not $script:oEmbedUrlCache[$oEmbedUrl] -or $Force) {
            $script:oEmbedUrlCache[$oEmbedUrl] = Invoke-RestMethod -Uri $oEmbedUrl |
                Add-Member NoteProperty 'Url' $Url -Force -PassThru |
                Add-Member NoteProperty 'oEmbedUrl' $oEmbedUrl -Force -PassThru
            $script:oEmbedUrlCache[$oEmbedUrl].pstypenames.insert(0,'OpenEmbedding')
        }
        $script:oEmbedUrlCache[$oEmbedUrl]
        
    }
}
