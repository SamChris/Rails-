class Tag < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many(
    :taggings,
    class_name: "Tagging",
    foreign_key: :tag_id,
    primary_key: :id
  )

  has_many :short_urls, through: :taggings, source: :short_url
end
