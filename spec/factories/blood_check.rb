FactoryBot.define do
  factory :blood_check do
    identifier { SecureRandom.uuid }
    check_date { Date.new(2020, 3, 29) }
    notes { "Some info" }
    association :user
  end
end
