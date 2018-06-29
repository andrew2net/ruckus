class Front::QuestionsController < Front::BaseAccountController
  inherit_resources
  belongs_to :profile

  before_action :load_resource

  layout false, only: [:new]
  respond_to :js, only: :create

  def new
    new! do
      resource.build_user
    end
  end

  def create
    user_params = params[:question].delete(:user_attributes)
    @question = parent.questions.new(permitted_params[:question])
    if @question.add_user(user_params)
      mixpanel_tracker ||= mixpanel_tracker(parent.account)
      mixpanel_tracker.track_event :visitor_question, questioner_name: @question.user.name, questioner_email: @question.user.email, questioner_date: Date.today
      AccountMailer.question_message(resource).deliver
      AccountMailer.question_asker_notification(resource).deliver
    end
  end

  private

  def load_resource
    @profile = parent.decorate
  end

  def permitted_params
    params.permit(:profile_id, question: [:text, user_attributes: [:first_name, :last_name, :email, :subscribed]])
  end
end
