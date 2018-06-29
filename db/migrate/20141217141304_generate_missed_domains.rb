class GenerateMissedDomains < ActiveRecord::Migration
  def change
    Profile.all.each do |profile|
      profile.domains.create(new_account: true) unless profile.domains.exists?
    end
  end
end
