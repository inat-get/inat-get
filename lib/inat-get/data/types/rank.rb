# frozen_string_literal: true

require 'set'
require 'is-enum'

module INatGet::Data; end
module INatGet::Data::Enum; end

class INatGet::Data::Enum::Rank < IS::Enum

  # order_no должен быть целым числом, поэтому дробные уровни вынесены в отдельный параметр

  define :stateofmatter, 100
  define :kingdom,        70
  define :phylum,         60
  define :subphylum,      57
  define :superclass,     53
  define :class,          50
  define :subclass,       47
  define :infraclass,     45
  define :subterclass,    44
  define :superorder,     43
  define :order,          40
  define :suborder,       37
  define :infraorder,     36, level: 35
  define :parvorder,      35, level: 34.5
  define :zoosection,     34
  define :zoosubsection,  33, level: 33.5
  define :superfamily,    32, level: 33
  define :epifamily,      31, level: 32
  define :family,         30
  define :subfamily,      27
  define :supertribe,     26
  define :tribe,          25
  define :subtribe,       24
  define :genus,          20
  define :genushybrid,    20
  define :subgenus,       15
  define :section,        13
  define :subsection,     12
  define :complex,        11
  define :species,        10
  define :hybrid,         10
  define :subspecies,      5
  define :variety,         5
  define :form,            5
  define :infrahybrid,     5

  def level
    @attrs[:level] || order_no
  end

  define :division,     alias: :phylum
  define :gen,          alias: :genus
  define :sp,           alias: :species
  define :spp,          alias: :species
  define :infraspecies, alias: :subspecies
  define :ssp,          alias: :subspecies
  define :subsp,        alias: :subspecies
  define :trinomial,    alias: :subspecies
  define :var,          alias: :variety

  finalize!

  PREFERRED = [ 
    :kingdom, 
    :phylum, 
    :class, 
    :order, 
    :superfamily, 
    :family, 
    :genus, 
    :species, 
    :subspecies, 
    :variety 
  ].map { |v| INatGet::Data::Enum::Rank.of(v) }.to_set.freeze

end
