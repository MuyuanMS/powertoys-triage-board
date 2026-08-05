<#  serve.ps1 — tiny localhost static server for the v3 member board.
    Serves this folder over http://localhost:<port>/ so the page can fetch
    data/index.json + data/items/<n>.json. Holds no token and never calls GitHub —
    all GitHub writes happen in the browser as the signed-in member.
    Usage:  pwsh -File serve.ps1 [-Port 8790]
#>
param([int]$Port = 8790)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$mime = @{ '.html'='text/html; charset=utf-8'; '.js'='text/javascript; charset=utf-8'
          '.json'='application/json; charset=utf-8'; '.css'='text/css; charset=utf-8'
          '.svg'='image/svg+xml'; '.png'='image/png'; '.ico'='image/x-icon' }
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "v3 member board: http://localhost:$Port/  (Ctrl+C to stop)"
try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'index.html' }
    $path = Join-Path $root $rel
    $ctx.Response.Headers['Cache-Control'] = 'no-store'
    if ((Test-Path $path -PathType Leaf) -and ($path.StartsWith($root))) {
      $ext = [System.IO.Path]::GetExtension($path).ToLower()
      $ctx.Response.ContentType = $(if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' })
      $bytes = [System.IO.File]::ReadAllBytes($path)
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $b = [Text.Encoding]::UTF8.GetBytes('not found')
      $ctx.Response.OutputStream.Write($b, 0, $b.Length)
    }
    $ctx.Response.OutputStream.Close()
  }
} finally { $listener.Stop() }
