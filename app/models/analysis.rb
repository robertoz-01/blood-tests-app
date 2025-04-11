class Analysis < ApplicationRecord
  has_many :check_entries
  has_many :blood_checks, through: :check_entries
end
