class EvmHistories < ActiveRecord::Base

  attr_protected :id
  NOT_AVAILABLE = "N/A"

  def self.getScheduledEVM(evmList)
    # push -1 for prevent empty list
    evmList.push(-1)
    evms = EvmHistories.where('project_id IN (?)', evmList)
    evms
  end

  def self.saveFromEvmTotalHash(evmTotalHash, project_id)
    evmTotalHash.each do |key, evm|
      bac = (evm['bac'].to_s == NOT_AVAILABLE) ? nil : evm['bac']
      pv = (evm['pv'].to_s == NOT_AVAILABLE) ? nil : evm['pv']
      ev = (evm['ev'].to_s == NOT_AVAILABLE) ? nil : evm['ev']
      av = (evm['av'].to_s == NOT_AVAILABLE) ? nil : evm['av']
      self.create(project_id: project_id, bac: bac, pv: pv, ev: ev, av: av)
    end
  end
end
