json.array! @tenants do |tenant|
  json.partial! 'api/staff/tenants/tenant', tenant: tenant
end
