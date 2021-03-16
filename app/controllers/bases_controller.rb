class BasesController < ApplicationController
  before_action :admin_user, only: [:index, :create, :update, :destroy]

  def index
    @base = Base.new
    @bases = Base.all
  end

  def create
    @base = Base.new(base_params)
    @bases = Base.all
    if @base.save
      flash[:success] = "拠点情報を登録しました。"
      redirect_to bases_url
    else
      @msgs = @base.errors.full_messages
      render :index
    end
  end

  def update
    @base = Base.find(params[:id])
    @bases = Base.all
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_url
    else
      @msgs = @base.errors.full_messages
      render :index
    end
  end

  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_url
  end

  private
    def base_params
      params.require(:base).permit(:name, :number, :attendance_type)
    end

end
