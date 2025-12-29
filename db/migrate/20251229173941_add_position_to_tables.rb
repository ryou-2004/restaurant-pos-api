class AddPositionToTables < ActiveRecord::Migration[8.0]
  def change
    # テーブルマップ上の位置（グリッド単位：0-100）
    add_column :tables, :position_x, :float, default: 0
    add_column :tables, :position_y, :float, default: 0

    # テーブルの形状（円形・四角形・長方形）
    add_column :tables, :shape, :string, default: 'square'
  end
end
