# 家計簿 API

家計の支出を管理するための RESTful API です。支出の登録・取得・更新・削除に加え、月次集計やカテゴリ別集計機能を提供します。

## 技術スタック

- Ruby 3.4.5
- Rails 8.1.2 (API モード)
- PostgreSQL
- Dev Container (Docker Compose)

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
    # 依存パッケージのインストール
    bin/setup

    # データベースの作成・マイグレーション
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

- **app コンテナ** — Ruby on Rails アプリケーション (GitHub CLI, Node.js 同梱)
- **db コンテナ** — PostgreSQL (ヘルスチェック付きで app より先に起動)

データベース接続情報:

| 項目 | 値 |
|---|---|
| ホスト | `db` |
| ユーザー | `postgres` |
| パスワード | `postgres` |
| データベース名 | `rails_practice_development` |

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

## テスト

```bash
bin/rails test
```

## ヘルスチェック

```
GET /up
```
