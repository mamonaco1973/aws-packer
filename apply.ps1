
./build/check_env.ps1
$returnCode = $LASTEXITCODE

# Check if the return code indicates failure
if ($returnCode -ne 0) {
    Write-Host "ERROR: check_env.ps1 failed with exit code $returnCode. Stopping the script." -ForegroundColor Red
    exit $returnCode
}

$env:AWS_DEFAULT_REGION = "us-east-2"

./build/apply_phase_1.ps1
./build/apply_phase_2.ps1
./build/apply_phase_3.ps1

Write-Host "NOTE: Validating Build"
./validate.ps1

