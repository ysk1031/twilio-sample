json.array!(@entries) do |entry|
  json.extract! entry, :name, :email, :mobile_number, :verification_code, :verified
  json.url entry_url(entry, format: :json)
end
