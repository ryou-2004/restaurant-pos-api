# テナントユーザーログインレスポンス
json.token @token

json.user do
  json.id @tenant_user.id
  json.name @tenant_user.name
  json.email @tenant_user.email
  json.role @tenant_user.role
  json.user_type 'tenant'
end

json.tenant do
  json.id @tenant_user.tenant.id
  json.name @tenant_user.tenant.name
  json.subdomain @tenant_user.tenant.subdomain

  json.subscription do
    json.plan @tenant_user.tenant.subscription.plan
    json.realtime_enabled @tenant_user.tenant.subscription.realtime_enabled
    json.polling_enabled @tenant_user.tenant.subscription.polling_enabled
    json.max_stores @tenant_user.tenant.subscription.max_stores
  end
end
