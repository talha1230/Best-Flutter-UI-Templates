# 1. Configure paths
$projectRoot = "C:\Users\Talha PC\Best-Flutter-UI-Templates"
$jdkPath = "$projectRoot\android\jdk11"
$jdkZipPath = "$env:TEMP\jdk11.zip"
$jdkUrl = "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.20.1%2B1/OpenJDK11U-jdk_x64_windows_hotspot_11.0.20.1_1.zip"

# 2. Download and extract JDK if needed
if (-not (Test-Path $jdkPath)) {
    Write-Host "Downloading portable JDK 11..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZipPath
    
    Write-Host "Extracting JDK..."
    Expand-Archive -Path $jdkZipPath -DestinationPath $jdkPath -Force
    Remove-Item $jdkZipPath
    
    $jdkExtractedPath = Get-ChildItem $jdkPath -Directory | Select-Object -First 1
    if ($jdkExtractedPath) {
        $env:JAVA_HOME = $jdkExtractedPath.FullName
    }
}

# 3. Set environment for build
if (Test-Path $env:JAVA_HOME) {
    $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    Write-Host "Using Java at: $env:JAVA_HOME"
    
    # 4. Update Gradle config
    Set-Location "$projectRoot\android"
    
    $gradleProps = @"
org.gradle.java.home=$($env:JAVA_HOME -replace '\\', '\\')
org.gradle.jvmargs=-Xmx2048M
"@
    Set-Content "gradle.properties" $gradleProps -Encoding UTF8
    
    # 5. Run build
    Write-Host "Running Gradle build..."
    .\gradlew.bat clean build
} else {
    throw "Failed to set up Java environment"
}