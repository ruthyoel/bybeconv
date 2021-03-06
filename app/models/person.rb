include BybeUtils
class Person < ActiveRecord::Base
  attr_accessible :affiliation, :comment, :country, :dates, :name, :nli_id, :other_designation, :title, :viaf_id, :public_domain, :profile_image
  is_impressionable # for statistics
  belongs_to :toc
  belongs_to :period
  has_and_belongs_to_many :work
  has_and_belongs_to_many :expression
  has_and_belongs_to_many :manifestation
  scope :has_toc, -> { where.not(toc_id: nil) }

  has_attached_file :profile_image, styles: { full: "720x1040", medium: "360x520", thumb: "180x260", tiny: "90x120"}, default_url: "/assets/:style/missing.png", storage: :s3, s3_credentials: 'config/s3.yml', s3_region: 'us-east-1'
  validates_attachment_content_type :profile_image, content_type: /\Aimage\/.*\z/

  def self.person_by_viaf(viaf_id)
    Person.find_by_viaf_id(viaf_id)
  end
  def self.create_or_get_person_by_viaf(viaf_id)
    p = Person.person_by_viaf(viaf_id)
    if p.nil?
      viaf_record = viaf_record_by_id(viaf_id)
      fail Exception if viaf_record.nil?
      #debugger
      bdate = viaf_record['birthDate'].nil? ? '?' : viaf_record['birthDate'].encode('utf-8')
      ddate = viaf_record['deathDate'].nil? ? '?' : viaf_record['deathDate'].encode('utf-8')
      datestr = bdate+'-'+ddate
      p = Person.new(dates: datestr, name: viaf_record['labels'][0].encode('utf-8'), viaf_id: viaf_id)
      p.save!
    end
    p
  end

  def period_string
    return '' if period.nil?
    return period.name
  end

  def has_comment?
    return false if comment.nil?
    return false if comment.empty?
    return true
  end
end
