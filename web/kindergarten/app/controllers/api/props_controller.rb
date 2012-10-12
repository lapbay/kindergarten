# encoding: utf-8

class Api::PropsController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      #props = Prop.all
      index = params[:index].to_i

      if params['longitude'] and params['latitude']
        location = [params['longitude'].to_f, params['latitude'].to_f]
      else
        location = [180.0, 180.0]
      end
      max_distance = Rails.application.config.max_allowed_distance

      tasks = Task.where(:loc => {"$near" => location , '$maxDistance' => max_distance/111.12})

      if tasks.size < 1
        render :status=>200, :json=>{:c=>500, :d=>"#{max_distance} 公里内没有正在进行的号角任务，没有寻获任何宝物"}
        return
      end

      prop1 = {name: '道具一', desc: '是个衣服', url: '/default.png'}
      prop2 = {name: '道具2', desc: '很好看', url: '/default.png'}
      if index == 0
        props = [prop1]
      else
        props = [prop1, prop2]
      end
      render :status=>200, :json=>{:c=>200, :d=>props}
    end
  end

  def show
    if request.format == :json
      prop = Prop.find(params['id'])

      if prop
        render :status=>200, :json=>{:c=>200, :d=> {:prop => prop}}
      else
        render :status=>200, :json=>{:c=>404, :d=> 'not found'}
      end
    end
  end
end
