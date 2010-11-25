require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_issue_history do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include?(RedmineIssueHistory::IssuePatch)
    Issue.send(:include, RedmineIssueHistory::IssuePatch)
  end
end



Redmine::Plugin.register :redmine_issue_history do
  name 'Redmine Issue History plugin'
  author 'Palyan Alexander'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/freedayko/redmine_issue_history'
  author_url 'http://apmpc.dp.ua/'
end
