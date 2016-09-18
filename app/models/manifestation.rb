class Manifestation < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_many :taggings
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_many :recommendations

  has_paper_trail
  has_many :external_links

  def long?
    return false # TODO: implement
  end
  def copyright?
    return expressions[0].copyrighted # TODO: implement more generically
  end
  def chapters?
    return false # TODO: implement
  end
  def approved_tags
    return Tag.find(self.taggings.approved.pluck(:tag_id))
  end
  def as_prose?
    # TODO: implement more generically
    return expressions[0].works[0].genre == 'poetry' ? false : true
  end
end
