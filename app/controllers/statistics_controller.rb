class StatisticsController < ApplicationController
  before_action :jwt_required

  def index
    params.require(:area)

    total_applicant_count = User.joins(:status).where('is_final_submit = ?', true).count

    if params[:area] == 'daejeon'
      return render json: User.statistics(true), status: :ok
    elsif params[:area] == 'nationwide'
      return render json: User.statistics(false), status: :ok
    elsif params[:area] == 'all'
      return render json: {
        nationwide: User.statistics(false),
        daejeon: User.statistics(true),
        total_applicant_count: total_applicant_count,
        total_competition_rate: (total_applicant_count.to_r / 80).round(2).to_f
      }, status: :ok
    end

    render status: :bad_request
  end
end
