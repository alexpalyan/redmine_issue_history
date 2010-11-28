class CreateIssueVersions < ActiveRecord::Migration
  class Issue < ActiveRecord::Base

  end

  def self.up
    create_table :issue_versions do |t|
      t.column :issue_id, :integer
      t.column :journal_id, :integer
      t.column :data, :binary
      t.column :compression, :string, :limit => 6, :default => ""
      t.column :version, :integer
    end

    Issue.all.each do |issue|
      IssueVersion.create do |iv|
        iv.journal_id = 0
        iv.issue_id = issue.id
        iv.text = issue.description
        iv.version = 1
      end
    end
  end

  def self.down
    drop_table :issue_versions
  end
end
