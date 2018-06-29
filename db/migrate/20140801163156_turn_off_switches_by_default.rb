class TurnOffSwitchesByDefault < ActiveRecord::Migration
  def up
    change_column_default :profiles, :events_on, false
    change_column_default :profiles, :press_on, false
    change_column_default :profiles, :questions_on, false
    change_column_default :profiles, :social_feed_on, false
    change_column_default :profiles, :issues_on, false
    change_column_default :profiles, :media_on, false
    change_column_default :profiles, :biography_on, false
  end

  def down
    change_column_default :profiles, :events_on, true
    change_column_default :profiles, :press_on, true
    change_column_default :profiles, :questions_on, true
    change_column_default :profiles, :social_feed_on, true
    change_column_default :profiles, :issues_on, true
    change_column_default :profiles, :media_on, true
    change_column_default :profiles, :biography_on, true
  end
end
