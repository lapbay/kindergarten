# encoding: utf-8

class Api::UserPropsController < HowjoyController
respond_to :json

def index
  if request.format == :json
    prop1 = {name: '道具一', desc: '是个衣服', url: '/default.png'}
    prop2 = {name: '道具2', desc: '很好看', url: '/default.png'}
    props = [prop1, prop2]
    render :status=>200, :json=>{:c=>200, :d=>props}
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
