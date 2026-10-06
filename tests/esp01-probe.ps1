# Windows PowerShell 5.1: list ports, or inspect an ESP with existing AT firmware.
# Example: .\tests\esp01-probe.ps1 -Port COM5 -Baud 115200
# No flashing, reset commands, baud changes or persistent configuration writes.
[CmdletBinding()]
param(
    [ValidatePattern('^COM[0-9]+$')][string]$Port,
    [ValidateRange(2400,4500000)][int]$Baud = 115200
)

$ErrorActionPreference = 'Stop'
$available = @([System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object)
if (-not $Port) {
    if ($available.Count) { $available } else { 'No COM ports detected.' }
    return
}
if ($Port -notin $available) { throw "$Port is not present. Available: $($available -join ', ')" }

$serial = [System.IO.Ports.SerialPort]::new(
    $Port, $Baud, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One)
$serial.Handshake = [System.IO.Ports.Handshake]::None
$serial.DtrEnable = $false
$serial.RtsEnable = $false
$serial.ReadTimeout = 100
$serial.WriteTimeout = 2000
$serial.Encoding = [System.Text.Encoding]::ASCII
$serial.ReadBufferSize = 65536

function Invoke-EspQuery([string]$Command) {
    $reply = [System.Text.StringBuilder]::new()
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    $serial.Write($Command + "`r`n")
    do {
        $part = $serial.ReadExisting()
        if ($part) { [void]$reply.Append($part) }
        $text = $reply.ToString()
        if ($text -match '(?m)^(OK|ERROR|FAIL)\r?$') { break }
        Start-Sleep -Milliseconds 10
    } while ($timer.ElapsedMilliseconds -lt 3000)
    [pscustomobject]@{
        Command = $Command
        Ok = [bool]($text -match '(?m)^OK\r?$')
        ElapsedMs = $timer.ElapsedMilliseconds
        Response = $text.Trim()
    }
}

try {
    $serial.Open()
    # Let any boot output arrive, then separate it from command responses.
    Start-Sleep -Milliseconds 300
    $pending = $serial.ReadExisting()
    if ($pending) { Write-Verbose ("Initial UART text: " + $pending) }
    $probe = Invoke-EspQuery 'AT'
    $probe
    if (-not $probe.Ok) { throw 'No AT acknowledgement. Stop here; check baud, wiring and boot mode.' }
    foreach ($command in @('AT+GMR', 'AT+UART_CUR?')) {
        $result = Invoke-EspQuery $command
        $result
        if ($result.Response -notmatch '(?m)^(OK|ERROR|FAIL)\r?$') {
            throw 'Incomplete command reply; stop before issuing another query.'
        }
    }
} finally {
    if ($serial.IsOpen) { $serial.Close() }
    $serial.Dispose()
}
