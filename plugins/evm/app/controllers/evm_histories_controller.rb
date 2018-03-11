class EvmHistoriesController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    
    evmHistories = EvmHistories.where('project_id=?', @project.id).order('updated_at ASC')
    Rails.logger.debug("My object: #{@project.start_date.inspect}")
    @chartPoints = EvmHistories.getChartPoints(evmHistories)
    Rails.logger.debug("My object: #{@chartPoints.inspect}")
    # render "index"
  end
end
