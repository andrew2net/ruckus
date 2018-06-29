class Profile::SocialPostsController < Profile::BaseController
  inherit_resources
  layout 'account/admin/modal'
  respond_to :html, :js

  def create
    create! do |success, failure|
      success.js do
        prefix = current_profile.candidate? ? 'campaign' : 'chapter'
        suffix = 'local' if !resource.facebook? && !resource.twitter?
        suffix = 'facebook' if resource.facebook? && !resource.twitter?
        suffix = 'twitter' if !resource.facebook? && resource.twitter?
        suffix = 'all' if resource.facebook? && resource.twitter?

        mixpanel_tracker.track_event("#{prefix}_update_post_#{suffix}".to_sym)

        render :show
      end

      failure.js do
        render 'create'

        if resource.has_social_errors?
          flash[:alert] = resource.social_errors.join('</br>').html_safe
        end

        resource.deactivate_oauth_accounts!
      end
    end
  end

  private

  def begin_of_association_chain
    current_profile
  end

  def permitted_params
    params.permit(social_post: [:message, provider: []])
  end

  def end_of_association_chain
    @end_of_association_chain ||= super.order(created_at: :desc)
  end
end
