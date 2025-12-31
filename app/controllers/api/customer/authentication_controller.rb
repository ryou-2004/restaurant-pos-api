class Api::Customer::AuthenticationController < ActionController::API
  include Loggable

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

    # アクティブなテーブルセッションを検索（店員が作成済みのもの）
    table_session = TableSession.find_by(
      store_id: table.store_id,
      table_id: table.id,
      status: :active
    )

    unless table_session
      render json: { error: 'このテーブルはまだ利用開始されていません。店員にお声がけください。' }, status: :forbidden
      return
    end

    # QRログイン成功を記録
    log_authentication(:login, table_session, success: true, metadata: {
      qr_code: qr_code,
      table_id: table.id,
      table_number: table.number,
      login_method: 'qr_code'
    })

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
    @table_session = current_table_session

    if @table_session
      # ログアウトを記録
      log_authentication(:logout, @table_session, success: true)
    end

    # 将来的にセッション無効化やテーブル状態のリセットを実装可能
    render json: { message: 'ログアウトしました' }, status: :ok
  end

  private

  def current_table_session
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JsonWebToken.decode(token)

    if decoded && decoded[:user_type] == 'customer'
      TableSession.find_by(id: decoded[:table_session_id])
    end
  rescue
    nil
  end
end
