require File.expand_path('../../test_helper', __FILE__)

class EvmHistoriesTest < ActiveSupport::TestCase
  fixtures :evm_histories, :evm_settings

  # Replace this with your real tests.
  def test_avalable
    evm = EvmHistories.first
    # Rails.logger.debug("My object: #{evm.ev.inspect}")
    assert true
  end

  def test_getChartPoints
    evmHistories = EvmHistories.where('project_id=?', 1).order('updated_at ASC')
    chartPoints = EvmHistories.getChartPoints(evmHistories)
    Rails.logger.debug("My chart: #{chartPoints.inspect}")

    evmHistories = EvmHistories.where('project_id=?', 3).order('updated_at ASC')
    chartPoints = EvmHistories.getChartPoints(evmHistories)
    Rails.logger.debug("My chart: #{chartPoints.inspect}")
  end
end
