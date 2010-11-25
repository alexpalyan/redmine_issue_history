class CreateIssueVersions < ActiveRecord::Migration
  def self.up
    create_table :issue_versions do |t|
      t.column :issue_id, :integer
      t.column :journal_id, :integer
      t.column :data, :binary
      t.column :compression, :string, :limit => 6, :default => ""
      t.column :version, :integer
    end
  end

  def self.down
    drop_table :issue_versions
  end
end
