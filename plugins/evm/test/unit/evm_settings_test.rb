require File.expand_path('../../test_helper', __FILE__)

class EvmSettingsTest < ActiveSupport::TestCase
  fixtures :evm_settings

  # Replace this with your real tests.
  def test_getScheduledEVMProjectsList
    projects = EvmSettings.getScheduledEVMProjectsList()
    Rails.logger.debug("My object: #{projects.inspect}")
  end
end
