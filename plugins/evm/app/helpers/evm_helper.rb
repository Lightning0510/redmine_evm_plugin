module EvmHelper
  def evm_to_csv(items, query, list_evm, evmTotalHash, options={})
    options ||= {}
    columns = (options[:columns] == 'all' ? query.available_inline_columns : query.inline_columns)
    query.available_block_columns.each do |column|
      if options[column.name].present?
        columns << column
      end
    end

    # columns.each do |column|
    #   Rails.logger.debug("My object: #{column.caption.to_s.inspect}")
    #   # Rails.logger.debug("My object: #{csv_content(column,item).inspect}")
    # end
    evm_header = %w[BAC	PV	EV	AV	SV	CV	SPI	CPI]
    headers = columns.map {|c| c.caption.to_s} + evm_header

    Redmine::Export::CSV.generate do |csv|
      # csv header fields
      csv << headers
      # csv lines
      items.each do |item|
        evm_content = []
        catch :evm do
          list_evm.each do |key, evm|
            if (key == item.id)
              evm_content = EvmCalculator.to_csv_content(evm)
              throw :evm
            end
          end
        end
        evm_content = columns.map {|c| csv_content(c, item)} + evm_content
        csv << evm_content
      end

      total_column_width = headers.length - evm_header.length
      total_column_content = []
      for i in 1..total_column_width do
        if(i == total_column_width - 1)
          total_column_content.push("Total")
        else
          total_column_content.push("")
        end
      end

      csv << total_column_content + evmTotalHash.values[0].values
    end
  end
end
