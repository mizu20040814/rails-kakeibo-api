class Expense < ApplicationRecord
  validates :date, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :category, presence: true, length: { maximum: 50 }
  validates :memo, length: { maximum: 200 }
end
