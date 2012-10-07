# encoding: utf-8

class Api::SearchesController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      case params['scope']
        when 'profile'
          res = Profile.all
        when 'task'
          res = Task.all
      end
      render :status=>200, :json=>{:c=>200, :d=>res}
    end
  end

  def create
    if request.format == :json
      resp = []
      case params['scope']
        when 'profile'
          resp = Profile.all
        when 'task'
          resp = Task.all
      end
      if resp
        resp.each do |r|
          re = {id: r.id, name: r.name}
          resp << re
        end
        render :status=>200, :json=>{:c=>200, :d=> resp}
      else
        render :status=>200, :json=>{:c=>404, :d=> 'not found'}
      end
    end
  end
end
