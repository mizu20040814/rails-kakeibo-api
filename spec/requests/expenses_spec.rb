require 'rails_helper'

RSpec.describe "Expenses API", type: :request do
  describe "GET /expenses/:id" do
    it "指定した支出を取得できる" do
      expense = create(:expense, amount: 1500)

      get "/expenses/#{expense.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["amount"]).to eq(1500)
    end

    it "存在しないIDは404を返す" do
      get "/expenses/9999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /expenses/:id" do
    it "支出を削除できる" do
      expense = create(:expense)

      delete "/expenses/#{expense.id}"

      expect(response).to have_http_status(:no_content)
      expect(Expense.find_by(id: expense.id)).to be_nil
    end
  end
end
