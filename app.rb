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

    @db.execute 'CREATE TABLE IF NOT EXISTS Comments
    (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      created_date DATE,
      content TEXT,
      post_id INTEGER
    );'
end



get '/' do
  # выбираем список постов из БД
  @results = @db.execute 'SELECT * FROM Posts order by id desc'
  erb :index
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
  content = params[:content]
  # проверка на пустое сообщение
  if content.strip.empty?
    @error = "Type text for your post"
    return erb :new
  end
  # сохранение данных в БД
  @db.execute 'INSERT INTO Posts
    (content, created_date) values (?, datetime());', [content]
  # перенаправление на главную страницу
  redirect to '/'
end

# вывод информации о посте
get '/details/:post_id' do
  # получаем переменную из URL
  post_id = params[:post_id]
  # получаем список постов
  # у нас будет только один пост
  results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  # выбираем этот один пост в перменную row
  @row = results[0]
  # возвращаем представление details.erb
  erb :details
end


# обработчик post-запроса
# браузер отправляет данные на сервер
post '/details/:post_id' do
  # получаем переменную из URL
  post_id = params[:post_id]
  # получаем переменную из post-запроса
  content = params[:content]
  # сохранение данных в БД
  @db.execute 'INSERT INTO Comments
    (content, created_date, post_id) values (?, datetime(), ?);', [content, post_id]
  erb "You typed comment: #{content} for post #{post_id}"
  # перенаправление на страницу поста
  redirect to ('/details/' + post_id)
end

#Если убрать, то Sinatra выдает ошибку
helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end
