require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'


configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

get '/about' do

  erb "hi"
  # @error = 'Something in wrong!!!'
  erb :about
end

get '/visit' do
  erb :visit
end

get '/contacts' do
  #  @error = 'Something in wrong!!!'
  erb :contacts
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

post('/visit') do
  @name = params[:name]
  @phone = params[:phone]
  @date = params[:date]
  @parik = params[:parik]
  @color = params[:color]

  hh = {
      :name => 'Введите имя',
      :phone => 'Введите телефон',
      :date => 'Введите дату',
      :parik => 'Выберите парикмахера',
      :@color => 'Выберите цвет'
  }

  @error = hh.select { |key, _| params[key] == "" }.values.join(", ")
  if @error != ''
    return erb :visit
    #hh.each do |key, value|
    # if params[key] == ''
    #   @error = hh[key]
    #   return erb :visit
    # end
  end


  f = File.open './public/users.txt', 'a'
  f.write "User: #{@name} will call #{@phone} at #{@date} by #{@parik} in #{@color}.\n"
  f.close
  erb :visit
end

post('/contacts') do

  @name = params[:name]
  @email = params[:email]
  @text = params[:text]

  hh = {
      :name => 'Введите имя',
      :email => 'Введите email',
      :text => 'Введите текст письма'
  }

  @error = hh.select { |key, _| params[key] == "" }.values.join(", ")


  f = File.open './public/contacts.txt', 'a'
  f.write "email: #{@email} Message: #{@text}.\n"
  f.close
   erb :contacts
end