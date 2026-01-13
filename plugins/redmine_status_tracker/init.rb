Redmine::Plugin.register :redmine_status_tracker do
  name 'Redmine Status Tracker Plugin'
  author 'Münir Erkar'
  description 'İş kayıtlarının durum değişikliklerini ve sürelerini analiz eden eklenti.'
  version '0.0.1'
  url 'https://github.com/munirerkar/redmine_status_tracker'
  author_url 'https://munirerkar.netlify.app/'
  project_module :status_tracker do
    permission :view_status_tracker, :status_tracker => :index
  end
  menu :project_menu, :status_tracker, { :controller => 'status_tracker', :action => 'index' }, :caption => :label_status_tracker, :after => :issues, :param => :project_id
end
