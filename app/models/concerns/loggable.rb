module Loggable
  extend ActiveSupport::Concern

  # 機密情報として扱うキー
  SENSITIVE_KEYS = %w[
    password password_digest password_confirmation
    token access_token refresh_token auth_token
    secret secret_key api_key api_secret
    credit_card credit_card_number cvv
  ].freeze

  # ========================================
  # 基本的なログ記録メソッド
  # ========================================

  # 汎用的なアクティビティログ記録
  def log_activity(action_type, resource: nil, metadata: {})
    ActivityLog.log(
      user: current_user_for_logging,
      action_type: action_type.to_s,
      tenant: current_tenant_for_logging,
      store: current_store_for_logging,
      resource: resource,
      metadata: mask_sensitive_data(metadata),
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  # ========================================
  # 認証ログ
  # ========================================

  # 認証関連のログ（ログイン、ログアウト、失敗など）
  def log_authentication(action_type, user, success:, metadata: {})
    ActivityLog.log(
      user: user,
      action_type: action_type.to_s,
      tenant: user.try(:tenant),
      store: user.try(:store),
      resource: nil,
      metadata: mask_sensitive_data(metadata.merge(success: success)),
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end

  # ========================================
  # CRUD操作ログ
  # ========================================

  # CRUD操作のログ（変更前後を記録）
  def log_crud_action(action_type, resource, before: nil, after: nil)
    metadata = {}
    metadata[:before] = before if before.present?
    metadata[:after] = after if after.present?

    # 変更内容を記録
    if before.present? && after.present?
      changes = {}
      before.keys.each do |key|
        if before[key] != after[key]
          changes[key] = [before[key], after[key]]
        end
      end
      metadata[:changes] = changes if changes.present?
    end

    log_activity(action_type, resource: resource, metadata: metadata)
  end

  # ========================================
  # ビジネスイベントログ
  # ========================================

  # ビジネスイベントのログ（注文、決済など）
  def log_business_event(action_type, resource, metadata: {})
    log_activity(action_type, resource: resource, metadata: metadata)
  end

  private

  # ========================================
  # ヘルパーメソッド
  # ========================================

  # ログ記録用のユーザーを取得
  def current_user_for_logging
    # StaffUser（システム管理者）
    return Current.staff_user if defined?(Current.staff_user) && Current.staff_user.present?

    # TenantUser または StoreUser
    return Current.user if defined?(Current.user) && Current.user.present?

    # Customer (TableSession)
    return Current.table_session if defined?(Current.table_session) && Current.table_session.present?

    # ゲストユーザー（匿名）
    nil
  end

  # ログ記録用のテナントを取得
  def current_tenant_for_logging
    # Current.tenant が設定されている場合
    return Current.tenant if defined?(Current.tenant) && Current.tenant.present?

    # ユーザーからテナントを取得
    user = current_user_for_logging
    return nil if user.nil?

    case user.class.name
    when 'StaffUser'
      nil  # スタッフはテナントに属さない
    when 'TenantUser'
      user.tenant
    when 'TableSession'
      user.tenant
    else
      user.try(:tenant)
    end
  end

  # ログ記録用の店舗を取得
  def current_store_for_logging
    # Current.store が設定されている場合
    return Current.store if defined?(Current.store) && Current.store.present?

    # @current_store_id から取得（Store系コントローラー）
    return Store.find_by(id: @current_store_id) if defined?(@current_store_id) && @current_store_id.present?

    # ユーザーからstoreを取得
    user = current_user_for_logging
    return nil if user.nil?

    case user.class.name
    when 'TableSession'
      user.store
    else
      user.try(:store)
    end
  end

  # 機密情報をマスキング
  def mask_sensitive_data(data)
    return data unless data.is_a?(Hash)

    data.deep_dup.tap do |masked_data|
      SENSITIVE_KEYS.each do |key|
        if masked_data.key?(key) || masked_data.key?(key.to_sym)
          masked_data[key] = '[FILTERED]'
          masked_data[key.to_sym] = '[FILTERED]'
        end
      end

      # ネストしたハッシュも再帰的にマスキング
      masked_data.each do |k, v|
        masked_data[k] = mask_sensitive_data(v) if v.is_a?(Hash)
      end
    end
  end
end
