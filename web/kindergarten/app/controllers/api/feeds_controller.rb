# encoding: utf-8

class Api::FeedsController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      page = params[:page].to_i
      if current_user.profile.social
        friends = current_user.profile.social.feed_sources
        friends << current_user.profile.id
        if page > 0
          feeds = Feed.in(:$or => [{:profile_id => friends}, {:class_unit_id => current_user.profile.class_unit_id}]).skip(10 * page).limit(10)
        else
          feeds = Feed.in(:$or => [{:profile_id => friends}, {:class_unit_id => current_user.profile.class_unit_id}]).limit(10)
        end
        #feeds = Feed.in(profile_id: friends)
      else
        if page > 0
          feeds = current_user.profile.class_unit.feeds.skip(10 * page).limit(10)
        else
          feeds = current_user.profile.class_unit.feeds.limit(10)
        end
      end
      render :status=>200, :json=>{:c=>200, :d=>feeds}

    end
  end

  def show
    if request.format == :json
      feed = Feed.first
      render :status=>200, :json=>{:c=>200, :d=>feed}
    end
  end

  def create
    if request.format == :json
      feed1 = Feed.new(title: '测试消息 in seed', content: params['msg'], type: 0)
      current_user.profile.feeds << feed1
      current_user.profile.class_unit.feeds << feed1
      render :status=>200, :json=>{:c=>200, :d=>'done'}
    end
  end

  def self.make_private(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 0)
    profile.feeds << feed1
  end

  def self.make_friend(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 1)
    profile.feeds << feed1
  end

  def self.make_public(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 2)
    profile.feeds << feed1
  end
end
