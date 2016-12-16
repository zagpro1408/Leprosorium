require 'rubygems'
require 'sinatra'
require 'sqlite3'


def init_db
    @db = SQLite3::Database.new 'leprosorium.db'
    @db.results_as_hash = true
end

#Запускает метод init_db перед каждым действием;
#Испольуется для сокращения кода;
before do
  init_db
end

#Создаем таблицы при инициализации приложения;
#Всегда когда сохраняем файл и когда обнвляем страницу;
configure do
  init_db
  @db.execute 'CREATE TABLE IF NOT EXISTS Posts
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_date DATE,
      content TEXT
    );'
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/new' do
  erb :new
end

post '/new' do
  @content = params[:content]

  erb "<b>You typed:</b> #{@content}"
end

#Если убрать, то Sinatra выдает ошибку
helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end
