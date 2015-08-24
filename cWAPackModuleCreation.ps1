Import-Module xDSCResourceDesigner
$BuildDir = 'C:\'

New-xDscResource -ModuleName cWAPack -Name 'BG_WAPackVMRole' -FriendlyName 'WAPackVMRole' -ClassVersion '1.0.0.0' -Path $BuildDir -Property @(
    New-xDscResourceProperty -Name Name -Type String -Attribute Key -Description 'Cloud Service and VM Role Name'
    New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet 'Present','Absent'
    New-xDscResourceProperty -Name Url -Type String -Attribute Required -Description 'Tenant Public API or Tenant API URL'
    New-xDscResourceProperty -Name SubscriptionId -Type String -Attribute Required -Description 'Subscription ID'
    New-xDscResourceProperty -Name Credential -Type PSCredential -Attribute Required -Description 'Credentials to acquire token'
    New-xDscResourceProperty -Name VMRoleGIName -Type String -Attribute Required -Description 'VM Role Gallery Item name'
    New-xDscResourceProperty -Name VMRoleGIVersion -Type String -Attribute Write -Description 'VM Role Gallery Item Version. Specify if multiple versions are published'
    New-xDscResourceProperty -Name VMRoleGIPublisher -Type String -Attribute Write -Description 'VM Role Gallery Item Publisher. Specify if multiple VM Roles with the same name but different publishers are published'
    New-xDscResourceProperty -Name VMSize -Type String -Attribute Write -ValidateSet 'Small','A7','ExtraSmall','Large','A6','Medium','ExtraLarge'
    New-xDscResourceProperty -Name OSDiskSearch -Type String -Attribute Write -ValidateSet 'LatestApplicable','LatestApplicableWithFamilyName','Specified'
    New-xDscResourceProperty -Name OSDiskFamilyName -Type String -Attribute Write
    New-xDscResourceProperty -Name OSDiskRelease -Type String -Attribute Write
    New-xDscResourceProperty -Name NetworkReference -Type String -Attribute Required
    New-xDscResourceProperty -Name VMRoleParameters -Type Hashtable -Attribute Write
    New-xDscResourceProperty -Name TokenSource -Type String -Attribute Required -ValidateSet 'ASPNET','ADFS'
    New-xDscResourceProperty -Name TokenUrl -Type String -Attribute Required
    New-xDscResourceProperty -Name TokenPort -Type Uint16 -Attribute Write -Description 'Specify custom port to acquire token. Defaults for ADFS: 443, ASP.Net: 30071'
    New-xDscResourceProperty -Name Port -Type Uint16 -Attribute Write -Description 'Specify API port. Default: 30006'
) -Force