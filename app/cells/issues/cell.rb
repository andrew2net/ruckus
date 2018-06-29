class Issues::Cell < BaseCell
  self_contained!
  include ApplicationHelper # category_color_block_class

  def show
    @category_id.present? ? render_issues : render
  end

  def render_switch
    render partial: 'switch' if show_issues_switch?
  end

  def render_pencil
    render partial: 'pencil' if show_navigation?
  end

  def render_issue_categories
    render partial: 'issue_categories' if show_issues?
  end

  def render_issues
    render partial: 'issues' if show_issues?
  end

  def render_issue(issue)
    render partial: 'issue', locals: { issue: issue }
  end

  def categories
    allowed_categories
  end

  def collection
    issues_with_category
  end

  def show_issues?
    @issues_exist ||= profile.issues.exists?
    show_navigation? || (profile.issues_on? && @issues_exist)
  end

  def issues_with_category
     show_placeholders? ? issues_with_placeholders : issues
  end

  def show_placeholders?
    show_navigation? && issues.length <= 3
  end

  def issues_with_placeholders
    [issues.first, issues.second, issues.third]
  end

  def issues
    @issues ||= profile.issues.by_position.includes(:issue_category)
    @issues = @issues.where(issue_category_id: @category_id) if issues_for_category?
    @issues
  end

  def allowed_categories
    profile.allowed_categories
  end

  def shown_issue_categories
    profile.shown_issue_categories
  end

  def editing_link(issue)
    show_navigation? ? builder_modal_link(issue) : public_modal_link(issue)
  end

  private
  def issues_for_category?
    @category_id.present? && @category_id != :all
  end

  def builder_modal_link(issue)
    link_to ' ', edit_profile_issue_path(issue), class: 'slide-link'
  end

  def public_modal_link(issue)
    link_to ' ', front_profile_issue_path(profile, issue, show_modal: true), class: 'slide-link ajax-issue-link'
  end

  def show_issues_switch?
    show_navigation? && profile.issues.any?
  end
end
