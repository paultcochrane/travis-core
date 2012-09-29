require 'core_ext/active_record/none_scope'

module Travis
  module Services
    module Branches
      autoload :All,   'travis/services/branches/all'
      autoload :ByIds, 'travis/services/branches/by_ids'
    end
  end
end
