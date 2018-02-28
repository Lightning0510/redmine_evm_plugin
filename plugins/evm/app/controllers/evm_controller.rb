class EvmController < ApplicationController
  default_search_scope :issues

  before_filter :find_optional_project, :only => [:index]

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  helper :projects
  helper :attachments
  helper :queries
  include QueriesHelper
  helper :repositories
  helper :sort
  include SortHelper
  include EvmHelper

  def index
      retrieve_query

      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a

      @project = Project.find(params[:project_id])

      # Rails.logger.debug("My object: #{session[:query].inspect}")
      if @query.valid?
        case params[:format]
        when 'csv', 'pdf'
          @limit = Setting.issues_export_limit.to_i
          if params[:columns] == 'all'
            @query.column_names = @query.available_inline_columns.map(&:name)
          end
        else
          @limit = per_page_option
        end

        @parent_issues = Issue.select(:parent_id).distinct.where('parent_id IS NOT NULL AND project_id=?', @project.id)
        parent_id_list = [-1]
        @parent_issues.each do |issue|
          parent_id_list.push(issue.parent_id)
        end

        @total_issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :conditions => ['issues.id NOT IN (?) ', parent_id_list])

        @issue_count = @total_issues.length
        @issue_pages = Paginator.new @issue_count, @limit, params['page']
        @offset ||= @issue_pages.offset
        @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :order => sort_clause,
                                :offset => @offset,
                                :limit => @limit,
                                :conditions => ['issues.id NOT IN (?) ', parent_id_list])

        @issue_count_by_group = @query.issue_count_by_group

        @list_evm = {}
        @total_issues.each do |issue|
          @list_evm[issue.id] = EvmCalculator.new(issue)
        end
        @evmTotalHash = EvmCalculator.calculate_total(@list_evm, Date.yesterday)
        # @test_issues = @issues
        # @test_issues.each do |issue|
        #   Rails.logger.debug("My object: #{issue.inspect}")
        # end
        # Rails.logger.debug("My object: #{@issues.inspect}")

        respond_to do |format|
          format.html { render :file => 'plugins/evm/app/views/evm/index.html.erb', :layout => !request.xhr? }
          format.api  {
            Issue.load_visible_relations(@issues) if include_in_api_response?('relations')
          }
          format.csv  { send_data(evm_to_csv(@issues, @query, @list_evm, @evmTotalHash, params[:csv]), :type => 'text/csv; header=present', :filename => 'evm.csv') }
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
