#ディレクトリ名とサイズの設定
$directoryname = “corp.example.com“
$directorysize = "small" 

#管理者パスワードの取得
$password = (Get-Credential -Credential Administrator).Password

#
$vpcId = (Get-EC2Vpc -Filter @{Name="Tag:Name"; Values="Examples"}).VpcId

#Simple ADディレクトリの作成
New-DSDirectory -Name $directoryname -Password $password -Size $directorysize -VpcSettings_SubnetId $subnetId -VpcSettings_VpcId $vpcId 

#作成したSimple ADディレクトリの確認
Get-DSDirectory | Where-Object -FilterScript {$_.Name -eq $directoryname}