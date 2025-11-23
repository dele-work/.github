#!/bin/bash

# インタラクティブにリポジトリを選択してテンプレートを適用するスクリプト

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🔍 Organization名を入力してください (例: dele):"
read -r ORG

if [ -z "$ORG" ]; then
    echo "❌ Organization名が入力されていません"
    exit 1
fi

echo ""
echo "📋 $ORG のリポジトリ一覧を取得中..."

# リポジトリ一覧を取得
REPOS=$(gh repo list "$ORG" --limit 1000 --json nameWithOwner,description,isPrivate,updatedAt \
    --jq '.[] | "\(.nameWithOwner)|\(.description // "説明なし")|\(if .isPrivate then "🔒 Private" else "🌍 Public" end)|更新: \(.updatedAt[0:10])"' | \
    sort -t'|' -k4 -r)

if [ -z "$REPOS" ]; then
    echo "❌ リポジトリが見つかりませんでした"
    exit 1
fi

# リポジトリを配列に格納
IFS=$'\n' read -d '' -r -a REPO_ARRAY <<< "$REPOS"
SELECTED_REPOS=()

# ヘッダーを表示
printf "\n%-50s %-40s %-15s %s\n" "リポジトリ" "説明" "公開設定" "最終更新"
printf "%-50s %-40s %-15s %s\n" "$(printf '%.0s-' {1..50})" "$(printf '%.0s-' {1..40})" "$(printf '%.0s-' {1..15})" "$(printf '%.0s-' {1..10})"

# リポジトリ一覧を番号付きで表示
for i in "${!REPO_ARRAY[@]}"; do
    IFS='|' read -r name desc visibility updated <<< "${REPO_ARRAY[$i]}"
    # 説明を40文字に制限
    desc_truncated=$(echo "$desc" | cut -c1-40)
    [ ${#desc} -gt 40 ] && desc_truncated="${desc_truncated}..."
    
    printf "[%2d] %-50s %-40s %-15s %s\n" $((i+1)) "$name" "$desc_truncated" "$visibility" "$updated"
done

echo ""
echo "📝 テンプレートを適用したいリポジトリの番号を入力してください"
echo "   複数選択する場合は、スペース区切りで入力 (例: 1 3 5)"
echo "   範囲指定も可能 (例: 1-5 または all で全て選択)"
echo "   終了するには 'q' を入力"
echo ""

while true; do
    read -r -p "> " selection
    
    if [ "$selection" = "q" ]; then
        break
    elif [ "$selection" = "all" ]; then
        # 全て選択
        for i in "${!REPO_ARRAY[@]}"; do
            repo_name=$(echo "${REPO_ARRAY[$i]}" | cut -d'|' -f1)
            SELECTED_REPOS+=("$repo_name")
        done
        break
    else
        # 選択をパース
        for item in $selection; do
            if [[ $item =~ ^[0-9]+-[0-9]+$ ]]; then
                # 範囲指定 (例: 1-5)
                start=$(echo "$item" | cut -d'-' -f1)
                end=$(echo "$item" | cut -d'-' -f2)
                for ((n=start; n<=end && n<=${#REPO_ARRAY[@]}; n++)); do
                    repo_name=$(echo "${REPO_ARRAY[$((n-1))]}" | cut -d'|' -f1)
                    if [[ ! " ${SELECTED_REPOS[@]} " =~ " ${repo_name} " ]]; then
                        SELECTED_REPOS+=("$repo_name")
                    fi
                done
            elif [[ $item =~ ^[0-9]+$ ]]; then
                # 単一選択
                if [ "$item" -ge 1 ] && [ "$item" -le "${#REPO_ARRAY[@]}" ]; then
                    repo_name=$(echo "${REPO_ARRAY[$((item-1))]}" | cut -d'|' -f1)
                    if [[ ! " ${SELECTED_REPOS[@]} " =~ " ${repo_name} " ]]; then
                        SELECTED_REPOS+=("$repo_name")
                    fi
                fi
            fi
        done
        
        # 現在の選択を表示
        echo ""
        echo "✅ 現在選択中のリポジトリ:"
        for repo in "${SELECTED_REPOS[@]}"; do
            echo "   - $repo"
        done
        echo ""
        echo "他にも選択しますか？ (番号を入力、または 'q' で確定)"
    fi
done

if [ ${#SELECTED_REPOS[@]} -eq 0 ]; then
    echo "❌ リポジトリが選択されていません"
    exit 0
fi

echo ""
echo "📦 以下の${#SELECTED_REPOS[@]}個のリポジトリにテンプレートを適用します:"
for repo in "${SELECTED_REPOS[@]}"; do
    echo "   - $repo"
done

echo ""
echo "📋 コピーするファイルを選択してください:"
echo "  [1] すべてのファイル（Issue/PR template + ポリシー文書）"
echo "  [2] Issue/PR templateのみ（SECURITY.md等は除外）"
read -r -p "選択 (1-2): " file_choice

if [ "$file_choice" = "2" ]; then
    COPY_OPTION="--templates-only"
    echo ""
    echo "✅ Issue/PR templateのみをコピーします"
else
    COPY_OPTION=""
    echo ""
    echo "✅ すべてのファイルをコピーします"
fi

echo ""
read -p "実行しますか？ (y/N): " confirm

if [[ $confirm == [yY] ]]; then
    echo ""
    for repo in "${SELECTED_REPOS[@]}"; do
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 処理中: $repo"
        "$SCRIPT_DIR/setup-repo.sh" "$repo" $COPY_OPTION
        echo ""
    done
    echo "✨ すべて完了しました！"
else
    echo "❌ キャンセルしました"
fi