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
      render json: {
        blood_check: { identifier: @blood_check.identifier,
                       check_date: @blood_check.check_date,
                       notes: @blood_check.notes }
      }, status: :created
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_entity
    end
  end

  def update
    @blood_check = BloodCheck.find_by!(identifier: params[:id])

    if @blood_check.update(params.require(:blood_check).permit(:check_date, :notes))
      render json: { identifier: @blood_check.identifier }, status: :ok
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_entity
    end
  end
end
