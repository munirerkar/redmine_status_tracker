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

    counts = base_scope.group(:status).count
    @chart_labels = counts.map { |status, count| status.name }
    @chart_data = counts.map { |status, count| count }

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
    @issue_count = base_scope.count
    @limit = per_page_option
    
    @issue_pages = Paginator.new @issue_count, @limit, params['page']

    @offset ||= @issue_pages.offset
    @issues = base_scope.limit(@limit).offset(@offset).to_a
  end
  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
