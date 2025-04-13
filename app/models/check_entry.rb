class CheckEntry < ApplicationRecord
  belongs_to :blood_check
  belongs_to :analysis

  def self.insert_user_entries(user_entries, blood_check)
    existing_entries = CheckEntry.where(identifier: user_entries.map(&:identifier))
    existing_entries_by_identifiers = existing_entries.map { |e| [e.identifier, e] }.to_h

    existing_analyses = Analysis.all.to_a
    existing_analyses_by_name = existing_analyses.map { |a| [a.default_name, a] }.to_h

    user_entries.each do |entry|
      unless existing_analyses_by_name.has_key?(entry.name)
        existing_analyses_by_name[entry.name] = Analysis.create!(
          default_name: entry.name,
          unit: entry.unit,
          reference_lower: entry.reference_lower,
          reference_upper: entry.reference_upper
        )
      end
      if existing_entries_by_identifiers.has_key?(entry.identifier)
        existing_entries_by_identifiers[entry.identifier].update(value: entry.value, analysis: existing_analyses_by_name[entry.name])
      else
        CheckEntry.create(
          identifier: entry.identifier,
          value: entry.value,
          blood_check: blood_check,
          analysis: existing_analyses_by_name[entry.name]
        )
      end
    end
  end
end
