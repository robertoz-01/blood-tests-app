class CheckEntry < ApplicationRecord
  belongs_to :blood_check
  belongs_to :analysis

  class << self
    def insert_user_entries(user_entries, blood_check)
      analyses_by_name = get_or_create_analyses(user_entries)

      existing_entries = CheckEntry.where(identifier: user_entries.map(&:identifier))
      existing_entries_by_identifiers = existing_entries.map { |e| [ e.identifier, e ] }.to_h

      check_entries = user_entries.map do |entry|
        analysis = analyses_by_name[entry.name]

        if existing_entries_by_identifiers.has_key?(entry.identifier)
          existing_check_entry = existing_entries_by_identifiers[entry.identifier]
          existing_check_entry.update(value: entry.value, analysis: analysis)
          existing_check_entry
        else
          new_check_entry = CheckEntry.create(
            identifier: entry.identifier,
            value: entry.value,
            blood_check: blood_check,
            analysis: analysis
          )
          new_check_entry
        end
      end

      check_entries.map { |check_entry| ViewModels::UserEntry.from_check_entry(check_entry) }
    end

    private

    def get_or_create_analyses(user_entries)
      existing_analyses = Analysis.all.to_a
      analyses_by_name = existing_analyses.map { |a| [ a.default_name, a ] }.to_h

      user_entries.each do |entry|
        unless analyses_by_name.has_key?(entry.name)
          analyses_by_name[entry.name] = Analysis.create!(
            default_name: entry.name,
            unit: entry.unit,
            reference_lower: entry.reference_lower,
            reference_upper: entry.reference_upper
          )
        end
      end
      analyses_by_name
    end
  end
end
