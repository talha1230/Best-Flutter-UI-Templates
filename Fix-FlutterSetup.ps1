# Configuration
$androidStudioPath = "${env:PROGRAMFILES}\Android\Android Studio"
$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$emulatorPath = "$androidSdkPath\emulator\emulator.exe"
$adbPath = "$androidSdkPath\platform-tools\adb.exe"

function Test-FlutterInstallation {
    try {
        $flutterVersion = flutter --version
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter command failed"
        }
        Write-Host "Flutter installation verified" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Flutter SDK not found or corrupted. Please install Flutter from https://flutter.dev/setup" -ForegroundColor Red
        return $false
    }
}

function Test-AndroidSDK {
    if (-not (Test-Path $androidSdkPath)) {
        Write-Host "Android SDK not found at: $androidSdkPath" -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path $emulatorPath)) {
        Write-Host "Android Emulator not found at: $emulatorPath" -ForegroundColor Red
        return $false
    }
    Write-Host "Android SDK installation verified" -ForegroundColor Green
    return $true
}

function Get-ValidEmulators {
    if (-not (Test-Path $emulatorPath)) {
        Write-Host "Emulator not found!" -ForegroundColor Red
        return @()
    }

    $emulators = & $emulatorPath -list-avds
    if ($emulators) {
        Write-Host "`nAvailable emulators:" -ForegroundColor Cyan
        $emulators | ForEach-Object { Write-Host "  - $_" }
        return $emulators
    } else {
        Write-Host "No emulators found. Please create one in Android Studio." -ForegroundColor Yellow
        return @()
    }
}

function Start-AndroidEmulator {
    param (
        [Parameter(Mandatory=$true)]
        [string]$EmulatorName
    )
    
    Write-Host "`nStarting emulator: $EmulatorName" -ForegroundColor Cyan
    
    # Kill any existing emulator processes
    Get-Process | Where-Object { $_.Name -like "qemu-system*" } | Stop-Process -Force
    
    # Start emulator in background
    Start-Process -FilePath $emulatorPath -ArgumentList "-avd", $EmulatorName -NoNewWindow
    
    Write-Host "Waiting for emulator to boot..."
    $timeout = 120 # seconds
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    
    while ($timer.Elapsed.TotalSeconds -lt $timeout) {
        $bootCheck = & $adbPath shell getprop sys.boot_completed 2>$null
        if ($bootCheck -eq "1") {
            Write-Host "Emulator is ready!" -ForegroundColor Green
            return $true
        }
        Start-Sleep -Seconds 2
    }
    
    Write-Host "Emulator failed to start within timeout period" -ForegroundColor Red
    return $false
}

# Main execution
try {
    if (-not (Test-FlutterInstallation)) { exit 1 }
    if (-not (Test-AndroidSDK)) { exit 1 }
    
    $emulators = Get-ValidEmulators
    if (-not $emulators) { exit 1 }
    
    $selectedEmulator = $emulators[0]
    if (-not (Start-AndroidEmulator -EmulatorName $selectedEmulator)) { exit 1 }
    
    Write-Host "`nLaunching Flutter app..." -ForegroundColor Cyan
    flutter clean
    flutter pub get
    flutter run
}
catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    exit 1
}