class CheckEntry < ApplicationRecord
  belongs_to :blood_check
  belongs_to :analysis
end
