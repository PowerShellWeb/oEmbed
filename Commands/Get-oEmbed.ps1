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
    [CmdletBinding(PositionalBinding=$false,SupportsShouldProcess,DefaultParameterSetName='?url')]
    param(
    # The URL
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='?url')]
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

    # The name of an oEmbed provider.  Wildcards are supported.
    [Parameter(Mandatory,ParameterSetName='ProviderByName')]
    [SupportsWildcards()]
    [string]
    $ProviderName,

    # If set, will list the oEmbed providers.
    [Parameter(Mandatory,ParameterSetName='ProviderList')]
    [switch]
    $ProviderList
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

        if (-not $script:oEmbedDomainCache) {
            $script:oEmbedDomainCache = [Ordered]@{}
        }

        $oEmbedQueue = [Collections.Queue]::new()
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'ProviderList') {
            return $script:cachedOmbedProviders
        }
        # If we're asking for a Provider by Name
        if ($PSCmdlet.ParameterSetName -eq 'ProviderByName') {
            # filter the list of providers
            return $script:cachedOmbedProviders | 
                # and return the name
                Where-Object Provider_Name -like $ProviderName        
        }        
        $matchingEndpoint = 
            if (-not $script:oEmbedDomainCache[$url.DnsSafeHost]) {
                :oEmbedProvider foreach ($oEmbedProvider in $script:cachedOmbedProviders) {
                    foreach ($oEmbedEndpoint in $oEmbedProvider.Endpoints) {
                        foreach ($oEmbedScheme in $oEmbedEndpoint.Schemes) {
                            if ($url -like $oEmbedScheme) {
                                $script:oEmbedDomainCache[$url.DnsSafeHost] = $oEmbedEndpoint.url
                                $script:oEmbedDomainCache[$url.DnsSafeHost]
                                break oEmbedProvider
                            }
                        }
                    }                
                }
            } else {
                $script:oEmbedDomainCache[$url.DnsSafeHost]
            }
            
        
        if (-not $matchingEndpoint) {
            Write-Error "No oEmbed Provider found for URL '$url'"
            return
        }        

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

        $oEmbedQueue.Enqueue([Ordered]@{
            Url = $Url
            oEmbedUrl = $oEmbedUrl
        })        
    }

    end {        
        $counter = 0
        $total = $oEmbedQueue.Count
        $progressId = $MyInvocation.HistoryId
        foreach ($queueItem in $oEmbedQueue) {
            $url = $queueItem.Url
            $oEmbedUrl = $queueItem.oEmbedUrl
            if ($oEmbedQueue.Count -gt 1) {
                $counter++
                Write-Progress "oEmbed" "Retrieving oEmbed data for $url" -PercentComplete (
                    $counter * 100 / $total
                ) -Id $progressId
            }
            if (-not $script:oEmbedUrlCache[$oEmbedUrl] -or $Force) {
                $script:oEmbedUrlCache[$oEmbedUrl] = Invoke-RestMethod -Uri $oEmbedUrl |
                    Add-Member NoteProperty 'Url' $Url -Force -PassThru |
                    Add-Member NoteProperty 'oEmbedUrl' $oEmbedUrl -Force -PassThru
                $script:oEmbedUrlCache[$oEmbedUrl].pstypenames.insert(0,'OpenEmbedding')
            }
    
            
            $script:oEmbedUrlCache[$oEmbedUrl]        
        }

        if ($oEmbedQueue.Count -gt 1) {
            Write-Progress "oEmbed" "Retrieving oEmbed data" -Completed -Id $progressId
        }
    }
}
