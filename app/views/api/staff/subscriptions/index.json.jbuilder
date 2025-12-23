json.array! @subscriptions do |subscription|
  json.partial! 'api/staff/subscriptions/subscription', subscription: subscription
end
