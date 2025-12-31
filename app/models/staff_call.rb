class StaffCall < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  belongs_to :store
  belongs_to :table
  belongs_to :table_session
  belongs_to :resolved_by, class_name: 'TenantUser', foreign_key: :resolved_by_id, optional: true

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    pending: 0,    # 対応待ち
    acknowledged: 1,  # 確認済み
    resolved: 2    # 対応完了
  }

  enum :call_type, {
    general: 'general',        # 一般的な呼び出し
    order_request: 'order_request',  # 注文依頼
    water_request: 'water_request',  # お水のおかわり
    payment_request: 'payment_request', # お会計依頼
    assistance: 'assistance'   # その他サポート
  }, _prefix: true

  # ========================================
  # バリデーション
  # ========================================
  validates :status, presence: true
  validates :call_type, presence: true

  # ========================================
  # スコープ
  # ========================================
  scope :active, -> { where(status: [:pending, :acknowledged]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_store, ->(store_id) { where(store_id: store_id) }

  # ========================================
  # パブリックメソッド
  # ========================================

  # 対応完了にする
  def resolve!(user)
    update!(
      status: :resolved,
      resolved_at: Time.current,
      resolved_by_id: user.id
    )
  end

  # 確認済みにする
  def acknowledge!
    update!(status: :acknowledged) if pending?
  end

  # 待機時間（分）
  def waiting_minutes
    return 0 if resolved?
    ((resolved_at || Time.current) - created_at) / 60
  end
end
