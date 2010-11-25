# RedmineIssueHistory
module RedmineIssueHistory
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, :partial => 'issues/show_history'
  end
end