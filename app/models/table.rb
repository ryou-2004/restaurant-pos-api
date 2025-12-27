class Table < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  belongs_to :store

  # ========================================
  # Enum定義
  # ========================================
  enum :status, {
    available: 0,  # 空席
    occupied: 1,   # 使用中
    reserved: 2,   # 予約済み
    cleaning: 3    # 清掃中
  }

  # ========================================
  # バリデーション
  # ========================================
  validates :number, presence: true, length: { maximum: 10 }
  validates :number, uniqueness: { scope: :store_id, message: 'は同じ店舗内で既に使用されています' }
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :status, presence: true
  validates :qr_code, uniqueness: true, allow_nil: true

  # ========================================
  # スコープ
  # ========================================
  scope :available_tables, -> { where(status: :available) }
  scope :occupied_tables, -> { where(status: :occupied) }

  # ========================================
  # コールバック
  # ========================================
  before_create :generate_qr_code

  # ========================================
  # パブリックメソッド
  # ========================================

  # テーブルを使用中にする
  def occupy!
    update!(status: :occupied)
  end

  # テーブルを空席にする
  def make_available!
    update!(status: :available)
  end

  # ========================================
  # プライベートメソッド
  # ========================================
  private

  def generate_qr_code
    # QRコード用のユニークな文字列を生成
    # フォーマット: {tenant_id}-{store_id}-{table_number}-{random}
    self.qr_code = "#{tenant_id}-#{store_id}-#{number}-#{SecureRandom.hex(8)}"
  end
end
