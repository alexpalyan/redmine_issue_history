ActionController::Routing::Routes.draw do |map|
  map.with_options  :controller => 'issue_versions' do |issue_versions|
    issue_versions.show_issue_versions 'issues/:issue_id/versions', :action => 'index'
    issue_versions.diff_issue_versions 'issues/:issue_id/versions/diff', :action => 'diff', :conditions => { :method => :post }
    issue_versions.show_issue_version 'issues/:issue_id/version/:version', :action => 'show', :constraints => {:version => /^\d/}
  end

#  map.resources :issues do |issue|
#    issue.resourses :issue_versions, :as => 'versions', :only => [:index, :show, :diff]
#  end

#  map.resource :issue_versions, :path_prefix => '/issues/:issue_id', :as => 'versions'
end