class Entry < ActiveRecord::Base
  attr_accessor :verification_code_confirmation

  validates_presence_of :name, :email, :mobile_number

  scope :id_is, ->id{ where(id: id) }
  scope :not_verified, ->{ where(verified: false) }

  after_create :issue_verification_code
  after_create :send_verification_code

  VERIFICATION_CODE_LENGTH = 4

  def verify_and_save(attributes)
    self.verification_code_confirmation = attributes[:verification_code_confirmation]
    if self.verification_code == self.verification_code_confirmation
      self.verified = true
      self.verification_code = nil
      self.save
    else
      self.errors.add(:verification_code_confirmation, "この#{Entry.human_attribute_name :verification_code_confirmation}は不正な値です")
      return false
    end
  end

  private
  def issue_verification_code
    self.verification_code = [*0..9].sample(VERIFICATION_CODE_LENGTH).join
    self.save!
  end

  def send_verification_code

  end
end
