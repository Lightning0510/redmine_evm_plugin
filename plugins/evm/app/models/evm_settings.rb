class EvmSettings < ActiveRecord::Base

  SAVE_HISTORIES_YES = 1
  SAVE_HISTORIES_NO = 0

  attr_protected :id

  def self.getScheduledEVMProjectsList
    projects = self.select(:project_id).where(save_histories: SAVE_HISTORIES_YES)
    projects.map {|p| p.project_id}
  end
end
