class BloodCheck < ApplicationRecord
  belongs_to :user

  has_many :check_entries
  has_many :analyses, through: :check_entries
end
