module Tenantable
  extend ActiveSupport::Concern

  included do
    # テナントとの関連付け
    belongs_to :tenant

    # デフォルトスコープでテナント分離を保証
    # Current.tenantが設定されている場合のみ適用
    default_scope -> { where(tenant: Current.tenant) if Current.tenant.present? }

    # バリデーション
    validates :tenant, presence: true

    # 新規レコード作成時に自動的にCurrent.tenantを設定
    before_validation :set_current_tenant, on: :create
  end

  private

  def set_current_tenant
    self.tenant ||= Current.tenant
  end
end
