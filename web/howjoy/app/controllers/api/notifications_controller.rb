# encoding: utf-8

class Api::NotificationsController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      notis = current_user.profile.notifications
      render :status=>200, :json=>{:c=>200, :d=>notis}
    end
  end

  def create
    if request.format == :json
      if params['act'] and params['act'] == 'invite'
        profiles = ActiveSupport::JSON.decode(params['profiles'])
        name = current_user.profile.name
        profiles.each do |prof|
          profile = Profile.find(prof)
          if profile
            noti1 = Notification.new(title: "#{name} 邀请你参加活动", content: '', type: params['task_type'], privacy: 0, task: {id: params['task_id']})
            profile.notifications << noti1
            noti1.save!
          end
        end
        render :status=>200, :json=>{:c=>200, :d=>'done'}
      end
    end
  end

  def self.make_private(profile, title,  content, type)
    noti1 = Notification.new(title: title, content: content, type: type, privacy: 0)
    profile.notifications << noti1
  end

  def self.make_friend(profile, title,  content, type)
    noti1 = Notification.new(title: title, content: content, type: type, privacy: 1)
    profile.notifications << noti1
  end

  def self.make_public(profile, title,  content, type)
    noti1 = Notification.new(title: title, content: content, type: type, privacy: 2)
    profile.notifications << noti1
  end
end
