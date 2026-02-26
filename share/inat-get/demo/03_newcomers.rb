# Новички предыдущего месяца. Максимально просто: те, кто сделал наблюдение в течение
#  предыдущего месяца, и зарегистрировался в нем же. Естестаенно, в рамках некоторого
#  проекта, чтобы не тащить слишком много.

prj = project 'bioraznoobrazie-rayonov-sverdlovskoy-oblasti'

month = today.month - 1
year = if month == 0
  month = 12
  today.year - 1
else
  today.year
end

period = range(year: year, month: month)
obs = observations project: prj, created: period

lst = obs % :user
lst.filter! { |ds| period === ds.key.created }
lst.sort! { |ds| ds.key.created }

File.open "#{ name }.md", 'w' do |file|
  file.puts "\#\# Новички проекта «#{ prj.title }»"
  file.puts "*#{ period.begin.to_date } — #{ period.end.to_date - 1 }*"
  file.puts ''
  lst.each do |ds|
    file.puts "+ #{ ds.key.login } (#{ ds.key.created.to_date }) — #{ ds.count } набл."
  end
  file.puts ''
  file.puts "Всего #{ lst.count } пользователей"
end
