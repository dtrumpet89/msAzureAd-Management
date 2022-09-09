Import-Module AzureAD
Import-Module MSOnline

# Import CSV file containing Group Names and ObjectIds
$groups = Import-Csv .\groupIds.csv

function getGroupIdByName($groupName) {

    $result = $groups | Where-Object { $_.groupName -eq $groupName } | Select $_.groupId
    return $result.groupId

}

$filePath = 'deviceNames.csv'

Import-Csv $filePath | forEach {

    $serial = $_.SerialNumber
    $filter = "serialNumber eq '$serial'"
    
    $intuneDevice = Get-IntuneManagedDevice -Filter $filter

    $intuneDeviceId = "'" + $intuneDevice.id + "'"
    $deviceName = $_.DeviceName
    $currentDeviceName = $intuneDevice.deviceName

    $msolDevice = Get-MsolDevice -Name $deviceName
    
    $grpId = getGroupIdByName($_.Group)
    if( $null -ne $msolDevice -and $msolDevice.ObjectId ) {
        Write-Host "Adding " $deviceName "to" $_.Group
        Add-AzureADGroupMember -ObjectId $grpId -RefObjectId $msolDevice.ObjectId
    } else {
        Write-Host "Unable to locate device" $deviceName
    }


}
