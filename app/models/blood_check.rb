class BloodCheck < ApplicationRecord
  has_many :check_entries
  has_many :analyses, through: :check_entries

  def user_entries
    check_entries.map do |entry|
      UserEntry.new(identifier: entry.identifier,
                    name: entry.analysis.default_name,
                    value: entry.value,
                    unit: entry.analysis.unit,
                    reference: "#{entry.analysis.reference_lower}-#{entry.analysis.reference_upper}"
      )
    end
  end
end
