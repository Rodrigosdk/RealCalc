#!/usr/bin/env bash
# Atualiza as dependências compatíveis (dentro do ^ atual) e gera os textos da issue e do PR
# no formato dos templates do projeto. Usado pelo workflow dependency-update.yml.
#
# Uso: scripts/update_dependencies.sh <pasta_de_saida>
# Gera em <pasta_de_saida>:
#   changes.md   tabela com os pacotes atualizados (vazia se nada mudou)
#   majors.md    tabela com as versões major disponíveis que exigem mudança manual
#   reason.txt   motivo da atualização (segurança ou manutenção de rotina)
#   direct.txt   uma linha "pacote: antiga → nova" por dependência direta atualizada
#   changed      "true" se o pubspec.lock mudou, "false" caso contrário
set -euo pipefail

out="${1:?informe a pasta de saída}"
mkdir -p "$out"

outdated_json() {
  flutter pub outdated --json --show-all 2>/dev/null
}

before="$(outdated_json)"

flutter pub upgrade --tighten >/dev/null

after="$(outdated_json)"

pub_link() {
  echo "[changelog](https://pub.dev/packages/$1/changelog)"
}

# Pacotes cuja versão atual mudou com o upgrade.
jq -r --argjson before "$before" '
  ($before.packages | map({key: .package, value: (.current.version // "-")}) | from_entries) as $old
  | .packages[]
  | select(.current.version != null and $old[.package] != .current.version)
  | [.package, .kind, $old[.package], .current.version] | @tsv
' <<<"$after" | sort -t$'\t' -k2,2 -k1,1 >"$out/changes.tsv"

kind_label() {
  case "$1" in
    direct) echo "direta" ;;
    dev) echo "dev" ;;
    *) echo "transitiva" ;;
  esac
}

table_header() {
  echo "| Pacote | Tipo | Versão atual → nova | Changelog |"
  echo "| --- | --- | --- | --- |"
}

table_rows() {
  while IFS=$'\t' read -r pkg kind old new; do
    echo "| \`$pkg\` | $(kind_label "$kind") | $old → $new | $(pub_link "$pkg") |"
  done
}

if [ -s "$out/changes.tsv" ]; then
  echo "true" >"$out/changed"
  direct="$(awk -F'\t' '$2 == "direct" || $2 == "dev"' "$out/changes.tsv")"
  transitive="$(awk -F'\t' '$2 != "direct" && $2 != "dev"' "$out/changes.tsv")"
  awk -F'\t' '$2 == "direct" || $2 == "dev" {print $1 ": " $3 " → " $4}' "$out/changes.tsv" >"$out/direct.txt"
  {
    if [ -n "$direct" ]; then
      table_header
      table_rows <<<"$direct"
    else
      echo "Nenhuma dependência direta mudou; só pacotes transitivos."
    fi
    if [ -n "$transitive" ]; then
      echo
      echo "<details>"
      echo "<summary>Dependências transitivas ($(wc -l <<<"$transitive"))</summary>"
      echo
      table_header
      table_rows <<<"$transitive"
      echo
      echo "</details>"
    fi
  } >"$out/changes.md"
else
  echo "false" >"$out/changed"
  : >"$out/changes.md"
  : >"$out/direct.txt"
fi

# Dependências diretas com versão nova fora do ^ atual (normalmente major): só avisa.
jq -r '
  .packages[]
  | select(.kind == "direct" or .kind == "dev")
  | select(.current.version != null and .latest.version != null)
  | select(.current.version != .latest.version)
  | [.package, .current.version, .latest.version] | @tsv
' <<<"$after" >"$out/majors.tsv"

if [ -s "$out/majors.tsv" ]; then
  {
    echo "| Pacote | Versão atual | Última versão | Changelog |"
    echo "| --- | --- | --- | --- |"
    while IFS=$'\t' read -r pkg cur latest; do
      echo "| \`$pkg\` | $cur | $latest | $(pub_link "$pkg") |"
    done <"$out/majors.tsv"
  } >"$out/majors.md"
else
  : >"$out/majors.md"
fi

# Se alguma versão anterior tinha alerta de segurança e saiu, o motivo é segurança.
if jq -e '[.packages[] | select(.isCurrentAffectedByAdvisory == true)] | length > 0' <<<"$before" >/dev/null &&
  jq -e --argjson before "$before" '
    ($before.packages | map(select(.isCurrentAffectedByAdvisory == true) | .package)) as $vuln
    | [.packages[] | select((.package | IN($vuln[])) and .isCurrentAffectedByAdvisory != true)]
    | length > 0' <<<"$after" >/dev/null; then
  echo "Correção de segurança" >"$out/reason.txt"
else
  echo "Manutenção de rotina" >"$out/reason.txt"
fi

rm -f "$out/changes.tsv" "$out/majors.tsv"
