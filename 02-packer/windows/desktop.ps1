try {
    # Customize Desktop Icons

    # Remove EC2 Tools - End Users don't need them on the desktop.
    # Server 2022 ships them as .website files on Administrator's desktop;
    # Server 2025 ships .url files and also puts them in the Default
    # profile, which every new user (packer included) is copied from.

    Remove-Item -Path "C:\Users\Administrator\Desktop\EC2*.website",
                      "C:\Users\Administrator\Desktop\EC2*.url",
                      "C:\Users\Default\Desktop\EC2*.website",
                      "C:\Users\Default\Desktop\EC2*.url" `
                -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Error "An error occurred configuring desktop icons."
    exit 1
}
