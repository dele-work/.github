#!/bin/bash

# エイリアスをシェルの設定ファイルに追加

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 使用しているシェルを判定
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    echo "サポートされていないシェルです"
    exit 1
fi

# エイリアスを追加
echo "" >> "$SHELL_CONFIG"
echo "# dele organization repo setup" >> "$SHELL_CONFIG"
echo "alias dele-setup='$SCRIPT_DIR/setup-repo.sh'" >> "$SHELL_CONFIG"

echo "✅ エイリアスを追加しました"
echo "📝 以下のコマンドで新しいリポジトリをセットアップできます:"
echo "   dele-setup dele/repository-name"
echo ""
echo "変更を反映するには以下を実行してください:"
echo "   source $SHELL_CONFIG"