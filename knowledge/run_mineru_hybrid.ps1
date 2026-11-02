param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [Parameter(Mandatory = $true)]
    [string]$Output,

    [ValidateSet('auto', 'txt', 'ocr')]
    [string]$Method = 'auto',

    [int]$Start = -1,

    [int]$End = -1,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
# venv 可能在 knowledge/.venv（原布局）或上一级 shopkeeper_brain/.venv（已移动），自动探测
$venvCandidates = @(
    (Join-Path $projectRoot '.venv'),
    (Join-Path (Split-Path -Parent $projectRoot) '.venv')
)
$venvRoot = $null
foreach ($c in $venvCandidates) {
    if (Test-Path (Join-Path $c 'Scripts\mineru.exe')) { $venvRoot = $c; break }
}
if (-not $venvRoot) { throw ("未找到含 mineru.exe 的 venv: " + ($venvCandidates -join '; ')) }
$mineruExe = Join-Path $venvRoot 'Scripts\mineru.exe'
$torchLibDir = Join-Path $venvRoot 'Lib\site-packages\torch\lib'
$cudaShimRoot = Join-Path $projectRoot '.cuda-shim'
$cudaShimBin = Join-Path $cudaShimRoot 'bin'
$tempRoot = Join-Path $projectRoot '.tmp'

if (-not (Test-Path $mineruExe)) {
    throw "MinerU executable not found: $mineruExe"
}

if (-not (Test-Path $torchLibDir)) {
    throw "Torch CUDA runtime directory not found: $torchLibDir"
}

New-Item -ItemType Directory -Force -Path $cudaShimBin | Out-Null
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
Copy-Item (Join-Path $torchLibDir '*.dll') $cudaShimBin -Force

$env:MINERU_MODEL_SOURCE = 'local'
$env:CUDA_PATH = $cudaShimRoot
$env:TEMP = $tempRoot
$env:TMP = $tempRoot
$env:TMPDIR = $tempRoot

$mineruArgs = @(
    '-p', $Path,
    '-o', $Output,
    '-b', 'hybrid-auto-engine',
    '-m', $Method
)

if ($Start -ge 0) {
    $mineruArgs += @('-s', $Start)
}

if ($End -ge 0) {
    $mineruArgs += @('-e', $End)
}

if ($ExtraArgs) {
    $mineruArgs += $ExtraArgs
}

& $mineruExe @mineruArgs
exit $LASTEXITCODE
