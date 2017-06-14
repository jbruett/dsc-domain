@{
    AllNodes = @(
        @{
            NodeName   = "*"
            DomainName = "domain1.local"
        }
        @{
            NodeName                    = "primarydc"
            Role                        = "PrimaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
        @{
            NodeName                    = "secondarydc"
            Role                        = "SecondaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}