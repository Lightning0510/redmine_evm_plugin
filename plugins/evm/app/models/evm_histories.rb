class EvmHistories < ActiveRecord::Base

  attr_protected :id

  def self.getScheduledEVM(evmList)
    # push -1 for prevent empty list
    evmList.push(-1)
    evms = EvmHistories.where('project_id IN (?)', evmList)
    evms
  end
end
