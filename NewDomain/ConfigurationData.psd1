@{
    AllNodes = @(
        @{
            Nodename                    = "dc1"
            Role                        = "PrimaryDC"
            DomainName                  = "contoso.com"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}