Write-Host "Enabling Windows Developer Mode..." -ForegroundColor Yellow

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator!"
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

try {
    # Enable Developer Mode
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
    
    # Open Developer Settings
    start ms-settings:developers
    
    Write-Host "`nDeveloper Mode has been enabled." -ForegroundColor Green
    Write-Host "Please ensure you enable 'Developer Mode' in the Settings window that just opened." -ForegroundColor Yellow
    Write-Host "`nAfter enabling, run these commands:" -ForegroundColor Cyan
    Write-Host "1. flutter pub get" -ForegroundColor White
    Write-Host "2. flutter run -d edge" -ForegroundColor White
    
    Read-Host "`nPress Enter to exit"
} catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
