function Sort-IPAddresses($IPs)
{
    $Data = foreach ($IP in $IPs)
    {
        $Octets = $IP.split('.')

        $Formatted = foreach ($Octet in $Octets)
        {
            if ($Octet.length -eq 1){"00" + $Octet} 
            elseif ($Octet.length -eq 2){"0" + $Octet} 
            else {$Octet}
        }
        $Formatted -join '' 
    }
    $Sorted = $Data | Sort-Object
    $Output = foreach($Obj in $Sorted)
    {
        $Obj[0] + $Obj[1] + $Obj[2] + '.' + $Obj[3] + $Obj[4] + $Obj[5] + '.' + $Obj[6] + $Obj[7] + $Obj[8] + '.' + $Obj[9] + $Obj[10] + $Obj[11]
    }
    $Output
}