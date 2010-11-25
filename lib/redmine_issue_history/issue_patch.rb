module RedmineIssueHistory
  # Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        after_save :add_to_history_from_issue
        after_destroy :remove_issue_history
      end

    end

    module ClassMethods
    end

    module InstanceMethods
      # This will add to the IssueHistory new text
      def add_to_history_from_issue
        # TODO: remove changed_attributes, should be detected by other way
        if changed_attributes.present? && changed_attributes['description'].present?
          old_description = changed_attributes['description']
          new_description = description
          old_version = IssueVersion.maximum('version', :conditions => {:issue_id => id})
          new_version = old_version + 1;

          if @current_journal
            # attributes changes
              @current_journal.details << JournalDetail.new(:property => 'attr',
                                                            :prop_key => 'description',
                                                            :old_value => old_version,
                                                            :value => new_version)
            @current_journal.save

            IssueVersion.create do |iv|
              iv.journal = @current_journal unless @current_journal.nil?
              iv.issue = self
              iv.text = new_description
              iv.version = new_version
            end

            # reset current journal
            init_journal @current_journal.user, @current_journal.notes
          end
        end
        #IssueVersion.update_from_issue(self)
        return true
      end

      def remove_issue_history
        IssueVersion.destroy_all(['issue_id = (?)', self.id]) if self.id
      end
    end
  end
end
