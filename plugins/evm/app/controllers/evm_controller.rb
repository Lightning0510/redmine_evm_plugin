class EvmController < ApplicationController
  default_search_scope :issues

  before_filter :authorize, :except => [:index, :new, :create]
  before_filter :find_optional_project, :only => [:index, :new, :create]

  accept_rss_auth :index, :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  helper :journals
  helper :projects
  helper :custom_fields
  helper :issue_relations
  helper :watchers
  helper :attachments
  helper :queries
  include QueriesHelper
  helper :repositories
  helper :sort
  include SortHelper
  helper :timelog

  def index
      # @current_project = Project.find(params[:project_id])
      # @root_project = Issue.select(:parent_id).distinct.where('parent_id IS NOT NULL AND project_id=?', @current_project.id)
      # if(@root_project.blank?) 
      #   @issues = Issue.wherr
      # Rails.logger.debug("My object: #{@issues.inspect}")

      retrieve_query

      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      # case params[:format]
      # when 'csv', 'pdf'
      #   @limit = Setting.issues_export_limit.to_i
      #   if params[:columns] == 'all'
      #     @query.column_names = @query.available_inline_columns.map(&:name)
      #   end
      # when 'atom'
      #   @limit = Setting.feeds_limit.to_i
      # when 'xml', 'json'
      #   @offset, @limit = api_offset_and_limit
      #   @query.column_names = %w(author)
      # else
      #   @limit = per_page_option
      # end

      # @issue_count = @query.issue_count
      # @issue_pages = Paginator.new @issue_count, @limit, params['page']

      # Rails.logger.debug("Query: #{params.inspect}")

      
      @project = Project.find(params[:project_id])
      # @list_issues = []
      # project_issues  = Issue.where('project_id = ?', @project.id)
      # @list_evm = []

      # project_issues.each do |issue|
      #   if issue.leaf?
      #     # key = issue.id
      #     @list_issues.push(issue)
      #     @list_evm.push(EvmCalculator.new(issue))
      #   end
      # end

      # @evmHash = EvmCalculator.calculate_total(@list_evm, Date.today)
      # Rails.logger.debug("My object: #{@evmHash.inspect}")
      if @query.valid?
        case params[:format]
        when 'csv', 'pdf'
          @limit = Setting.issues_export_limit.to_i
          if params[:columns] == 'all'
            @query.column_names = @query.available_inline_columns.map(&:name)
          end
        when 'atom'
          @limit = Setting.feeds_limit.to_i
        when 'xml', 'json'
          @offset, @limit = api_offset_and_limit
          @query.column_names = %w(author)
        else
          @limit = per_page_option
        end
  
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

        @list_evm = {}
        @issues.each do |issue|
          @list_evm[issue.id] = EvmCalculator.new(issue)
        end

        @evmTotalHash = EvmCalculator.calculate_total(@list_evm, Date.today)
        
        Rails.logger.debug("My object: #{@evmTotalHash.inspect}")
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
