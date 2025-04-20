#!/usr/bin/env pwsh

# ---- Resolve project root --------------------------------------
# Get the directory where this script is located and go up one level
$PROJECT_ROOT = (Get-Item $PSScriptRoot).Parent.FullName
Write-Host "[INFO] Project root: $PROJECT_ROOT"

# ---- Extract version from pubspec.yaml -------------------------
$version = (Get-Content "$PROJECT_ROOT\pubspec.yaml" | Select-String "^version:" | ForEach-Object { $_.ToString().Split(":")[1].Trim() })
Write-Host "[INFO] Version: $version"

# ---- Generate timestamp (YYYYMMDD_HHMM) -----------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
Write-Host "[INFO] Timestamp: $timestamp"

# ---- Prepare output directory ----------------------------------
$OUTDIR = "$PROJECT_ROOT\symbol-archives\android\${version}_${timestamp}"
if (-not (Test-Path $OUTDIR)) {
    New-Item -ItemType Directory -Path $OUTDIR -Force | Out-Null
}
Write-Host "[INFO] Output directory: $OUTDIR"

# ---- Build AAB with obfuscation & split-debug-info -------------
Write-Host "[BUILD] Building Android AAB to: $OUTDIR"
# & flutter build appbundle --obfuscate --split-debug-info="$OUTDIR"

# ---- Copy ProGuard/R8 mapping.txt ------------------------------
$mappingSrc = "$PROJECT_ROOT\build\app\outputs\mapping\release\mapping.txt"

if (Test-Path $mappingSrc) {
    Copy-Item -Path $mappingSrc -Destination "$OUTDIR\mapping.txt" -Force
    Write-Host "[OK] Copied mapping.txt from $mappingSrc"
} else {
    Write-Host "[ERROR] mapping.txt not found at: $mappingSrc"
}

# ---- Get native debug symbols and create zip -------------------
$nativeLibsDir = "$PROJECT_ROOT\build\app\intermediates\flutter\release"
Write-Host "[INFO] Native libraries directory: $nativeLibsDir"

# Check if the directory exists
if (Test-Path $nativeLibsDir) {
    Write-Host "[INFO] Native libraries directory found, proceeding..."
    
    # Define the output zip file path
    $symbolsZip = "$OUTDIR\native-debug-symbols.zip"
    Write-Host "[ZIP] Creating symbols zip file: $symbolsZip"
    
    # Create an empty ZIP file with proper bytes
    $zipHeaderBytes = @(80, 75, 5, 6) + (,0 * 18)
    [System.IO.File]::WriteAllBytes($symbolsZip, $zipHeaderBytes)
    
    # Use Shell.Application (Windows Explorer method)
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($symbolsZip)
    
    # Find architecture folders
    $architectureDirs = @()
    foreach ($arch in @("arm64-v8a", "armeabi-v7a", "x86_64")) {
        $archPath = "$nativeLibsDir\$arch"
        if (Test-Path $archPath) {
            $architectureDirs += $archPath
            Write-Host "[INFO] Found architecture: $arch"
        }
    }
    
    if ($architectureDirs.Count -gt 0) {
        # Add all architecture folders to the zip
        Write-Host "[ZIP] Adding architecture folders to zip file..."
        foreach ($dir in $architectureDirs) {
            Write-Host "[ZIP] Adding: $dir"
            $zipFile.CopyHere($dir)
            # Wait for a moment to allow the operation to start
            Start-Sleep -Seconds 2
        }
        
        # Wait for zip operation to complete
        Write-Host "[ZIP] Waiting for zip operation to complete..."
        Start-Sleep -Seconds 5
        
        if (Test-Path $symbolsZip) {
            $fileSize = (Get-Item $symbolsZip).Length
            Write-Host "[SUCCESS] Created native-debug-symbols.zip at: $symbolsZip (Size: $fileSize bytes)"
        } else {
            Write-Host "[ERROR] Failed to create symbols zip file"
        }
    } else {
        Write-Host "[ERROR] No architecture folders found in $nativeLibsDir"
    }
} else {
    Write-Host "[WARNING] Native libraries directory not found at: $nativeLibsDir"
}

Write-Host "[DONE] Android symbols + mapping saved to: $OUTDIR"
