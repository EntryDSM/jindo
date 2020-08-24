class ApplicantsController < ApplicationController
  before_action :jwt_required

  def show
    return render status: :not_found unless current_user

    if current_user.status.is_final_submit
      render json: current_user.applicant_information,
             status: :ok
    else
      render current_user.applicant_contact,
             status: :locked
    end
  end

  def index
    params.require(:index)

    presence_index = params.values_at(*User::FILTERS).index { |value| !value.nil? }
    valid_filter = params[User::FILTERS[presence_index]] if presence_index

    render json: User.applicants_information(params[:index].to_i,
                                             presence_index,
                                             valid_filter,
                                             is_daejeon: to_bool(params[:is_daejeon]),
                                             is_nationwide: to_bool(params[:is_nationwide]),
                                             not_arrived: to_bool(params[:not_arrived]),
                                             not_paid: to_bool(params[:not_paid]),
                                             is_common: to_bool(params[:is_common]),
                                             is_meister: to_bool(params[:is_meister]),
                                             is_social: to_bool(params[:is_social])),
           status: :ok
  end

  def update
    return render status: :not_found unless current_user

    user_status = current_user.status
    user_status.update!(is_paid: params[:is_paid]) if params[:is_paid]
    user_status.update!(is_printed_application_arrived: params[:is_arrived]) if params[:is_arrived]
    user_status.update!(is_final_submit: params[:is_final_submit]) if params[:is_final_submit]

    render status: :no_content
  end

  def create
    Admin.create_exam_code
    render status: :ok
  end

  private

  def to_bool(bool)
    ActiveModel::Type::Boolean.new.cast(bool)
  end
end
