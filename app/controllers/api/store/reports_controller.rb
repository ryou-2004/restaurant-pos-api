class Api::Store::ReportsController < Api::Store::BaseController
  # ========================================
  # before_action定義
  # ========================================
  before_action :set_store

  # ========================================
  # アクション
  # ========================================

  # GET /api/store/reports/daily?date=2025-12-30&store_id=1
  def daily
    date = params[:date] ? Date.parse(params[:date]) : Date.current
    report = ReportService.new(@store).daily_report(date)

    render json: report
  rescue ArgumentError => e
    render json: { error: '日付の形式が不正です' }, status: :bad_request
  end

  # GET /api/store/reports/monthly?year=2025&month=12&store_id=1
  def monthly
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month

    report = ReportService.new(@store).monthly_report(year, month)

    render json: report
  rescue ArgumentError => e
    render json: { error: 'パラメータが不正です' }, status: :bad_request
  end

  private

  # ========================================
  # プライベートメソッド
  # ========================================

  def set_store
    # store_idパラメータがあればそれを使用、なければテナントの最初の店舗
    @store = if params[:store_id].present?
               current_tenant.stores.find(params[:store_id])
             else
               current_tenant.stores.first
             end

    unless @store
      render json: { error: '店舗が見つかりません' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: '店舗が見つかりません' }, status: :not_found
  end
end
