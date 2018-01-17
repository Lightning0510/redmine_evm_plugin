class PollsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @polls = Poll.find(:all) # @project.polls
  end  

  def vote
    poll = Poll.find(params[:id])
    poll.vote(params[:answer])
    if poll.save
      flash[:notice] = 'Vote saved.'
    end
    redirect_to :action => 'index'
  end
end
