class Ability
  include CanCan::Ability

  def initialize(account)
    if account.present?
      if account.profile.premium?
        can :manage, Domain

        can :create, Account do |new_account, profile|
          profile.has_admin?(account)
        end

        can :update_ownership_type, Account do |editor_account, profile|
          profile.has_admin?(account) &&
            editor_account != account &&
            editor_account.invitation_accepted_at.present?
        end

        can :destroy, Account do |destroyable_account, profile|
          profile.has_admin?(account) &&
            destroyable_account != account &&
            profile.accounts.include?(destroyable_account)
        end
      else
        can :index, Domain
      end
    end
  end
end
