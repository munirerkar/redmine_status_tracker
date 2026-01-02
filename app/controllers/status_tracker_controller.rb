class StatusTrackerController < ApplicationController
  unloadable
  def index
    @issues = Issue.order('created_on DESC').limit(10)
    counts = Issue.group(:status).count
    @chart_labels = counts.map { |status, count| status.name }
    @chart_data = counts.map { |status, count| count }
  end
end
