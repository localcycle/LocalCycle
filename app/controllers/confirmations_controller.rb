class ConfirmationsController < Devise::ConfirmationsController

  # Overwrite the confirmation methods to allow for "gradual engagement".

  def show
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])
    super if resource.nil? or resource.confirmed?
  end

  def confirm
    self.resource = resource_class.find_by_confirmation_token(params[resource_name][:confirmation_token]) if params[resource_name][:confirmation_token].present?
    if resource.update_attributes(params[resource_name]) && resource.password_match?
      self.resource = resource_class.confirm_by_token(params[resource_name][:confirmation_token])
      set_flash_message :notice, :confirmed
      sign_in_and_redirect(resource_name, resource)
    else
      render :action => "show"
    end
  end

  def fixconfirm
    redirect_to root_url
  end
end
