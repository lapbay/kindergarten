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
      book = Book.find(params[:id])
      if book
        render :status=>200, :json=>{:c=>200, :d=> book}
      else
        render :status=>200, :json=>{:c=>404, :d=> '书目不存在'}
      end
    end
  end

  def create
    if request.format == :json
      name = params[:file].original_filename
      root = 'books'
      directory = params[:type]
      path = File.join(directory, name)
      file_path = File.join(root, path)
      content = params[:file].read
      File.open(file_path, 'wb') { |f| f.write(content); f.close }
      cover = params[:cover].original_filename
      path = File.join(directory, cover)
      cover_path = File.join(root, path)
      content = params[:cover].read
      File.open(cover_path, 'wb') { |f| f.write(content); f.close }
      Book.create!(title: params[:title], desc: params[:desc], path: file_path, url: '', type: params[:type], no: params[:no], cover: cover_path)
      render :status=>200, :json=>{:c=>200, :d=> "book is uploaded"}
    end
  end
end
