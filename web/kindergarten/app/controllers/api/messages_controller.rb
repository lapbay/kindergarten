# encoding: utf-8

class Api::MessagesController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      if params[:page]
        page = params[:page].to_i
      else
        page = 0
      end
      res = []
      if params[:with]
        with_id = params[:with]
        if with_id == 'self' or with_id == current_user.profile.id.to_s
          render :status=>200, :json=>{:c=>500, :d=>'cant talk to oneself'}
          return
        end
        to_profile = Profile.find(with_id)
        if not to_profile
          render :status=>200, :json=>{:c=>404, :d=>'用户不存在'}
          return
        end

        if page > 0
          msgs = Message.where(:$or => [{:from_id => current_user.profile.id.to_s, :to_id => with_id}, {:to_id => current_user.profile.id.to_s, :from_id => with_id}])
        else
          msgs = Message.where(:$or => [{:from_id => current_user.profile.id.to_s, :to_id => with_id}, {:to_id => current_user.profile.id.to_s, :from_id => with_id}])
        end
        res = msgs
      else
        if page > 0
          msgs = Message.where(:$or => [{:from_id => current_user.profile.id.to_s}, {:to_id => current_user.profile.id.to_s}])
        else
          msgs = Message.where(:$or => [{:from_id => current_user.profile.id.to_s}, {:to_id => current_user.profile.id.to_s}])
        end
        my_id = current_user.profile.id.to_s
        ids = {}
        msgs.each do |msg|
          if msg[:from_id] == my_id
            other_id = msg[:to_id]
          else
            other_id = msg[:from_id]
          end
          ids[other_id] = msg
        end
        res = ids.values
      end
      render :status=>200, :json=>{:c=>200, :d=>res}
    end
  end

  def create
    if request.format == :json
      txt = params[:msg]
      from_profile = current_user.profile
      to_profile = Profile.find(params[:to])
      if txt.size > 0 and to_profile
        from = {name: from_profile.name, avatar: from_profile.avatar}
        to = {name: to_profile.name, avatar: to_profile.avatar}
        Message.create!(content: txt, type: 0, from_id: from_profile.id.to_s, to_id: to_profile.id.to_s, from: from, to: to)
        render :status=>200, :json=>{:c=>200, :d=>'done'}
      else
        render :status=>200, :json=>{:c=>500, :d=>'私信不能为空'}
      end
    end
  end

  def self.send_message(profile, content, type)
    msg = Message.new(content: content, type: type)
    profile.messages << msg
  end

end
