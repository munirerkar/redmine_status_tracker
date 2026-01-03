class StatusTrackerController < ApplicationController
  unloadable
  helper :status_tracker
  include StatusTrackerHelper
  before_action :find_project
  before_action :authorize
  def index
    @issues = @project.issues.order('created_on DESC')
    counts = @issues.group(:status).count
    @chart_labels = counts.map { |status, count| status.name }
    @chart_data = counts.map { |status, count| count }
  end
  private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
