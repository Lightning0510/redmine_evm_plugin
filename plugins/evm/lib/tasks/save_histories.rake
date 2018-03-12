desc <<-END_DESC
Check for and assign periodic tasks
Example:
  rake redmine:check_periodictasks RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

namespace :redmine do
    namespace :plugins do
      task :save_histories => [:environment] do
        EvmRecorder.saveEvmHistories()
      end
    end
end
