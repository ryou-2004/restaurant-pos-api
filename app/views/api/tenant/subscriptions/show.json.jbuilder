json.partial! 'api/shared/subscription', subscription: @subscription if @subscription

json.created_at @subscription.created_at if @subscription
json.updated_at @subscription.updated_at if @subscription
