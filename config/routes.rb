# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'projects/:project_id/status_tracker', :to => 'status_tracker#index'