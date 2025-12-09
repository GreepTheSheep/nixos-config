# Lint script for NixOS Configuration

write-host "Linting NixOS Configuration..."

# Run statix inside a container
# We use 'nix shell' to get statix ephemerally
# We use --privileged matching the build script for consistency, though less critical for linting.

$lintCmd = "echo 'Running Statix...'
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#statix -c statix check .
echo 'Running Deadnix (Scanning for unused code)...'
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#deadnix -c deadnix ."

# Handle line endings for the shell command
$cleanCmd = $lintCmd -replace "`r`n", ";" -replace "`n", ";"

docker run --rm -v "${PWD}:/app" -w /app nixos/nix:latest sh -c "$cleanCmd"

if ($LASTEXITCODE -eq 0) {
    write-host "Linting passed successfully!" -ForegroundColor Green
} else {
    write-host "Linting found issues." -ForegroundColor Red
}
