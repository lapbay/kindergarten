# encoding: utf-8

class Api::ApiSessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  def create
    email = params[:email]
    password = params[:password]
    if request.format != :json
      render :status=>406, :json=>{:message=>"The request must be json"}
      return
    end

    if email.nil? or password.nil?
      render :status=>400,
             :json=>{:message=>"The request must contain the user email and password."}
      return
    end

    @user=User.find_by_email(email.downcase)

    if @user.nil?
      logger.info("User #{email} failed signin, user cannot be found.")
      render :status=>200, :json=>{:c=>401, :d=>{:message=>"用户名或密码错误"}}
      return
    end

    # http://rdoc.info/github/plataformatec/devise/master/Devise/Models/TokenAuthenticatable
    @user.ensure_authentication_token!

    if not @user.valid_password?(password)
      logger.info("User #{email} failed signin, password \"#{password}\" is invalid")
      render :status=>200, :json=>{:c=>401, :d=>{:message=>"用户名或密码错误"}}
    else
      render :status=>200, :json=>{:c=>200, :d=>{:token => @user.authentication_token, :profile => @user.profile}}
    end
  end

  def destroy
    @user = User.find_by_authentication_token(params[:token])
    if @user.nil?
      logger.info("Token not found.")
      render :status=>200, :json=>{:c=>201, :d=>{:message=>"Token 无效"}}
    else
      @user.reset_authentication_token!
      render :status=>200, :json=>{:c=>200, :d=>{:token=>params[:token]}}
    end
  end

end