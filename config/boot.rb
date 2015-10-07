require 'rubygems'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

LOGIN_SUC_CODE = "_system_login_next"
COOKIE_DOMAIN = "wanguoschool.com"
