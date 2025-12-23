json.array! @users do |user|
  json.partial! 'api/tenant/users/user', user: user
end
