class ApplicationController < ActionController::Base
  # Torna seguro em ambientes onde o gem 'browser' não esteja carregado
  if defined?(Browser::ActionController)
    include Browser::ActionController
    allow_browser versions: :modern if respond_to?(:allow_browser)
  end
end
