json.token @token

json.user do
  json.id @staff_user.id
  json.name @staff_user.name
  json.email @staff_user.email
  json.role @staff_user.role
  json.user_type 'staff'
end
