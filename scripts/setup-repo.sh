#!/bin/bash

# 使い方: ./setup-repo.sh <owner>/<repo> [--templates-only]
# 例: ./setup-repo.sh dele/new-project
#     ./setup-repo.sh dele/new-project --templates-only

REPO=$1
OPTION=$2
TEMPLATE_DIR=$(dirname "$0")/..

if [ -z "$REPO" ]; then
    echo "使い方: ./setup-repo.sh <owner>/<repo> [--templates-only]"
    echo "オプション:"
    echo "  --templates-only  Issue/PR templateのみをコピー（ポリシー文書は除外）"
    exit 1
fi

echo "📁 $REPO にテンプレートファイルをコピーしています..."

# リポジトリをクローン
TEMP_DIR=$(mktemp -d)
gh repo clone "$REPO" "$TEMP_DIR" -- --depth=1

# .githubディレクトリを作成
mkdir -p "$TEMP_DIR/.github"

# Issue templatesをコピー
if [ -d "$TEMPLATE_DIR/ISSUE_TEMPLATE" ]; then
    mkdir -p "$TEMP_DIR/.github/ISSUE_TEMPLATE"
    cp "$TEMPLATE_DIR/ISSUE_TEMPLATE"/*.md "$TEMP_DIR/.github/ISSUE_TEMPLATE/" 2>/dev/null || true
    echo "✅ Issue templates をコピーしました"
fi

# PR templateをコピー
if [ -f "$TEMPLATE_DIR/PULL_REQUEST_TEMPLATE.md" ]; then
    cp "$TEMPLATE_DIR/PULL_REQUEST_TEMPLATE.md" "$TEMP_DIR/.github/"
    echo "✅ PR template をコピーしました"
fi

# --templates-only オプションが指定されていない場合は、ポリシー文書もコピー
if [ "$OPTION" != "--templates-only" ]; then
    # その他のファイルをコピー
    for file in SECURITY.md CONTRIBUTING.md CODE_OF_CONDUCT.md; do
        if [ -f "$TEMPLATE_DIR/$file" ]; then
            cp "$TEMPLATE_DIR/$file" "$TEMP_DIR/.github/"
            echo "✅ $file をコピーしました"
        fi
    done
fi

# 変更をコミット＆プッシュ
cd "$TEMP_DIR"
git add .
if git diff --staged --quiet; then
    echo "変更はありません"
else
    git commit -m "Add organization templates and configuration files"
    git push
    echo "✅ テンプレートファイルをプッシュしました"
fi

# 一時ディレクトリを削除
rm -rf "$TEMP_DIR"

echo "✨ 完了しました！"