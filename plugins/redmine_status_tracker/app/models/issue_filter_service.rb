class IssueFilterService
  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def filter
    results = @scope

    if @params[:status_id].present?
      results = results.where(status_id: @params[:status_id])
    end

    if @params[:assigned_to_id].present?
      results = results.where(assigned_to_id: @params[:assigned_to_id])
    end

    if @params[:category_id].present?
      results = results.where(category_id: @params[:category_id])
    end

    results
  end
end