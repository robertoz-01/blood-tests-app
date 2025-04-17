FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user-#{n}@example.com" }
    sequence(:user_name) { "userName" }
    password { "password123" }
  end
end
