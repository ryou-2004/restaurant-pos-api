class AddPrintingToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :printing_enabled, :boolean, default: false

    # スタンダード以上は印刷機能を有効化
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE subscriptions
          SET printing_enabled = true
          WHERE plan IN (1, 2)
        SQL
      end
    end
  end
end
