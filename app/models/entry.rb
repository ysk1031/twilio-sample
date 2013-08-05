class Entry < ActiveRecord::Base
  attr_accessor :verification_code_confirmation

  validates_presence_of :name, :email, :mobile_number
  validates :mobile_number, format: { with: /\A\d{11}\z/ }

  scope :id_is, ->id{ where(id: id) }
  scope :not_verified, ->{ where(verified: false) }

  after_create :issue_verification_code

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

  def send_verification_code
    @call = twilio_client.account.calls.create(
      from: (ENV['TWILIO_PHONE_NUMBER'] || TWILIO_PHONE_NUMBER),
      to: formatted_mobile_number,
      url: "#{ENV['APP_URL'] || APP_URL}/entries/#{self.id}/verification_call.xml"
    )

    #twilio_client.account.sms.messages.create(
    #  from: TWILIO_PHONE_NUMBER,
    #  to: formatted_mobile_number,
    #  body: "こんにちは。以下の認証コードを入力してください。\n#{self.verification_code}"
    #)
  end

  private
  def issue_verification_code
    self.verification_code = [*0..9].sample(VERIFICATION_CODE_LENGTH).join
    self.save!
  end

  def twilio_client
    @twilio_client ||= Twilio::REST::Client.new((ENV['TWILIO_SID'] || TWILIO_SID), (ENV['TWILIO_TOKEN'] || TWILIO_TOKEN))
  end

  def formatted_mobile_number
    "+81#{self.mobile_number[1..-1]}"
  end
end
