# encoding: utf-8

class Api::BooksController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      res = Book.all
      render :status=>200, :json=>{:c=>200, :d=>res}
    end
  end

  def show
    if request.format == :json
      #resp = []
      resp = Book.first
      render :status=>200, :json=>{:c=>404, :d=> resp}
    end
  end

  def create
    if request.format == :json
      #resp = []
      resp = Book.create!(title: 'book title again', desc: 'book desc again', path: 'static/a/b/c.html', url: 'http://www.apple.com/')
      render :status=>200, :json=>{:c=>200, :d=> resp}
    end
  end
end
