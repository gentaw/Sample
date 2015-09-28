Configuration CreateADDomain
{
    param
    (
        [Parameter(Mandatory)]
        [string]$DomainDNSName,

        [Parameter(Mandatory)]
        [pscredential]$DomainCredential,

        [Parameter(Mandatory)]
        [pscredential]$SafemodePassword

    )
    
    Import-DscResource -Module xActiveDirectory

    Node localhost
    {
        WindowsFeature ADDSInstall
        {
        Ensure = "Present"
        Name = "AD-Domain-Services"
        }

        WindowsFeature ADDSToolsInstall
        {
        Ensure = "Present"
        Name = "RSAT-ADDS-Tools"
        }

        xADDomain ActiveDirectory
        {
        DomainName = $DomainDNSName
        DomainAdministratorCredential = $DomainCredential
        SafemodeAdministratorPassword = $SafemodePassword
        DependsOn = "[WindowsFeature]ADDSinstall"
        }
     } 
}

$ConfigData = @{   
                 AllNodes = @(        
                              @{     
                                 NodeName = "localhost"                       
                                 PSDscAllowPlainTextPassword = $true 
                              } 
                            )  
              } 

$domainDNSName = "example.com"
$password = ConvertTo-SecureString -AsPlainText -Force "yourPassword"
$credential = New-Object System.Management.Automation.PSCredential "$DomainDNSName\Administrator",$password

CreateADDomain -ConfigurationData $ConfigData -DomainDNSName $domainDNSName -DomainCredential $credential -SafemodePassword $credential
Start-DscConfiguration  .\CreateADDomain
