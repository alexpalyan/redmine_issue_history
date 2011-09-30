module RedmineIssueHistory
  # Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        has_many :issue_versions
        #after_save :add_to_history_from_issue
        alias_method_chain :create_journal, :description
        after_destroy :remove_issue_history
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      # This will add to the IssueHistory new text
      def create_journal_with_description
        if @issue_before_change.nil? || description != @issue_before_change.description
          old_version = issue_versions.maximum('version')
          new_version = old_version ? old_version + 1 : 1;
          if @current_journal && Redmine::VERSION::STRING < "1.2.0"
            # attributes changes
            @current_journal.details << JournalDetail.new(:property => 'attr',
                                                          :prop_key => 'description',
                                                          :old_value => old_version,
                                                          :value => new_version)

          end
        end
        create_journal_without_description
        if new_version
          IssueVersion.create do |iv|
            iv.journal = @current_journal ? @current_journal : Journal.new
            iv.issue = self
            iv.text = description
            iv.version = new_version
          end
        end
      end

      def remove_issue_history
        IssueVersion.destroy_all(['issue_id = (?)', self.id]) if self.id
      end

      def diff(version_to=nil, version_from=nil)
        version_to = version_to ? version_to.to_i : self.content.version
        version_from = version_from ? version_from.to_i : version_to - 1
        version_to, version_from = version_from, version_to unless version_from < version_to
        
        content_to = issue_versions.find_by_version(version_to)
        content_from = issue_versions.find_by_version(version_from)

        (content_to && content_from) ? WikiDiff.new(content_to, content_from) : nil
      end

      def version
        issue_versions.maximum('version') || 0
      end
    end
  end
end
