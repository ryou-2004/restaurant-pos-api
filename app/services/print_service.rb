# 印刷サービス
# 注文の厨房チケット印刷データを生成し、印刷ログを記録する
class PrintService
  def initialize(store)
    @store = store
    @tenant = store.tenant
  end

  # 注文の厨房チケット印刷データを生成
  def generate_kitchen_ticket(order)
    template = active_kitchen_template
    rendered_html = render_template(template, order)

    {
      html: rendered_html,
      template_id: template.id,
      order_id: order.id
    }
  end

  # 印刷ログを記録
  def log_print(order, template_id, status, error: nil, printer_name: nil)
    PrintLog.create!(
      tenant: @tenant,
      store: @store,
      order: order,
      print_template_id: template_id,
      printed_at: Time.current,
      status: status,
      error_message: error,
      printer_name: printer_name
    )
  rescue StandardError => e
    Rails.logger.error "印刷ログ記録エラー: #{e.message}"
    # ログ記録失敗は致命的ではないため、処理を継続
  end

  private

  # アクティブな厨房チケットテンプレートを取得
  def active_kitchen_template
    # 1. 店舗固有のテンプレート
    template = @store.print_templates
                     .template_type_kitchen_ticket
                     .active
                     .first

    # 2. テナント共通テンプレート
    template ||= @tenant.print_templates
                        .where(store_id: nil)
                        .template_type_kitchen_ticket
                        .active
                        .first

    # 3. デフォルトテンプレート（保存せずにインメモリで使用）
    template || PrintTemplate.default_kitchen_ticket_template
  end

  # テンプレートをレンダリング
  def render_template(template, order)
    # テンプレートコンテキスト用の変数をバインディングに設定
    store = @store

    # ERBテンプレートをレンダリング
    ERB.new(template.content).result(binding)
  rescue StandardError => e
    Rails.logger.error "テンプレートレンダリングエラー: #{e.message}"
    # エラー時はシンプルなフォールバックHTML
    fallback_html(order)
  end

  # エラー時のフォールバックHTML
  def fallback_html(order)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <style>
          body { font-family: monospace; padding: 20px; }
          h1 { text-align: center; }
          .item { margin: 10px 0; }
        </style>
      </head>
      <body>
        <h1>注文 #{order.order_number}</h1>
        <p>テーブル: #{order.table_id || '-'}</p>
        <p>時刻: #{order.created_at.strftime('%H:%M')}</p>
        <hr>
        #{order.order_items.map { |item|
          "<div class='item'>#{item.menu_item_name} × #{item.quantity}</div>"
        }.join}
        <hr>
        <p>#{@store.name}</p>
      </body>
      </html>
    HTML
  end
end
