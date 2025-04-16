try {
    # Customize Desktop Icons

    # Remove EC2 Tools - End Users don't need them on the desktop

    del C:\Users\Administrator\Desktop\EC2*.website
}
catch {
    Write-Error "An error occurred configuring desktop icons."
    exit 1
}
