class ActivityLog < ApplicationRecord
  # ========================================
  # ポリモーフィック関連
  # ========================================
  belongs_to :user, polymorphic: true
  belongs_to :resource, polymorphic: true, optional: true
  belongs_to :tenant, optional: true
  belongs_to :store, optional: true

  # ========================================
  # アクションタイプのenum定義
  # ========================================
  VALID_ACTION_TYPES = %w[
    login logout login_failed
    create read update delete
    order_placed order_cooking_started order_ready order_delivered order_cancelled
    payment_completed payment_failed
    table_session_started table_session_ended
    menu_viewed page_accessed
  ].freeze

  validates :action_type, inclusion: { in: VALID_ACTION_TYPES }

  # ========================================
  # スコープ
  # ========================================
  scope :by_tenant, ->(tenant_id) { where(tenant_id: tenant_id) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }
  scope :by_action_type, ->(action_type) { where(action_type: action_type) }
  scope :by_user_type, ->(user_type) { where(user_type: user_type) }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?', Time.current.beginning_of_month) }

  # ========================================
  # コールバック（改ざん防止）
  # ========================================
  before_update :prevent_modification
  before_destroy :prevent_deletion

  # ========================================
  # クラスメソッド
  # ========================================

  # ログ記録のファクトリーメソッド
  def self.log(user:, action_type:, tenant: nil, store: nil, resource: nil, metadata: {}, ip_address: nil, user_agent: nil)
    create!(
      user: user,
      action_type: action_type,
      tenant: tenant,
      store: store,
      resource: resource,
      metadata: metadata,
      ip_address: ip_address,
      user_agent: user_agent
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "ActivityLog記録失敗: #{e.message}"
    nil
  end

  # 統計データ取得
  def self.stats(scope = all)
    {
      total_count: scope.count,
      today_count: scope.today.count,
      this_week_count: scope.this_week.count,
      this_month_count: scope.this_month.count,
      by_action_type: scope.group(:action_type).count
    }
  end

  # ========================================
  # インスタンスメソッド
  # ========================================

  # ユーザー名を取得
  def user_name
    return 'ゲスト' if user.nil?

    case user_type
    when 'StaffUser', 'TenantUser'
      user.name
    when 'TableSession'
      "テーブル#{user.table_number}"
    else
      "不明 (#{user_type})"
    end
  rescue StandardError
    "不明"
  end

  # リソース名を取得
  def resource_name
    return nil if resource.nil?

    case resource_type
    when 'Order'
      resource.order_number
    when 'MenuItem'
      resource.name
    when 'Store'
      resource.name
    when 'Tenant'
      resource.name
    else
      "##{resource_id}"
    end
  rescue StandardError
    "##{resource_id}"
  end

  private

  # 更新を禁止（改ざん防止）
  def prevent_modification
    raise ActiveRecord::ReadOnlyRecord, 'ActivityLogは更新できません'
  end

  # 削除を禁止（改ざん防止）
  def prevent_deletion
    raise ActiveRecord::ReadOnlyRecord, 'ActivityLogは削除できません'
  end
end
