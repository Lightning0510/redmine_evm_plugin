require File.expand_path('../../test_helper', __FILE__)

class EvmHistoriesTest < ActiveSupport::TestCase
  fixtures :evm_histories, :evm_settings

  # Replace this with your real tests.
  def test_avalable
    evm = EvmHistories.first
    # Rails.logger.debug("My object: #{evm.ev.inspect}")
    assert true
  end

  def test_getScheduledEVM
    projects = EvmSettings.getScheduledEVMProjectsList()
    evms = EvmHistories.getScheduledEVM(projects)
    Rails.logger.debug("My object: #{evms.inspect}")
  end
end
