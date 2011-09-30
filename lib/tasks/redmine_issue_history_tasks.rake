# desc "Explaining what the task does"
# task :redmine_issue_history do
#   # Task goes here
# end

namespace :redmine_issue_history do
  desc "Move all history from plugin to core journal (Redmine 1.2)"
  task :move_to_core => :environment do
    journal_detail = nil
    IssueVersion.all(:order => "issue_id, journal_id DESC").each do |iv|
      if journal_detail
        journal_detail.old_value = iv.text
        journal_detail.save
        printf "Updated journal record %d for issue %d\n", journal_detail.id, iv.issue_id
      end
      new_journal_detail = iv.journal ? iv.journal.details.first( :conditions => { :prop_key => "description"}) : nil
      if new_journal_detail && (journal_detail.nil? || new_journal_detail.journal.journalized_id == journal_detail.journal.journalized_id)
        journal_detail = new_journal_detail
        journal_detail.value = iv.text
      else
        journal_detail = nil
      end
    end
  end
end