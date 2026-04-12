#!/usr/bin/env bash
set -euo pipefail

REPO="koompi/nimmit-brain"
RESTRICTED_FILES=("SOUL.md" "IDENTITY.md")
RESTRICTED_PATTERNS=("approval" "approval-gate")

check_gh() {
  command -v gh >/dev/null 2>&1 || { echo "Error: gh CLI required. Install: https://cli.github.com"; exit 1; }
}

main() {
  check_gh

  echo "=== Open PRs for $REPO ==="
  echo

  pr_list=$(gh pr list --repo "$REPO" --state open --json number,title,files --limit 50)

  if [ -z "$pr_list" ] || [ "$pr_list" = "[]" ]; then
    echo "No open PRs."
    exit 0
  fi

  echo "$pr_list" | jq -r '.[] | "PR #\(.number): \(.title)"'

  echo
  echo "=== Review Checklist ==="
  echo

  echo "$pr_list" | jq -c '.[]' | while read -r pr; do
    number=$(echo "$pr" | jq -r '.number')
    title=$(echo "$pr" | jq -r '.title')
    files=$(echo "$pr" | jq -r '.files[].path')

    echo "--- PR #$number: $title ---"
    echo

    restricted=false
    while IFS= read -r f; do
      [ -z "$f" ] && continue

      for rf in "${RESTRICTED_FILES[@]}"; do
        if [[ "$f" == *"$rf"* ]]; then
          echo "  ⛔ RESTRICTED: $f (touches $rf)"
          restricted=true
        fi
      done
    done <<< "$files"

    if ! $restricted; then
      echo "  ✅ No restricted files touched"
    fi

    echo "  📁 Files: $(echo "$files" | tr '\n' ', ' | sed 's/,$//')"
    echo

    echo "  Checklist:"
    echo "  - [ ] One change per PR?"
    echo "  - [ ] Lesson explained?"
    echo "  - [ ] No credentials/secrets?"
    echo "  - [ ] No vendor lock-in?"
    echo "  - [ ] Markdown formatting OK?"
    echo
  done
}

main "$@"
