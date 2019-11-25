class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) # ログインフォームから受け取ったemailの値を使ってユーザーオブジェクトを検索しuserに代入。
    if user && user.authenticate(params[:session][:password]) # has_secure_passwordの機能であるauthenticateメソッドを利用して認証の実行。
      # ログイン後にユーザー情報ページにリダイレクトする。
      log_in user
      # チェックボックスがオンの時（"remember_me" => "1"）ユーザー情報を記憶します。オフの場合は記憶しません。
      rparams[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = '認証に失敗しました。'
      render :new
    end
  end

  def destroy
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in? # 複数タブでログアウト処理した時のエラー対策
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
  
end
