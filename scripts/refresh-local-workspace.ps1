[CmdletBinding()]
param(
    [string]$Remote = "origin"
)

$ErrorActionPreference = "Stop"

# SecureDelivery - Atualização local segura do workspace
#
# Objetivo:
# - buscar todas as referências mais recentes do remoto;
# - fazer fast-forward das branches locais quando for seguro;
# - repetir o processo em todos os submódulos;
# - nunca executar push, reset --hard, rebase ou merge commit.
#
# Uso:
#   .\scripts\refresh-local-workspace.ps1
#   .\scripts\refresh-local-workspace.ps1 -Remote origin
#
# Regras:
# - branch local atrás do remoto -> fast-forward;
# - branch local igual ao remoto -> nada;
# - branch local à frente -> preservada;
# - branch divergida -> preservada + aviso;
# - branch atual com working tree suja -> não é movimentada;
# - branch em outro worktree -> não é movimentada.

function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
    Write-Host "[ OK ] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Err([string]$Message) {
    Write-Host "[ERRO] $Message" -ForegroundColor Red
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [switch]$AllowFailure
    )

    & git @Arguments
    $exitCode = $LASTEXITCODE

    if (-not $AllowFailure -and $exitCode -ne 0) {
        throw "Falha ao executar: git $($Arguments -join ' ')"
    }

    return $exitCode
}

function Test-DirtyWorkingTree {
    $status = & git status --porcelain --untracked-files=normal
    return -not [string]::IsNullOrWhiteSpace(($status -join "`n"))
}

function Get-CheckedOutBranches {
    $lines = & git worktree list --porcelain 2>$null
    $branches = @()

    foreach ($line in $lines) {
        if ($line -match '^branch refs/heads/(.+)$') {
            $branches += $Matches[1]
        }
    }

    return $branches
}

function Test-BranchCheckedOut {
    param([string]$Branch)

    return (Get-CheckedOutBranches) -contains $Branch
}

function Test-IsAncestor {
    param(
        [string]$Ancestor,
        [string]$Descendant
    )

    & git merge-base --is-ancestor $Ancestor $Descendant 2>$null
    return $LASTEXITCODE -eq 0
}

function Update-LocalBranches {
    param([string]$RepoLabel)

    & git remote get-url $Remote *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "$RepoLabel`: remoto '$Remote' não existe. Pulando."
        return
    }

    Write-Info "$RepoLabel`: git fetch $Remote --prune --tags"
    Invoke-Git -Arguments @("fetch", $Remote, "--prune", "--tags") | Out-Null

    $currentBranch = (& git symbolic-ref --short -q HEAD 2>$null)
    if ($LASTEXITCODE -ne 0) {
        $currentBranch = $null
    }

    $currentDirty = Test-DirtyWorkingTree

    $branches = & git for-each-ref --format="%(refname:short)" refs/heads/

    foreach ($branch in $branches) {
        if ([string]::IsNullOrWhiteSpace($branch)) {
            continue
        }

        $localRef = "refs/heads/$branch"
        $remoteRef = "refs/remotes/$Remote/$branch"

        & git show-ref --verify --quiet $remoteRef
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "$RepoLabel`: '$branch' não possui '$Remote/$branch'. Preservada."
            continue
        }

        $localSha = (& git rev-parse $localRef).Trim()
        $remoteSha = (& git rev-parse $remoteRef).Trim()

        if ($localSha -eq $remoteSha) {
            Write-Ok "$RepoLabel`: $branch já está atualizada."
            continue
        }

        if (Test-IsAncestor -Ancestor $localRef -Descendant $remoteRef) {
            if ($branch -eq $currentBranch) {
                if ($currentDirty) {
                    Write-Warn "$RepoLabel`: $branch está atrás, mas o working tree possui alterações. Não atualizada."
                    continue
                }

                Write-Info "$RepoLabel`: fast-forward da branch atual '$branch'."
                & git merge --ff-only $remoteRef
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$RepoLabel`: $branch atualizada para $Remote/$branch."
                }
                else {
                    Write-Err "$RepoLabel`: não foi possível fazer fast-forward de '$branch'."
                }
            }
            else {
                if (Test-BranchCheckedOut -Branch $branch) {
                    Write-Warn "$RepoLabel`: $branch está aberta em outro worktree. Não atualizada."
                    continue
                }

                Write-Info "$RepoLabel`: fast-forward do ponteiro local '$branch' sem checkout."
                & git branch -f $branch $remoteRef *> $null
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$RepoLabel`: $branch atualizada para $Remote/$branch."
                }
                else {
                    Write-Err "$RepoLabel`: não foi possível atualizar '$branch'."
                }
            }

            continue
        }

        if (Test-IsAncestor -Ancestor $remoteRef -Descendant $localRef) {
            Write-Warn "$RepoLabel`: $branch possui commits locais à frente de $Remote/$branch. Preservada."
            continue
        }

        Write-Warn "$RepoLabel`: $branch divergiu de $Remote/$branch. Resolva manualmente; nada foi alterado."
    }
}

function Update-Repository {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        Write-Warn "$Label`: diretório inexistente. Pulando."
        return
    }

    Push-Location $Path

    try {
        & git rev-parse --is-inside-work-tree *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "$Label`: não é um repositório Git. Pulando."
            return
        }

        Write-Host ""
        Write-Info "===== $Label ====="
        Update-LocalBranches -RepoLabel $Label
    }
    finally {
        Pop-Location
    }
}

& git rev-parse --show-toplevel *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Execute este script dentro de um repositório Git."
}

$Root = (& git rev-parse --show-toplevel).Trim()

Write-Host ""
Write-Info "SecureDelivery - refresh local seguro"
Write-Info "Workspace: $Root"
Write-Info "Remoto:    $Remote"

# Atualiza o superprojeto.
Update-Repository -Path $Root -Label "workspace principal"

$gitmodules = Join-Path $Root ".gitmodules"

if (Test-Path -LiteralPath $gitmodules -PathType Leaf) {
    Push-Location $Root

    try {
        Write-Host ""
        Write-Info "Sincronizando configuração dos submódulos..."
        Invoke-Git -Arguments @("submodule", "sync", "--recursive") | Out-Null

        Write-Info "Inicializando submódulos ausentes..."
        Invoke-Git -Arguments @("submodule", "update", "--init", "--recursive") | Out-Null

        $submoduleLines = & git submodule status --recursive 2>$null
        $submodulePaths = @()

        foreach ($line in $submoduleLines) {
            $trimmed = $line.Trim()

            # Formato normal:
            # <prefix><sha> path (describe)
            if ($trimmed -match '^[+\-U ]?[0-9a-fA-F]+\s+([^\s]+)') {
                $submodulePaths += $Matches[1]
            }
        }

        $submodulePaths = $submodulePaths | Sort-Object -Unique
    }
    finally {
        Pop-Location
    }

    foreach ($submodulePath in $submodulePaths) {
        $fullPath = Join-Path $Root $submodulePath
        Update-Repository -Path $fullPath -Label "submódulo: $submodulePath"
    }
}
else {
    Write-Info "Nenhum .gitmodules encontrado."
}

Write-Host ""
Write-Ok "Refresh concluído."
Write-Info "Nenhum push, rebase, reset --hard ou merge commit foi executado."
Write-Info "Branches divergidas ou com commits locais foram preservadas."
