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

    raw_counts = filtered_scope.group(:category_id, :assigned_to_id).count

    category_ids = raw_counts.keys.map(&:first).compact.uniq
    user_ids = raw_counts.keys.map(&:last).compact.uniq

    categories_map = IssueCategory.where(id: category_ids).pluck(:id, :name).to_h
    users_map = User.where(id: user_ids).pluck(:id, :firstname, :lastname).map { |id, f, l| [id, "#{f} #{l}"] }.to_h
    
    @summary_table = raw_counts.map do |(cat_id, user_id), count|
      {
        category_name: categories_map[cat_id] || l(:label_none),
        user_name: users_map[user_id] || l(:label_none),         
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

    cat_chart_hash = Hash.new(0)
    @summary_table.each { |row| cat_chart_hash[row[:category_name]] += row[:count] }
    @category_chart_data = cat_chart_hash.map { |name, count| { name: name, count: count } }.sort_by { |h| h[:count] }.reverse

    user_chart_hash = Hash.new(0)
    @summary_table.each { |row| user_chart_hash[row[:user_name]] += row[:count] }
    @user_chart_data = user_chart_hash.map { |name, count| { name: name, count: count } }.sort_by { |h| h[:count] }.reverse

    #TABLO İÇİN SAYFALAMA (PAGINATION)
    @limit = per_page_option
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
