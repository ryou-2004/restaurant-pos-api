class Current < ActiveSupport::CurrentAttributes
  # スレッドローカルな変数として、現在のリクエストコンテキストを管理
  attribute :tenant, :user
end
