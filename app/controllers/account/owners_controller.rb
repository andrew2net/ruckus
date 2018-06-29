class Account::OwnersController < ApplicationController
  inherit_resources
  before_action :authenticate_account!
  before_action :authorize_ownership_change!

  belongs_to :profile
  defaults resource_class: Account, collection_name: 'accounts'

  def update
    parent.update_column :owner_id, resource.id
  end

  private
  def authorize_ownership_change!
    authorize! :set_as_owner, resource, parent
  end
end
