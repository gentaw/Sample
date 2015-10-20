#Get VPC Id
$filtername = new-object Amazon.EC2.Model.Filter
$filtername.Name = "tag:Name"
$filtername.Value = "Examples"
$vpcId = (Get-EC2Vpc -Filter $filtername).VpcId

#Create VPC and Subnet
if ($vpcId -eq $null)
    {
        $vpcId = (New-EC2Vpc -CidrBlock 10.0.0.0/16).VpcId
        $tag = New-Object Amazon.EC2.Model.Tag
        $tag.Key = "Name"
        $tag.Value = "Examples"
        New-EC2Tag -Resource $vpcId -Tag $tag
        $subnetID = New-EC2Subnet -VpcId $vpcid -CidrBlock 10.0.0.0/24 -AvailabilityZone ap-northeast-1a
        $subnetID += New-EC2Subnet -VpcId $vpcid -CidrBlock 10.0.1.0/24 -AvailabilityZone ap-northeast-1c
    }
    else
    {
        $subnetId = (Get-EC2Subnet | Where-Object -FilterScript {$_.VpcId -eq $vpcId}).SubnetId
    }

#Get Directory ID
$directoryname = "test.example.com"
$directoryId = (Get-DSDirectory | Where-Object -FilterScript {$_.Name -eq $directoryname}).DirectoryId

#Create Directory
if ($directoryId -eq $null) 
    {
        $password = (Get-Credential -Credential Administrator).Password
        $directorysize = "small"

        $directoryid = New-DSDirectory -Name $directoryname -Password $password -Size $directorysize -VpcSettings_SubnetId $subnetId -VpcSettings_VpcId $vpcId
        
        #Wait until Directory status is Active
        do
            {
                $directoryStage = (Get-DSDirectory -DirectoryId $directoryId).Stage
                "Directory Status is now " + $directoryStage
                Start-Sleep -s 10
            }
        while ($directoryStage -ne "Active")

}

#Get WorkSpaces Parameters
$bundleId = (Get-WKSWorkspaceBundles -Owner AMAZON | Where-Object -FilterScript {$_.Name -eq "Value(Japanese)"}).BundleId
$workspaces = @()

#Create WorkSpaces Users
for ($i = 1; $i -le 10; $i++ )
{
$username = "User_" + $i
$workspaces += @{"BundleID" = $bundleId; "DirectoryId" = $directoryId; "UserName" = $username}
}

#Create WorkSpaces
$response = New-WKSWorkspace -Workspace $workspaces
$response.PendingRequests
$response.FailedRequests