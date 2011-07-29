class Document < ActiveRecord::Base
  validates :content, presence: true
  
  belongs_to :site
end