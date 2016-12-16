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


# вызывается каждый раз при конфигурации приложения:
# когда изменился код программы И перезагрузилась страница
configure do
  # инициализация БД
  init_db
  # создает таблицу, если таблица не существует
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


# обработчик get-запроса /new
# (браузер получает страницу с сервера)
get '/new' do
  erb :new
end


# обработчик post-запроса
# (браузер отправляет данные на сервер)
post '/new' do
  # получаем переменную из post-запроса
  @content = params[:content]

  if @content.length < 1
    @error = "Type text"
    return erb :new
  end

  erb "<b>You typed:</b> #{@content}"
end


#Если убрать, то Sinatra выдает ошибку
helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end
