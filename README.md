# マスタリーのためのRails道場 "What Would You Do?"

https://storesinc.tech/conf/2025

STORES Tech Conf 2025 "What would You Do?" で行われるワークショップ「マスタリーのためのRails道場」用のリポジトリです。

## 概要

このRailsアプリケーションは、お店の来店予約管理と注文管理を行うシステムです。
このお店のお客さんはログインせずに来店予約ができ、従業員はログインして予約管理・注文処理・決済を行えます。

## ワークショップの内容
- 各自のGitHubアカウントにこのリポジトリをフォークしてください
- 開始後60分間は環境構築を行い、アプリケーションの説明を読みながら課題に挑戦してください
- 60分を経過したらその時点での実装をPull Requestとして本体のリポジトリに投げてください
- 残り時間で各自の実装を眺めて感想を伝えたり、自分の実装を改善したり、参加者同士で議論するなど、自由に過ごしてください

## 環境構築

```bash
git clone <repository-url>
cd rails_dojo_wwyd

./bin/setup --skip-server
./bin/rails server
```

## アプリケーションの説明（動作確認方法）

### 来店予約機能
http://127.0.0.1:3000/

- ログイン不要
- フォームを入力して予約を作成できます


### 予約一覧・詳細機能
http://127.0.0.1:3000/dashboard/reservations

- ログインが必要（README:ログイン情報参照）
- 来店予約機能で作成された予約情報と、開発用のseedデータを確認できます
- 予約詳細ページから注文作成ページに遷移できます

### 注文作成・一覧
http://localhost:3000/dashboard/orders

- 予約情報を元に注文を作成できます
- 注文の作成自体は課題1となっているのでまだ動作しません

## 課題

### 課題1: 注文情報の作成と決済処理

注文情報の作成と決済を行う機能を `Dashboard::OrdersController#create` に実装してください。

- [ ] Orderレコードの作成
    - `Reservation has_one Order` の関係であることに注意してください
    - `Order#email` にはリクエストパラメータで指定された `Reservation#email` の値を保存してください
    - `Order#name` にはリクエストパラメータで指定された `Item#name` の値を保存してください
- [ ] 決済APIクライアント（`PaymentApiClient.execute`）を呼び出し、Paymentレコードの作成
    - `Order has_one Payment` の関係であることに注意してください
    - `PaymentApiClient.execute` の引数 `token` にはリクエストパラメータ `params[:order][:token]` の値を設定してください
    - `PaymentApiClient.execute` の引数 `amount` にはリクエストパラメータで指定された商品の価格 `Item#price` の値を設定してください
- [ ] 予約ステータス（`Reservation#status`）を `pending` から `completed` に更新
    - すでに `completed` である場合はエラーとしてください
- [ ] 指定されたアイテムの在庫数（`Item#stock`）を1減らす
    - 在庫が1未満であればエラーとしてください
- [ ] エラーが発生した場合はその情報を `flash.alert.now` に保持し、画面に表示できるようにする

### 課題2: (任意)自由課題

このアプリケーションをもっと良くするために、思いついた改善点があれば何でも取り組んでください。

## 備考

- UserとItemはseedからのみ生成されます
- 決済APIは `PaymentApiClient` クラスでダミー実装されています
    - 実際の決済処理は行われません
    - Web APIのダミー実装なのでまれにタイムアウトすることまで模しています

## ログイン情報

seedで以下のユーザーが作成されます：

- **山田太郎**: `admin@example.com` / `railsdojo20251126`
- **田中花子**: `test@example.com` / `railsdojo20251126`
- **佐藤次郎**: `sato@example.com` / `railsdojo20251126`
- **鈴木三郎**: `suzuki@example.com` / `railsdojo20251126`

## 注意事項

- このアプリケーションはワークショップ用のため、本番環境での使用は想定していません
