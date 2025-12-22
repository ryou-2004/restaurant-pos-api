# 開発環境用のシードデータ

# ========================================
# テナント1: ベーシックプラン（手動リロード）
# ========================================
tenant1 = Tenant.find_or_create_by!(subdomain: 'demo-basic') do |t|
  t.name = 'デモカフェ（ベーシック）'
end

subscription1 = Subscription.find_or_create_by!(tenant: tenant1) do |s|
  s.plan = :basic
  s.max_stores = 1
  s.realtime_enabled = false
  s.polling_enabled = false
  s.expires_at = 1.year.from_now
end

user1 = User.find_or_create_by!(tenant: tenant1, email: 'admin@demo-basic.local') do |u|
  u.name = '管理者'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
end

puts "✅ テナント1作成完了: #{tenant1.name} (#{tenant1.subdomain})"
puts "   プラン: #{subscription1.plan}"
puts "   管理者: #{user1.email}"

# ========================================
# テナント2: スタンダードプラン（ポーリング）
# ========================================
tenant2 = Tenant.find_or_create_by!(subdomain: 'demo-standard') do |t|
  t.name = 'デモレストラン（スタンダード）'
end

subscription2 = Subscription.find_or_create_by!(tenant: tenant2) do |s|
  s.plan = :standard
  s.max_stores = 5
  s.realtime_enabled = false
  s.polling_enabled = true
  s.expires_at = 1.year.from_now
end

user2 = User.find_or_create_by!(tenant: tenant2, email: 'admin@demo-standard.local') do |u|
  u.name = '管理者'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
end

puts "✅ テナント2作成完了: #{tenant2.name} (#{tenant2.subdomain})"
puts "   プラン: #{subscription2.plan}"
puts "   管理者: #{user2.email}"

# ========================================
# テナント3: エンタープライズプラン（WebSocket）
# ========================================
tenant3 = Tenant.find_or_create_by!(subdomain: 'demo-enterprise') do |t|
  t.name = 'デモホテルレストラン（エンタープライズ）'
end

subscription3 = Subscription.find_or_create_by!(tenant: tenant3) do |s|
  s.plan = :enterprise
  s.max_stores = 50
  s.realtime_enabled = true
  s.polling_enabled = true
  s.expires_at = 1.year.from_now
end

user3_admin = User.find_or_create_by!(tenant: tenant3, email: 'admin@demo-enterprise.local') do |u|
  u.name = '管理者'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
end

user3_manager = User.find_or_create_by!(tenant: tenant3, email: 'manager@demo-enterprise.local') do |u|
  u.name = 'マネージャー'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :manager
end

user3_staff = User.find_or_create_by!(tenant: tenant3, email: 'staff@demo-enterprise.local') do |u|
  u.name = 'スタッフ'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :staff
end

puts "✅ テナント3作成完了: #{tenant3.name} (#{tenant3.subdomain})"
puts "   プラン: #{subscription3.plan}"
puts "   管理者: #{user3_admin.email}"
puts "   マネージャー: #{user3_manager.email}"
puts "   スタッフ: #{user3_staff.email}"

# ========================================
# メニュー項目作成（全テナント共通）
# ========================================
[tenant1, tenant2, tenant3].each do |tenant|
  Current.tenant = tenant

  # ドリンクカテゴリ
  MenuItem.find_or_create_by!(tenant: tenant, name: 'コーヒー（ホット）') do |m|
    m.category = 'ドリンク'
    m.price = 400
    m.description = '香り豊かなブレンドコーヒー'
    m.available = true
  end

  MenuItem.find_or_create_by!(tenant: tenant, name: 'コーヒー（アイス）') do |m|
    m.category = 'ドリンク'
    m.price = 450
    m.description = '冷たいアイスコーヒー'
    m.available = true
  end

  MenuItem.find_or_create_by!(tenant: tenant, name: 'オレンジジュース') do |m|
    m.category = 'ドリンク'
    m.price = 350
    m.description = 'フレッシュオレンジジュース'
    m.available = true
  end

  # フードカテゴリ
  MenuItem.find_or_create_by!(tenant: tenant, name: 'ハンバーグステーキ') do |m|
    m.category = 'メイン'
    m.price = 1200
    m.description = 'ジューシーなハンバーグ'
    m.available = true
  end

  MenuItem.find_or_create_by!(tenant: tenant, name: 'カルボナーラ') do |m|
    m.category = 'パスタ'
    m.price = 980
    m.description = '濃厚クリームソースのパスタ'
    m.available = true
  end

  MenuItem.find_or_create_by!(tenant: tenant, name: 'シーザーサラダ') do |m|
    m.category = 'サラダ'
    m.price = 600
    m.description = 'フレッシュ野菜のサラダ'
    m.available = true
  end

  # デザートカテゴリ
  MenuItem.find_or_create_by!(tenant: tenant, name: 'チーズケーキ') do |m|
    m.category = 'デザート'
    m.price = 500
    m.description = '濃厚なベイクドチーズケーキ'
    m.available = true
  end

  puts "✅ #{tenant.name} にメニュー項目を追加"
end

puts "\n========================================="
puts "シードデータの投入が完了しました"
puts "========================================="
