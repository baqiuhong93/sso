# encoding: utf-8
class AuthController < ApplicationController
  before_filter :authenticate_user!, :except => [:access_token]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]
  
  def welcome
    cookies[LOGIN_SUC_CODE] = {:value => params[:service], :domain => COOKIE_DOMAIN} unless params[:service].nil?
    _redirect_url = cookies[LOGIN_SUC_CODE] || GlobalSettings.study_url
    cookies.delete(LOGIN_SUC_CODE, :domain => COOKIE_DOMAIN) unless cookies[LOGIN_SUC_CODE].nil?
    redirect_to _redirect_url
  end

  def authorize
    AccessGrant.prune!
    access_grant = current_user.access_grants.create({:client => application, :state => params[:state]}, :without_protection => true)
    redirect_to access_grant.redirect_uri_for(params[:redirect_uri])
  end

  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "找不到应用!"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "访问码认证失败!"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def failure
    render :text => "ERROR: #{params[:message]}"
  end

  def user
    hash = {
      :provider => 'josh_id',
      :id => current_user.id.to_s,
      :info => {
         :email      => current_user.email,
         :name => current_user.name,
         :salt => current_user.salt
      },
      :extra => {
         :last_name  => current_user.last_name
      }
    }
    render :json => hash.to_json
  end

  # Incase, we need to check timeout of the session from a different application!
  # This will be called ONLY if the user is authenticated and token is valid
  # Extend the UserManager session
  def isalive
    warden.set_user(current_user, :scope => :user)
    response = { 'status' => 'ok' }

    respond_to do |format|
      format.any { render :json => response.to_json }
    end
  end

  protected

  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end

end
