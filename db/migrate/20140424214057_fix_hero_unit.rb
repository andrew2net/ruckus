class FixHeroUnit < ActiveRecord::Migration
  def up
    only_if_defined do
      Profile.all.each { |profile| profile.send(:copy_hero_unit) }
    end
  end

  private

  def only_if_defined
    yield
  rescue Exception => e
    puts e.to_s
  end
end
