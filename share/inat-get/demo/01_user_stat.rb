# Сформируем простой отчет по таксонам, которые наблюдал пользователь с начала года.
# Отчет будет выведен в текущий каталог с именем user_stat.md (формат Markdown)

year = today.year

user = get_user 'shikhalev'      # Здесь указываем ID или логин пользователя, я указал свой

# Получаем наблюдения
observations = select_observations user: user, observed: time_range(year: year), quality_grade: 'research'

by_taxon = observations % :taxon

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Отчет для пользователя ' + user.login + (user.name ? " (#{ user.name })" : '')
  file.puts ''
  by_taxon.each do |ds|
    # Здесь ds.key — это объект Taxon
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ observations.count }** наблюдений"
end
