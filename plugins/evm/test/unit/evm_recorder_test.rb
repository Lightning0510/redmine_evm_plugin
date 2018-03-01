require File.expand_path('../../test_helper', __FILE__)

class EvmRecorderTest < ActiveSupport::TestCase
  fixtures :projects,:issues,:time_entries, :evm_histories, :evm_settings

  def test_saveEvmHistories
    EvmRecorder.saveEvmHistories()
  end
end
