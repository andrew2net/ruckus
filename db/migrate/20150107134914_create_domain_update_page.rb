class CreateDomainUpdatePage < ActiveRecord::Migration
  def up
    Page.create name: 'how-to-update-domain', data: ''
  end

  def down
    Page.where(name: 'how-to-update-domain').destroy_all
  end
end
