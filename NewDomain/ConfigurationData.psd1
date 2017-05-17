@{
    AllNodes = @(
        @{
            NodeName   = "*"
            DomainName = "contoso.com"
        }
        @{
            NodeName                    = "dc1"
            Role                        = "PrimaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
        @{
            NodeName                    = "dc2"
            Role                        = "SecondaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}