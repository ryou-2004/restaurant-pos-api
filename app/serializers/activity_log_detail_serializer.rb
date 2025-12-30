class ActivityLogDetailSerializer
  # 詳細表示用のシリアライザ（metadataを含む）
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
      metadata: @activity_log.metadata,
      ip_address: @activity_log.ip_address,
      user_agent: @activity_log.user_agent,
      created_at: @activity_log.created_at.iso8601,
      updated_at: @activity_log.updated_at.iso8601
    }
  end
end
