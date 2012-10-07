# encoding: utf-8

class Api::FriendshipsController < HowjoyController
respond_to :json

def index
  if request.format == :json
    if !params['profile_id'] or params['profile_id'] == 'self'
      profile = current_user.profile
    else
      profile = Profile.find(params['profile_id'])
    end
    friends = profile.social.friends
    render :status=>200, :json=>{:c=>200, :d=>friends}
    return
    if params['profile_id'] == current_user.profile.id.to_s or params['profile_id'] == 'self'
      profile = Profile.find(params['profile_id'])
      friends = profile.social.friends
      render :status=>200, :json=>{:c=>200, :d=>friends}
    else
      render :status=>200, :json=>{:c=>403, :d=>{'message' => 'cannot see others requests'}}
    end
  end
end

def create
  if request.format == :json
    if params['profile_id'] == current_user.profile.id.to_s or params['profile_id'] == 'self'
      render :status=>200, :json=>{:c=>500, :d=>{'message' => '这是你自己'}}
      return
    end
    to_follow = Profile.find(params['profile_id'])
    if to_follow
      my_profile = current_user.profile
      frs = my_profile.requests
      frs.each do |fr|
        if fr.from_id.to_s == params['profile_id']
          friend1 = Friend.new(relation: 1, profile_id: fr.from_id, name: to_follow.name, url: '')
          if not my_profile.social
            my_profile.social = Social.new()
          end
          my_profile.social.feed_sources << friend1.profile_id
          my_profile.social.friends << friend1
          my_profile.update

          if not to_follow.social
            to_follow.social = Social.new()
          end
          friend2 = Friend.new(relation: 1, profile_id: current_user.profile.id, name: current_user.profile.name, url: '')
          to_follow.social.feed_sources << friend2.profile_id
          to_follow.social.friends << friend2

          fr.remove
          feed1 = Feed.new(title: "#{current_user.profile.name} 和 #{to_follow.name} 成为了好友", content: '', type: 2, privacy: 0)
          feed1.people = {'id' => to_follow.id}
          current_user.profile.feeds << feed1
          feed1.save!

          #feed2 = Feed.new(title: "#{to_follow.name} 和 #{current_user.profile.name} 成为了好友", content: '', type: 2, privacy: 0)
          #feed2.people = {'id' => current_user.profile.id}
          #to_follow.feeds << feed2
          #feed2.save!

          noti1 = Notification.new(title: "#{current_user.profile.name} 接受了你的好友请求", content: '', type: 2, privacy: 0)
          noti1.people = {'id' => current_user.profile.id}
          to_follow.notifications << noti1
          noti1.save!

          to_follow.update
          render :status=>200, :json=>{:c=>200, :d=>{:id => '对方已发送请求，双方成为好友'}}
          return
        end
      end

      fr = FriendRequest.new(from_id: current_user.profile.id)
      to_follow.requests << fr

      #Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} followed you", to_follow.name, 2)
      #Api::NotificationsController.make_public(to_follow, "#{current_user.profile.name} wants to be your friends", '', 2)
      noti2 = Notification.new(title: "#{current_user.profile.name} 希望成为你的好友", content: '', type: 2, privacy: 0)
      noti2.people = {'id' => current_user.profile.id}
      to_follow.notifications << noti2

      noti2.save!
      to_follow.update

      render :status=>200, :json=>{:c=>200, :d=>{:id => 'create'}}
    else
      render :status=>200, :json=>{:c=>404, :d=>{'message' => '用户不存在'}}
    end
  end
end

def update
  if request.format == :json
    if params['profile_id'] == current_user.profile.id.to_s or params['profile_id'] == 'self'
      my_profile = current_user.profile
      case params['act']
        when 'accept'
          frs = my_profile.requests
          frs.each do |fr|
            if fr.from_id.to_s == params['id']
              to_profile = Profile.find(fr.from_id)
              puts to_profile.name
              friend1 = Friend.new(relation: 1, profile_id: fr.from_id, name: to_profile.name, url: '')
              if not my_profile.social
                my_profile.social = Social.new()
              end
              my_profile.social.feed_sources << friend1.profile_id
              my_profile.social.friends << friend1
              friend1.save!
              my_profile.update

              if not to_profile.social
                to_profile.social = Social.new()
              end
              friend2 = Friend.new(relation: 1, profile_id: current_user.profile.id, name: current_user.profile.name, url: '')
              to_profile.social.feed_sources << friend2.profile_id
              to_profile.social.friends << friend2
              friend2.save!
              to_profile.update

              fr.remove

              #feed1 = Feed.new(title: "#{current_user.profile.name} 和 #{to_profile.name} 成为了好友", content: '', type: 2, privacy: 0)
              #feed1.people = {'id' => to_profile.id}
              #current_user.profile.feeds << feed1
              #feed1.save!

              feed2 = Feed.new(title: "#{to_profile.name} 和 #{current_user.profile.name} 成为了好友", content: '', type: 2, privacy: 0)
              feed2.people = {'id' => current_user.profile.id}
              to_profile.feeds << feed2
              feed2.save!

              noti1 = Notification.new(title: "#{current_user.profile.name} 接受了你的好友请求", content: '', type: 2, privacy: 0)
              noti1.people = {'id' => to_profile.id}
              to_profile.notifications << noti1
              noti1.save!
              break
            end
          end
        when 'ignore'
          frs = my_profile.requests
          frs.each do |fr|
            if fr.from_id.to_s == params['id']
              fr.remove
              break
            end
          end
        else
          render :status=>200, :json=>{:c=>200, :d=>{:message => '无效操作'}}
          return
      end
      render :status=>200, :json=>{:c=>200, :d=>{:name => 'update'}}
    else
      render :status=>200, :json=>{:c=>200, :d=>{:name => '将不更新'}}
    end

  end
end

def show
  if request.format == :json
    render :status=>200, :json=>{:c=>200, :d=>'show'}
  end
end

def destroy
  if request.format == :json
    #frs = current_user.profile.requests
    #frs.each do |fr|
    #  if fr.id.to_s == params['id']
    #    fr.remove
    #    break
    #  end
    #end
    #render :status=>200, :json=>{:c=>200, :d=>'destroyed'}

    if params['profile_id'] == current_user.profile.id.to_s or params['profile_id'] == 'self'
      my_profile = current_user.profile
      if my_profile.social
        my_profile.social.feed_sources.delete(Moped::BSON::ObjectId(params['id']))
        my_profile.social.friends.each do |friend|
          if friend.profile_id.to_s == params['id']
            friend.remove
            break
          end
        end
        my_profile.update
      end

      to_profile = Profile.find(params['id'])
      if to_profile and to_profile.social
        to_profile.social.feed_sources.delete(my_profile.id)
        to_profile.social.friends.each do |friend|
          if friend.profile_id == my_profile.id
            friend.remove
            break
          end
        end
        to_profile.update
      end

      render :status=>200, :json=>{:c=>200, :d=>{'message' => 'removed'}}
    else
      render :status=>200, :json=>{:c=>403, :d=>{'message' => 'cannot see others requests'}}
    end
  end
end

end
