class Api::Store::TableSessionsController < Api::Store::BaseController
  include Loggable

  # アクティブなテーブルセッション一覧取得
  def index
    @table_sessions = current_store.table_sessions
                                   .active
                                   .includes(:table, :orders)
                                   .order(started_at: :asc)

    render json: @table_sessions.map { |session|
      {
        id: session.id,
        table_id: session.table_id,
        table_number: session.table.number,
        party_size: session.party_size,
        status: session.status,
        started_at: session.started_at,
        duration_minutes: session.duration_in_minutes,
        order_count: session.orders.count,
        total_amount: session.total_amount
      }
    }
  end

  # テーブルセッション作成（店員が顧客を案内したとき）
  def create
    table = current_store.tables.find_by(id: params[:table_id])

    unless table
      render json: { error: 'テーブルが見つかりません' }, status: :not_found
      return
    end

    # 既にアクティブなセッションがある場合はエラー
    existing_session = TableSession.find_by(
      store_id: current_store.id,
      table_id: table.id,
      status: :active
    )

    if existing_session
      render json: { error: 'このテーブルは既に使用中です' }, status: :conflict
      return
    end

    # 新しいセッションを作成
    @table_session = TableSession.create!(
      tenant_id: current_tenant.id,
      store_id: current_store.id,
      table_id: table.id,
      party_size: params[:party_size],
      status: :active,
      started_at: Time.current
    )

    # テーブルセッション開始を記録
    log_business_event(:table_session_started, @table_session, metadata: {
      table_id: table.id,
      table_number: table.number,
      party_size: @table_session.party_size
    })

    render json: {
      id: @table_session.id,
      table_id: @table_session.table_id,
      table_number: table.number,
      party_size: @table_session.party_size,
      status: @table_session.status,
      started_at: @table_session.started_at
    }, status: :created
  rescue StandardError => e
    Rails.logger.error "TableSession creation error: #{e.message}"
    render json: { error: 'セッションの作成に失敗しました' }, status: :internal_server_error
  end

  # テーブルセッション終了（会計完了時）
  def complete
    @table_session = TableSession.find_by(
      id: params[:id],
      store_id: current_store.id,
      status: :active
    )

    unless @table_session
      render json: { error: 'アクティブなセッションが見つかりません' }, status: :not_found
      return
    end

    @table_session.complete!

    # テーブルセッション終了を記録
    log_business_event(:table_session_ended, @table_session, metadata: {
      table_id: @table_session.table_id,
      duration_minutes: @table_session.duration_in_minutes,
      total_amount: @table_session.total_amount
    })

    render json: {
      id: @table_session.id,
      status: @table_session.status,
      ended_at: @table_session.ended_at,
      duration_minutes: @table_session.duration_in_minutes
    }, status: :ok
  rescue StandardError => e
    Rails.logger.error "TableSession completion error: #{e.message}"
    render json: { error: 'セッションの終了に失敗しました' }, status: :internal_server_error
  end
end
