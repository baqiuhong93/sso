class ApplicationController < ActionController::Base
  after_filter :reset_last_captcha_code!
  
  protect_from_forgery
end
