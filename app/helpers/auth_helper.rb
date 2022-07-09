# frozen_string_literal: true

module AuthHelper
  # OAuth設定のクライアントID
  CLIENT_ID = ENV['CLIENT_ID']
  # OAuth設定のクライアントシークレット
  CLIENT_SECRET = ENV['CLIENT_SECRET']
  # notionのURL
  SITE = 'https://api.notion.com'
  # 認可エンドポイント
  AUTHORIZE_URL = '/v1/oauth/authorize'
  # トークンエンドポイント
  TOKEN_URL = '/v1/oauth/token'

  # CSRF対策のランダムな値
  STATE = SecureRandom.alphanumeric

  # ログインURLの生成
  def get_login_url
    client = OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site: SITE,
      authorize_url: AUTHORIZE_URL,
      token_url: TOKEN_URL
    )

    client.auth_code.authorize_url(
      # 認可コード取得後のリダイレクト先
      # notion public integration のリダイレクトURIと揃える必要あり
      redirect_uri: 'http://localhost:3000/authorize',
      state: STATE,
      owner: 'user'
    )
  end

  # アクセストークン取得のための認可コードを送信
  def get_token_from_code(auth_code)
    client = OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site: SITE,
      authorize_url: AUTHORIZE_URL,
      token_url: TOKEN_URL
    )

    client.auth_code.get_token(
      auth_code,
      # notion public integration のリダイレクトURIと揃える必要あり
      redirect_uri: 'http://localhost:3000/authorize'
    )
  end

  # アクセストークンの取得
  def get_access_token
    # セッションから現在のアクセストークンハッシュを取得
    token_hash = session[:notion_token]

    client = OAuth2::Client.new(
      CLIENT_ID,
      CLIENT_SECRET,
      site: SITE,
      authorize_url: AUTHORIZE_URL,
      token_url: TOKEN_URL
    )

    token = OAuth2::AccessToken.from_hash(client, token_hash)

    # アクセストークンが期限切れの場合、リフレッシュトークンからアクセストークンを取得
    if token.expired?
      new_token = token.refresh!
      # 新アクセストークンをセッションへ保存
      session[:notion_token] = new_token.to_hash
      access_token = new_token
    else
      access_token = token
    end

    access_token
  end
end
