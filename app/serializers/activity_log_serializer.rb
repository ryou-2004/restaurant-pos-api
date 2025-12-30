class ActivityLogSerializer
  # 一覧表示用のシンプルなシリアライザ
  def initialize(activity_log)
    @activity_log = activity_log
  end

  def as_json(_options = {})
    {
      id: @activity_log.id,
      user_type: @activity_log.user_type,
      user_id: @activity_log.user_id,
      user_name: @activity_log.user_name,
      tenant_id: @activity_log.tenant_id,
      store_id: @activity_log.store_id,
      action_type: @activity_log.action_type,
      resource_type: @activity_log.resource_type,
      resource_id: @activity_log.resource_id,
      resource_name: @activity_log.resource_name,
      ip_address: @activity_log.ip_address,
      created_at: @activity_log.created_at.iso8601
    }
  end

  # 配列のシリアライズ
  def self.serialize_collection(activity_logs)
    activity_logs.map { |log| new(log).as_json }
  end
end
