# Сформируем простой отчет по таксонам, которые наблюдал пользователь с начала года.
# Отчет будет выведен в текущий каталог с именем user_stat.md (формат Markdown)

year = today.year

usr = user 'shikhalev'      # Здесь указываем ID или логин пользователя, я указал свой

# Получаем наблюдения
obs = observations user: usr, observed: range(year: year), quality_grade: 'research'

by_taxon = obs % :taxon

File::open 'user_stat.md', 'w' do |file|
  file.puts '## Отчет для пользователя ' + usr.login
  file.puts ''
  by_taxon.each do |ds|
    # Здесь ds.key — это объект Taxon
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ obs.count }** наблюдений"
end
