class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.date :date, null: false
      t.integer :amount, null: false
      t.string :category, limit: 50, null: false
      t.string :memo, limit: 200

      t.timestamps
    end
  end
end
