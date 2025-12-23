json.id subscription.id

json.tenant do
  json.id subscription.tenant.id
  json.name subscription.tenant.name
  json.subdomain subscription.tenant.subdomain
end

json.plan subscription.plan
json.realtime_enabled subscription.realtime_enabled
json.polling_enabled subscription.polling_enabled
json.max_stores subscription.max_stores
json.expires_at subscription.expires_at
json.active subscription.active?
json.created_at subscription.created_at
json.updated_at subscription.updated_at
