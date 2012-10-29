# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'SETTING UP DEFAULT USER LOGIN'
#user = User.create! :name => 'First User', :email => 'user@howjoy.com', :password => 'please', :password_confirmation => 'please', :profile => Profile.new(name: 'test profile', start_at: Time.now)
user1 = User.create! :name => 'First User', :email => 'user@howjoy.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user1.name

user2 = User.create! :name => 'Second User', :email => 'user2@howjoy.com', :password => 'please', :password_confirmation => 'please'
puts 'New user created: ' << user2.name

puts 'SETTING UP DEFAULT CLASS'
class_unit1 = ClassUnit.create! :name => '一班', :grade => 1
puts 'New class created: ' << class_unit1.name

class_unit2 = ClassUnit.create! :name => '二班', :grade => 2
puts 'New class created: ' << class_unit2.name

puts 'SETTING UP DEFAULT TASK'
task1 = Task.create! :type => 0, :name => '默认创建的任务', :desc => '默认创建的任务', :deadline => Time.now, :start_at => Time.now, :categories => ['默认'], :place => '海淀区苏州街', loc: [0.0, 0.0], bonus: '20块钱'
puts 'New task created: ' << task1.name

puts 'SETTING UP DEFAULT USER PROFILE'
profile1 = Profile.new(name: '号角管理员', start_at: Time.now)
puts 'New profile created: ' << profile1.name
profile2 = Profile.new(name: '测试用户', start_at: Time.now)
puts 'New profile created: ' << profile2.id.to_s

puts 'SETTING UP DEFAULT USER TASK'
user_task1 = UserTask.new(type: task1.type, role: 10, status: 1, name: task1.name, place: task1.place, start_at: task1.start_at)
puts 'New user_task created: ' << user_task1.role.to_s

puts 'SETTING UP DEFAULT USER NOTIFICATION'
notification1 = Notification.new(title: '测试通知 in seed', content: '测试通知详情 in seed', type: 0)
puts 'New notification created: ' << notification1.title

puts 'SETTING UP DEFAULT FEED'
feed1 = Feed.new(title: '测试消息 in seed', content: '测试消息详情 in seed', type: 0)
puts 'New feed created: ' << feed1.title

puts 'SETTING UP DEFAULT FRIENDSHIP'
friend1 = Friend.new(relation: 1, profile_id: profile2.id)
social1 = Social.new()
social1.feed_sources << profile2.id
social1.friends << friend1
puts 'New friend created: ' << friend1.relation.to_s

profile1.social = social1
profile1.notifications << notification1
profile1.feeds << feed1
profile1.owns << task1
profile1.tasks << user_task1
task1.profiles << user_task1
profile1.update
task1.update

user1.profile = profile1
user2.profile = profile2

class_unit1.profiles << profile1
class_unit2.profiles << profile2