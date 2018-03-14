desc <<-END_DESC
Check for and assign save_histories tasks
Example:
  rake redmine:plugins:save_histories RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

namespace :redmine do
    namespace :plugins do
      task :save_histories => [:environment] do
        EvmRecorder.saveEvmHistories()
      end
    end
end
