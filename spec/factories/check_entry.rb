FactoryBot.define do
  factory :check_entry do
    identifier { SecureRandom.uuid }
    value { 5.7 }
    association :blood_check
    association :analysis
  end
end
