class HowjoyController < ActionController::Base
  #before_filter :find_post, :only => [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!

  protected
  def authenticate_admin!
    if current_user.role < 10
      if request.format == :json
        render :status=>200, :json=>{:c=>403, :d=>'not authorized'}
      else
        render :status=>200, :json=>{:c=>403, :d=>'not authorized'}
      end
    end
  end

  protected
  def check_permission!
    if current_user.profile.permission < 10
      if request.format == :json
        render :status=>200, :json=>{:c=>403, :d=>'do not have permission'}
      else
        render :status=>200, :json=>{:c=>403, :d=>'do not have permission'}
      end
    end
  end
end
