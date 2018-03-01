require File.expand_path('../../test_helper', __FILE__)

class EvmSettingsTest < ActiveSupport::TestCase
  fixtures :evm_settings

  # Replace this with your real tests.
  def test_getScheduledEVMProjectsList
    projects = EvmSettings.getScheduledEVMProjectsList()
    Rails.logger.debug("My object: #{projects.inspect}")
  end

  def test_turnOffSaveHistories
    EvmSettings.turnOffSaveHistories(1)
    Rails.logger.debug("My object: #{EvmSettings.where(project_id: 1).inspect}")
    EvmSettings.turnOnSaveHistories(1)
    Rails.logger.debug("My object: #{EvmSettings.where(project_id: 1).inspect}")
    EvmSettings.turnOnSaveHistories(100)
    Rails.logger.debug("My object: #{EvmSettings.where(project_id: 100).inspect}")
  end
end
