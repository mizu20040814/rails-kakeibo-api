class ExpensesController < ApplicationController
  # GET /expenses
  def index
    @expenses = Expense.all
    render json: @expenses
  end

  # GET /expenses/:id
  def show
    @expense = Expense.find(params[:id])
    render json: @expense
  end

  # POST /expenses
  def create
    @expense = Expense.new(expense_params)
    if @expense.save
      render json: @expense
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /expenses/:id
  def update
    @expense = Expense.find(params[:id])
    if @expense.update(expense_params)
      render json: @expense
    else
      render json: @expense.errors, status: :unprocessable_entity
    end
  end

  # DELETE /expenses/:id
  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy
    head :no_content
  end

  # GET /expenses/monthly_summary?year=2025&month=3
  def monthly_summary
    year = params[:year].to_i
    month = params[:month].to_i

    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    total = Expense.where(date: start_date..end_date).sum(:amount)

    render json: { year: year, month: month, total: total }
  end

  # GET /expenses/category_monthly_summary?year=2025&month=3
  def category_monthly_summary
    year = params[:year].to_i
    month = params[:month].to_i

    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    summary = Expense.where(date: start_date..end_date)
                     .group(:category)
                     .sum(:amount)

    render json: { year: year, month: month, summary: summary }
  end

  # TODO: GET /expenses/yearly_summary?year=2025
  # TODO: Check this API
  def yearly_summary
    year = params[:year].to_i
    start_date = Date.new(year, 1, 1)
    end_date = start_date.end_of_year

    total = Expense.where(date: start_date..end_date).sum(:amount)

    render json: { year: year, total: total }
  end

  # TODO: GET /expenses/category_yearly_summary?year=2025
  # TODO: Check this API
  def category_yearly_summary
    year = params[:year].to_i
    start_date = Date.new(year, 1, 1)
    end_date = start_date.end_of_year

    summary = Expense.where(date: start_date..end_date)
                     .group(:category)
                     .sum(:amount)

    render json: { year: year, summary: summary }
  end

  private

  def expense_params
    params.require(:expense).permit(:date, :amount, :category, :memo)
  end
end
