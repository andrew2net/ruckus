class Account::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication

  def new
    @account = build_resource
    @account.build_candidate_profile
    @account.build_organization_profile

    render 'new', layout: false
  end

  def create
    attrs = sign_up_params

    build_resource(attrs)

    resource.invitation_accepted_at = Time.now
    resource.invitation_created_at = Time.now
    resource.invitation_sent_at = Time.now

    if resource.save
      @profile = resource.profile
      @profile.owner_id = resource.id
      @profile.save
      resource.profiles << @profile
      resource.update_column :profile_id, @profile.id
      Media::ProfileUpdater::DefaultBackgroundImage.new(@profile).process

      AccountMailer.welcome_email(resource).deliver
      yield resource if block_given?

      sign_up(resource_name, resource)
      set_flash_message :notice, :signed_up

      mixpanel_tracker(resource).track_event :user_sign_up
      render :show
    else
      clean_up_passwords resource
      flash.now[:alert] = resource.errors.full_messages.to_sentence
    end
  end

  def update
    account_params = devise_parameter_sanitizer.sanitize(:account_update)
    profile_params = account_params[:profile_attributes]
    account_params.delete(:profile_attributes)

    @account = current_account
    @profile = current_profile

    old_name = current_profile.name
    old_phone = current_profile.phone

    if @account.update(account_params) && @profile.update(profile_params)
      @profile.reload

      new_name = @profile.name
      new_phone = @profile.phone

      mixpanel_tracker.track_event(:display_name_update) if old_name != new_name
      mixpanel_tracker.track_event(:display_phone_update) if old_phone != new_phone

      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in current_account, bypass: true
      redirect_to after_update_path_for(current_account)
    else
      errors = [@account.errors.full_messages.to_sentence, @profile.errors.full_messages.to_sentence].join(' ')
      redirect_to edit_profile_my_account_path, alert: errors
    end
  end

  def destroy
    resource.delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    mixpanel_tracker(resource).track_event :account_status_deactivate
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
end
