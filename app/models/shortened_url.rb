class ShortenedUrl < ActiveRecord::Base
  attr_accessible :long_url, :short_url, :submitter_id
  validates :short_url, :uniqueness => true, :presence => true
  validates_length_of :long_url, maximum: 1024
  validate :only_5_urls_per_10_minutes

  def only_5_urls_per_10_minutes
    num_urls = ShortenedUrl.where("submitter_id = (?)", self.submitter_id).where(created_at: 5.minutes.ago..Time.now).count(:submitter_id)
    puts
    puts num_urls
    puts
    errors[:base] << "WAIT, you've submitted too many urls!" if num_urls > 5
  end

  belongs_to(
    :submitter,
    :class_name => 'User',
    :foreign_key => :submitter_id,
    :primary_key => :id
  )

  has_many(
    :visits,
    :class_name => "Visit",
    :foreign_key => :short_url_id,
    :primary_key => :id
  )

  has_many(
    :taggings,
    class_name: "Tagging",
    foreign_key: :short_url_id,
    primary_key: :id
  )

  has_many :tags, through: :taggings, source: :tag
  has_many :visitors, :through => :visits, :source => :visitor, :uniq => true

  def self.random_code
    random_code_generated = false
    until random_code_generated
      random_code = SecureRandom.urlsafe_base64(16)
      code_uniq = !ShortenedUrl.find_by_short_url(random_code)
      random_code_generated = true if code_uniq
    end

    random_code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    shortened_url = self.random_code
    ShortenedUrl.new({:short_url=>shortened_url, :long_url=>long_url, :submitter_id=>user.id}).save!
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visits.count(:visitor_id, distinct: true)
  end

  def num_recent_uniques
    visits.where(created_at: Time.now-600..Time.now).count(:visitor_id, distinct: true)
  end


end
