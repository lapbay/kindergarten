# encoding: utf-8
require 'RMagick'

class Api::RecordsController < HowjoyController
  include Math
  include Magick
  respond_to :json

  def index
    if request.format == :json
      max_distance = Rails.application.config.max_allowed_distance
      records = Record.where(:loc => {"$near" => [-122.40, 37.79] , '$maxDistance' => max_distance/111.12})

      render :status=>200, :json=>{:c=>200, :d=>records}
    end
  end

  def create
    if request.format == :json
      if params[:super_task_id]
        user_task1 = current_user.profile.tasks.find_by(task_id: Moped::BSON::ObjectId(params[:super_task_id]))
        task1 = Task.find(params[:id])
      else
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
        task1 = user_task1.task
      end
      if user_task1 and task1
        if params['longitude'] and params['latitude']
          location = [params['longitude'].to_f, params['latitude'].to_f]
        else
          location = [0, 0]
        end
        dis = getDistance(location, task1.loc)
        max_distance = Rails.application.config.max_allowed_distance
        if dis >= max_distance
          #render :status=>200, :json=>{:c=>500, :d=>"不在任务地点范围 #{max_distance} 公里内，无法完成任务"}
          #return
        end

        if params['friends']
          friends = ActiveSupport::JSON.decode(params['friends'])
        else
          friends = []
        end
        friends.each do |fid|
          friend = Profile.find(fid)
          noti1 = Notification.new(title: "#{current_user.profile.name} 与你一起参加了活动", content: task1.name, type: task1.type, privacy: 0)
          noti1.task = {'id' => task1.id}
          friend.notifications << noti1
          noti1.save!
        end
        if params[:photo]
          name = params[:photo].original_filename
          root = 'public'
          directory = 'images/upload'
          path = File.join(directory, name)
          file_path = File.join(root, path)
          content = params[:photo].read
          File.open(file_path, 'wb') { |f| f.write(content); f.close }
          img = Magick::Image.read(file_path).first
          record1 = Record.new(url: path, name: name, md5: params[:md5], height: img.rows, width: img.columns, loc: location, desc: params[:desc], type: params[:type], friends: friends)
          img.destroy!
          task1.records << record1
          user_task1.records << record1
          if record1.type.to_i == 2
            if params[:super_task_id] and user_task1.step > 0
              ongoing_subtask = user_task1.subtasks[user_task1.step - 1]
              ongoing_subtask['status'] = 2
              if user_task1.step < ongoing_subtask.size
                user_task1.step += 1
              end
            else
              user_task1.status = 2
            end
          end
          record1.save!
          user_task1.update
          task1.update

          Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} 完成了一个任务", record1.url, task1.type)
          render :status=>200, :json=>{:c=>200, :d=>'record done with photo'}
        else
          record1 = Record.new(loc: location, desc: params[:desc], type: params[:type], friends: friends)
          task1.records << record1
          user_task1.records << record1
          if record1.type == 2
            if params[:super_task_id] and user_task1.step > 0
              ongoing_subtask = user_task1.subtasks[user_task1.step - 1]
              puts ongoing_subtask
              ongoing_subtask['status'] = 2
              if user_task1.step < ongoing_subtask.size
                user_task1.step += 1
              end
            else
              user_task1.status = 2
            end
          end
          record1.save!
          user_task1.update
          task1.update

          Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} 完成了一个任务", record1.desc, task1.type)
          render :status=>200, :json=>{:c=>200, :d=>'record done'}
        end
      end
    else
      render :status=>200, :json=>{:c=>404, :d=>'任务不存在'}
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
        render :status=>200, :json=>{:c=>404, :d=> '用户不存在'}
      end
    end
  end


  protected
  def getDistance (loc1, loc2)
    lng1 = loc1[0]
    lat1 = loc1[1]
    lng2 = loc2[0]
    lat2 = loc2[1]

    lat_diff = (lat1 - lat2)*PI/180.0
    lng_diff = (lng1 - lng2)*PI/180.0
    lat_sin = Math.sin(lat_diff/2.0) ** 2
    lng_sin = Math.sin(lng_diff/2.0) ** 2
    first = Math.sqrt(lat_sin + Math.cos(lat1*PI/180.0) * Math.cos(lat2*PI/180.0) * lng_sin)
    result = Math.asin(first) * 2 * 6378 #kilometers

    puts loc1
    puts loc2
    puts result.to_i

    result.to_i #kilometers
  end
end
