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
      bac = (evm['bac'].to_s == NOT_AVAILABLE) || (evm['bac'].nil?) ? 0.0 : evm['bac']
      pv = (evm['pv'].to_s == NOT_AVAILABLE) || (evm['pv'].nil?) ? 0.0 : evm['pv']
      ev = (evm['ev'].to_s == NOT_AVAILABLE) || (evm['ev'].nil?) ? 0.0 : evm['ev']
      av = (evm['av'].to_s == NOT_AVAILABLE) || (evm['av'].nil?) ? 0.0 : evm['av']
      self.create(project_id: project_id, bac: bac, pv: pv, ev: ev, av: av)
    end
  end

  def self.getChartPoints(evmHistories)
    chartPoints = {}
    bacPoints = []
    pvPoints = []
    evPoints = []
    avPoints = []
    datePoints = []
    cpiPoints = []
    spiPoints = []

    evmHistories.each do |evm|
      bacPoints.push(evm.bac)
      pvPoints.push(evm.pv)
      evPoints.push(evm.ev)
      avPoints.push(evm.av)
      datePoints.push(evm.created_at.strftime('%Y%m%d'))

      #spi and cpi
      cpi = calculate_cpi(evm.ev, evm.av)
      cpi = EvmCalculator.metric_round(cpi,1)

      spi = calculate_cpi(evm.ev, evm.pv)
      spi = EvmCalculator.metric_round(spi,1)

      cpiPoints.push(cpi)
      spiPoints.push(spi)

    end

    chartPoints['bac'] = bacPoints
    chartPoints['pv'] = pvPoints
    chartPoints['ev'] = evPoints
    chartPoints['av'] = avPoints
    chartPoints['date'] = datePoints
    chartPoints['cpi'] = cpiPoints
    chartPoints['spi'] = spiPoints

    chartPoints
  end

  # CPI
  def self.calculate_cpi(ev,av)
      cpi = (ev == NOT_AVAILABLE || av <= 0.0) ? 0.0 : ev/av
      return cpi
  end

  # SPI
  def self.calculate_spi(ev,pv)
      spi = (ev == NOT_AVAILABLE || pv == NOT_AVAILABLE || pv <= 0.0) ? 0.0 : ev/pv
      return spi
  end
end
