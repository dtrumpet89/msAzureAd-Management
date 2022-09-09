Import-Module Microsoft.Graph.Intune

Connect-MSGraph

$filePath = 'deviceNames.csv'

Import-Csv $filePath | forEach {

    $serial = $_.SerialNumber
    $filter = "serialNumber eq '$serial'"

    $intuneDevice = Get-IntuneManagedDevice -Filter $filter

    $deviceId = "'" + $intuneDevice.id + "'"
    $deviceName = $_.DeviceName

    if( $null -ne $intuneDevice ) {

        if( $intuneDevice.deviceName -ne $deviceName) {
        
            write-host "Changing: " $intuneDevice.deviceName " to " $deviceName
    
            $Resource = "deviceManagement/managedDevices(" + $deviceId + ")/setDeviceName"
            $GraphApiVersion = “Beta”
            $uri = “https://graph.microsoft.com/$graphApiVersion/$($resource)”

            $jsonPayload = @"
{deviceName: "$($deviceName)"}
"@

            if( $deviceId.Length -gt 1 ) {
                Invoke-MSGraphRequest -HttpMethod POST -Url $uri -Content $jsonPayload -Verbose -ErrorAction Continue
            } else {
                Write-Host $deviceName "-" $serial "not found"
            }

            $uri = $null
            $JSONPayload = $null
            $deviceId = $null
            $inTuneDevice = $null

        } else {
            write-host $deviceName "already updated"
        }
    } else {
        Write-Host $deviceName "device id not found"
    }

}
