class EvmHistoriesSaver < ApplicationController
  default_search_scope :issues

  before_filter :find_optional_project

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

  def self.mylog
    retrieve_query

    Rails.logger.debug("#{@query.inspect}")
  end
end
