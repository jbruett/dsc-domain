@{
    AllNodes = @(
        @{
            NodeName   = "*"
            DomainName = "domain1.local"
        }
        @{
            NodeName                    = "base-dc1"
            Role                        = "PrimaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
        @{
            NodeName                    = "base-dc2"
            Role                        = "SecondaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}