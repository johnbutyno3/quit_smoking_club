$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$requiredFiles = @(
    'docs/QSC_RULES.md',
    'docs/QSC_CURRENT_PHASE.md',
    'docs/QSC_V3_TODO.md'
)

$missing = @()

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path $fullPath)) {
        $missing += $relativePath
    }
}

if ($missing.Count -gt 0) {
    foreach ($path in $missing) {
        Write-Error "Missing required file: $path"
    }
    exit 1
}

Write-Output 'QSC Development Environment OK'
exit 0
