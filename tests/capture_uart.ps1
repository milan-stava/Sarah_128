param(
    [string]$Port = 'COM6',
    [int]$Baud = 2304000,
    [string]$OutputDirectory,
    [int]$Seconds = 1800
)
$ErrorActionPreference = 'Stop'
if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path ([IO.Path]::GetTempPath()) ('sara-uart-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))
}
[IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
$serial = New-Object IO.Ports.SerialPort
$serial.PortName = $Port
$serial.BaudRate = $Baud
$serial.DataBits = 8
$serial.Parity = [IO.Ports.Parity]::None
$serial.StopBits = [IO.Ports.StopBits]::One
$serial.Handshake = [IO.Ports.Handshake]::None
$serial.DtrEnable = $false
$serial.RtsEnable = $false
$serial.ReadBufferSize = 1048576
$serial.ReadTimeout = 200
$raw = $null
$index = $null
$total = [long]0
try {
    $serial.Open()
    $raw = [IO.File]::Open((Join-Path $OutputDirectory 'rx.bin'), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite)
    $index = [IO.StreamWriter]::new((Join-Path $OutputDirectory 'chunks.jsonl'), $false, [Text.UTF8Encoding]::new($false))
    $index.AutoFlush = $true
    $settings = @{port=$Port; baud=$Baud; format='8N1'; mode='receive-only'; startedUtc=[DateTime]::UtcNow.ToString('o')}
    [IO.File]::WriteAllText((Join-Path $OutputDirectory 'settings.json'), ($settings | ConvertTo-Json))
    $buffer = New-Object byte[] 65536
    $timer = [Diagnostics.Stopwatch]::StartNew()
    Write-Output ('READY ' + $Port + ' ' + $Baud + ' 8N1 ' + $OutputDirectory)
    while ($timer.Elapsed.TotalSeconds -lt $Seconds -and -not [IO.File]::Exists((Join-Path $OutputDirectory 'stop'))) {
        $available = $serial.BytesToRead
        if ($available -eq 0) { Start-Sleep -Milliseconds 10; continue }
        $count = $serial.Read($buffer, 0, [Math]::Min($available, $buffer.Length))
        $raw.Write($buffer, 0, $count)
        $raw.Flush()
        $index.WriteLine((@{utc=[DateTime]::UtcNow.ToString('o'); offset=$total; count=$count} | ConvertTo-Json -Compress))
        $total += $count
    }
} finally {
    if ($index) { $index.Dispose() }
    if ($raw) { $raw.Dispose() }
    if ($serial.IsOpen) { $serial.Close() }
    $serial.Dispose()
    Write-Output ('STOPPED bytes=' + $total)
}
