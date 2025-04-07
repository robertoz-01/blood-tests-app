class BloodChecksController < ApplicationController
  def index
    @blood_checks = Current.user.blood_checks
  end
end
