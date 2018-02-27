require File.expand_path('../../test_helper', __FILE__)

class EvmHistoriesTest < ActiveSupport::TestCase
  fixtures :evm_histories

  # Replace this with your real tests.
  def test_avalable
    evm = EvmHistories.first
    Rails.logger.debug("My object: #{evm.ev.inspect}")
    assert true
  end
end
