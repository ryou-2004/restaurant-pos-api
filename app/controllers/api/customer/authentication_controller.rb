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

    # テーブルのステータスを確認（available または reserved のみ許可）
    unless table.available? || table.reserved?
      render json: { 
        error: 'このテーブルは現在使用できません',
        table_status: table.status
      }, status: :forbidden
      return
    end

    # テーブルを占有状態に変更
    table.update(status: :occupied) if table.available?

    # JWT トークン生成
    token_payload = {
      table_id: table.id,
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
