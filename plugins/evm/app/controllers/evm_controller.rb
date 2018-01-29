class EvmController < ApplicationController
  default_search_scope :issues

  before_filter :find_optional_project, :only => [:index]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  helper :projects

  helper :queries
  include QueriesHelper
  helper :repositories
  helper :sort
  include SortHelper

  def index
      retrieve_query

      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a
      
      @project = Project.find(params[:project_id])
      
      # Rails.logger.debug("My object: #{@evmHash.inspect}")
      if @query.valid?
        @limit = per_page_option
  
        @parent_issues = Issue.select(:parent_id).distinct.where('parent_id IS NOT NULL AND project_id=?', @project.id)
        parent_id_list = [-1]
        @parent_issues.each do |issue|
          parent_id_list.push(issue.parent_id)
        end

        @issue_count = @query.issue_count - @parent_issues.length
        @issue_pages = Paginator.new @issue_count, @limit, params['page']
        @offset ||= @issue_pages.offset
        @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :order => sort_clause,
                                :offset => @offset,
                                :limit => @limit,
                                :conditions => ['issues.id NOT IN (?) ', parent_id_list])
        
        @issue_count_by_group = @query.issue_count_by_group

        @total_issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :conditions => ['issues.id NOT IN (?) ', parent_id_list])

        @list_evm = {}
        @total_issues.each do |issue|
          @list_evm[issue.id] = EvmCalculator.new(issue)
        end

        @evmTotalHash = EvmCalculator.calculate_total(@list_evm, Date.yesterday)
        Rails.logger.debug("My object: #{Date.today.inspect}")
        respond_to do |format|
          format.html { render :file => 'plugins/evm/app/views/evm/index.html.erb', :layout => !request.xhr? }
        end
      else
        respond_to do |format|
          format.html { render(:file => 'plugins/evm/app/views/evm/index.html.erb', :layout => !request.xhr?) }
        end
      end
      rescue ActiveRecord::RecordNotFound
        render_404
  end
end
