require './region'

Project = INat::Entity::Project

from_date = Date::parse '2026-01-01'
till_date = Date::parse '2026-01-31'

oblast = Project::by_slug 'bioraznoobrazie-rayonov-sverdlovskoy-oblasti'

DISTRICTS.each do |key, obj|
  name = obj[:short]
  project = Project::by_slug key
  dataset = select project_id: project.id, created_at: (from_date .. till_date)
  user_list = dataset.to_list Listers::USER
  users = user_list.where { |ds| ds.object.created_at.to_date >= from_date }
  if !users.empty?
    users_table = rating_table users, limit: nil, count: nil, details: false, summary: false
    result = []
    result << '<h1>Приветствие новичкам</h1>'
    result << ''
    result << "За последнее время (январь 2026) проект пополнился новыми наблюдениями, в том числе от тех, кто недавно зарегистрировался на iNaturalist."
    result << ''
    result << "Хотелось бы поприветствовать новичков и, возможно, как-то помочь в освоении платформы. Кроме того, хочу обратить внимание, что iNaturalist — не только площадка для выкладывания наблюдений и определения всякого живого, но и сообщество, здесь, в общем-то, приветствуются вопросы (конечно, с соблюдением норм вежливости и такта)."
    result << ''
    result << 'Итак, приветствуем:'
    result << users_table.to_html
    result << ''
    result << "Рекомендую присоединится как к данному проекту — «#{ project }», так и к зонтичному проекту, объединяющему районы нашей области — <b>«#{ oblast }»</b>."
    result << ''
    result << 'Полезные материалы:'
    result << ''
    result << '<ul>'
    result << '<li><a href="https://www.inaturalist.org/posts/97837-vazhno-podborka-instruktsiy">Подборка инструкций от проекта «Флора России»</a>'
    result << '<ul>'
    result << '<li><a href="https://www.inaturalist.org/posts/50510-inaturalist">iNaturalist: как пользоваться</a></li>'
    result << '<li><a href="https://www.inaturalist.org/projects/flora-of-russia/journal/37806-kak-snimat-chto-snimat-uchimsya-u-klassikov">Как снимать, что снимать: учимся у классиков</a></li>'
    result << '</ul></li>'
    result << '</ul>'
    result << ''
    result << 'Если есть вопросы, их можно задавать прямо здесь.'
    output = result.join "\n"
    File.write "#{ name } - Новички.htm", output
  end
end
