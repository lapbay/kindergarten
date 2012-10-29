# encoding: utf-8

class Api::RegistrationsController < ApplicationController
  #include Devise::Controllers::InternalHelpers

  respond_to :json
  def create

    user = User.new(params[:user])
    if user.save
      if not user.profile
        user.profile = Profile.new(name: user.name, start_at: Time.now, user: user.id, class_unit_id: params[:class_id])
        user.profile.save
      end

      profiles = Profile.where(class_unit: user.profile.class_unit.id)
      profiles.each do |prof|
        if prof.id != user.profile.id
          if not prof.social
            prof.social = Social.new()
          end
          prof.social.feed_sources << user.profile.id
          prof.update
        end
      end

      render :json=> user.as_json(:auth_token=>user.authentication_token, :email=>user.email), :status=>201
      return
    else
      warden.custom_failure!
      render :json=> user.errors, :status=>422
    end
  end
end
