class AccountsController < ApplicationController
  decorates_assigned :profile
  layout 'account/public/main'
  before_action :load_resources, only: %i[show create]

  private

  def load_resources
    domain_name = DomainNameFetcher.new(request).fetch
    @domain = Domain.find_by(name: domain_name) if domain_name.present?
    raise ActionController::RoutingError, 'Not Found' unless @domain.present?
    @profile = ProfileDecorator.decorate(@domain.profile)
    unless @profile.premium_by_default? ||
           @profile.credit_card_holder.present? ||
           @profile.owner == current_account
      raise ActionController::RoutingError 'Not Found'
    end
    unless @profile.premium? || @profile.premium_by_default?
      redirect_to message_path(profile_id: @profile.id)
    end
    if !@domain.internal? && @domain.profile.suspended?
      redirect_to profile_path(@profile.domains.internal.first)
    elsif @domain.profile.accounts.any? && @domain.profile.active?
      @domain.visits.create(data: "")
      @account = @profile.accounts.reject(&:deleted?).first
    else
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end
