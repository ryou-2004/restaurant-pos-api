class PrintTemplate < ApplicationRecord
  # ========================================
  # 関連付け
  # ========================================
  belongs_to :tenant
  belongs_to :store, optional: true
  has_many :print_logs, dependent: :nullify

  # ========================================
  # Enum定義
  # ========================================
  enum :template_type, {
    kitchen_ticket: 'kitchen_ticket',
    receipt: 'receipt',
    label: 'label'
  }, _prefix: true

  # ========================================
  # バリデーション
  # ========================================
  validates :name, presence: true, length: { maximum: 100 }
  validates :content, presence: true
  validates :template_type, presence: true

  # ========================================
  # スコープ
  # ========================================
  scope :active, -> { where(is_active: true) }
  scope :for_tenant, ->(tenant) { where(tenant: tenant) }
  scope :for_store, ->(store) { where(store: store) }

  # ========================================
  # パブリックメソッド
  # ========================================

  # デフォルトの厨房チケットテンプレートを返す
  def self.default_kitchen_ticket_template
    new(
      name: 'デフォルト厨房チケット',
      template_type: :kitchen_ticket,
      content: default_kitchen_ticket_html,
      is_active: true,
      settings: {
        font_size: 14,
        line_height: 1.4,
        page_width: '80mm'
      }
    )
  end

  private

  # ========================================
  # プライベートメソッド
  # ========================================

  # デフォルトテンプレートHTML
  def self.default_kitchen_ticket_html
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          @media print {
            @page { margin: 0; size: 80mm auto; }
            body { margin: 10mm; }
          }
          body {
            font-family: monospace;
            font-size: 14px;
            line-height: 1.4;
          }
          .header {
            text-align: center;
            border-bottom: 2px solid #000;
            padding-bottom: 10px;
            margin-bottom: 15px;
          }
          .order-number {
            font-size: 24px;
            font-weight: bold;
          }
          .table-info {
            font-size: 18px;
            margin: 10px 0;
          }
          .items {
            margin: 15px 0;
          }
          .item {
            margin: 8px 0;
            padding: 5px 0;
            border-bottom: 1px dashed #ccc;
          }
          .item-name {
            font-weight: bold;
            font-size: 16px;
          }
          .item-quantity {
            font-size: 18px;
            float: right;
          }
          .item-notes {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
          }
          .footer {
            text-align: center;
            margin-top: 20px;
            padding-top: 10px;
            border-top: 2px solid #000;
          }
        </style>
      </head>
      <body>
        <div class="header">
          <div class="order-number">注文 <%= order.order_number %></div>
          <div class="table-info">テーブル: <%= order.table_id || '-' %></div>
          <div><%= order.created_at.strftime('%H:%M') %></div>
        </div>

        <div class="items">
          <% order.order_items.each do |item| %>
            <div class="item">
              <span class="item-name"><%= item.menu_item_name %></span>
              <span class="item-quantity">× <%= item.quantity %></span>
              <% if item.notes.present? %>
                <div class="item-notes">備考: <%= item.notes %></div>
              <% end %>
            </div>
          <% end %>
        </div>

        <% if order.notes.present? %>
          <div style="margin-top: 15px; padding: 10px; background: #f5f5f5;">
            <strong>注文メモ:</strong><br>
            <%= order.notes %>
          </div>
        <% end %>

        <div class="footer">
          <%= store.name %>
        </div>
      </body>
      </html>
    HTML
  end
end
