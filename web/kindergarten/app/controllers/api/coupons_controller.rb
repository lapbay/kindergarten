# encoding: utf-8

class Api::CouponsController < HowjoyController
  respond_to :json

  def index
    if request.format == :json
      #props = Coupon.all
      if false
        coupon = 'some coupon for business'
        render :status=>200, :json=>{:c=>200, :d=>coupon}
      else
        render :status=>200, :json=>{:c=>404, :d=>'不是一个可用的号角优惠券'}
      end
    end
  end

  def create
    if request.format == :json
      #props = Coupon.all
      code = params[:txt]
      if true
        coupon = 'some coupon for business'
        render :status=>200, :json=>{:c=>200, :d=>{:coupon=>coupon}}
      else
        render :status=>200, :json=>{:c=>404, :d=>'不是一个可用的号角优惠券'}
      end
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
