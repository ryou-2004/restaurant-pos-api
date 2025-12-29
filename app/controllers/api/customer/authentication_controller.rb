class Api::Customer::AuthenticationController < ActionController::API
  # このコントローラーのみ認証不要（ログインエンドポイントのため）
  skip_before_action :authenticate_customer_session, raise: false

  def login_via_qr
    qr_code = params[:qr_code]

    unless qr_code.present?
      render json: { error: 'QRコードが指定されていません' }, status: :bad_request
      return
    end

    # QRコードからテーブルを検索
    table = Table.find_by(qr_code: qr_code)

    unless table
      render json: { error: 'QRコードが無効です' }, status: :not_found
      return
    end

    # 複数人が同じテーブルで何度でもログインできるように
    # ステータスチェックと変更を削除

    # アクティブなテーブルセッションを検索または作成
    table_session = TableSession.find_or_create_active_session(
      store_id: table.store_id,
      table_id: table.id
    )

    # JWT トークン生成
    token_payload = {
      table_id: table.id,
      table_session_id: table_session.id,
      tenant_id: table.tenant_id,
      store_id: table.store_id,
      user_type: 'customer',
      exp: 24.hours.from_now.to_i
    }

    token = JsonWebToken.encode(token_payload)

    # セッション情報を返す
    render json: {
      token: token,
      session: {
        table_id: table.id,
        table_number: table.number,
        table_session_id: table_session.id,
        store_id: table.store_id,
        store_name: table.store.name,
        tenant_id: table.tenant_id,
        tenant_name: table.tenant.name
      }
    }, status: :ok
  rescue StandardError => e
    Rails.logger.error "QR login error: #{e.message}"
    render json: { error: 'ログインに失敗しました' }, status: :internal_server_error
  end

  def logout
    # 将来的にセッション無効化やテーブル状態のリセットを実装可能
    render json: { message: 'ログアウトしました' }, status: :ok
  end
end
