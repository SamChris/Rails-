class Tagging < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to(
    :short_url,
    class_name: "ShortenedUrl",
    foreign_key: :short_url_id,
    primary_key: :id
  )

  belongs_to(
    :tag,
    class_name: "Tag",
    foreign_key: :tag_id,
    primary_key: :id
  )

  def self.add_tag!(short_url, tag)
    tagging = Tagging.new
    tagging.short_url_id = short_url.id
    tagging.tag_id = tag.id
    tagging.save!
  end

end
