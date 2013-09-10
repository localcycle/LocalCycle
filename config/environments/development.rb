LOCALCYCLE::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # PAYPAL SETTINGS
  PAYPAL_EMAIL = ENV['PAYPAL_EMAIL']
  PAYPAL_SECRET = ENV['PAYPAL_SECRET']
  PAYPAL_CERT_ID = ENV['PAYPAL_CERT_ID']
  PAYPAL_URL = ENV['PAYPAL_URL']

  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
      bucket: "localcycle",
      access_key_id: ENV["EC2_ACCESS_KEY"],
      secret_access_key: ENV["EC2_SECRET_KEY"]
    }
  }


  # Don't care if the mailer can't send
  # config.action_mailer.async = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: 'localcycle.org' }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => "smtp.sendgrid.net",
    :port                 => 587,
    :domain               => 'localcycle.org',
    :user_name            => ENV['SENDMAIL_USERNAME'],
    :password             => ENV['SENDMAIL_PASSWORD'],
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }
  config.action_mailer.perform_deliveries = false

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false
  config.assets.logger = false

  DEBUG = true


  ANET_API_LOGIN_ID = "99p4s4TTSm"
  ANET_KEY = "264KZdxGs936Mq2a"
  ANET_QUESTION = "Simon"
  ANET_GATEWAY = '423541'
  
#Test Cards
#- American Express Test Card: 370000000000002
#- Discover Test Card: 6011000000000012	
#- Visa Test Card: 4007000000027	
#- Second Visa Test Card: 4012888818888	
#- JCB: 3088000000000017	
#- Diners Club/ Carte Blanche: 38000000000006


end
