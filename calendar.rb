require 'sinatra'
require "sinatra/json"
require "sinatra/reloader" if development?
require 'jwt'
require 'mongoid'

models = File.join(File.dirname(__FILE__), 'models')
$LOAD_PATH << File.expand_path(models)

libs = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.expand_path(libs)

# Constent Missing for requiring models files
def Object.const_missing(const)
    require const.to_s.underscore
    klass = const_get(const)
    return klass if klass
end

module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
      attrs["id"] = attrs["_id"].to_s
      attrs.delete '_id'
      attrs
    end
  end
end

Mongoid.load!("./db/config/mongoid.yml")

before do
  content_type :json
end

before '/user' do
  authenticate
end

def authenticate
  begin
    #p 'authenticate started'
    #p "headers #{request.env['HTTP_AUTHORIZATION']}"
    token = request.env['HTTP_AUTHORIZATION'].split(' ').last
    #p "token #{token}"
    payload, header = AuthToken.valid?(token)
    @current_user = User.find_by(id: payload['user_id'])
  rescue
    halt json({ error: 'Authorization header not valid'}, status: :unauthorized)    
  end
end

# ?email=foo&password=2221
post '/register' do
  user = User.new params
  if user.save
    token = AuthToken.issue_token({ user_id: user._id.to_s })
    json user: user, token: token
  else
    json errors: user.errors
  end
end

# TODO remove it
# {"email":"foo","password":"2221"}
post '/register.json' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  p params_json
  user = User.new params_json
  if user.save
    token = AuthToken.issue_token({ user_id: user.id.to_s })
    json user: user, token: token
  else
    json errors: user.errors
  end
end

# ?email=foo&password=2221
get '/login' do
  user = User.find_by(email: params[:email].downcase)
  if user && user.authenticate(params[:password])
    token = AuthToken.issue_token({ user_id: user.id.to_s })
    json user: user, token: token
  else
    json({error: "Invalid email/password combination"}, status: :unauthorized)
  end
end

get '/user' do
  json @current_user
end

# all tasks
get '/tasks' do
  @current_user.tasks.to_json
end

# CREATE
post '/tasks' do
  task = @current_user.tasks.build(params)

  if task.save
    task.to_json
  else
    json errors: task.errors
  end
end

# READ
get '/tasks/:id' do
  task = Task.find(params[:id])

  if @current_user.tasks.include? task
    task.to_json
  else
    halt 401
  end
end

# UPDATE
put '/tasks/:id' do
  task = Task.find(params[:id])
  
  halt 401 unless @current_user.tasks.include? task
  
  if task.update(params)
    task.to_json
  else
    json errors: task.errors
  end
end

# DELETE
delete '/tasks/:id/delete' do
  task = Task.find(params[:id])
  
  halt 401 unless @current_user.tasks.include? task

  if task.destroy
    {:success => "ok"}.to_json
  else
    json errors: task.errors
  end
end


