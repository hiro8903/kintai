class OvertimeRequestsController < ApplicationController

  before_action :logged_in_user, only: [:new, :edit, :edit_user_overtime_request, :update]
  # before_action :correct_user, only: [:edit_user_overtime_request, :update]
  before_action :admin_user, only: [:new, :edit, :edit_user_overtime_request]
  before_action :admin_or_correct_user, only: [:new, :edit, :edit_user_overtime_request]
  before_action :set_one_month, only: [:new, :edit, :edit_user_overtime_request]


  def new
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
  end

  def edit
    @user = User.find(params[:user_id])
  end

  def update

  end


      # 管理権限者、または現在ログインしているユーザーを許可します。
      def admin_or_correct_user
        @user = User.find(params[:user_id]) if @user.blank?
        unless current_user?(@user) || current_user.admin?
          flash[:danger] = "権限がありません。"
          redirect_to(root_url)
        end  
      end
end
