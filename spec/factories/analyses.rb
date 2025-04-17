FactoryBot.define do
  factory :analysis do
    default_name { "Red blood cells" }
    other_names { [ "Erythrocytes", "RBC", "Red cells" ] }
    unit { "mg/dL" }
    reference_lower { 4 }
    reference_upper { 5.5 }
  end
end
