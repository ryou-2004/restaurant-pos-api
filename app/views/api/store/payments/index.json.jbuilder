json.array! @payments do |payment|
  json.partial! 'api/store/payments/payment', payment: payment
end
