#!/bin/bash

EXCLUDE_FILES=(
    "$(realpath "$0")"
)

TARGET_DIR="$1"
CUSTOM_MSG="$2"

if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$(pwd)"
else
    TARGET_DIR="${TARGET_DIR//\\//}"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "❌ Directory not found: $TARGET_DIR"
        exit 1
    fi
    cd "$TARGET_DIR" || exit 1
fi

if [ ! -d ".git" ]; then
    echo "❌ Not a Git repository (no .git folder found in '$TARGET_DIR')."
    exit 1
fi

CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
if [ -z "$CURRENT_BRANCH" ]; then
    echo "❌ No current branch found. Please switch to a valid branch."
    exit 1
fi

LAST_MSG=$(git log -1 --pretty=%B 2>/dev/null)
if [ -z "$LAST_MSG" ]; then
    echo "❌ No commits exist on this branch. Cannot proceed."
    exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  There are uncommitted changes in your working directory."
    echo "   Please commit or stash them first, then re-run this script."
    exit 1
fi

if [ -z "$CUSTOM_MSG" ]; then
    CUSTOM_MSG="$LAST_MSG"
fi

echo "✅ Resetting history to a single commit with message: '$CUSTOM_MSG'"

git checkout --orphan temp_clean_branch

git add -A

for file in "${EXCLUDE_FILES[@]}"; do
    if [ -e "$file" ]; then
        rel_path=$(realpath --relative-to="$TARGET_DIR" "$file" 2>/dev/null || echo "$file")
        if git ls-files --error-unmatch "$rel_path" >/dev/null 2>&1 || [ -f "$rel_path" ]; then
            git reset HEAD -- "$rel_path" 2>/dev/null || git rm --cached "$rel_path" 2>/dev/null
        fi
    fi
done

git commit -m "$CUSTOM_MSG"

git branch -D "$CURRENT_BRANCH"

git branch -m "$CURRENT_BRANCH"

echo "✅ Done! Your branch '$CURRENT_BRANCH' now has exactly one commit."
echo "   Commit message: '$CUSTOM_MSG'"
echo ""
echo "🔔 To push to remote (overwriting history), use:"
echo "   git push --force-with-lease origin $CURRENT_BRANCH"