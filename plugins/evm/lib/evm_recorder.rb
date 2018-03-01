class EvmRecorder
  def self.saveEvmHistories
    settingProjectList = EvmSettings.getScheduledEVMProjectsList()
    evmTotalHash = {}
    settingProjectList.each do |project|
      # parent_issues = Issue.select(:parent_id).distinct.where('parent_id IS NOT NULL AND project_id=?', project)
      # parent_id_list = [-1]
      # parent_issues.each do |issue|
      #   parent_id_list.push(issue.parent_id)
      # end
      #
      # issues = Issue.where('project_id=? AND id IS NOT IN (?)', project, parent_id_list)
      # Rails.logger.debug("My object: #{parent_id_list.inspect}")
      total_issues = []
      project_issues = Issue.where('project_id=?', project)
      project_issues.each do |issue|
        if issue.leaf?
          total_issues.push(issue)
        end
      end

      list_evm = {}
      total_issues.each do |issue|
        list_evm[issue.id] = EvmCalculator.new(issue)
      end

      evm = EvmCalculator.calculate_total(list_evm, Date.yesterday)
      EvmHistories.saveFromEvmTotalHash(evm, project)

      Rails.logger.debug("My object: #{project.inspect}")
      Rails.logger.debug("My object: #{evm.inspect}")
    end
    Rails.logger.debug("My object: #{EvmHistories.all().inspect}")
  end
end
