# Cancer Care Navigator - local launcher
# Serves this folder on http://localhost (this computer only) and opens the app in your default browser.
# Close this window to stop the app.

param([switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$page = 'cancer_care_navigator.html'

$mime = @{
  '.html' = 'text/html; charset=utf-8'; '.js' = 'text/javascript; charset=utf-8'; '.mjs' = 'text/javascript; charset=utf-8'
  '.css' = 'text/css; charset=utf-8'; '.json' = 'application/json'; '.png' = 'image/png'; '.svg' = 'image/svg+xml'
  '.woff2' = 'font/woff2'; '.woff' = 'font/woff'; '.ttf' = 'font/ttf'; '.ico' = 'image/x-icon'; '.md' = 'text/plain; charset=utf-8'
}

# Find a free port, starting at 8765
$listener = $null
foreach ($port in 8765..8785) {
  try {
    $l = New-Object System.Net.HttpListener
    $l.Prefixes.Add("http://localhost:$port/")
    $l.Start()
    $listener = $l
    break
  } catch { }
}
if (-not $listener) { Write-Host 'Could not find a free port between 8765 and 8785.'; Read-Host 'Press Enter to close'; exit 1 }

$url = "http://localhost:$port/$page"
Write-Host ''
Write-Host '  Cancer Care Navigator is running.' -ForegroundColor Green
Write-Host "  Open: $url"
Write-Host '  Close this window to stop the app.'
Write-Host ''
if (-not $NoBrowser) { Start-Process $url }

$rootFull = [IO.Path]::GetFullPath($root)
while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $res = $ctx.Response
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if (-not $rel) { $rel = $page }
    $full = [IO.Path]::GetFullPath((Join-Path $rootFull $rel))
    # Serve only files inside this folder, and never git metadata
    if ($full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase) -and $full -notmatch '\\\.git(\\|$)' -and (Test-Path $full -PathType Leaf)) {
      $ext = [IO.Path]::GetExtension($full).ToLower()
      $res.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $res.Headers.Add('Cache-Control', 'no-cache')
      $bytes = [IO.File]::ReadAllBytes($full)
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
    }
  } catch {
    $res.StatusCode = 500
  } finally {
    $res.Close()
  }
}
