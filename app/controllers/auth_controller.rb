class AuthController < ApplicationController
  include AuthHelper

  # 認可コードからアクセストークンを取得
  def get_token
    token = get_token_from_code(params[:code])
    session[:notion_token] = token.to_hash

    redirect_to root_path
  end
end
