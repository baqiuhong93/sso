# encoding: utf-8
class SessionsController < Devise::SessionsController

  def new
    cookies[LOGIN_SUC_CODE] = {:value => params[:service], :domain => COOKIE_DOMAIN} unless params[:service].nil?
    super
  end
  
  def create
    puts session
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    puts "22222"
    sign_in_and_redirect(resource_name, resource)
  end

  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    respond_to do |format|
      format.json { 
        render :json => {:success => true} 
      }
      format.html { 
        _redirect_url = cookies[LOGIN_SUC_CODE] || GlobalSettings.study_url
        cookies.delete(LOGIN_SUC_CODE, :domain => COOKIE_DOMAIN) unless cookies[LOGIN_SUC_CODE].nil?
        redirect_to _redirect_url
      }
    end
  end

  def destroy
    cookies.delete "JSESSIONID"
    super
  end

  def failure
    respond_to do |format|
      format.json { render :json => {:success => false, :errors => ["账号或密码错误."]} }
      format.html { render "sessions/new" }
    end
  end
    
end

