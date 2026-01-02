class StatusTrackerController < ApplicationController
  unloadable
  def index
    @issues = Issue.order('created_on DESC').limit(10)
  end
end
