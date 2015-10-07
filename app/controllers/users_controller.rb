# encoding: utf-8
class UsersController < ApplicationController

  def update_password
    @user = User.find(params[:id])
    puts params[:current_password]
    puts params[:password]
    puts @user.salt
    if Digest::MD5.hexdigest(@user.id.to_s + params[:current_password] + params[:password] + @user.salt) != params[:key]
      render :json => {"status" => "error", "msg" => "认证失败!"} and return
    end
    user_pwd_hash = {:current_password => params[:current_password], :password => params[:password],:password_confirmation => params[:password]}
    if @user.update_with_password(user_pwd_hash)
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      render :json => {"status" => "success", "msg" => "密码修改成功!"} and return
    else
      render :json => {"status" => "error", "msg" => "密码修改失败!"} and return
    end
  end
  
  
  def update_email
    @user = User.find(params[:id])
    if Digest::MD5.hexdigest(params[:id].strip + params[:email].strip + @user.salt) != params[:key]
      render :json => {"status" => "error", "msg" => "认证失败!"} and return
    end
    email_count = User.where("email = ? and id != ?", params[:email].strip, params[:id].strip).count
    if email_count == 0
      @user.update_attribute(:email, params[:email].strip)
      render :json => {"status" => "success", "msg" => "修改成功!"} and return
    else
      render :json => {"status" => "error", "msg" => "邮箱地址已被使用!"} and return
    end
  end
  
  def status
    if user_signed_in?
      if params[:callback].blank?
        render :text => '{"sign_in" : true, "name" : "'+current_user.name+'"}'
      else
        render :text => params[:callback] + '({"sign_in" : true, "name" : "'+current_user.name+'"})'
      end
    else
      if params[:callback].blank?
        render :text => '{"sign_in" : false}'
      else
        render :text => params[:callback] + '({"sign_in" : false})'
      end
    end
  end
  
  
end