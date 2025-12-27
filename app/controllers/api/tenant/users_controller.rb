class Api::Tenant::UsersController < Api::Tenant::BaseController
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
      render json: serialize_user(@user), status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: serialize_user(@user)
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
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
