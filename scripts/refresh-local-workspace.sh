#!/usr/bin/env bash
set -u

# SecureDelivery - Atualização local segura do workspace
#
# Objetivo:
# - buscar todas as referências mais recentes do remoto;
# - fazer fast-forward das branches locais quando for seguro;
# - repetir o processo em todos os submódulos;
# - nunca executar push, reset --hard, rebase ou merge commit.
#
# Uso:
#   ./scripts/refresh-local-workspace.sh
#
# Opcional:
#   ./scripts/refresh-local-workspace.sh --remote origin
#
# Regras:
# - branch local atrás do remoto -> fast-forward;
# - branch local igual ao remoto -> nada;
# - branch local à frente -> preservada;
# - branch divergida -> preservada + aviso;
# - branch atual com working tree suja -> não é movimentada;
# - branch em outro worktree -> não é movimentada.

REMOTE="origin"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      REMOTE="${2:-}"
      if [[ -z "$REMOTE" ]]; then
        echo "ERRO: --remote exige um nome."
        exit 2
      fi
      shift 2
      ;;
    -h|--help)
      sed -n '1,35p' "$0"
      exit 0
      ;;
    *)
      echo "ERRO: argumento desconhecido: $1"
      exit 2
      ;;
  esac
done

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERRO: execute este script dentro de um repositório Git."
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)"

info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m[ OK ]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m[ERRO]\033[0m %s\n' "$*"; }

is_dirty() {
  [[ -n "$(git status --porcelain --untracked-files=normal)" ]]
}

checked_out_branches() {
  git worktree list --porcelain 2>/dev/null |
    awk '/^branch refs\/heads\// {
      sub(/^branch refs\/heads\//, "", $0)
      print $0
    }'
}

branch_is_checked_out() {
  local branch="$1"
  checked_out_branches | grep -Fxq "$branch"
}

refresh_local_branches() {
  local repo_label="$1"

  if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
    warn "$repo_label: remoto '$REMOTE' não existe. Pulando."
    return 0
  fi

  info "$repo_label: git fetch $REMOTE --prune --tags"
  if ! git fetch "$REMOTE" --prune --tags; then
    error "$repo_label: falha no fetch."
    return 1
  fi

  local current_branch
  current_branch="$(git symbolic-ref --short -q HEAD || true)"

  local current_dirty="false"
  if is_dirty; then
    current_dirty="true"
  fi

  local branch
  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue

    local remote_ref="refs/remotes/$REMOTE/$branch"
    local local_ref="refs/heads/$branch"

    if ! git show-ref --verify --quiet "$remote_ref"; then
      warn "$repo_label: '$branch' não possui '$REMOTE/$branch'. Preservada."
      continue
    fi

    local local_sha remote_sha
    local_sha="$(git rev-parse "$local_ref")"
    remote_sha="$(git rev-parse "$remote_ref")"

    if [[ "$local_sha" == "$remote_sha" ]]; then
      ok "$repo_label: $branch já está atualizada."
      continue
    fi

    # Local está atrás: local é ancestral do remoto.
    if git merge-base --is-ancestor "$local_ref" "$remote_ref"; then
      if [[ "$branch" == "$current_branch" ]]; then
        if [[ "$current_dirty" == "true" ]]; then
          warn "$repo_label: $branch está atrás, mas o working tree possui alterações. Não atualizada."
          continue
        fi

        info "$repo_label: fast-forward da branch atual '$branch'."
        if git merge --ff-only "$remote_ref"; then
          ok "$repo_label: $branch atualizada para $REMOTE/$branch."
        else
          error "$repo_label: não foi possível fazer fast-forward de '$branch'."
        fi
      else
        if branch_is_checked_out "$branch"; then
          warn "$repo_label: $branch está aberta em outro worktree. Não atualizada."
          continue
        fi

        info "$repo_label: fast-forward do ponteiro local '$branch' sem checkout."
        if git branch -f "$branch" "$remote_ref" >/dev/null; then
          ok "$repo_label: $branch atualizada para $REMOTE/$branch."
        else
          error "$repo_label: não foi possível atualizar '$branch'."
        fi
      fi

      continue
    fi

    # Remoto é ancestral do local: há commits locais ainda não presentes no remoto.
    if git merge-base --is-ancestor "$remote_ref" "$local_ref"; then
      warn "$repo_label: $branch possui commits locais à frente de $REMOTE/$branch. Preservada."
      continue
    fi

    # Nenhum é ancestral do outro.
    warn "$repo_label: $branch divergiu de $REMOTE/$branch. Resolva manualmente; nada foi alterado."
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)
}

refresh_repo_path() {
  local path="$1"
  local label="$2"

  if [[ ! -d "$path" ]]; then
    warn "$label: diretório inexistente. Pulando."
    return 0
  fi

  (
    cd "$path" || exit 1

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      warn "$label: não é um repositório Git. Pulando."
      exit 0
    fi

    echo
    info "===== $label ====="
    refresh_local_branches "$label"
  )
}

cd "$ROOT" || exit 1

echo
info "SecureDelivery - refresh local seguro"
info "Workspace: $ROOT"
info "Remoto:    $REMOTE"

# Atualiza primeiro o superprojeto.
refresh_repo_path "$ROOT" "workspace principal"

# Sincroniza configuração e inicializa submódulos no commit registrado,
# sem buscar branch remota automaticamente.
if [[ -f "$ROOT/.gitmodules" ]]; then
  echo
  info "Sincronizando configuração dos submódulos..."
  git submodule sync --recursive

  info "Inicializando submódulos ausentes..."
  git submodule update --init --recursive

  # git submodule status --recursive retorna os paths relativos ao top-level.
  mapfile -t SUBMODULE_PATHS < <(
    git submodule status --recursive 2>/dev/null |
      awk '{print $2}' |
      sort -u
  )

  for submodule_path in "${SUBMODULE_PATHS[@]}"; do
    refresh_repo_path "$ROOT/$submodule_path" "submódulo: $submodule_path"
  done
else
  info "Nenhum .gitmodules encontrado."
fi

echo
ok "Refresh concluído."
info "Nenhum push, rebase, reset --hard ou merge commit foi executado."
info "Branches divergidas ou com commits locais foram preservadas."
