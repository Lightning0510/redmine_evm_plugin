class EvmRecorder

  CALCULATE_DAY = Date.today - 1
  VALIDATE_CALCULATE_DAY_RANGE = 30

  def self.saveEvmHistories
    settingProjectList = Project.all()
    Rails.logger.debug("projectList: #{settingProjectList.length().inspect}")

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

      project_id = project.id
      Rails.logger.debug("project: #{project.inspect}")
      Rails.logger.debug("project: #{CALCULATE_DAY.inspect}")
      issue_with_last_due_date = Issue.where('project_id=?', project).maximum('due_date')

      if !issue_with_last_due_date.blank?
        project_due_date = issue_with_last_due_date
        project_start_date = project.start_date
        Rails.logger.debug("start date: #{project_start_date.inspect}")
        Rails.logger.debug("due date: #{project_due_date.inspect}")

        if(!project_due_date.blank? && !project_start_date.blank?)
          if (CALCULATE_DAY <= (project_due_date + VALIDATE_CALCULATE_DAY_RANGE) && CALCULATE_DAY >= project_start_date)
            list_evm = {}
            total_issues.each do |issue|
              list_evm[issue.id] = EvmCalculator.new(issue)
            end

            evm = EvmCalculator.calculate_total(list_evm, CALCULATE_DAY)
            EvmHistories.saveFromEvmTotalHash(evm, project_id)

            Rails.logger.debug("My object: #{evm.inspect}")
          end
        end
      end
    end
    Rails.logger.debug("My object: #{EvmHistories.all().inspect}")
  end
end
