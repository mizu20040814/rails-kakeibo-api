# 家計簿 API

家計の支出を管理するための RESTful API です。支出の登録・取得・更新・削除に加え、月次・年次の集計やカテゴリ別集計機能を提供します。

## 技術スタック

- Ruby 3.4.5
- Rails 8.1.2 (API モード)
- PostgreSQL
- Dev Container (Docker Compose)

### テスト・品質管理

- RSpec + FactoryBot + DatabaseCleaner
- RuboCop（静的解析・コードスタイル）
- Brakeman（セキュリティ静的解析）
- bundler-audit（Gem の脆弱性チェック）

## 開発環境のセットアップ

本プロジェクトは **Dev Container** を使用しており、VS Code または GitHub Codespaces で統一された開発環境を利用できます。

### 前提条件

- [Docker](https://www.docker.com/)
- [VS Code](https://code.visualstudio.com/) + [Dev Containers 拡張機能](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

または

- [GitHub Codespaces](https://github.com/features/codespaces)

### 起動手順

1. リポジトリをクローン

    ```bash
    git clone <repository-url>
    ```

2. VS Code でフォルダを開き、「Reopen in Container」を選択（または Codespaces で開く）

3. コンテナが起動したら、ターミナルで以下を実行

    ```bash
    # 依存パッケージのインストール・DB 準備
    bin/setup

    # または個別に実行する場合
    bundle install
    bin/rails db:create db:migrate

    # サーバー起動
    bin/rails server
    ```

サーバーはコンテナ内のポート 3000 で起動します。VS Code のポートフォワーディングにより `http://localhost:3000` でアクセスできます。

### Dev Container の構成

```
.devcontainer/
├── devcontainer.json       # Dev Container 設定
├── Dockerfile              # Ruby 3.4 (Debian bullseye) ベースイメージ
├── docker-compose.yml      # app + PostgreSQL のマルチコンテナ構成
└── create-db-user.sql      # DB 初期ユーザー作成スクリプト
```

- **app コンテナ** — Ruby on Rails アプリケーション（GitHub CLI, Node.js 同梱）
- **db コンテナ** — PostgreSQL（ヘルスチェック付きで app より先に起動）

データベース接続情報:

| 項目 | 値 |
|---|---|
| ホスト | `db` |
| ユーザー | `postgres` |
| パスワード | `postgres` |
| データベース名（開発） | `rails_practice_development` |
| データベース名（テスト） | `rails_practice_test` |

## データモデル

### expenses テーブル

| カラム | 型 | 制約 | 説明 |
|---|---|---|---|
| id | bigint | PK | ID |
| date | date | NOT NULL | 支出日 |
| amount | integer | NOT NULL | 金額 |
| category | string(50) | NOT NULL | カテゴリ |
| memo | string(200) | | メモ |
| created_at | datetime | NOT NULL | 作成日時 |
| updated_at | datetime | NOT NULL | 更新日時 |

### バリデーション

| フィールド | ルール |
|---|---|
| date | 必須 |
| amount | 必須、整数、1 以上 |
| category | 必須、50 文字以内 |
| memo | 200 文字以内 |

## API エンドポイント

### 支出 CRUD

| メソッド | パス | 説明 |
|---|---|---|
| GET | `/expenses` | 支出一覧の取得 |
| GET | `/expenses/:id` | 支出の取得 |
| POST | `/expenses` | 支出の登録 |
| PATCH/PUT | `/expenses/:id` | 支出の更新 |
| DELETE | `/expenses/:id` | 支出の削除 |

### 集計

| メソッド | パス | 説明 |
|---|---|---|
| GET | `/expenses/monthly_summary?year=YYYY&month=MM` | 月次合計金額の取得 |
| GET | `/expenses/category_monthly_summary?year=YYYY&month=MM` | カテゴリ別月次合計の取得 |
| GET | `/expenses/yearly_summary?year=YYYY` | 年次合計金額の取得 |
| GET | `/expenses/category_yearly_summary?year=YYYY` | カテゴリ別年次合計の取得 |

### エラーレスポンス

| ステータスコード | 条件 | レスポンス例 |
|---|---|---|
| 404 Not Found | 存在しない ID を指定 | `{"error": "Record not found"}` |
| 400 Bad Request | 必須パラメータ不足 | `{"error": "param is missing or the value is empty: expense"}` |
| 422 Unprocessable Entity | バリデーションエラー | `{"amount": ["must be greater than 0"]}` |

## リクエスト / レスポンス例

### 支出の登録

```bash
curl -X POST http://localhost:3000/expenses \
  -H "Content-Type: application/json" \
  -d '{"expense": {"date": "2026-03-01", "amount": 1500, "category": "食費", "memo": "ランチ"}}'
```

```json
{
  "id": 1,
  "date": "2026-03-01",
  "amount": 1500,
  "category": "食費",
  "memo": "ランチ",
  "created_at": "2026-03-01T12:00:00.000Z",
  "updated_at": "2026-03-01T12:00:00.000Z"
}
```

### 支出の更新

```bash
curl -X PATCH http://localhost:3000/expenses/1 \
  -H "Content-Type: application/json" \
  -d '{"expense": {"amount": 2000, "memo": "ディナーに変更"}}'
```

```json
{
  "id": 1,
  "date": "2026-03-01",
  "amount": 2000,
  "category": "食費",
  "memo": "ディナーに変更",
  "created_at": "2026-03-01T12:00:00.000Z",
  "updated_at": "2026-03-01T13:00:00.000Z"
}
```

### 支出の削除

```bash
curl -X DELETE http://localhost:3000/expenses/1
```

レスポンス: `204 No Content`

### 月次集計

```bash
curl http://localhost:3000/expenses/monthly_summary?year=2026&month=3
```

```json
{
  "year": 2026,
  "month": 3,
  "total": 45000
}
```

### カテゴリ別月次集計

```bash
curl http://localhost:3000/expenses/category_monthly_summary?year=2026&month=3
```

```json
{
  "year": 2026,
  "month": 3,
  "summary": {
    "食費": 20000,
    "交通費": 10000,
    "日用品": 15000
  }
}
```

### 年次集計

```bash
curl http://localhost:3000/expenses/yearly_summary?year=2026
```

```json
{
  "year": 2026,
  "total": 540000
}
```

### カテゴリ別年次集計

```bash
curl http://localhost:3000/expenses/category_yearly_summary?year=2026
```

```json
{
  "year": 2026,
  "summary": {
    "食費": 240000,
    "交通費": 120000,
    "日用品": 180000
  }
}
```

## テスト

### RSpec

```bash
# 全テスト実行
bundle exec rspec

# リクエストスペックのみ
bundle exec rspec spec/requests/
```

### Minitest

```bash
bin/rails test
```

### CI（全チェック一括実行）

```bash
bin/ci
```

以下が順番に実行されます:

1. `bin/setup --skip-server` — 環境セットアップ
2. `bin/rubocop` — コードスタイルチェック
3. `bin/bundler-audit` — Gem 脆弱性チェック
4. `bin/brakeman` — セキュリティ静的解析
5. `bin/rails test` — テスト実行
6. `bin/rails db:seed:replant` — シードデータの検証

## GitHub Actions CI

プルリクエストおよび `main` ブランチへのプッシュ時に自動的に CI が実行されます。

| ジョブ | 内容 |
|---|---|
| `scan_ruby` | Brakeman + bundler-audit によるセキュリティチェック |
| `lint` | RuboCop によるコードスタイルチェック |
| `test` | PostgreSQL サービスコンテナを使用したテスト実行 |

## ヘルスチェック

```
GET /up
```
