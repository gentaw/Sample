Configuration ComputerJoinDomain
{
    param
    (
    [Parameter(Mandatory)]
    [string]$MachineName,

    [Parameter(Mandatory)]
    [string]$DomainDNSName,  
      
    [Parameter(Mandatory)]
    [pscredential]$credential
    )

    Import-DscResource -Module xComputerManagement

    Node localhost
    {
        xComputer JoinDomain
        {
        Name = $MachineName
        DomainName = $DomainDNSName
        Credential = $credential
        }
    } 
}


$DomainDNSName = "example.com"
$password = ConvertTo-SecureString -AsPlainText -Force "yourPassword"
$credential = New-Object System.Management.Automation.PSCredential "$DomainDNSName\Administrator",$password

ComputerJoinDomain -ConfigurationData $ConfigData -MachineName $env:COMPUTERNAME -DomainDNSName $DomainDNSName -credential $credential -OutputPath .
Start-DscConfiguration  .\ComputerJoinDomain
Restart-Computer