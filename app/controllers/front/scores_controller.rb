class Front::ScoresController < Front::BaseController
  respond_to :json

  def create
    @score = Score.find_or_initialize_by scorable_id: params[:scorable_id],
                                         scorable_type: params[:scorable_type],
                                         ip: request.remote_ip

    if @score.new_record?
      if @score.save
        case @score.scorable_type
        when 'Issue'
          profile = Issue.find(@score.scorable_id).profile
          mixpanel_tracker(profile.account).track_event :visitor_issue_upvote
        when 'Event'
          profile = Event.find(@score.scorable_id).profile
          mixpanel_tracker(profile.account).track_event :visitor_event_upvote
        when 'SocialPost'
          profile = SocialPost.find(@score.scorable_id).profile
          mixpanel_tracker(profile.account).track_event :visitor_campaign_update_post_upvote
        end
        render json: true
      else
        render json: false, status: 422
      end
    else
      @score.destroy
      render json: true, status: 204
    end
  end

private

  def permitted_params
    params.permit([:scorable_id, :scorable_type])
  end
end
