class Api::Tenant::UsersController < Api::Tenant::BaseController
  before_action :require_owner, except: [:index, :show]
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = current_tenant.tenant_users
                           .order(created_at: :desc)
                           .page(params[:page])
  end

  def show
  end

  def create
    @user = current_tenant.tenant_users.new(user_params)
    @user.password = SecureRandom.hex(16) if @user.password.blank?

    if @user.save
      render :show, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render :show
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
    params.require(:user).permit(:name, :email, :password, :role)
  end
end
