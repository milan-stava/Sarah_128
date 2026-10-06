# Run locally: credentials are prompted, never printed or saved to a file.
[CmdletBinding()]
param(
    [ValidatePattern('^COM[0-9]+$')][string]$Port = 'COM7',
    [ValidateRange(2400,4500000)][int]$Baud = 115200
)
$ErrorActionPreference = 'Stop'
$ssid = Read-Host '2.4 GHz Wi-Fi SSID (same network as PC)'
if ([string]::IsNullOrWhiteSpace($ssid)) { throw 'SSID is required.' }
$secret = Read-Host 'Wi-Fi password' -AsSecureString
$serial = [System.IO.Ports.SerialPort]::new($Port,$Baud)
$serial.DtrEnable = $false
$serial.RtsEnable = $false
$serial.Handshake = [System.IO.Ports.Handshake]::None
$serial.Encoding = [System.Text.UTF8Encoding]::new($false)
$serial.WriteTimeout = 2000
$ptr = [IntPtr]::Zero

function Escape-AtString([string]$Value) {
    if ($Value.Contains("`r") -or $Value.Contains("`n")) { throw 'Newlines are not allowed in credentials.' }
    return $Value.Replace('\','\\').Replace('"','\"').Replace(',','\,')
}
function Send-AndWait([string]$Command,[int]$TimeoutMs) {
    [void]$serial.ReadExisting()
    $serial.Write($Command+"`r`n")
    $reply = [System.Text.StringBuilder]::new()
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    do {
        [void]$reply.Append($serial.ReadExisting())
        $text = $reply.ToString()
        if ($text -match '(?m)^OK\r?$') { return }
        if ($text -match '(?m)^(ERROR|FAIL)\r?$') { throw 'ESP rejected the command. Check Wi-Fi credentials and signal.' }
        Start-Sleep -Milliseconds 20
    } while ($timer.ElapsedMilliseconds -lt $TimeoutMs)
    throw 'ESP reply timed out. Check Wi-Fi and baud rate.'
}
try {
    $serial.Open()
    Send-AndWait 'AT' 3000
    Send-AndWait 'AT+CWMODE_CUR=1' 3000
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    $command = 'AT+CWJAP_CUR="' + (Escape-AtString $ssid) + '","' + (Escape-AtString $password) + '"'
    # The reply can echo the password: never print or log that reply.
    Send-AndWait $command 30000
    'ESP joined Wi-Fi. Serial port is now released for testing.'
} finally {
    $password = $null
    $command = $null
    if ($ptr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
    $secret.Dispose()
    if ($serial.IsOpen) { $serial.Close() }
    $serial.Dispose()
}
