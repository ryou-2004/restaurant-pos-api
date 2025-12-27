# frozen_string_literal: true

Rswag::Api.configure do |c|
  # OpenAPI仕様ファイルが配置されているディレクトリ
  c.openapi_root = Rails.root.join('swagger').to_s
end
