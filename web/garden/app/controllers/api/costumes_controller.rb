# encoding: utf-8

class Api::CostumesController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      profiles = Profile.all
      render :status=>200, :json=>{:c=>200, :d=>profiles}
    end
  end

  def show
    if request.format == :json
      if params['id'] == 'self'
        profile = current_user.profile
      else
        profile = Profile.find(params['id'])
      end
      if profile
        render :status=>200, :json=>{:c=>200, :d=> {:profile => profile, :feeds => profile.feeds, :debug => current_user.profile.id}}
      else
        render :status=>200, :json=>{:c=>404, :d=> 'not found'}
      end
    end
  end
end
