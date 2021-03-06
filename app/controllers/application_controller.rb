class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  before_filter :store_location

  before_filter :set_locale

  def store_location
    return unless request.get? 
    if !request.path.include?('/people/') && !request.xhr?
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def set_locale
    if current_person
      I18n.locale = current_person.locale
    elsif session[:locale]
      I18n.locale = session[:locale]
    else
      parsed_locale = request.host.split('.').last
      I18n.locale = parsed_locale == 'br' ? 'pt-br' : 'en'
    end
  end

  def get_locale
    render json: {locale: I18n.locale}.to_json
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name unless controller_name == 'omniauth_callbacks'
  end
end

