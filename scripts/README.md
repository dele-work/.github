# Organization Template Setup Scripts

dele organizationの新規リポジトリに組織標準のテンプレートファイル（Issue templates、PR template、各種ポリシー文書）を自動的に適用するためのスクリプト集です。

## 背景

GitHubの組織レベルの`.github`リポジトリは、publicでないと自動的にデフォルトファイルが適用されません。このスクリプトは、privateな`.github`リポジトリからでもテンプレートファイルを新規リポジトリにコピーできるようにします。

## 前提条件

- GitHub CLI (`gh`) がインストールされていること
- `gh auth login` で認証済みであること
- dele organizationのリポジトリへの書き込み権限があること

## スクリプト一覧

### 1. interactive-setup.sh
インタラクティブにリポジトリを選択してテンプレートファイルを適用します。

```bash
./interactive-setup.sh
```

**機能:**
- Organization名を入力
- リポジトリ一覧を表示（説明、公開設定、最終更新日付き）
- 複数のリポジトリを選択可能
  - 個別選択: `1 3 5`
  - 範囲選択: `1-5`
  - 全選択: `all`
- 選択したリポジトリに一括でテンプレートを適用

### 2. setup-repo.sh
単一のリポジトリにテンプレートファイルを適用します。

```bash
# すべてのファイルをコピー
./setup-repo.sh dele/repository-name

# Issue/PR templateのみをコピー（ポリシー文書は除外）
./setup-repo.sh dele/repository-name --templates-only
```

**動作内容:**
- 指定されたリポジトリをクローン
- `.github`ディレクトリを作成
- 以下のファイルをコピー:
  - Issue templates (ISSUE_TEMPLATE/*.md)
  - Pull Request template (PULL_REQUEST_TEMPLATE.md)
  - セキュリティポリシー (SECURITY.md)
  - コントリビューションガイド (CONTRIBUTING.md)
  - 行動規範 (CODE_OF_CONDUCT.md)
- 変更をコミット＆プッシュ

### 3. setup-all-repos.sh
dele organization内の全リポジトリに一括でテンプレートを適用します。

```bash
# すべてのファイルをコピー
./setup-all-repos.sh

# Issue/PR templateのみをコピー
./setup-all-repos.sh --templates-only
```

**動作内容:**
- 組織内の全リポジトリ一覧を取得
- 確認プロンプトを表示
- 各リポジトリに対して`setup-repo.sh`を実行

### 4. install-alias.sh
シェルにエイリアスを追加して、どこからでも簡単にスクリプトを実行できるようにします。

```bash
# インストール（初回のみ）
./install-alias.sh

# シェル設定を再読み込み
source ~/.zshrc  # またはsource ~/.bashrc

# 以降は以下のコマンドで実行可能
dele-setup dele/repository-name
```

## 使用例

### インタラクティブモードでの使用例

```bash
# 1. インタラクティブセットアップを起動
./scripts/interactive-setup.sh

# 2. Organization名を入力
> dele

# 3. リポジトリ一覧が表示される
[番号] リポジトリ名                説明                    公開設定      最終更新
[ 1] dele/project-a             APIサーバー              🔒 Private    2024-11-23
[ 2] dele/project-b             フロントエンド            🌍 Public     2024-11-22
[ 3] dele/project-c             共通ライブラリ            🔒 Private    2024-11-20
...

# 4. 適用したいリポジトリを選択
> 1 3          # 個別選択
> 5-10         # 範囲選択  
> all          # 全て選択

# 5. 実行確認後、選択したリポジトリに自動適用
```

### 新規リポジトリ作成時の標準的なワークフロー

```bash
# 1. 新しいリポジトリを作成
gh repo create dele/new-project --private --description "新しいプロジェクト"

# 2. テンプレートファイルを適用
cd /path/to/.github
./scripts/setup-repo.sh dele/new-project

# 3. リポジトリで開発を開始
gh repo clone dele/new-project
cd new-project
```

### 既存リポジトリへの適用

```bash
# 特定のリポジトリに適用
./scripts/setup-repo.sh dele/existing-repo

# または全リポジトリに一括適用
./scripts/setup-all-repos.sh
```

## コピーされるファイル

| ファイル | 説明 | 配置場所 |
|---------|------|----------|
| BUG_REPORT.md | バグ報告用テンプレート | .github/ISSUE_TEMPLATE/ |
| FEATURE_REQUEST.md | 機能要望用テンプレート | .github/ISSUE_TEMPLATE/ |
| DATA_REQUEST.md | データリクエスト用テンプレート | .github/ISSUE_TEMPLATE/ |
| IMPROVEMENT.md | 改善提案用テンプレート | .github/ISSUE_TEMPLATE/ |
| INVESTIGATION.md | 調査依頼用テンプレート | .github/ISSUE_TEMPLATE/ |
| SPEC_CLARIFICATION.md | 仕様確認用テンプレート | .github/ISSUE_TEMPLATE/ |
| PULL_REQUEST_TEMPLATE.md | プルリクエストテンプレート | .github/ |
| SECURITY.md | セキュリティポリシー | .github/ |
| CONTRIBUTING.md | コントリビューションガイド | .github/ |
| CODE_OF_CONDUCT.md | 行動規範 | .github/ |

## 注意事項

- 既存のファイルがある場合は上書きされます
- `.github`リポジトリ自体には適用されません（無限ループ防止）
- 変更がない場合はコミットされません

## トラブルシューティング

### 権限エラーが発生する場合
```bash
# GitHub CLIの再認証
gh auth refresh

# 必要な権限があるか確認
gh auth status
```

### スクリプトが実行できない場合
```bash
# 実行権限を付与
chmod +x scripts/*.sh
```

### リポジトリが見つからない場合
- リポジトリ名が正しいか確認（`owner/repo`形式）
- プライベートリポジトリへのアクセス権限があるか確認

## カスタマイズ

テンプレートファイルを追加・変更したい場合は、`.github`リポジトリのルートディレクトリにファイルを配置し、`setup-repo.sh`スクリプトの該当箇所を編集してください。

```bash
# 例: 新しいファイルを追加する場合
# setup-repo.shの「その他のファイルをコピー」セクションに追加
for file in SECURITY.md CONTRIBUTING.md CODE_OF_CONDUCT.md YOUR_NEW_FILE.md; do
    # ...
done
```