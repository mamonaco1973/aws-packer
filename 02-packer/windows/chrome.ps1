# Set strict error handling
$ErrorActionPreference = "Stop"

# https://www.snel.com/support/install-chrome-in-windows-server/

try {
    Write-Host "Starting Chrome installation..." -ForegroundColor Cyan

    # Define temp path and installer name
    $LocalTempDir    = $env:TEMP
    $ChromeInstaller = "ChromeInstaller.exe"
    $InstallerPath   = Join-Path $LocalTempDir $ChromeInstaller

    # Download Chrome installer
    Write-Host "Downloading Chrome installer to $InstallerPath..."
    (New-Object System.Net.WebClient).DownloadFile(
        'http://dl.google.com/chrome/install/375.126/chrome_installer.exe',
        $InstallerPath
    )

    # Run the installer silently
    Write-Host "Launching Chrome installer..."
    & $InstallerPath /silent /install

    # Monitor installation process
    $Process2Monitor = "ChromeInstaller"
    Do {
        $ProcessesFound = Get-Process -ErrorAction SilentlyContinue |
                          Where-Object { $_.Name -eq $Process2Monitor } |
                          Select-Object -ExpandProperty Name

        if ($ProcessesFound) {
            Write-Host "Still running: $($ProcessesFound -join ', ')"
            Start-Sleep -Seconds 2
        } else {
            # Clean up installer file
            Write-Host "Chrome installer finished. Cleaning up..."
            Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue -Verbose
        }
    } Until (-not $ProcessesFound)

    Write-Host "Chrome installation completed successfully." -ForegroundColor Green
}
catch {
    Write-Error "An error occurred during Chrome installation: $_"
    exit 1
}
