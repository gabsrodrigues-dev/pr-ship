pr-ship() {
  local input_repo="$1"
  local head="${2:-development}"
  local base="${3:-sandbox}"

  if [[ -z "$input_repo" ]]; then
    echo "❌ Erro: informe o repositório (ex: autor/repo ou apenas repo)"
    return 1
  fi

  # Se não tiver "/", adiciona o owner padrão
  if [[ "$input_repo" != */* ]]; then
    repo="gabsrodrigues-dev/$input_repo"
  else
    repo="$input_repo"
  fi

  local owner="${repo%%/*}"
  local repo_name="${repo##*/}"

  echo "📦 Repositório: $repo"
  echo "🌿 Branch origem (head): $head"
  echo "🎯 Branch destino (base): $base"
  echo "🚀 Criando Pull Request..."

  pr_number=$(gh api repos/"$owner"/"$repo_name"/pulls \
    -f title="Merge via terminal" \
    -f head="$head" \
    -f base="$base" \
    -f body="Criando PR e executando o Merge via pr-ship — by Gabs" \
    --jq .number 2>/dev/null)

  if [[ -z "$pr_number" ]]; then
    echo "❌ Erro ao criar PR"
    return 1
  fi

  echo "✅ PR criado com sucesso!"
  echo "🔗 https://github.com/$repo/pull/$pr_number"

  echo "🔀 Executando merge..."
  gh api repos/"$owner"/"$repo_name"/pulls/"$pr_number"/merge \
    -X PUT \
    -f merge_method=merge \
    --jq '"✅ Merge realizado: \(.merged)"' || {
      echo "❌ Erro ao fazer merge"
      return 1
    }

  echo "🎉 Processo finalizado com sucesso!"
}
