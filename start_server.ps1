param(
    [int]$Port = 8080,
    [switch]$SkipServer
)

$Host.UI.RawUI.WindowTitle = "Messenger Server"

Write-Host ""
Write-Host "  ===========================================" -ForegroundColor Cyan
Write-Host "    Messenger - Server + ngrok Tunnel" -ForegroundColor Cyan
Write-Host "  ===========================================" -ForegroundColor Cyan
Write-Host ""

if (-not $SkipServer) {
    Write-Host "[1/3] Starting Spring Boot server on port $Port..." -ForegroundColor Yellow
    $serverProcess = Start-Process -FilePath "cmd" `
        -ArgumentList "/c cd /d `"$PSScriptRoot`" && gradlew.bat bootRun" `
        -PassThru -WindowStyle Normal
    Write-Host "  Server PID: $($serverProcess.Id)" -ForegroundColor DarkGray

    Write-Host "[2/3] Waiting for server to be ready..." -ForegroundColor Yellow
    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 2
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port/api/actuator/health" -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                $ready = $true
                break
            }
        } catch { }
        Write-Host "  Waiting... ($($i * 2)s)" -ForegroundColor DarkGray
    }

    if ($ready) {
        Write-Host "  Server is UP!" -ForegroundColor Green
    } else {
        Write-Host "  Server may not be ready yet, starting ngrok anyway..." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "[SKIP] Server start skipped (assuming already running)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "[3/3] Starting ngrok tunnel..." -ForegroundColor Yellow

$ngrokProcess = Start-Process -FilePath "ngrok" `
    -ArgumentList "http $Port --log=stdout" `
    -PassThru -WindowStyle Hidden -RedirectStandardOutput "$PSScriptRoot\ngrok_output.tmp"

Start-Sleep -Seconds 4

try {
    $tunnels = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $tunnels.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1 -ExpandProperty public_url

    if (-not $publicUrl) {
        $publicUrl = $tunnels.tunnels | Select-Object -First 1 -ExpandProperty public_url
    }

    Write-Host ""
    Write-Host "  ===========================================" -ForegroundColor Green
    Write-Host "   SERVER IS LIVE!" -ForegroundColor Green
    Write-Host "  ===========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Local URL:   http://localhost:$Port" -ForegroundColor White
    Write-Host "  Public URL:  $publicUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Enter the Public URL in the Messenger app" -ForegroundColor Yellow
    Write-Host "  on the 'Connect to Server' screen." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ngrok Dashboard: http://127.0.0.1:4040" -ForegroundColor DarkGray
    Write-Host "  ===========================================" -ForegroundColor Green

    $publicUrl | Set-Content "$PSScriptRoot\ngrok_url.txt"
    Write-Host ""
    Write-Host "  URL saved to ngrok_url.txt" -ForegroundColor DarkGray

} catch {
    Write-Host "  Could not fetch ngrok URL. Check http://127.0.0.1:4040" -ForegroundColor Red
}

Write-Host ""
Write-Host "  Press Ctrl+C to stop everything." -ForegroundColor DarkGray
Write-Host ""

try {
    while ($true) { Start-Sleep -Seconds 60 }
} finally {
    Write-Host "Shutting down..." -ForegroundColor Yellow
    if ($ngrokProcess -and -not $ngrokProcess.HasExited) {
        Stop-Process -Id $ngrokProcess.Id -Force -ErrorAction SilentlyContinue
    }
    if ($serverProcess -and -not $serverProcess.HasExited) {
        Stop-Process -Id $serverProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Remove-Item "$PSScriptRoot\ngrok_output.tmp" -ErrorAction SilentlyContinue
}
