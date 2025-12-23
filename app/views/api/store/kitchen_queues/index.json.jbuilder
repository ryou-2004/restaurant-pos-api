json.array! @kitchen_queues do |kitchen_queue|
  json.partial! 'api/store/kitchen_queues/kitchen_queue', kitchen_queue: kitchen_queue
end
