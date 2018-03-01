class EvmSettings < ActiveRecord::Base

  SAVE_HISTORIES_YES = 1
  SAVE_HISTORIES_NO = 0

  attr_protected :id

  def self.getScheduledEVMProjectsList
    projects = self.select(:project_id).where(save_histories: SAVE_HISTORIES_YES)
    projects.map {|p| p.project_id}
  end

  def self.turnOnSaveHistories(project_id)
    setting = self.where(project_id: project_id).first
    if(setting.nil?)
      self.create(project_id: project_id, save_histories: SAVE_HISTORIES_YES)
    else
      setting.update(save_histories: SAVE_HISTORIES_YES)
      setting.save
    end
  end

  def self.turnOffSaveHistories(project_id)
    setting = self.where(project_id: project_id).first
    if(setting.nil?)
      self.create(project_id: project_id, save_histories: SAVE_HISTORIES_NO)
    else
      setting.update(save_histories: SAVE_HISTORIES_NO)
      setting.save
    end
  end
end
