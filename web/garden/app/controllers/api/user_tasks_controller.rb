# encoding: utf-8

class Api::UserTasksController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      if params['profile_id'] == 'self'
        tasks = current_user.profile.tasks
      else
        tasks = UserTask.where(profile_id: params['profile_id'])
      end
      resp = []
      if tasks.size > 0
        tasks.each do |t|
          name = t.name
          tid = t.task_id
          super_tid = nil
          if t.step > 0 and t.subtasks.size > 0
            name = name + ' > ' + t.subtasks[t.step - 1]['name']
            tid = t.subtasks[t.step - 1]['id']
            super_tid = t.task_id
          end
          task = {:type => t.type, :task_id => tid, :name => name, :place => t.place}
          if super_tid
            task[:super_task_id] = super_tid
          end
          resp << task
        end
      end
      render :status=>200, :json=>{:c=>200, :d=>resp}
    end
  end

  def create
    if request.format == :json
      task1 = Task.find(params[:id])
      if task1
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
        if not user_task1
          if task1.subtasks.size > 0
            user_subtasks = []
            task1.subtasks.each do |subtask|
              user_subtasks << {id: subtask.id.to_s, name: subtask.name, type: subtask.type, role: 11, status: 1, place: subtask.place, start_at: subtask.name}
            end
            user_task1 = UserTask.new(role: 11, status: 1, step: 1, name: task1.name, place: task1.place, start_at: task1.start_at, subtasks: user_subtasks)
          else
            user_task1 = UserTask.new(role: 11, status: 1, name: task1.name, place: task1.place, start_at: task1.start_at)
          end
          current_user.profile.tasks << user_task1
          task1.profiles << user_task1
          current_user.profile.save
          task1.count += 1
          task1.save
        else
          user_task1.role = 11
          user_task1.status = 1
          user_task1.update
        end

        feed1 = Feed.new(title: "#{current_user.profile.name} 加入了一个任务", content: task1.name, type: task1.type, privacy: 0)
        feed1.task = {'id' => task1.id}
        current_user.profile.feeds << feed1
        feed1.save!

        render :status=>200, :json=>{:c=>200, :d=>{:id => user_task1.id}}
      else
        render :status=>200, :json=>{:c=>200, :d=>{:message => '任务不存在'}}
      end
    end
  end

  def update
    puts 'updating'
    if request.format == :json
      task1 = Task.find(params[:id])
      if task1
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
        if not user_task1
          render :status=>200, :json=>{:c=>200, :d=>{:message => '还未加入这个任务'}}
        else
          user_task1.status = 2
          user_task1.update
          render :status=>200, :json=>{:c=>200, :d=>{:id => user_task1.id}}
        end
      else
        render :status=>200, :json=>{:c=>200, :d=>{:message => '任务不存在'}}
      end
    end
  end

  def destroy
    if request.format == :json
      task1 = Task.find(params[:id])
      if task1
        user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
        if not user_task1
          render :status=>200, :json=>{:c=>200, :d=>{:message => '还未加入这个任务'}}
        else
          task1.count -= 1
          user_task1.status = 0
          user_task1.update
          render :status=>200, :json=>{:c=>200, :d=>{:id => user_task1.id}}
        end
      else
        render :status=>200, :json=>{:c=>200, :d=>{:message => '任务不存在'}}
      end
    end
  end

  def show
    if request.format == :json
      task1 = current_user.profile.tasks.find(params[:id])
      if task1
        render :status=>200, :json=>{:c=>200, :d=>task1}
      else
        render :status=>200, :json=>{:c=>404, :d=>'任务不存在'}
      end
    end
  end
end
