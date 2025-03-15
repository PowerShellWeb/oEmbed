# oEmbed

Open Embedding with PowerShell


## The oEmbed Standard

There's lots of content on the internet.  How do we embed it?


Over the years, most large sites seem to have agreeded on a standard or two.

[oEmbed](https://oEmbed.com/) is one such standard.

## The oEmbed module

This is a PowerShell module for oEmbed.

It lets you get open embeddings for any url that supports the [oEmbed standard](https://oEmbed.com/)

It contains a single command: `Get-Ombed`

This command is aliased to `oEmbed`

~~~PowerShell
oEmbed "https://youtu.be/nHlJODYBLKs?si=XmWPX6ulPDlaEzO0"
~~~

We can also list all the providers:

~~~PowerShell
oEmbed -ProviderList
~~~

Or get them by wildcard:

~~~PowerShell
oEmbed -ProviderName *tube*
~~~