# 店舗ユーザー情報レスポンス
json.user do
  json.id @tenant_user.id
  json.name @tenant_user.name
  json.email @tenant_user.email
  json.role @tenant_user.role
  json.user_type 'store'
end

json.tenant do
  json.id @tenant_user.tenant.id
  json.name @tenant_user.tenant.name
  json.subdomain @tenant_user.tenant.subdomain
end
