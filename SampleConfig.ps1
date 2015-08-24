#New Deployment
configuration WAPVMRole {
    param (
        [PSCredential] $Credential
    )
    Import-DscResource -ModuleName cWAPack
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.NodeName {
        WAPackVMRole DSCClient {
            VMSize = 'Medium'
            Name = 'TestDSC'
            SubscriptionId = 'b5a9b263-066b-4a8f-87b4-1b7c90a5bcad'
            Url = 'https://api.bgelens.nl'
            Credential = $Credential
            VMRoleGIName = 'DSCPullServerClient'
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
$Cred = New-Object -TypeName pscredential -ArgumentLis @('ben@bgelens.nl', (ConvertTo-SecureString -String 'MySecurePWD!' -AsPlainText -Force))
$configdata = @{
    AllNodes = @(
       @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 
       } 
    )
}
WAPVMRole -ConfigurationData $configdata -Credential $Cred
Start-DscConfiguration .\WAPVMRole -Wait -Verbose 

#Remove VM Role
configuration WAPVMRolepurge {
    param (
        [PSCredential] $Credential
    )
    Import-DscResource -ModuleName cWAPack
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.NodeName {
        WAPackVMRole DSCClient {
            Name = 'TestDSC'
            SubscriptionId = 'b5a9b263-066b-4a8f-87b4-1b7c90a5bcad'
            Url = 'https://api.bgelens.nl'
            Credential = $Credential
            TokenSource = 'ADFS'
            TokenUrl = 'https://sts.bgelens.nl'
            TokenPort = 443
            Ensure = 'Absent'
            Port = 443
            VMRoleGIName = 'DSCPullServerClient'
            NetworkReference = 'Internal'
        }
    }
}
$Cred = New-Object -TypeName pscredential -ArgumentLis @('ben@bgelens.nl', (ConvertTo-SecureString -String 'MySecurePWD!' -AsPlainText -Force))
$configdata = @{
    AllNodes = @(
       @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true 
       } 
    )
}

WAPVMRolepurge -ConfigurationData $configdata -Credential $Cred
Start-DscConfiguration .\WAPVMRolepurge -Wait -Verbose