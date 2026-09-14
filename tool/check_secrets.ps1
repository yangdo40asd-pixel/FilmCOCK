param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$resolvedRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path

$excludedPaths = @(
    'config/api_keys.example.json',
    'lib/firebase_options.dart',
    'tool/check_secrets.ps1'
)

$secretPatterns = @(
    '(?i)(tmdb_api_key|kofic_api_key|tmdb_read_access_token)[^\r\n]{0,16}[:=][ \t]*["'']?(?!replace-)[A-Za-z0-9._-]{16,}',
    '(?i)(authorization|auth_header)[^\r\n]{0,16}bearer[ \t]+[A-Za-z0-9._-]{20,}',
    '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
)

$repositoryFiles = & git -C $resolvedRoot -c core.quotepath=false ls-files --cached --others --exclude-standard
if ($LASTEXITCODE -ne 0) {
    throw 'Git 파일 목록을 읽지 못했습니다.'
}

$findings = [System.Collections.Generic.List[string]]::new()
foreach ($relativePath in $repositoryFiles) {
    $normalizedPath = $relativePath.Replace('\', '/')
    if ($excludedPaths -contains $normalizedPath) {
        continue
    }

    $absolutePath = Join-Path $resolvedRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        continue
    }

    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $absolutePath -ErrorAction SilentlyContinue) {
        $lineNumber++
        foreach ($pattern in $secretPatterns) {
            if ($line -match $pattern) {
                $findings.Add("${normalizedPath}:$lineNumber")
                break
            }
        }
    }
}

if ($findings.Count -gt 0) {
    Write-Error "비밀정보로 의심되는 값이 발견되었습니다:`n$($findings -join "`n")"
    exit 1
}

Write-Output '비밀정보로 의심되는 하드코딩 값을 찾지 못했습니다.'
