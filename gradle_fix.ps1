# Script configuration
$ErrorActionPreference = "Stop"
$configPath = @{
    AndroidSDK = "$env:LOCALAPPDATA\Android\Sdk"
    FlutterSDK = "$env:LOCALAPPDATA\flutter"
    GradleFile = ".\android\app\build.gradle"
    VSCode = "${env:LOCALAPPDATA}\Programs\Microsoft VS Code"
}

# Administrator check function
function Assert-AdminPrivileges {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Please run this script as Administrator"
    }
}

# Flutter environment validation
function Test-FlutterEnvironment {
    try {
        $flutterVersion = flutter --version
        if (-not $?) { throw "Flutter not found" }
        
        if (-not (Test-Path $configPath.AndroidSDK)) {
            throw "Android SDK not found"
        }
        
        Write-Host "✓ Environment check passed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Environment check failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main repair function
function Repair-FlutterSetup {
    Write-Host "Starting Flutter environment repair..." -ForegroundColor Cyan
    
    try {
        # Clean project
        flutter clean
        
        # Update Gradle wrapper
        if (Test-Path ".\android") {
            Remove-Item ".\android\gradlew*" -Force -ErrorAction SilentlyContinue
            flutter pub get
        }
        
        # Accept Android licenses
        flutter doctor --android-licenses
        
        # Final verification
        flutter doctor -v
        
        Write-Host "Repair completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during repair: $_" -ForegroundColor Red
        exit 1
    }
}

# Main execution
try {
    Assert-AdminPrivileges
    if (Test-FlutterEnvironment) {
        Repair-FlutterSetup
    }
}
catch {
    Write-Host "Critical error: $_" -ForegroundColor Red
    exit 1
}