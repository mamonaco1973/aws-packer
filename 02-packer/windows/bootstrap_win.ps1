<powershell>

net user Administrator "${password}"
wmic useraccount where "name='Administrator'" set PasswordExpires=FALSE

Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
$ErrorActionPreference = "Stop"

# Remove existing WinRM listeners
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse -ErrorAction SilentlyContinue

# Create self-signed certificate
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"

# Create WinRM HTTPS listener
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# Configure WinRM
winrm quickconfig -q
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/client '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"; CredSSP="true"; Negotiate="true"}'

# Enable firewall access for WinRM
New-NetFirewallRule -DisplayName "Allow WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Restart and configure WinRM service
Stop-Service winrm
Set-Service winrm -StartupType Automatic
Start-Service winrm

</powershell>
