# frozen_string_literals: true

# Common module for {TrueClass} and {FalseClass}.
module Boolean

end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end
