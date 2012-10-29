# encoding: utf-8

class Api::ProfilesController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      profiles = Profile.where(class_unit: current_user.profile.class_unit.id)
      render :status=>200, :json=>{:c=>200, :d=>profiles}
    end
  end

  def show
    if request.format == :json
      relation = 0
      if params['id'] == current_user.profile.id.to_s or params['id'] == 'self'
        relation = 1
        profile = current_user.profile
      else
        profile = Profile.find(params['id'])
        if profile
          frs = profile.requests
          frs.each do |fr|
            if fr.from_id.to_s == current_user.profile.id.to_s
              relation = 3 #current user sent a request
              break
            end
          end
          frs = current_user.profile.requests
          frs.each do |fr|
            if fr.from_id.to_s == params['id']
              relation = 4 #this user sent a request to current user
              break
            end
          end
        end
      end
      if profile
        friends = []
        if current_user.profile.social and current_user.profile.social.feed_sources.include?(profile.id)
          relation = 2
          friends = profile.social.friends
        end
        data = []
        case params['scope']
          when 'tasks'
            data = profile.tasks
          when 'photos'
            data = profile.records
          else
            data = profile.feeds
        end
        render :status=>200, :json=>{:c=>200, :d=> {:profile => profile, :data => data, :friends => friends, :relation => relation}}
      else
        render :status=>200, :json=>{:c=>404, :d=> 'not found'}
      end
    end
  end
end
