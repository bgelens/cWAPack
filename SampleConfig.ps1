#New Deployment
configuration WAPVMRole {
    Import-DscResource -ModuleName cWAPack

    node 'localhost' {
        WAPackVMRole DSCClient {
            VMSize = 'Medium'
            Name = 'TestDSC'
            SubscriptionId = 'b5a9b263-066b-4a8f-87b4-1b7c90a5bcad'
            Url = 'https://api.bgelens.nl'
            Credential = Get-Credential
            VMRoleName = 'DSCPullServerClient'
            OSDiskSearch = 'LatestApplicable'
            NetworkReference = 'Internal'
            TokenSource = 'ADFS'
            TokenUrl = 'https://sts.bgelens.nl'
            TokenPort = 443
            Ensure = 'Present'
            Port = 443
            VMRoleParameters = @{
                VMRoleAdminCredential = 'Administrator:P@$Sw0rd!'
                DSCPullServerClientConfigurationId = '7844f909-1f2e-4770-9c97-7a2e2e5677ae'
                DSCPullServerClientCredential = 'Domain\certreq:Password!'
            }
        }
    }
}

$configdata = @{
    AllNodes = @(
       @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
       } 
    )
}
WAPVMRole -ConfigurationData $configdata
Start-DscConfiguration .\WAPVMRole -Wait -Verbose 

#Remove VM Role
configuration WAPVMRolepurge {
    Import-DscResource -ModuleName cWAPack

    node 'localhost' {
        WAPackVMRole DSCClient {
            Name = 'TestDSC'
            SubscriptionId = 'b5a9b263-066b-4a8f-87b4-1b7c90a5bcad'
            Url = 'https://api.bgelens.nl'
            Credential = Get-Credential
            TokenSource = 'ADFS'
            TokenUrl = 'https://sts.bgelens.nl'
            TokenPort = 443
            Ensure = 'Absent'
            Port = 443
            VMRoleName = 'DSCPullServerClient'
            NetworkReference = 'Internal'
        }
    }
}

$configdata = @{
    AllNodes = @(
       @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
       } 
    )
}

WAPVMRolepurge -ConfigurationData $configdata
Start-DscConfiguration .\WAPVMRolepurge -Wait -Verbose