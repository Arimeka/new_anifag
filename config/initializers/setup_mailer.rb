require 'assets/development_mail_interceptor'

ActionMailer::Base.smtp_settings = {
  :address  => 'smtp.gmail.com',
  :port=> 587,
  :domain => 'anifag.com',
  :user_name  => 'user',
  :password  => 'password',
  :authentication       => "plain",
  :enable_starttls_auto => true
} 

ActionMailer::Base.default_url_options[:host] = "www.anifag.com"

Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
