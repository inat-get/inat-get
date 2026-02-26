# А здесь мы реализуем следуеющее: по некоторому району найдем список таксонов,
#  которых данный пользователь не наблюдал (а другие наблюдали).

usr = user 'shikhalev'
plc = place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

obs_full = observations place: plc, quality_grade: 'research', rank: (.. Rank.complex)
lst_full = obs_full % :taxon
# Фокус-покус: если поменять местами строку выше и строку ниже, итоговый результат
#  не изменится, но время выполнения увеличится примерно в два раза...
#  Увы, механизм кэширования пока не совершенен.
obs_user = obs_full.where user: usr
lst_user = obs_user % :taxon

lst_other = lst_full - lst_user
lst_other.sort! { |ds| -ds.count }

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Недонайденные'
  file.puts ''
  lst_other.each do |ds|
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ lst_other.count }** таксонов."
end
