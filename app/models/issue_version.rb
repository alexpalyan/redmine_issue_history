class IssueVersion < ActiveRecord::Base
  unloadable
  belongs_to :journal
  belongs_to :issue

  def text=(plain)
    case Setting.wiki_compression
    when 'gzip'
    begin
      self.data = Zlib::Deflate.deflate(plain, Zlib::BEST_COMPRESSION)
      self.compression = 'gzip'
    rescue
      self.data = plain
      self.compression = ''
    end
    else
      self.data = plain
      self.compression = ''
    end
    plain
  end

  def text
    @text ||= case compression
    when 'gzip'
       Zlib::Inflate.inflate(data)
    else
      # uncompressed data
      data
    end
  end

  def author
    journal ? journal.user : issue.author
  end

  def updated_on
    journal ? journal.created_on : issue.created_on
  end

  # Returns the previous version or nil
  def previous
    @previous ||= WikiContent::Version.find(:first,
                                            :order => 'version DESC',
                                            :include => :author,
                                            :conditions => ["wiki_content_id = ? AND version < ?", wiki_content_id, version])
  end
end
