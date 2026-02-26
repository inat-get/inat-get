# А здесь мы реализуем следуеющее: по некоторому району найдем список таксонов,
#  которых данный пользователь не наблюдал (а другие наблюдали).

usr = user 'shikhalev'
plc = place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

obs_full = observations place: plc, quality_grade: 'research', rank: (.. Rank.complex)
lst_full = obs_full % :taxon

obs_user = observations place: plc, quality_grade: "research", rank: (.. Rank.complex), user: usr
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
