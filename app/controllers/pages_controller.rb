class PagesController < ApplicationController
  def hyperlect_app
    if request.user_agent =~ /\b(Android|iPhone|iPad|Windows Phone|Opera Mobi|Kindle|BackBerry|PlayBook)\b/i
      if params[:reset_password_token].present?
        redirect_to "#{ENV['HYPERLECTAPP_URL']}?mode=#{params[:mode]}&reset_password_token=#{params[:reset_password_token]}"
      else
        redirect_to "#{ENV['HYPERLECTAPP_URL']}?mode=#{params[:mode]}"
      end
    else
      redirect_to edit_user_user_password_url(reset_password_token: params[:reset_password_token])
    end
  end

  def stripe_connect_redirect
    redirect_to "#{ENV['HYPERLECTAPP_URL']}?code=#{params[:code]}", status: 301
  end
end
