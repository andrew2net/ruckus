class Profile::DomainsController < Profile::BaseController
  inherit_resources
  load_and_authorize_resource
  respond_to :js, except: :index

  def create
    @domain.valid?

    if @domain.save
      mixpanel_tracker.track_event :url_create
    end

    render :new
  end

  def update
    update! do |success, failure|
      success.js do
        mixpanel_tracker.track_event :url_update
        render :show
      end
      failure.js { render :edit }
    end
  end

  private

  def collection
    begin_of_association_chain.domains.where.not(id: current_profile.domain.id)
  end

  def begin_of_association_chain
    current_profile
  end

  def permitted_params
    params.permit(domain: [:name])
  end
end
