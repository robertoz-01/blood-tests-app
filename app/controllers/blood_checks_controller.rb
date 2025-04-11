class BloodChecksController < ApplicationController
  def index
    @blood_checks = Current.user.blood_checks
  end

  def new
    @blood_check = BloodCheck.new
  end

  def edit
    @blood_check = BloodCheck.find_by!(identifier: params[:id])
    render :new
  end

  def create
    @blood_check = BloodCheck.new(params.expect(blood_check: [:check_date, :notes]))
    @blood_check.user_id = Current.user.id

    if @blood_check.save
      user_entries = CheckEntry.insert_user_entries(user_entries_from_params, @blood_check)
      render json: {
        blood_check: { identifier: @blood_check.identifier,
                       check_date: @blood_check.check_date,
                       notes: @blood_check.notes },
        user_entries: user_entries
      }, status: :created
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_entity
    end
  end

  def update
    @blood_check = BloodCheck.find_by!(identifier: params[:id])

    if @blood_check.update(params.require(:blood_check).permit(:check_date, :notes))
      user_entries = CheckEntry.insert_user_entries(user_entries_from_params, @blood_check)
      render json: {
        blood_check: { identifier: @blood_check.identifier,
                       check_date: @blood_check.check_date,
                       notes: @blood_check.notes },
        user_entries: user_entries
      }, status: :ok
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_entries_from_params
    params.expect(entries: [[:identifier, :name, :value, :unit, :reference]])
      .map { |entry_data| UserEntry.new(entry_data) }
  end
end
