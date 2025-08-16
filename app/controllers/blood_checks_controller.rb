class BloodChecksController < ApplicationController
  def index
    @blood_checks = Current.user.blood_checks
  end

  def new
    @blood_check = BloodCheck.new
  end

  def edit
    @blood_check = blood_check_by_id!
    render :new
  end

  def create
    @blood_check = BloodCheck.new(params.expect(blood_check: [ :check_date, :notes ]))
    @blood_check.user_id = Current.user.id

    if @blood_check.save
      user_entries = CheckEntry.insert_user_entries(user_entries_from_params, @blood_check)
      render json: ViewModels::BloodCheckWithEntries.new(@blood_check, user_entries),
             status: :created
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_content
    end
  end

  def update
    @blood_check = blood_check_by_id!

    if @blood_check.update(params.require(:blood_check).permit(:check_date, :notes))
      user_entries = CheckEntry.insert_user_entries(user_entries_from_params, @blood_check)
      render json: ViewModels::BloodCheckWithEntries.new(@blood_check, user_entries),
             status: :ok
    else
      render json: { errors: @blood_check.errors }, status: :unprocessable_content
    end
  end

  def load_from_pdf
    user_entries = ExtractorService.entries_from_pdf(params.expect(:pdf_file).tempfile)
    render json: {
      user_entries: user_entries
    }, status: :created
  end

  def compare
    @blood_checks = blood_checks_by_ids!
    analyses_ids = Set.new
    @blood_checks.each do |blood_check|
      blood_check.check_entries.each { |entry| analyses_ids << entry.analysis_id }
    end

    @analyses = Analysis.includes(:check_entries).where(check_entries: { analysis_id: analyses_ids })
  end

  private

  def blood_check_by_id!
    Current.user.blood_checks.find_by!(identifier: params[:id])
  end

  def blood_checks_by_ids!
    identifiers = params.require(:identifiers).split(",")
    blood_checks = Current.user.blood_checks.where(identifier: identifiers).includes(:check_entries)

    if blood_checks.count != identifiers.count
      raise ActiveRecord::RecordNotFound
    end

    blood_checks
  end

  def user_entries_from_params
    return [] if params[:entries].blank?

    params.expect(entries: [ [ :identifier, :name, :value, :unit, :reference_lower, :reference_upper ] ])
          .map { |entry_data| ViewModels::UserEntry.new(entry_data) }
  end
end
