class TableSession < ApplicationRecord
  # ========================================
  # Concerns
  # ========================================
  include Tenantable

  # ========================================
  # 関連付け
  # ========================================
  belongs_to :store
  belongs_to :tenant
  has_many :orders, dependent: :nullify
  has_one :payment, dependent: :destroy

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    active: 0,      # 利用中
    completed: 1    # 完了（会計済み）
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :table_id, presence: true
  validates :status, presence: true
  validates :started_at, presence: true
  validates :party_size, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # ========================================
  # スコープ
  # ========================================
  scope :active_sessions, -> { where(status: :active) }
  scope :by_table, ->(table_id) { where(table_id: table_id) }
  scope :today, -> { where('started_at >= ?', Time.current.beginning_of_day) }

  # ========================================
  # パブリックメソッド
  # ========================================

  # セッションの合計金額を計算
  def total_amount
    orders.sum(:total_amount)
  end

  # セッションの注文数
  def order_count
    orders.count
  end

  # 滞在時間（分）
  def duration_in_minutes
    return nil unless started_at
    end_time = ended_at || Time.current
    ((end_time - started_at) / 60).to_i
  end

  # セッションを完了する
  def complete!
    update!(status: :completed, ended_at: Time.current)
  end

  # アクティブなセッションを検索または作成
  def self.find_or_create_active_session(store_id:, table_id:, party_size: nil)
    # 既存のアクティブなセッションを検索
    active_session = where(store_id: store_id, table_id: table_id, status: :active).first

    # 見つかればそれを返す
    return active_session if active_session

    # なければ新規作成
    create!(
      store_id: store_id,
      table_id: table_id,
      party_size: party_size,
      status: :active,
      started_at: Time.current
    )
  end
end
