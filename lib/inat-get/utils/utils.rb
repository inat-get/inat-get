# frozen_string_literals: true

# Extension of standard class
class Module

  def short_name
    self.name&.split('::')&.last
  end

end
