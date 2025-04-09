class BloodChecksController < ApplicationController
  def index
    @blood_checks = Current.user.blood_checks
  end

  def new
    @blood_check = BloodCheck.new
  end

  def create
    @blood_check = BloodCheck.new(params.expect(blood_check: [:check_date, :notes]))
    @blood_check.user_id = Current.user.id

    if @blood_check.save
      render json: { identifier: @blood_check.identifier }, status: :created
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_entity
    end
  end
end
