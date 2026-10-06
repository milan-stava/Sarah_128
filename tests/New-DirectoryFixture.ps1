param([Parameter(Mandatory=$true)][string]$Root)
$ErrorActionPreference = 'Stop'
if (Test-Path -LiteralPath $Root) { throw 'Cil uz existuje. Pouzij novy prazdny nazev slozky.' }
$rootPath = [IO.Path]::GetFullPath($Root)
[IO.Directory]::CreateDirectory($rootPath) | Out-Null
foreach ($name in @('empty','small','large')) {
    [IO.Directory]::CreateDirectory((Join-Path $rootPath $name)) | Out-Null
}
foreach ($name in @('alpha.txt','beta with space.txt','gamma.txt')) {
    [IO.File]::WriteAllText((Join-Path $rootPath ('small\'+$name)), "SARAH D1 test`r`n")
}
foreach ($name in @('sub-a','sub-b')) {
    [IO.Directory]::CreateDirectory((Join-Path $rootPath ('small\'+$name))) | Out-Null
}
for ($i=1; $i -le 700; $i++) {
    [IO.File]::WriteAllText((Join-Path $rootPath ('large\item-{0:D4}.txt' -f $i)), 'D1')
}
Write-Output "Pripraveno: $rootPath"
Write-Output 'empty: 0 polozek; small: 3 soubory a 2 adresare; large: 700 souboru.'
Write-Output 'Syntetickou polozku .. do techto poctu nepocitej.'
