require 'diff'

class IssueVersionsController < ApplicationController
  unloadable
  menu_item :issues

  helper :wiki

  before_filter :find_issue

  def index
    @version_count = @issue.issue_versions.count
    @version_pages = Paginator.new self, @version_count, per_page_option, params['p']
    # don't load text
    @versions = @issue.issue_versions.find :all,
                                            :select => "id, issue_id, journal_id, version",
                                            :order => 'version DESC',
                                            :limit  =>  @version_pages.items_per_page + 1,
                                            :offset =>  @version_pages.current.offset

    render :layout => false if request.xhr?
  end

  def show
    @issue_version = @issue.issue_versions.find_by_version(params[:version])
  end

  def diff
    @diff = @issue.diff(params[:version], params[:version_from])
    render_404 unless @diff
  end

private
  # Copy from IssuesController
  def find_issue
    @issue = Issue.find(params[:issue_id], :include => [:project, :tracker, :status, :author, :priority, :category])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
