class CreatePrintTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :print_templates do |t|
      t.references :tenant, null: false, foreign_key: true, index: true
      t.references :store, null: true, foreign_key: true, index: true
      t.string :template_type, null: false, default: 'kitchen_ticket'
      t.string :name, null: false
      t.text :content, null: false
      t.boolean :is_active, default: true
      t.jsonb :settings, default: {}

      t.timestamps
    end

    add_index :print_templates, [:tenant_id, :template_type, :is_active]
  end
end
