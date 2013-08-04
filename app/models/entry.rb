class Entry < ActiveRecord::Base
  validates_presence_of :name, :email, :mobile_number
end
