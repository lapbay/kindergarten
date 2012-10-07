# encoding: utf-8

class Api::UserCostumesController < HowjoyController
respond_to :json

def index
  if request.format == :json
    render :status=>200, :json=>{:c=>200, :d=>'index'}
  end
end

def create
  if request.format == :json
    render :status=>200, :json=>{:c=>200, :d=>{:id => 'create'}}
  end
end

def update
  if request.format == :json
    render :status=>200, :json=>{:c=>200, :d=>{:name => 'update'}}
  end
end

def show
  if request.format == :json
    render :status=>200, :json=>{:c=>200, :d=>'show'}
  end
end
end
