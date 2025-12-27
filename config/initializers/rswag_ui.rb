# frozen_string_literal: true

Rswag::Ui.configure do |c|
  # Swagger UIで表示するOpenAPI仕様ファイルのパス
  c.openapi_endpoint '/api-docs/v1/swagger.json', 'Restaurant POS API V1'
end
