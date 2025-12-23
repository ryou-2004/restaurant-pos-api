json.id tenant.id
json.name tenant.name
json.subdomain tenant.subdomain
json.created_at tenant.created_at

json.subscription do
  json.partial! 'api/shared/subscription', subscription: tenant.subscription if tenant.subscription
end

json.user_count tenant.tenant_users.size
