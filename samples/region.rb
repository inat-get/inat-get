require 'inat/app/task/dsl'
require 'inat/report/report_dsl'

DISTRICTS = {

  'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona' => {
    short: 'Алапаевск',
    neighbours: {
      projects: [
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-verhnesaldinskogo-rayona',
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-garinskogo-rayona',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-nizhney-saldy',
        'bioraznoobrazie-prigorodnogo-rayona',
        'bioraznoobrazie-rezhevskogo-rayona',
        'bioraznoobrazie-serovskogo-rayona-sosva',
        'bioraznoobrazie-taborinskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-artinskogo-rayona' => {
    short: 'Арти',
    neighbours: {
      projects: [
        'bioraznoobrazie-achitskogo-rayona',
        'bioraznoobrazie-krasnoufimska-i-krasnoufimskogo-rayona',
        'bioraznoobrazie-nizhneserginskogo-rayona',
      ],
      places: [
        'belokatayskiy-rayon',
        'mechetlinskiy-rayon',
        'nyazepetrovskiy-mun-rayon-2020',
      ]
    }
  },

  'bioraznoobrazie-artyomovskogo-rayona' => {
    short: 'Артёмовский',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-rezhevskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-asbesta' => {
    short: 'Асбест',
    neighbours: {
      projects: [
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-beryozovskogo',
        'bioraznoobrazie-bogdanovichskogo-rayona',
        'bioraznoobrazie-rezhevskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-achitskogo-rayona' => {
    short: 'Ачит',
    neighbours: {
      projects: [
        'bioraznoobrazie-artinskogo-rayona',
        'bioraznoobrazie-krasnoufimska-i-krasnoufimskogo-rayona',
        'bioraznoobrazie-nizhneserginskogo-rayona',
        'bioraznoobrazie-shalinskogo-rayona',
      ],
      places: [
        'suksunskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-baykalovskogo-rayona' => {
    short: 'Байкалово',
    neighbours: {
      projects: [
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-slobodo-turinskogo-rayona',
        'bioraznoobrazie-talitskogo-rayona',
        'bioraznoobrazie-tugulymskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-beloyarskogo-rayona' => {
    short: 'Белоярский',
    neighbours: {
      projects: [
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-beryozovskogo',
        'bioraznoobrazie-bogdanovichskogo-rayona',
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-zarechnogo',
        'bioraznoobrazie-kamenska-uralskogo-i-kamenskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
        'bioraznoobrazie-sysertskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-beryozovskogo' => {
    short: 'Берёзовский',
    neighbours: {
      projects: [
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-zarechnogo',
        'bioraznoobrazie-rezhevskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-bogdanovichskogo-rayona' => {
    short: 'Богданович',
    neighbours: {
      projects: [
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-kamenska-uralskogo-i-kamenskogo-rayona',
        'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
      ],
      places: [
        'katayskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-verhney-pyshmy-i-sredneuralska' => {
    short: 'Верхняя Пышма',
    neighbours: {
      projects: [
        'bioraznoobrazie-beryozovskogo',
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-rezhevskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-verhnesaldinskogo-rayona' => {
    short: 'Верхняя Салда',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-krasnouralska',
        'bioraznoobrazie-nizhney-saldy',
        'bioraznoobrazie-prigorodnogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-verhoturskogo-rayona' => {
    short: 'Верхотурье',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-verhnesaldinskogo-rayona',
        'bioraznoobrazie-krasnouralska',
        'bioraznoobrazie-nizhney-tury-i-lesnogo',
        'bioraznoobrazie-novolyalinskogo-rayona',
        'bioraznoobrazie-serovskogo-rayona-sosva',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-garinskogo-rayona' => {
    short: 'Гари',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-ivdelya-i-pelyma',
        'bioraznoobrazie-serova',
        'bioraznoobrazie-serovskogo-rayona-sosva',
        'bioraznoobrazie-taborinskogo-rayona',
      ],
      places: [
        'kondinskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-ekaterinburga' => {
    short: 'Екатеринбург',
    neighbours: {
      projects: [
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-beryozovskogo',
        'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-polevskogo',
        'bioraznoobrazie-revdy-i-degtyarska',
        'bioraznoobrazie-sysertskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-zarechnogo' => {
    short: 'Заречный',
    neighbours: {
      projects: [
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-beryozovskogo',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-ivdelya-i-pelyma' => {
    short: 'Ивдель',
    neighbours: {
      projects: [
        'bioraznoobrazie-garinskogo-rayona',
        'bioraznoobrazie-severouralska',
        'bioraznoobrazie-serova',
      ],
      places: [
        'berezovskiy-rayon',
        'kondinskiy-rayon',
        'krasnovisherskiy-rayon',
        'sovetskiy-rayon-khanty-mansiy-ru',
        'troitsko-pechorskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-irbita-i-irbitskogo-rayona' => {
    short: 'Ирбит',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-baykalovskogo-rayona',
        'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona',
        'bioraznoobrazie-pyshminskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
        'bioraznoobrazie-talitskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-kamenska-uralskogo-i-kamenskogo-rayona' => {
    short: 'Каменск-Уральск',
    neighbours: {
      projects: [
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-bogdanovichskogo-rayona',
        'bioraznoobrazie-sysertskogo-rayona',
      ],
      places: [
        'kaslinskiy-mun-rayon-2020',
        'katayskiy-rayon',
        'kunashak-mun-rayon-2020',
      ],
    }
  },

  'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona' => {
    short: 'Камышлов',
    neighbours: {
      projects: [
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-bogdanovichskogo-rayona',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-pyshminskogo-rayona',
        'bioraznoobrazie-suholozhskogo-rayona',
      ],
      places: [
        'dalmatovskiy-rayon',
        'katayskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-karpinska-i-volchanska' => {
    short: 'Карпинск',
    neighbours: {
      projects: [
        'bioraznoobrazie-krasnoturinska',
        'bioraznoobrazie-novolyalinskogo-rayona',
        'bioraznoobrazie-severouralska',
        'bioraznoobrazie-serova',
      ],
      places: [
        'aleksandrovsk-gorsovet',
        'gornozavodskiy-rayon',
        'kizel-gorsovet',
        'krasnovisherskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-kachkanara' => {
    short: 'Качканар',
    neighbours: {
      projects: [
        'bioraznoobrazie-kushvy-i-verhney-tury',
        'bioraznoobrazie-nizhney-tury-i-lesnogo',
      ],
      places: [
        'gornozavodskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-kirovgrada-i-verhnego-tagila' => {
    short: 'Кировград',
    neighbours: {
      projects: [
        'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
        'bioraznoobrazie-nizhnego-tagila',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-prigorodnogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-krasnoturinska' => {
    short: 'Краснотурьинск',
    neighbours: {
      projects: [
        'bioraznoobrazie-novolyalinskogo-rayona',
        'bioraznoobrazie-severouralska',
        'bioraznoobrazie-serova',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-krasnouralska' => {
    short: 'Красноуральск',
    neighbours: {
      projects: [
        'bioraznoobrazie-verhnesaldinskogo-rayona',
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-kushvy-i-verhney-tury',
        'bioraznoobrazie-nizhney-tury-i-lesnogo',
        'bioraznoobrazie-prigorodnogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-krasnoufimska-i-krasnoufimskogo-rayona' => {
    short: 'Красноуфимск',
    neighbours: {
      projects: [
        'bioraznoobrazie-artinskogo-rayona',
        'bioraznoobrazie-achitskogo-rayona',
      ],
      places: [
        'askinskiy-rayon',
        'duvanskiy-rayon',
        'mechetlinskiy-rayon',
        'oktyabr-skiy-perm-ru',
        'suksunskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-kushvy-i-verhney-tury' => {
    short: 'Кушва',
    neighbours: {
      projects: [
        'bioraznoobrazie-kachkanara',
        'bioraznoobrazie-krasnouralska',
        'bioraznoobrazie-nizhney-tury-i-lesnogo',
        'bioraznoobrazie-nizhnego-tagila',
        'bioraznoobrazie-prigorodnogo-rayona',
      ],
      places: [
        'gornozavodskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-nevyanskogo-rayona-i-novouralska' => {
    short: 'Невьянск',
    neighbours: {
      projects: [
        'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
        'bioraznoobrazie-kirovgrada-i-verhnego-tagila',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-prigorodnogo-rayona',
        'bioraznoobrazie-rezhevskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-nizhnego-tagila' => {
    short: 'Нижний Тагил',
    neighbours: {
      projects: [
        'bioraznoobrazie-kirovgrada-i-verhnego-tagila',
        'bioraznoobrazie-kushvy-i-verhney-tury',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-prigorodnogo-rayona',
        'bioraznoobrazie-shalinskogo-rayona',
      ],
      places: [
        'gornozavodskiy-rayon',
        'lys-venskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-nizhney-saldy' => {
    short: 'Нижняя Салда',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-verhnesaldinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-nizhney-tury-i-lesnogo' => {
    short: 'Нижняя Тура',
    neighbours: {
      projects: [
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-kachkanara',
        'bioraznoobrazie-krasnouralska',
        'bioraznoobrazie-kushvy-i-verhney-tury',
        'bioraznoobrazie-novolyalinskogo-rayona',
      ],
      places: [
        'gornozavodskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-nizhneserginskogo-rayona' => {
    short: 'Нижние Серги',
    neighbours: {
      projects: [
        'bioraznoobrazie-artinskogo-rayona',
        'bioraznoobrazie-achitskogo-rayona',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-revdy-i-degtyarska',
        'bioraznoobrazie-shalinskogo-rayona',
      ],
      places: [
        'nyazepetrovskiy-mun-rayon-2020',
      ],
    }
  },

  'bioraznoobrazie-novolyalinskogo-rayona' => {
    short: 'Новая Ляля',
    neighbours: {
      projects: [
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-karpinska-i-volchanska',
        'bioraznoobrazie-krasnoturinska',
        'bioraznoobrazie-nizhney-tury-i-lesnogo',
        'bioraznoobrazie-serova',
        'bioraznoobrazie-serovskogo-rayona-sosva',
      ],
      places: [
        'gornozavodskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-pervouralska' => {
    short: 'Первоуральск',
    neighbours: {
      projects: [
        'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-kirovgrada-i-verhnego-tagila',
        'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
        'bioraznoobrazie-nizhneserginskogo-rayona',
        'bioraznoobrazie-nizhnego-tagila',
        'bioraznoobrazie-revdy-i-degtyarska',
        'bioraznoobrazie-shalinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-polevskogo' => {
    short: 'Полевской',
    neighbours: {
      projects: [
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-revdy-i-degtyarska',
        'bioraznoobrazie-sysertskogo-rayona',
      ],
      places: [
        164059,                                       # Внезапно место, у которого slug == null
        'nyazepetrovskiy-mun-rayon-2020',
      ],
    }
  },

  'bioraznoobrazie-prigorodnogo-rayona' => {
    short: 'Пригородный р-н',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-verhnesaldinskogo-rayona',
        'bioraznoobrazie-kirovgrada-i-verhnego-tagila',
        'bioraznoobrazie-krasnouralska',
        'bioraznoobrazie-kushvy-i-verhney-tury',
        'bioraznoobrazie-nizhnego-tagila',
        'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
        'bioraznoobrazie-rezhevskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-pyshminskogo-rayona' => {
    short: 'Пышма',
    neighbours: {
      projects: [
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona',
        'bioraznoobrazie-talitskogo-rayona',
      ],
      places: [
        'dalmatovskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-revdy-i-degtyarska' => {
    short: 'Ревда',
    neighbours: {
      projects: [
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-nizhneserginskogo-rayona',
        'bioraznoobrazie-pervouralska',
        'bioraznoobrazie-polevskogo',
      ],
      places: [
        'nyazepetrovskiy-mun-rayon-2020',
      ],
    }
  },

  'bioraznoobrazie-rezhevskogo-rayona' => {
    short: 'Реж',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-beryozovskogo',
        'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
        'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
        'bioraznoobrazie-prigorodnogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-severouralska' => {
    short: 'Североуральск',
    neighbours: {
      projects: [
        'bioraznoobrazie-ivdelya-i-pelyma',
        'bioraznoobrazie-karpinska-i-volchanska',
        'bioraznoobrazie-serova',
      ],
      places: [
        'krasnovisherskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-serova' => {
    short: 'Серов',
    neighbours: {
      projects: [
        'bioraznoobrazie-garinskogo-rayona',
        'bioraznoobrazie-ivdelya-i-pelyma',
        'bioraznoobrazie-karpinska-i-volchanska',
        'bioraznoobrazie-krasnoturinska',
        'bioraznoobrazie-novolyalinskogo-rayona',
        'bioraznoobrazie-severouralska',
        'bioraznoobrazie-serovskogo-rayona-sosva',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-serovskogo-rayona-sosva' => {
    short: 'Сосьва',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-verhoturskogo-rayona',
        'bioraznoobrazie-garinskogo-rayona',
        'bioraznoobrazie-novolyalinskogo-rayona',
        'bioraznoobrazie-serova',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-slobodo-turinskogo-rayona' => {
    short: 'Тур-я Слобода',
    neighbours: {
      projects: [
        'bioraznoobrazie-baykalovskogo-rayona',
        'bioraznoobrazie-tavdinskogo-rayona',
        'bioraznoobrazie-tugulymskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [
        'nizhnetavdinskiy-rayon-2023',
        'tyumenskiy-rayon-2023',
      ],
    }
  },

  'bioraznoobrazie-suholozhskogo-rayona' => {
    short: 'Сухой Лог',
    neighbours: {
      projects: [
        'bioraznoobrazie-artyomovskogo-rayona',
        'bioraznoobrazie-asbesta',
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-bogdanovichskogo-rayona',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-sysertskogo-rayona' => {
    short: 'Сысерть',
    neighbours: {
      projects: [
        'bioraznoobrazie-beloyarskogo-rayona',
        'bioraznoobrazie-ekaterinburga',
        'bioraznoobrazie-kamenska-uralskogo-i-kamenskogo-rayona',
        'bioraznoobrazie-polevskogo',
      ],
      places: [
        164059,
        'kaslinskiy-mun-rayon-2020',
        'snezhinsk-gor-okrug-2020',
      ],
    }
  },

  'bioraznoobrazie-taborinskogo-rayona' => {
    short: 'Таборы',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-garinskogo-rayona',
        'bioraznoobrazie-tavdinskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [
        'kondinskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-tavdinskogo-rayona' => {
    short: 'Тавда',
    neighbours: {
      projects: [
        'bioraznoobrazie-slobodo-turinskogo-rayona',
        'bioraznoobrazie-taborinskogo-rayona',
        'bioraznoobrazie-turinskogo-rayona',
      ],
      places: [
        'kondinskiy-rayon',
        'nizhnetavdinskiy-rayon-2023',
        'tobolskiy-rayon-2023',
      ],
    }
  },

  'bioraznoobrazie-talitskogo-rayona' => {
    short: 'Талица',
    neighbours: {
      projects: [
        'bioraznoobrazie-baykalovskogo-rayona',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-pyshminskogo-rayona',
        'bioraznoobrazie-tugulymskogo-rayona',
      ],
      places: [
        'dalmatovskiy-rayon',
        'shadrinskiy-rayon',
        'shatrovskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-tugulymskogo-rayona' => {
    short: 'Тугулым',
    neighbours: {
      projects: [
        'bioraznoobrazie-baykalovskogo-rayona',
        'bioraznoobrazie-slobodo-turinskogo-rayona',
        'bioraznoobrazie-talitskogo-rayona',
      ],
      places: [
        'isetskiy-rayon-ru',
        'tyumenskiy-rayon-2023',
        'shatrovskiy-rayon',
      ],
    }
  },

  'bioraznoobrazie-turinskogo-rayona' => {
    short: 'Туринск',
    neighbours: {
      projects: [
        'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
        'bioraznoobrazie-baykalovskogo-rayona',
        'bioraznoobrazie-irbita-i-irbitskogo-rayona',
        'bioraznoobrazie-slobodo-turinskogo-rayona',
        'bioraznoobrazie-taborinskogo-rayona',
        'bioraznoobrazie-tavdinskogo-rayona',
      ],
      places: [],
    }
  },

  'bioraznoobrazie-shalinskogo-rayona' => {
    short: 'Шаля',
    neighbours: {
      projects: [
        'bioraznoobrazie-achitskogo-rayona',
        'bioraznoobrazie-nizhneserginskogo-rayona',
        'bioraznoobrazie-nizhnego-tagila',
        'bioraznoobrazie-pervouralska',
      ],
      places: [
        'berezovskiy-rayon-perm-ru',
        'kishertskiy-rayon',
        'lys-venskiy-rayon',
        'suksunskiy-rayon',
      ],
    }
  },

}

# Административные округа
ZONES = {
  'bioraznoobrazie-vostochnogo-okruga-sverdlovskoy-oblasti' => {
    short: 'Восточный',
    content: [
      'bioraznoobrazie-alapaevska-i-alapaevskogo-rayona',
      'bioraznoobrazie-artyomovskogo-rayona',
      'bioraznoobrazie-baykalovskogo-rayona',
      'bioraznoobrazie-irbita-i-irbitskogo-rayona',
      'bioraznoobrazie-kamyshlova-i-kamyshlovskogo-rayona',
      'bioraznoobrazie-pyshminskogo-rayona',
      'bioraznoobrazie-rezhevskogo-rayona',
      'bioraznoobrazie-slobodo-turinskogo-rayona',
      'bioraznoobrazie-taborinskogo-rayona',
      'bioraznoobrazie-tavdinskogo-rayona',
      'bioraznoobrazie-talitskogo-rayona',
      'bioraznoobrazie-tugulymskogo-rayona',
      'bioraznoobrazie-turinskogo-rayona',
    ],
  },
  'bioraznoobrazie-gornozavodskogo-okruga-sverdlovskoy-oblasti' => {
    short: 'Горнозаводской',
    content: [
      'bioraznoobrazie-verhnesaldinskogo-rayona',
      'bioraznoobrazie-kirovgrada-i-verhnego-tagila',
      'bioraznoobrazie-kushvy-i-verhney-tury',
      'bioraznoobrazie-nevyanskogo-rayona-i-novouralska',
      'bioraznoobrazie-nizhnego-tagila',
      'bioraznoobrazie-nizhney-saldy',
      'bioraznoobrazie-prigorodnogo-rayona',
    ],
  },
  'bioraznoobrazie-zapadnogo-okruga-sverdlovskoy-oblasti' => {
    short: 'Западный',
    content: [
      'bioraznoobrazie-artinskogo-rayona',
      'bioraznoobrazie-achitskogo-rayona',
      'bioraznoobrazie-verhney-pyshmy-i-sredneuralska',
      'bioraznoobrazie-krasnoufimska-i-krasnoufimskogo-rayona',
      'bioraznoobrazie-nizhneserginskogo-rayona',
      'bioraznoobrazie-pervouralska',
      'bioraznoobrazie-polevskogo',
      'bioraznoobrazie-shalinskogo-rayona',
      'bioraznoobrazie-revdy-i-degtyarska',
    ],
  },
  'bioraznoobrazie-severnogo-okruga-sverdlovskoy-oblasti' => {
    short: 'Северный',
    content: [
      'bioraznoobrazie-verhoturskogo-rayona',
      'bioraznoobrazie-garinskogo-rayona',
      'bioraznoobrazie-ivdelya-i-pelyma',
      'bioraznoobrazie-karpinska-i-volchanska',
      'bioraznoobrazie-kachkanara',
      'bioraznoobrazie-krasnoturinska',
      'bioraznoobrazie-krasnouralska',
      'bioraznoobrazie-nizhney-tury-i-lesnogo',
      'bioraznoobrazie-novolyalinskogo-rayona',
      'bioraznoobrazie-severouralska',
      'bioraznoobrazie-serova',
      'bioraznoobrazie-serovskogo-rayona-sosva',
    ],
  },
  'bioraznoobrazie-yuzhnogo-okruga-sverdlovskoy-oblasti' => {
    short: 'Южный',
    content: [
      'bioraznoobrazie-asbesta',
      'bioraznoobrazie-beloyarskogo-rayona',
      'bioraznoobrazie-beryozovskogo',
      'bioraznoobrazie-bogdanovichskogo-rayona',
      'bioraznoobrazie-zarechnogo',
      'bioraznoobrazie-kamenska-uralskogo-i-kamenskogo-rayona',
      'bioraznoobrazie-suholozhskogo-rayona',
      'bioraznoobrazie-sysertskogo-rayona',
    ],
  },
}

# «Межмуниципальное»...
SPECIALS = {
  'mezhmunitsipalnoe-bioraznoobrazie-sverdlovskoy-oblasti' => {
    short: 'Межмуниципалка',
  }
}

class Area

  include INat::App::Task::DSL
  include INat::Report::Table::DSL
  include INat::Report::DSL
  include INat::App::Info
  include INat::Report
  include INat::Data::Types

  def initialize top_count, top_limit
    @top_count = top_count
    @top_limit = top_limit
  end

  private def season
    @finish.year
  end

  protected def select_main
    @projects.map { |pr| select(project_id: pr.id, quality_grade: QualityGrade::RESEARCH, date: (.. @finish)) }.reduce(DataSet::zero, :|)
  end

  private def gen_seasons
    # seasons_table = table do
    #   column '#', width: 3, align: :right, data: :line_no
    #   column 'Сезон', data: :year
    #   column 'Наблюдения', width: 6, align: :right,  data: :observations
    #   column 'Виды', width: 6, align: :right, data: :species
    #   column 'Новые', width: 6, align: :right, data: :news
    # end
    @main_ds = self.select_main
    @main_ls = @main_ds.to_list
    # @projects.map { |pr| select(project_id: pr.id, quality_grade: QualityGrade::RESEARCH, date: (.. @finish)) }.reduce(DataSet::zero, :|)
    @seasons = @main_ds.to_list Listers::YEAR
    @last_year = Period::Year[@finish]
    seasons_table, @last_ds, @delta = history_table @seasons, last: @last_year, extras: true
    # olds = List::zero
    # @last_year = nil
    # season_rows = []
    # @seasons.each do |ds|
    #   ls = ds.to_list
    #   @delta = ls - olds
    #   @last_year = ds.object
    #   season_rows << { year: @last_year, observations: ds.count, species: ls.count, news: @delta.count }
    #   @last_ds = ds
    #   olds += ls
    # end
    # this_year = Year[@finish]
    # if @last_year != this_year
    #   season_rows << { year: this_year, observations: 0, species: 0, news: 0 }
    #   @last_year = this_year
    #   @delta = List::zero
    #   @last_ds = DataSet::zero
    # end
    # @main_ls = @main_ds.to_list
    # bold_style = 'font-weight:bold;font-size:110%;'
    # season_rows.last[:style] = bold_style
    # season_rows << { line_no: '', year: '', observations: @main_ds.count, species: @main_ls.count, news: '', style: bold_style }
    # seasons_table << season_rows
    seasons_table.to_html
  end

  private def gen_top source, title
    users_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Наблюдатель', data: :user
      column 'Виды', width: 6, align: :right, data: :species
      column 'Наблюдения', width: 6, align: :right,  data: :observations
    end
    users = source.to_list Listers::USER
    users_table, _ = rating_table users, limit: 10, count: 10, details: false
    # user_rows = []
    # users.each do |ds|
    #   user = ds.object
    #   ls = ds.to_list Listers::SPECIES
    #   user_rows << {
    #     user: user,
    #     species: ls.count,
    #     observations: ds.count
    #   }
    # end
    # user_rows = user_rows.filter { |row| row[:species] >= @top_limit }.sort_by { |row| row[:species] }.reverse.take(@top_count)
    # users_table << user_rows
    result = []
    if !users_table.empty?
      result << "<h4>#{ title }</h4>"
      result << ''
      result << users_table.to_html
    end
    result.join "\n"
  end

  private def gen_tops
    result = []
    result << gen_top(@last_ds, 'За сезон')
    result << ""
    result << gen_top(@last_ds.where { |o| o.user.created_at.year == @finish.year }, "Новички")
    result << ""
    result << gen_top(@main_ds, 'За все время')
    result.join "\n"
  end

  private def gen_table source, observers: false, details: true
    # news_table = table do
    #   column '#', width: 3, align: :right, data: :line_no
    #   column 'Таксон', data: :taxon
    #   if details
    #     column 'Наблюдения', data: :observations
    #   else
    #     column 'Наблюдения', data: :observations, align: :right, width: 6
    #   end
    # end
    # if observers
    #   @@prefix ||= 0
    #   @@prefix += 1
    #   observers_table = table do
    #     column '#', width: 3, align: :right, data: :line_no, marker: true
    #     column 'Наблюдатель', data: :user
    #     column 'Виды', width: 6, align: :right, data: :species
    #     column 'Наблюдения', width: 6, align: :right,  data: :observations
    #   end
    #   by_users = source.to_dataset.to_list Listers::USER
    #   user_rows = []
    #   by_users.each do |ds|
    #     user = ds.object
    #     ls = ds.to_list Listers::SPECIES
    #     user_rows << {
    #       user: user,
    #       anchor: "#{ @@prefix }-user-#{ user.login }",
    #       species: ls.count,
    #       observations: ds.count,
    #     }
    #   end
    #   user_rows.sort_by! { |row| row[:species] }.reverse!
    #   observers_table << user_rows
    # end
    # news_rows = []
    # source.each do |ds|
    #   taxon = ds.object
    #   observations = []
    #   if details
    #     if observers
    #       ds.each do |obs|
    #         user = obs.user
    #         anchor = "#{ @@prefix }-user-#{ user.login }"
    #         observations << "#{ obs }<sup><a href=\"\##{ anchor }\">#{ user_rows.index { |i| i[:user] == user } + 1 }</a></sup>"
    #       end
    #     else
    #     observations = ds.observations.map(&:to_s)
    #     end
    #   else
    #     observations = [ ds.count.to_s ]
    #   end
    #   news_rows << { taxon: taxon, observations: observations.join(', ') }
    # end
    # news_table << news_rows
    news_table, observers_table = species_table source, observers: observers, details: details
    result = []
    result << news_table.to_html
    if observers
      result << ""
      result << "<h4>#{ observers }</h4>"
      result << ""
      result << observers_table.to_html
    end
    result.join "\n"
  end

  private def gen_news
    return "<i>В сезоне #{ @last_year.year } новых таксонов не наблюдалось.</i>" if @delta.empty?
    result = []
    result << "<h2>Новинки</h2>"
    result << ""
    result << "Таксоны, наблюдавшиеся в этом сезоне впервые."
    result << ""
    result << gen_table(@delta, observers: 'Наблюдатели новинок' )
    result.join "\n"
  end

  private def gen_lost
    olds = @seasons.select { |ds| ds.object <= @last_year - 3 }.reduce(DataSet::new(nil, []), :|).to_list(Listers::SPECIES)
    news = @seasons.select { |ds| ds.object > @last_year - 3 }.reduce(DataSet::new(nil, []), :|).to_list(Listers::SPECIES)
    missed_list = olds - news
    return '' if missed_list.empty?
    result = []
    result << "<h2>«Потеряшки»</h2>"
    result << ""
    result << "Ранее найденные таксоны без подтвержденных наблюдений в последние 3 сезона."
    result << ""
    result << gen_table(missed_list, observers: false)
    result.join "\n"
  end

  private def gen_signature
    # "\n<hr>\n\n<small>Отчет сгенерирован посредством <a href=\"https://github.com/shikhalev/inat-get\">INat::Get v#{ VERSION }</a></small>"
    "\n<hr>\n\n<small>Заходите в телеграм-канал «<a href=\"https://t.me/inat_sverdlobl\">Биоразнообразие Свердловской области в TG</a>» с ежедневными избранными наблюдениями и новостями проектов.</small>\n"
  end

  protected def generate_history
    result = []
    result << "<h1>Итоги сезона #{ season }</h1>"
    result << ""
    result << "Здесь и далее учитываются только наблюдения исследовательского уровня, если отдельно и явно не оговорено иное."
    result << ""
    result << "<h2>История</h2>"
    result << ""
    result << gen_seasons
    result << ""
    result << "<h2>Лучшие наблюдатели</h2>"
    result << ""
    result << "Тор-#{ @top_count } наблюдателей среди тех, кто набрал не менее #{ @top_limit } видов."
    result << ""
    result << gen_tops
    result << ""
    result << gen_news
    result << ""
    # result << gen_newbies
    # result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_history file = nil
    output = generate_history
    case file
    when nil
      File.write "#{ @name } - История.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

  private def gen_neighbours
    # neighbours_table = table do
    #   column '#', width: 3, align: :right, data: :line_no
    #   column 'Место', data: :place
    #   column 'Виды', width: 6, align: :right, data: :species
    #   column 'Наблюдения', width: 6, align: :right,  data: :observations
    # end
    @n_lists = []
    n_dss = []
    neighbour_rows = []
    @n_projects.each do |pr|
      ds = select project_id: pr.id, quality_grade: QualityGrade::RESEARCH, date: (.. @finish)
      ds.object = pr
      n_dss << ds
      ls = ds.to_list
      @n_lists << ls
      neighbour_rows << { place: pr, species: ls.count, observations: ds.count }
    end
    @n_places.each do |pl|
      ds = select place_id: pl.id, quality_grade: QualityGrade::RESEARCH, date: (.. @finish)
      ds.object = pl
      n_dss << ds
      ls = ds.to_list
      @n_lists << ls
      neighbour_rows << { place: pl, species: ls.count, observations: ds.count }
    end
    @neighbours_ls = @n_lists.reduce List::zero, :+
    # neighbour_rows << { line_no: '', place: '', species: @neighbours_ls.count, observations: @neighbours_ls.observation_count, style: 'font-weight:bold;' }
    # neighbours_table << neighbour_rows
    neighbours_table = summary_table n_dss
    neighbours_table.to_html
  end

  private def gen_unique details = true
    unique_ls = @main_ls - @neighbours_ls
    if !unique_ls.empty?
      result = []
      result << "<h2>«Уники»</h2>"
      result << ""
      result << "Таксоны, наблюдаемые здесь, но не найденные у соседей."
      result << ""
      result << gen_table(unique_ls, observers: 'Наблюдатели «уников»', details: details)
      result.join "\n"
    else
      ''
    end
  end

  protected def neighbour_count taxon
    result = 0
    @n_lists.each do |n|
      result += 1 if n.include?(taxon)
    end
    result
  end

  private def gen_wanted details = true
    wanted_ls = @neighbours_ls - @main_ls
    # TODO: переделать на where
    double_dss = wanted_ls.filter { |ds| neighbour_count(ds.object) >= 2 }
    double_ls = double_dss.sort_by { |ds| ds.count }.reverse.take(50).reduce(DataSet::zero, :|).to_list
    if !double_ls.empty?
      result = []
      result << "<h2>«Разыскиваются»</h2>"
      result << ""
      if double_dss.size <= 50
        result << "Таксоны, найденные как минимум у двух соседей, но не обнаруженнные здесь."
      else
        result << "Топ-50 (из #{ double_dss.size }) таксонов, найденных как минимум у двух соседей, но не обнаруженных здесь."
      end
      result << ""
      result << gen_table(double_ls, observers: false, details: details)
      result.join "\n"
    else
      ''
    end
  end

  private def generate_compare
    result = []
    result << "<h1>Сравнение</h1>"
    result << ""
    result << "Сравнение выполнялось со следующими проектами/территориями:"
    result << ""
    result << gen_neighbours
    result << ""
    result << gen_unique
    result << ""
    result << gen_wanted
    result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_compare file = nil
    output = generate_compare
    case file
    when nil
      File.write "#{ @name } - Сравнение.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

  def gen_alones
    alones = @main_ls.where { |ds| ds.count == 1 }
    result = []
    if !alones.empty?
      result << "<h4>Только одно подтвержденное наблюдение</h4>"
      result << ""
      result << gen_table(alones, observers: false)
    end
    result.join "\n"
  end

  def gen_unconfirmed
    unconf_ls = @projects.map { |pr| select(project_id: pr.id, quality_grade: QualityGrade::NEEDS_ID, date: (.. @finish)) }.reduce(DataSet::zero, :|).to_list
    unconfirmed = unconf_ls - @main_ls
    result = []
    if !unconfirmed.empty?
      result << "<h4>Только неподтвержденные наблюдения</h4>"
      result << ""
      result << "Требуется помощь в определении."
      result << ""
      result << gen_table(unconfirmed, observers: false)
    end
    result.join "\n"
  end

  private def generate_rare
    result = []
    result << "<h1>Виды, по которым недостаточно наблюдений</h1>"
    result << ""
    result << "Таксоны, наблюдений которых мало. Желательно обратить на них дополнительное внимание."
    result << ""
    result << gen_alones
    result << ""
    result << gen_unconfirmed
    result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_rare file = nil
    output = generate_rare
    case file
    when nil
      File.write "#{ @name } - Недо.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

end

class District < Area

  Project = INat::Entity::Project
  Place   = INat::Entity::Place

  def initialize slug, finish, top_count: 10, top_limit: 10
    super(top_count, top_limit)
    @slug = slug
    @finish = finish
    data = DISTRICTS[slug]
    @name = data[:short]
    @projects = [ Project::by_slug(slug) ]
    @n_projects = data[:neighbours][:projects].map do |pr|
      if Integer === pr
        Project::by_id pr
      else
        Project::by_slug pr
      end
    end
    @n_places = data[:neighbours][:places].map do |pl|
      if Integer === pl
        Place::by_id pl
      else
        Place::by_slug pl
      end
    end
  end

end

class Zone < Area

  Project = INat::Entity::Project
  Place   = INat::Entity::Place

  def initialize slug, finish, top_count: 10, top_limit: 10
    super(top_count, top_limit)
    @slug = slug
    @finish = finish
    data = ZONES[slug]
    @name = data[:short]
    @projects = data[:content].map { |pr| Project::by_slug(pr) }
    @n_projects = ZONES.map do |key, value|
      if key == slug
        []
      else
        value[:content].map { |pr| Project::by_slug(pr) }
      end
    end.flatten
    @n_projects << Project::by_slug('bioraznoobrazie-ekaterinburga')
    @n_places = []
  end

  def gen_zones
    neighbours_table = table do
      column '#', width: 3, align: :right, data: :line_no
      column 'Место', data: :place
      column 'Виды', width: 6, align: :right, data: :species
      column 'Наблюдения', width: 6, align: :right,  data: :observations
    end
    # Делаем запросы мо малым проектам, как задано в ZONES, но затем сводим их в таблицу по большим.
    @n_lists = []
    @places_lss = {}
    @n_projects.each do |pr|
      ds = select project_id: pr.id, quality_grade: QualityGrade::RESEARCH, date: (.. @finish)
      ls = ds.to_list
      @n_lists << ls
      place = nil
      ZONES.each do |key, zone|
        place = Project::by_slug(key) if zone[:content].include?(pr.slug.to_s)
      end
      place ||= pr
      place_ls = @places_lss[place]
      if place_ls
        @places_lss[place] = place_ls + ls
      else
        @places_lss[place] = ls
      end
    end
    neighbour_rows = []
    @places_lss.each do |place, ls|
      neighbour_rows << { place: place, species: ls.count, observations: ls.observation_count }
    end
    @neighbours_ls = @n_lists.reduce List::zero, :+
    neighbour_rows << { line_no: '', place: '', species: @neighbours_ls.count, observations: @neighbours_ls.observation_count, style: 'font-weight:bold;' }
    neighbours_table << neighbour_rows
    neighbours_table.to_html
  end

  protected def neighbour_count taxon
    result = 0
    @places_lss.each do |_, n|
      result += 1 if n.include?(taxon)
    end
    result
  end

  def generate_compare
    result = []
    result << "<h1>Сравнение</h1>"
    result << ""
    result << "Сравнение выполнялось со следующими проектами/территориями:"
    result << ""
    result << gen_zones
    result << ""
    result << gen_unique
    result << ""
    result << gen_wanted(false)
    result << ""
    result << gen_signature
    result.join "\n"
  end

end


class Special < Area

  include INat::App::Logger::DSL

  Project = INat::Entity::Project
  Place   = INat::Entity::Place

  def initialize slug, finish, top_count: 10, top_limit: 10
    super(top_count, top_limit)
    data = SPECIALS[slug]
    @name = data[:short]
    @slug = slug
    @finish = finish
    @projects = [ Project::by_slug(slug) ]
    @n_projects = DISTRICTS.map { |k, _| Project::by_slug(k) }
    @n_places = []
  end

  protected def select_main
    @projects.map { |pr| select(project_id: pr.id, quality_grade: [ QualityGrade::RESEARCH, QualityGrade::NEEDS_ID ], date: (.. @finish)) }.reduce(DataSet::zero, :|)
  end

  private def gen_unique
    gen_neighbours
    unique = @main_ls - @neighbours_ls
    gen_table(unique, observers: 'Наблюдатели уников')
  end

  protected def generate_history
    result = []
    result << "<h1>Итоги сезона #{ season }</h1>"
    result << ""
    result << "Здесь учитываются все наблюдения — как исследовательского уровня, так и требующие идентификации."
    result << ""
    result << "<h2>История</h2>"
    result << ""
    result << gen_seasons
    result << ""
    result << "Тор-#{ @top_count } наблюдателей среди тех, кто набрал не менее #{ @top_limit } видов."
    result << ""
    result << gen_tops
    result << ""
    result << gen_news
    result << ""
    result << "<h2>Уникальные таксоны</h2>"
    result << ""
    result << "Таксоны не попавшие ни в один нормальный районный проект."
    result << ""
    result << gen_unique
    result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_unique file = nil
    output = generate_unique
    case file
    when nil
      File.write "#{ @name } - Уники.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

  private def gen_radius_table list
    # radius_table = table do
    #   column '#', width: 3, align: :right, data: :line_no
    #   column 'Наблюдатель', width: 15, data: :observer
    #   column 'К-во', width: 3, align: :right, data: :count
    #   column 'Наблюдения', data: :observations
    # end
    # radius_rows = []
    # list.sort_by { |ds| -ds.count }.each do |ds|
    #   radius_rows << { observer: ds.object, count: ds.count, observations: ds.observations.map(&:to_s).join(', ') }
    # end
    # radius_rows << { line_no: '', observer: 'Всего:', count: list.observation_count, observations: '', style: 'font-weight: bold;' }
    # radius_table << radius_rows
    radius_table = rating_table list, count: nil, key: :observations
    radius_table.to_html
  end

  private def gen_radiuses
    result = []
    lister = lambda do |o|
      if o.obscured
        nil
      elsif o.positional_accuracy == nil
        nil
      elsif o.positional_accuracy >= 10000
        4
      elsif o.positional_accuracy >= 1000
        3
      elsif o.positional_accuracy >= 500
        2
      elsif o.positional_accuracy >= 10
        nil
      else
        nil
      end
    end
    subs = [
      'Меньше 10 м',
      '10–100 м',
      '500 м – 1 км',
      '1–10 км',
      'Больше 10 км'
    ]
    main_ls = @main_ds.to_list lister
    main_ls.reverse_each do |ds|
      if !ds.empty?
        ls = ds.to_list Listers::USER
        subtitle = subs[ds.object]
        result << "<h2>#{ subtitle }</h2>"
        result << ""
        # TODO: переделать таблицу
        result << gen_radius_table(ls)
        result << ""
      end
    end
    result.join "\n"
  end

  private def generate_radiuses
    result = []
    result << "<h1>Слишком большие радиусы</h1>"
    result << ""
    result << "Наблюдения, с открытым местоположением и большим (иногда очень) радиусом точности." +
              " Напомню, что в данный проект попадают наблюдения, которые не вошли ни в один районный проект" +
              " зачастую именно из-за геопозиций со слишком большими радиусами."
    result << ""
    result << gen_radiuses
    result << ""
    result << gen_signature
    result.join "\n"
  end

  def write_radiuses file = nil
    output = generate_radiuses
    case file
    when nil
      File.write "#{ @name } - Точность.htm", output
    when String
      File.write file, output
    when IO
      file.write output
    else
      raise TypeError, "Invalid file: #{ file.inspect }!", caller
    end
  end

end
