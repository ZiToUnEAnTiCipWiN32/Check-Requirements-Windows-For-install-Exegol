# Si vous recevez une erreur indiquant que l’exécution de scripts est désactivée sur votre système,
# PowerShell -ExecutionPolicy Bypass -File Check-Requirements-Windows-For-install-Exegol.ps1

# Vérifier si le script est exécuté en tant qu'administrateur
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"

if ($isAdmin) {
    # les couleurs
    $colorGreen = "Green"
    $colorRed = "Red"

    # Obtenir l'état du service Hyper-V
    $serviceStatus = (Get-Service vmcompute).Status

    Write-Host "vmcompute (Hyper-V) => " -NoNewline
    if ($serviceStatus -eq "Running") {
        Write-Host $serviceStatus -ForegroundColor $colorGreen
    } elseif ($serviceStatus -eq "Stopped") {
        Write-Host $serviceStatus -ForegroundColor $colorRed
    } else {
        Write-Host "Le status du service vmcompute est inconnu : $serviceStatus" -ForegroundColor $colorRed
    }

    # Obtenir le système d'exploitation
    $osInfo = [System.Environment]::OSVersion.Version

    Write-Host "OSVersion => " -NoNewline
    if ($osInfo.Major -eq 10) {
        Write-Host $osInfo.Major -ForegroundColor $colorGreen
    } elseif ($osInfo.Major -eq 11) {
        Write-Host $osInfo.Major -ForegroundColor $colorGreen
    } else {
        Write-Host "OSVersion est : $osInfo.Major" -ForegroundColor $colorRed
    }

    # Obtenir le Build du système d'exploitation
    $osVersion = [System.Environment]::OSVersion.Version.Build

    # Liste des Builds KB5020030
    $buildsAVerifier = 19042, 19043, 19044, 19045 

    Write-Host "KB5020030 => " -NoNewline
    switch ($osVersion) {
        {$_ -in $buildsAVerifier} {
            Write-Host $osVersion -ForegroundColor $colorGreen
            break
        }
        default {
            Write-Host "$osVersion ne figure pas dans KB5020030" -ForegroundColor $colorRed
        }
    }

    # Vérifier si Windows Terminal est installé
    $windowsTerminalStatus = (Get-AppxPackage -Name *Microsoft.WindowsTerminal*).Status

    Write-Host "Windows Terminal => " -NoNewline
    if ($windowsTerminalStatus -eq "Ok") {
        Write-Host $windowsTerminalStatus -ForegroundColor $colorGreen
    } else {
        Write-Host "erreur $windowsTerminalStatus" -ForegroundColor $colorRed
    }

    # Vérifier si WSL est déjà activé
    $wslState = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State

    Write-Host "Windows-Subsystem-Linux => " -NoNewline
    if ($wslState -eq "Enabled") {
        Write-Host $wslState -ForegroundColor $colorGreen
    } else {
        Write-Host "erreur $wslState" -ForegroundColor $colorRed
    }

    # Vérifier si la plateforme de machine virtuelle est activée
    $virtualMachineState = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State

    Write-Host "VirtualMachinePlatform => " -NoNewline
    if ($virtualMachineState -eq "Enabled") {
        Write-Host $virtualMachineState -ForegroundColor $colorGreen
    } else {
        Write-Host "erreur $virtualMachineState" -ForegroundColor $colorRed
    }
} else {
    Write-Host "Le script necessite des droits administrateur..."
    
    # Obtenir le chemin complet du script actuel
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # Relancer le script en tant qu'administrateur
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    Exit
}

Write-Host "`nPour execute WSL vous avez besoin que 'Hyper-V' ou 'la Virtual Machine Platform' soit actif"

# Ajouter une pause pour maintenir la fenêtre ouverte
Read-Host "Appuyez sur Entree pour quitter..."