# 店舗ユーザーログインレスポンス
json.token @token

json.user do
  json.id @user.id
  json.name @user.name
  json.email @user.email
  json.role @user.role
  json.user_type 'store'
end

json.tenant do
  json.id @user.tenant.id
  json.name @user.tenant.name
  json.subdomain @user.tenant.subdomain
end
