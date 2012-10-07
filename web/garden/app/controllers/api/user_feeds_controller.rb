# encoding: utf-8

class Api::UserFeedsController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      feeds = Feed.where(profile_id: params['profile_id'])
      render :status=>200, :json=>{:c=>200, :d=>feeds}
    end
  end
end
