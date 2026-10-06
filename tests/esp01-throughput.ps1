[CmdletBinding()]
param(
    [string]$Port='COM7',
    [string]$EspAddress='192.168.0.153',
    [int]$CurrentBaud=115200,
    [int]$TestBaud=115200,
    [ValidateRange(1,1048576)][int]$Bytes=363520,
    [switch]$CompileOnly
)
$ErrorActionPreference='Stop'
Add-Type -Path (Join-Path $PSScriptRoot 'esp01-throughput.cs')
if($CompileOnly){'Benchmark compilation OK';return}
[Esp01Throughput]::Run($Port,$EspAddress,$CurrentBaud,$TestBaud,$Bytes)
