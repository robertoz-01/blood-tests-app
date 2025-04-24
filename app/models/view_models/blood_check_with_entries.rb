# frozen_string_literal: true

module ViewModels
  class BloodCheckWithEntries
    def initialize(blood_check, user_entries)
      @blood_check = blood_check
      @user_entries = user_entries
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    def to_h
      {
        blood_check: { identifier: @blood_check.identifier,
                       check_date: @blood_check.check_date,
                       notes: @blood_check.notes },
        entries: @user_entries
      }
    end
  end
end
