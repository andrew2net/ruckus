class AccountsController < ApplicationController
  decorates_assigned :profile
  layout 'account/public/main'
  before_action :load_resources, only: [:show, :create]

  private

  def load_resources
    domain_name = DomainNameFetcher.new(request).fetch
    @domain = Domain.find_by(name: domain_name) if domain_name.present?
    if @domain.present?
      @profile = ProfileDecorator.decorate(@domain.profile)
      if @profile.premium_by_default? || @profile.credit_card_holder.present? || @profile.owner == current_account
        redirect_to message_path(profile_id: @profile.id) unless @profile.premium? || @profile.premium_by_default?
        if !@domain.internal? && @domain.profile.suspended?
          redirect_to profile_path(@profile.domains.internal.first)
        elsif @domain.profile.accounts.any? && @domain.profile.active?
          @domain.visits.create(data: "")
          @account = @profile.accounts.reject(&:deleted?).first
        else
          raise ActionController::RoutingError.new('Not Found')
        end
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
end
