
require './region'

DISTRICTS.each do |key, value|
  File.write value[:short] + '.inat', "require './region'\n" +
                                      "require './finish'\n" +
                                      "\n" +
                                      "district = District::new '#{ key }', FINISH_DATE\n" +
                                      "district.write_history\n" +
                                      "district.write_compare\n"
end

ZONES.each do |key, value|
  File.write value[:short] + '.inat', "require './region'\n" +
                                      "require './finish'\n" +
                                      "\n" +
                                      "zone = Zone::new '#{ key }', FINISH_DATE\n" +
                                      "zone.write_history\n" +
                                      "zone.write_compare\n"
end

SPECIALS.each do |key, value|
  File.write value[:short] + '.inat', "require './region'\n" +
                                      "require './finish'\n" +
                                      "\n" +
                                      "special = Special::new '#{ key }', FINISH_DATE\n" +
                                      "special.write_history\n" +
                                      "special.write_radiuses\n"
end
