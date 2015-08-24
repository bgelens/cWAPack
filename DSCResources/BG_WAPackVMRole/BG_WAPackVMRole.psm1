function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [parameter(Mandatory)]
        [String] $Name,

        [ValidateSet('Present','Absent')]
        [String] $Ensure,

        [parameter(Mandatory)]
        [String] $Url,

        [parameter(Mandatory)]
        [String] $SubscriptionId,

        [parameter(Mandatory)]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [String] $VMRoleGIName,

        [String] $VMRoleGIVersion,

        [String] $VMRoleGIPublisher,

        [ValidateSet('Small','A7','ExtraSmall','Large','A6','Medium','ExtraLarge')]
        [String] $VMSize = 'Medium',

        [ValidateSet('LatestApplicable','LatestApplicableWithFamilyName','Specified')]
        [String] $OSDiskSearch = 'LatestApplicable',

        [String] $OSDiskFamilyName,

        [String] $OSDiskRelease,

        [parameter(Mandatory)]
        [String] $NetworkReference,

        [Microsoft.Management.Infrastructure.CimInstance[]]	$VMRoleParameters,

        [parameter(Mandatory)]
        [ValidateSet('ASPNET','ADFS')]
        [String] $TokenSource,

        [parameter(Mandatory)]
        [String] $TokenUrl,
        
        #do not define default as functions for ADFS and ASP have different defaults
        [UInt16] $TokenPort,

        [UInt16] $Port = 30006
    )

    Setup @PSBoundParameters

    if (Get-WAPVMRole -CloudServiceName $Name -ErrorAction SilentlyContinue) {
        $Ensure = 'Present'
    } else {
        $Ensure = 'Absent'
    }
    Add-Member -InputObject $PSBoundParameters -MemberType NoteProperty -Name 'Ensure' -Value $Ensure
    $PSBoundParameters.Remove('Verbose')
    $PSBoundParameters.Remove('Debug')
    Write-Output -InputObject $PSBoundParameters
}

function Set-TargetResource {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [String] $Name,

        [ValidateSet('Present','Absent')]
        [String] $Ensure,

        [parameter(Mandatory)]
        [String] $Url,

        [parameter(Mandatory)]
        [String] $SubscriptionId,

        [parameter(Mandatory)]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [String] $VMRoleGIName,

        [String] $VMRoleGIVersion,

        [String] $VMRoleGIPublisher,

        [ValidateSet('Small','A7','ExtraSmall','Large','A6','Medium','ExtraLarge')]
        [String] $VMSize = 'Medium',

        [ValidateSet('LatestApplicable','LatestApplicableWithFamilyName','Specified')]
        [String] $OSDiskSearch = 'LatestApplicable',

        [String] $OSDiskFamilyName,

        [String] $OSDiskRelease,

        [parameter(Mandatory)]
        [String] $NetworkReference,

        [Microsoft.Management.Infrastructure.CimInstance[]]	$VMRoleParameters,

        [parameter(Mandatory)]
        [ValidateSet('ASPNET','ADFS')]
        [String] $TokenSource,

        [parameter(Mandatory)]
        [String] $TokenUrl,
        
        #do not define default as functions for ADFS and ASP have different defaults
        [UInt16] $TokenPort,

        [UInt16] $Port = 30006
    )

    try {
        Setup @PSBoundParameters

        if ($Ensure -eq 'Absent') {
            Get-WAPCloudService -Name $Name | Remove-WAPCloudService -Force | Out-Null
        } else {
            #Get GI with Name
            $GI = Get-WAPGalleryVMRole -Name $VMRoleGIName
            #If Multiple GI's returned, check if user specified version and select on that
            if ($GI -is [array] -and $VMRoleGIVersion) {
                $GI = Get-WAPGalleryVMRole -Name $VMRoleGIName -Version $VMRoleGIVersion
            }
            #If Multiple GI's returned, and version not specified or also returned multiple object, check if user specified Publisher and select on that.
            if ($GI -is [array] -and $VMRoleGIPublisher) {
                $GI = $GI | Where-Object -FilterScript {$_.Publisher -eq $VMRoleGIPublisher}
            }
            #If No GI is left, throw error.
            if ($null -eq $GI) {
                throw 'No VM Role Gallery Item found matching user criteria'
            } else {
                $GI | Out-String | Write-Verbose
            }

            if ($OSDiskSearch -eq 'LatestApplicable') {
            $OSDisk = $GI | Get-WAPVMRoleOSDisk | 
                Sort-Object Addedtime -Descending | 
                Select-Object -First 1
            } elseif ($OSDiskSearch -eq 'LatestApplicableWithFamilyName') {
                $OSDisk = $GI | Get-WAPVMRoleOSDisk | 
                    Where-Object -FilterScript {$_.FamilyName -eq $OSDiskFamilyName} | 
                    Sort-Object Addedtime -Descending | Select-Object -First 1
            } elseif ($OSDiskSearch -eq 'Specified') {
                $OSDisk = $GI | Get-WAPVMRoleOSDisk | 
                    Where-Object -FilterScript {$_.FamilyName -eq $OSDiskFamilyName -and $_.Release -eq $OSDiskRelease}
            }
            if ($null -eq $OSDisk) {
                throw 'No valid OS disk was found matching User provided criteria'
            }
            $OSDisk | Out-String | Write-Verbose

            $Net = Get-WAPVMNetwork -Name $NetworkReference
            if ($null -eq  $Net) {
                throw 'No valid virtual network was found'
            }
            $net | Out-String | Write-Verbose

            $VMProps = New-WAPVMRoleParameterObject -VMRole $GI -OSDisk $OSDisk -VMRoleVMSize $VMSize -VMNetwork $Net
            foreach ($P in $VMRoleParameters) {
                Add-Member -InputObject $VMProps -MemberType NoteProperty -Name $P.key -Value $P.value -Force
            }
            $VMProps | Out-String | Write-Verbose

            New-WAPVMRoleDeployment -VMRole $GI -ParameterObject $VMProps -CloudServiceName $Name | Out-Null
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction Stop
    }
}

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [parameter(Mandatory)]
        [String] $Name,

        [ValidateSet('Present','Absent')]
        [String] $Ensure,

        [parameter(Mandatory)]
        [String] $Url,

        [parameter(Mandatory)]
        [String] $SubscriptionId,

        [parameter(Mandatory)]
        [PSCredential] $Credential,

        [parameter(Mandatory)]
        [String] $VMRoleGIName,

        [String] $VMRoleGIVersion,

        [String] $VMRoleGIPublisher,

        [ValidateSet('Small','A7','ExtraSmall','Large','A6','Medium','ExtraLarge')]
        [String] $VMSize = 'Medium',

        [ValidateSet('LatestApplicable','LatestApplicableWithFamilyName','Specified')]
        [String] $OSDiskSearch = 'LatestApplicable',

        [String] $OSDiskFamilyName,

        [String] $OSDiskRelease,

        [parameter(Mandatory)]
        [String] $NetworkReference,

        [Microsoft.Management.Infrastructure.CimInstance[]] $VMRoleParameters,

        [parameter(Mandatory)]
        [ValidateSet('ASPNET','ADFS')]
        [String] $TokenSource,

        [parameter(Mandatory)]
        [String] $TokenUrl,

        [UInt16] $TokenPort,

        [UInt16] $Port
    )
    try {
        Setup @PSBoundParameters

        $VMRole = Get-WAPVMRole -CloudServiceName $Name -ErrorAction SilentlyContinue

        if ($Ensure -eq 'Present') {
            if ($null -ne $VMRole) {
                return $true
            } else {
                return $false
            }
        } else {
            if ($null -eq $VMRole) {
                return $true
            } else {
                return $false
            }
        }
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction Stop
    }
}

function Setup {
    param (
        $TokenSource,
        $TokenUrl,
        $TokenPort,
        $Credential,
        $Url,
        $Port,
        $SubscriptionId
    )
    try {
        if ($TokenSource -eq 'ADFS') {
            Write-Verbose "Acquiring ADFS token from $TokenUrl with credentials: $($Credential.username)"
            Get-WAPToken -Credential $Credential -URL $TokenUrl -Port $TokenPort -ADFS
        } else {
            Write-Verbose "Acquiring ASP.Net token from $TokenUrl"
            Get-WAPToken -Credential $Credential -URL $TokenUrl -Port $TokenPort
        }
        Connect-WAPAPI -URL $Url -Port $Port

        $Subscription = Get-WAPSubscription -Id $SubscriptionId
        if ($null -eq $SubscriptionId) {
            throw "Subscription with Id: $SubscriptionId was not found!"
        }
        $Subscription | Select-WAPSubscription
    } catch {
        Write-Error -ErrorRecord $_ -ErrorAction Stop
    }
}