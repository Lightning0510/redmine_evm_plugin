class PollsController < ApplicationController
  before_filter :find_project, :authorize, :only => :index

  def index
    @project = Project.find(params[:project_id])
    @polls = Poll.all # @project.polls
  end 

  def vote
    poll = Poll.find(params[:id])
    poll.vote(params[:answer])
    if poll.save
      flash[:notice] = 'Vote saved.'
    end
    redirect_to :action => 'index'
  end

  private

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end
end
