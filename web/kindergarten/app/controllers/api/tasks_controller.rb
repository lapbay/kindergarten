# encoding: utf-8

require "date"
class Api::TasksController < HowjoyController
  #before_filter :authenticate_user!
  respond_to :json

  def index
    if request.format == :json
      sleep(1)
      count = 1
      resp = []
      case params['scope']
        when 'all'
          #tasks = Task.all.limit(20)
          #tasks = Task.where(:loc => {"$near" => [-122.40, 37.785] , '$maxDistance' => 11/111.12})
          #tasks = Task.where(:status.exists => true, :status => {:$gt => 0}, :type => {:$lte => 1}).limit(20)
          tasks = Task.where(:status.exists => true, :type => {:$lte => 1}).limit(20)
          if tasks
            tasks.each do |t|
              task = {:type => t.type, :_id => t.id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d|%H:%M"), :place => t.place, :count => count}
              resp << task
            end
            end
        when 'search'
            keyword = params['kw']
            #tasks = Task.where(:status.exists => true, :type => {:$lte => 1}).limit(20)
            tasks = Task.where(:status.exists => true, :type => {:$lte => 1}, :name => {:$in => [keyword]}).limit(20)
            if tasks
              tasks.each do |t|
                task = {:type => t.type, :_id => t.id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d|%H:%M"), :place => t.place, :count => count}
                resp << task
              end
            end
        when 'recommend'
          tasks = Task.all.limit(20)
          if tasks
            tasks.each do |t|
              task = {:type => t.type, :_id => t.id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d|%H:%M"), :place => t.place, :count => count}
              resp << task
            end
          end
        when 'parted'
          tasks = current_user.profile.tasks.limit(20)
          if tasks
            tasks.each do |t|
              task = {:type => t.type, :_id => t.task_id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d|%H:%M"), :place => t.place, :count => count}
              resp << task
            end
          end
        when 'created'
          tasks = current_user.profile.owns.limit(20)
          if tasks
            tasks.each do |t|
              task = {:type => t.type, :_id => t.id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d|%H:%M"), :place => t.place, :count => count}
              resp << task
            end
          end
      end

      render :status=>200, :json=>{:c=>200, :d=>resp}
    end
  end

  def create
    if request.format == :json
      if params['type'] and params['type'] == 'series'
        subtasks = ActiveSupport::JSON.decode(params['subtasks'])
        subids = []
        user_subtasks = []

        start_at = DateTime.strptime(params.fetch(:start_at, '1989-06-04|20:00'), '%Y-%m-%d|%H:%M').to_time
        deadline = DateTime.strptime(params.fetch(:deadline, '1989-06-04|00:00'), '%Y-%m-%d|%H:%M').to_time
        geo_string = params.fetch(:place, ',')
        geo = geo_string.split(',')
        task1 = Task.create! :type => 1, :name => params.fetch(:name, ''), :desc => params.fetch(:desc, ''), :deadline => deadline, :start_at => start_at, :categories => [params.fetch(:categories, '')], :place => params.fetch(:place, ''), loc: [geo[0].to_f, geo[1].to_f], bonus: params.fetch(:bonus, '')

        subtasks.each do |subtask|
          if subtask['categories'] and subtask['desc']
            start_at = DateTime.strptime(subtask.fetch('start_at', '1989-06-04|20:00'), '%Y-%m-%d|%H:%M').to_time
            deadline = DateTime.strptime(subtask.fetch('deadline', '1989-06-04|00:00'), '%Y-%m-%d|%H:%M').to_time
            geo_string = subtask.fetch('place', ',')
            geo = geo_string.split(',')
            stask = Task.create! :superTask => task1.id, :type => 2, :name => subtask.fetch('name', ''), :desc => subtask.fetch('desc', ''), :deadline => deadline, :start_at => start_at, :categories => [subtask.fetch('categories', '')], :place => subtask.fetch('place', ''), loc: [geo[0].to_f, geo[1].to_f], bonus: subtask.fetch('bonus', '')
            current_user.profile.owns << stask
            subids << stask.id.to_s
            user_subtasks << {id: stask.id.to_s, name: stask.name, type: stask.type, role: 10, status: 0, place: stask.place, start_at: stask.start_at}
          end
        end
        task1.subtasks = subids
        current_user.profile.owns << task1

        user_task1 = UserTask.new(:type => task1.type, role: 10, status: 0, step: 1, name: task1.name, place: task1.place, start_at: task1.start_at, subtasks: user_subtasks)
        current_user.profile.tasks << user_task1
        task1.profiles << user_task1
        current_user.profile.update
        task1.update

        #Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} create a task", task1.name, 1)
        feed1 = Feed.new(title: '#{current_user.profile.name} 发布了一个系列活动', content: task1.name, type: task1.type, privacy: 0)
        feed1.task = {'id' => task1.id}
        current_user.profile.feeds << feed1
        feed1.save!
        render :status=>200, :json=>{:c=>200, :d=>{:id => task1.id}}
      else
        start_at = DateTime.strptime(params.fetch(:start_at, '1989-06-04|20:00'), '%Y-%m-%d|%H:%M').to_time
        deadline = DateTime.strptime(params.fetch(:deadline, '1989-06-04|00:00'), '%Y-%m-%d|%H:%M').to_time
        geo_string = params.fetch(:place, ',')
        geo = geo_string.split(',')
        task1 = Task.create! :type => 0, :name => params.fetch(:name, ''), :desc => params.fetch(:desc, ''), :deadline => deadline, :start_at => start_at, :categories => [params.fetch(:categories, '')], :place => params.fetch(:place, ''), loc: [geo[0].to_f, geo[1].to_f], bonus: params.fetch(:bonus, '')
        current_user.profile.owns << task1

        user_task1 = UserTask.new(type: task1.type, role: 10, status: 0, name: task1.name, place: task1.place, start_at: task1.start_at)
        current_user.profile.tasks << user_task1
        task1.profiles << user_task1
        current_user.profile.update
        task1.update

        #Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} create a task", task1.name, 1)
        feed1 = Feed.new(title: "#{current_user.profile.name} 发布了一个活动", content: task1.name, type: task1.type, privacy: 0)
        feed1.task = {'id' => task1.id}
        current_user.profile.feeds << feed1
        feed1.save!
        render :status=>200, :json=>{:c=>200, :d=>{:id => task1.id}}
      end
    end
  end

  def update
    if request.format == :json
      if params['type'] and params['type'] == 'series'
        task1 = Task.find(params[:id])
        if task1
          task1.desc = params[:desc]
          task1.update
          if task1.profiles
            task1.profiles.update_all(desc: task1.desc)
          end

          #Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} update a task", task1.name, 1)
          feed1 = Feed.new(title: "#{current_user.profile.name} 更新了活动", content: task1.name, type: task1.type, privacy: 0)
          feed1.task = {'id' => task1.id}
          current_user.profile.feeds << feed1
          feed1.save!

          render :status=>200, :json=>{:c=>200, :d=>{:desc => task1.desc}}
        else
          render :status=>200, :json=>{:c=>404, :d=>'not found'}
        end
      else
        task1 = Task.find(params[:id])
        if task1
          task1.desc = params[:desc]
          task1.update
          if task1.profiles
            task1.profiles.update_all(desc: task1.desc)
          end

          #Api::FeedsController.make_public(current_user.profile, "#{current_user.profile.name} update a task", task1.name, 1)
          feed1 = Feed.new(title: "#{current_user.profile.name} 更新了活动", content: task1.name, type: task1.type, privacy: 0)
          feed1.task = {'id' => task1.id}
          current_user.profile.feeds << feed1
          feed1.save!

          render :status=>200, :json=>{:c=>200, :d=>{:desc => task1.desc}}
        else
          render :status=>200, :json=>{:c=>404, :d=>'not found'}
        end
      end

    end
  end

  def show
    if request.format == :json
      task1 = Task.find(params[:id])
      if params[:super_task_id]
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:super_task_id])
      else
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
      end
      if task1
        res = {type: task1.type, name: task1.name, desc: task1.desc, start_at: task1.start_at.strftime("%Y-%m-%d|%H:%M"), place: task1.place, categories: task1.categories, bonus: task1.bonus, deadline: task1.deadline.strftime("%Y-%m-%d|%H:%M"), max: task1.max, count: task1.count, bonus: task1.bonus}
        res[:owner] = task1.profile.name
        res[:profile_id] = task1.profile.id

        records = []
        task1.records.each do |p|
          url = ''
          if p.url.length > 0
            url = File.join(Rails.application.config.static_resource_url, p.url)
          end
          record = [p.desc, url]
          records << record
        end
        res['other'] = [records]

        subtasks = Task.in(id: task1.subtasks)
        if subtasks
          res[:step] = user_task1.step
          res['subtasks'] = []
          subtasks.each do |subtask|
            s = {id: subtask.id, type: subtask.type, name: subtask.name, desc: subtask.desc, start_at: subtask.start_at.strftime("%Y-%m-%d|%H:%M"), place: subtask.place, categories: subtask.categories, bonus: subtask.bonus, deadline: subtask.deadline.strftime("%Y-%m-%d|%H:%M"), max: subtask.max, count: subtask.count, bonus: subtask.bonus, owner: task1.profile ? task1.profile.name : '', profile_id: task1.profile ? task1.profile.id : ''}
            res['subtasks'] << s
          end
        end
        if user_task1
          status = user_task1.status
          puts user_task1.step
          puts user_task1.subtasks
          if user_task1.step > 0 and user_task1.subtasks.size > 0
            status = user_task1.subtasks[user_task1.step - 1]['status']
          end
          render :status=>200, :json=>{:c=>200, :d=>{:task => res, :id => task1.id, :owner => user_task1.profile.name, :role => user_task1.role, :status => status}}
        else
          render :status=>200, :json=>{:c=>200, :d=>{:task => res, :id => task1.id, :role => 0, :status => 0}}
        end
      else
        render :status=>200, :json=>{:c=>404, :d=>'not found'}
      end
    end
  end
end
