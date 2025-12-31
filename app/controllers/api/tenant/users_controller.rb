class Api::Tenant::UsersController < Api::Tenant::BaseController
  include Loggable

  before_action :require_owner, except: [:index, :show]
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = current_tenant.tenant_users
                           .includes(:tags)
                           .order(created_at: :desc)

    render json: @users.map { |user| serialize_user(user) }
  end

  def show
    render json: serialize_user(@user)
  end

  def create
    @user = current_tenant.tenant_users.new(user_params)
    @user.password = SecureRandom.hex(16) if @user.password.blank?

    if @user.save
      # ユーザー作成を記録（パスワードは自動的にマスキングされる）
      log_activity(:create, resource: @user, metadata: {
        name: @user.name,
        email: @user.email,
        role: @user.role
      })

      render json: serialize_user(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    before_attrs = @user.attributes.slice('name', 'email', 'role')

    if @user.update(user_params)
      after_attrs = @user.attributes.slice('name', 'email', 'role')

      # ユーザー更新を記録
      log_crud_action(:update, @user, before: before_attrs, after: after_attrs)

      render json: serialize_user(@user)
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # ユーザー削除を記録
    log_activity(:delete, resource: @user, metadata: {
      name: @user.name,
      email: @user.email
    })

    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = current_tenant.tenant_users.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'ユーザーが見つかりません' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, tag_ids: [])
  end

  def serialize_user(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      tags: user.tags.map { |tag| { id: tag.id, name: tag.name } },
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
