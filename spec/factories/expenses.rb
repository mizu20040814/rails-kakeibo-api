FactoryBot.define do
  factory :expense do
    date { Date.today }
    amount { 1000 }
    category { "食費" }
    memo { "テスト用メモ" }
  end
end
