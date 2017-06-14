@{
    AllNodes = @(
        @{
            NodeName   = "*"
            DomainName = "domain1.local"
        }
        @{
            NodeName                    = "primary-dc"
            Role                        = "PrimaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
        @{
            NodeName                    = "secondary-dc"
            Role                        = "SecondaryDC"
            RetryCount                  = 20
            RetryIntervalSec            = 30
            PsDscAllowPlainTextPassword = $true
        }
    )
}