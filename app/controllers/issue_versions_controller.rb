class IssueVersionsController < ApplicationController
  unloadable


  def index
    @issue = Issue.find(params[:issue_id])
    @version_count = IssueVersion.count(:conditions => {:issue_id => params[:issue_id]})
    @version_pages = Paginator.new self, @version_count, per_page_option, params['p']
    # don't load text
    @versions = IssueVersion.find :all,
                                            :select => "id, issue_id, journal_id, version",
                                            :order => 'version DESC',
                                            :conditions => {:issue_id => params[:issue_id]},
                                            :limit  =>  @version_pages.items_per_page + 1,
                                            :offset =>  @version_pages.current.offset

    render :layout => false if request.xhr?
  end

  def show
    @version = IssueVersion.find(:first,
      :conditions => {:issue_id => params[:issue_id], :version => params[:version]})
  end

  def diff
  end
end
