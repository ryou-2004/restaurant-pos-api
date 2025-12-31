class AddEnhancedFieldsToMenuItems < ActiveRecord::Migration[8.0]
  def change
    # 画像URL（オプション）
    add_column :menu_items, :image_url, :string

    # アレルゲン情報（カンマ区切りまたはJSON形式、オプション）
    add_column :menu_items, :allergens, :text

    # 辛さレベル（0-5、0=辛くない、5=激辛、nilは辛さ情報なし）
    add_column :menu_items, :spice_level, :integer, default: 0
  end
end
