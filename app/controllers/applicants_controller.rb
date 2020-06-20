class ApplicantsController < ApplicationController
  before_action :jwt_required

  def show
    return render status: :not_found unless current_user

    render json: current_user.applicant_information,
           status: :ok
  end

  def index
    params.require(:index)

    filters = User::FILTERS
    presence_index = params.values_at(*filters).index { |value| !value.nil? }
    apps_inform = User.applicants_information(params[:index].to_i,
                                              presence_index,
                                              params[filters[presence_index.to_i]])

    render json: { applicants_information: apps_inform },
           status: :ok
  end

  def update
    return render status: :not_found unless current_user

    user_status = current_user.status
    user_status.update!(is_paid: params[:is_paid]) if params[:is_paid]
    user_status.update!(is_printed_application_arrived: params[:is_arrived]) if params[:is_arrived]
    user_status.update!(is_final_submit: params[:is_final_submit]) if params[:is_final_submit]

    render status: 204
  end
end
