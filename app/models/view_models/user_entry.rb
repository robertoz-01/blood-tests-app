# frozen_string_literal: true

# This class represents an entry coming from the user interface
module ViewModels
  class UserEntry
    include ActiveModel::API
    attr_accessor :identifier, :name, :value, :unit, :reference_lower, :reference_upper, :message

    def self.from_blood_check(blood_check)
      blood_check.check_entries.map do |entry|
        from_check_entry(entry)
      end
    end

    def self.from_check_entry(check_entry)
      new(identifier: check_entry.identifier,
          name: check_entry.analysis.default_name,
          value: check_entry.value,
          unit: check_entry.analysis.unit,
          reference_lower: check_entry.analysis.reference_lower,
          reference_upper: check_entry.analysis.reference_upper
      )
    end
  end
end
