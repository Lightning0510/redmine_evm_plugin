desc <<-END_DESC
Check for saving EVM

Example:
  rake redmine:plugins:save_evm RAILS_ENV="production"
END_DESC

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

namespace :redmine do
    namespace :plugins do
      task :save_evm => [:environment] do
        EvmHistoriesSaver.mylog
      end
    end
end
