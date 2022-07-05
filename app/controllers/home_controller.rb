class HomeController < ApplicationController
  include AuthHelper

  def index
    @login_url = get_login_url

    token = session[:notion_token]
    @access_token = token ? token['access_token'] : nil
  end
end
