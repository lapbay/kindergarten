class Admin::TasksController < HowjoyController
  #before_filter :authenticate_user!
  before_filter :authenticate_admin!
  respond_to :json
  def index
    if request.format == :json
      count = 1
      case params['scope']
        when 'all'
          tasks = Task.all.limit(20)
        when 'not'
          tasks = Task.where(:status.exists => true, :status => 0).limit(20)
        when 'yes'
          tasks = Task.where(:status.exists => true, :status => 1).limit(20)
      end

      resp = []
      if tasks
        tasks.each do |t|
          puts t.start_at
          task = { :_id => t.id, :name => t.name, :start_at => t.start_at.strftime("%Y-%m-%d, %H:%M"), :place => t.place, :status => t.status}
          resp << task
        end
      end
      render :status=>200, :json=>{:c=>200, :d=>resp}
    end
  end

  def create
    if request.format == :json

      task1 = Task.create! :name => params[:name], :desc => 'task desc from server', :deadline => Time.now, :start_at => Time.now, :type => 1, :place => 'some place', status: 0
      user_task1.profile.owns << task1

      user_task1 = UserTask.new(role: 10, status: 0, name: task1.name, place: task1.place, start_at: task1.start_at)
      current_user.profile.tasks << user_task1
      task1.profiles << user_task1
      user_task1.profile.update
      task1.update

      Api::FeedsController.make_public(user_task1.profile, "#{user_task1.profile.name} create a task", task1.name, 1)
      render :status=>200, :json=>{:c=>200, :d=>{:id => task1._id}}
    end
  end

  def update
    if request.format == :json
      task1 = Task.find(params[:id])

      task1.status = 1
      task1.update
      if task1 and task1.profiles
        #task1.profiles.update_all(status: task1.status)
      end
      puts task1.profile.name
      Api::FeedsController.make_public(task1.profile, "task approved", task1.id, 1)

      render :status=>200, :json=>{:c=>200, :d=>{:desc => task1.id}}
    end
  end

  def show
    if request.format == :json
      task1 = Task.find(params[:id])
      user_task1 = current_user.profile.tasks.find_by(task_id: params[:id])
      if task1
        resp = [[['name', task1.name], ['desc', task1.desc]], [['time', task1.start_at.strftime("%Y-%m-%d, %H:%M")], ['place', task1.place], ['type', task1.type]], [['bonus', task1.bonus], ['deadline', task1.deadline], ['max', task1.max], ['count', task1.count]]]
        if user_task1
          render :status=>200, :json=>{:c=>200, :d=>{:task => resp, :id => task1.id, :role => user_task1.role, :status => user_task1.status}}
        else
          render :status=>200, :json=>{:c=>200, :d=>{:task => resp, :id => task1.id, :role => 0, :status => 0}}
        end
      else
        render :status=>200, :json=>{:c=>404, :d=>'not found'}
      end
    end
  end
end
