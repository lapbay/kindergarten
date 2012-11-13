# encoding: utf-8

class Api::FeedsController < HowjoyController
  include Magick
  respond_to :json

  def index
    if request.format == :json
      page = params[:page].to_i
      if current_user.profile.social
        friends = current_user.profile.social.feed_sources
        friends << current_user.profile.id
        if page > 0
          feeds = Feed.in(:$or => [{:profile_id => friends}, {:class_unit_id => current_user.profile.class_unit_id}]).skip(10 * page).limit(10)
        else
          feeds = Feed.in(:$or => [{:profile_id => friends}, {:class_unit_id => current_user.profile.class_unit_id}]).limit(10)
        end
        #feeds = Feed.in(profile_id: friends)
      else
        if page > 0
          feeds = current_user.profile.class_unit.feeds.skip(10 * page).limit(10)
        else
          feeds = current_user.profile.class_unit.feeds.limit(10)
        end
      end
      render :status=>200, :json=>{:c=>200, :d=>feeds}

    end
  end

  def show
    if request.format == :json
      feed = Feed.first
      render :status=>200, :json=>{:c=>200, :d=>feed}
    end
  end

  def create
    if request.format == :json
      feed = Feed.new(title: param[:title], content: param[:content], type: param[:type], privacy: param[:privacy])
      unless request.get?
        i = params[:photo].size
        for num in (0..i-1)
          name = params[:photo][num].original_filename
          root = current_user.name
          directory = 'images/upload'
          path = File.join(directory, name)
          file_path = File.join(root, path)
          content = params[:photo][num].read
          File.open(file_path, 'wb') { |f| f.write(content); f.close }
          img = Magick::Image.read(file_path).first
          photo = Photo.new(url: path, md5: params[:md5], height: img.rows, width: img.columns)
          img.destroy!
          feed.photos << photo
        end
      end
      case params[:privacy]
        when 0
          current_user.profile.feeds << feed
          current_user.profile.class_unit.feeds << feed
        when 1
          current_user.profile.feeds << feed
        when 2
          current_user.profile.feeds << feed
      end
    end
  end

  def self.make_private(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 0)
    profile.feeds << feed1
  end

  def self.make_friend(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 1)
    profile.feeds << feed1
  end

  def self.make_public(profile, title,  content, type)
    feed1 = Feed.new(title: title, content: content, type: type, privacy: 2)
    profile.feeds << feed1
  end
end
