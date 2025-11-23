#!/bin/bash

# dele組織の全リポジトリにテンプレートを適用
# 使い方: ./setup-all-repos.sh [--templates-only]

echo "🔍 dele組織のリポジトリ一覧を取得中..."

# 組織の全リポジトリを取得
REPOS=$(gh repo list dele --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')

echo "📋 見つかったリポジトリ:"
echo "$REPOS"
echo ""

OPTION=$1
if [ "$OPTION" = "--templates-only" ]; then
    echo "✅ Issue/PR templateのみをコピーします"
else
    echo "✅ すべてのファイルをコピーします"
fi
echo ""

read -p "これらのリポジトリにテンプレートを適用しますか？ (y/N): " confirm

if [[ $confirm == [yY] ]]; then
    for repo in $REPOS; do
        # .githubリポジトリ自身はスキップ
        if [[ $repo == "dele/.github" ]]; then
            continue
        fi
        
        echo "📦 処理中: $repo"
        ./setup-repo.sh "$repo" $OPTION
        echo ""
    done
    echo "✅ すべて完了しました！"
else
    echo "❌ キャンセルしました"
fi