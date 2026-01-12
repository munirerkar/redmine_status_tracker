class StatusTrackerController < ApplicationController
  unloadable
  helper :status_tracker
  include StatusTrackerHelper
  before_action :find_project
  before_action :authorize
  def index
    sort_column = params[:sort] || 'id'
    sort_direction = params[:direction] || 'desc'
    allowed_columns = ['id', 'subject', 'status_id', 'created_on', 'category_id', 'assigned_to_id', 'updated_on']
    unless allowed_columns.include?(sort_column)
      sort_column = 'id'
    end
    
    base_scope = @project.issues.order("#{sort_column} #{sort_direction}")

    filtered_scope = IssueFilterService.new(base_scope, params).filter

    filtered_scope = filtered_scope.order("#{sort_column} #{sort_direction}")

    @issues = filtered_scope
    counts = filtered_scope.group(:status).count
    @status_names = counts.keys.map(&:name)
    @status_values = counts.values

    raw_counts = base_scope.group(:category_id, :assigned_to_id).count
    @summary_table = raw_counts.map do |(cat_id, user_id), count|
      category = IssueCategory.find_by(id: cat_id)
      user = User.find_by(id: user_id)
      {
        category_name: category ? category.name : 'Kategorisiz',
        user_name: user ? user.name : 'Atanmamış',
        count: count
      }
    end

    # Özet Tablosu Sıralaması
    summary_sort = params[:summary_sort] || 'count'
    summary_dir = params[:summary_dir] || 'desc'

    @summary_table.sort_by! do |item|
      case summary_sort
      when 'category' then item[:category_name]
      when 'user' then item[:user_name]
      else item[:count] 
      end
    end
    @summary_table.reverse! if summary_dir == 'desc'
    
    #TABLO İÇİN SAYFALAMA (PAGINATION)
    @limit = 10
    @issue_count = filtered_scope.count
    @issue_pages = Paginator.new @issue_count, @limit, params['page']
    @issues = filtered_scope.offset(@issue_pages.offset).limit(@limit)
  end
  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
