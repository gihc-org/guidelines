#!/usr/bin/env bash
# Sæt et nyt projekt op med guidelines og AGENTS.md-skelet.
# Kør fra projektets rodmappe: bash ~/projects/guidelines/new-project-setup.sh

set -e

GUIDELINES_DIR="$(cd "$(dirname "$0")" && pwd)"

# .guidelines symlink
if [ ! -L .guidelines ]; then
  ln -s "$GUIDELINES_DIR" .guidelines
  echo "✓ .guidelines → $GUIDELINES_DIR"
else
  echo "– .guidelines findes allerede"
fi

# .gitignore
if ! grep -q "^\.guidelines$" .gitignore 2>/dev/null; then
  echo ".guidelines" >> .gitignore
  echo "✓ .guidelines tilføjet til .gitignore"
fi

# AGENTS.md
if [ ! -f AGENTS.md ]; then
  cp "$GUIDELINES_DIR/AGENTS.template.md" AGENTS.md
  echo "✓ AGENTS.md oprettet fra template"
else
  echo "– AGENTS.md findes allerede"
fi

# CLAUDE.md
if [ ! -f CLAUDE.md ]; then
  echo "@AGENTS.md" > CLAUDE.md
  echo "✓ CLAUDE.md oprettet"
else
  echo "– CLAUDE.md findes allerede"
fi

echo ""
echo "Klar. Udfyld AGENTS.md og fjern de guidelines du ikke bruger."
