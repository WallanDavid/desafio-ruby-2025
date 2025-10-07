# Carregado apenas em test. Evita NoMethodError caso algo mude.
module Browser
  module ActionController; end
end unless defined?(Browser::ActionController)

class ActionController::Base
  class << self
    def allow_browser(*); end
  end
end unless ActionController::Base.respond_to?(:allow_browser)
