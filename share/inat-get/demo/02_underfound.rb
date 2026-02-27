# А здесь мы реализуем следуеющее: по некоторому району найдем список таксонов,
#  которых данный пользователь не наблюдал (а другие наблюдали).

user = get_user 'shikhalev'
place = get_place 'artinskiy-gorodskoy-okrug-osm-2023-sv-ru'

all_observations = select_observations place: place, quality_grade: 'research', rank: (.. Rank.complex)
full_list = all_observations % :taxon

user_observations = select_observations place: place, quality_grade: "research", rank: (.. Rank.complex), user: user
user_list = user_observations % :taxon

others_list = full_list - user_list
others_list.sort! { |ds| -ds.count }

File::open "#{ name }.md", 'w' do |file|
  file.puts '## Недонайденные'
  file.puts ''
  others_list.each do |ds|
    file.puts "+ #{ ds.key.common_name } *(#{ ds.key.name })* — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего **#{ others_list.count }** таксонов."
end
