module StatusTrackerHelper
    def calculate_time_in_statuses(issue)
        history = {}
        last_time = issue.created_on
        issue.journals.includes(:details).each do |journal|
            journal.details.each do |detail|
                if detail.prop_key == 'status_id'
                    duration = journal.created_on - last_time
                    old_status_id = detail.old_value.to_i
                    old_status = IssueStatus.find_by(id: old_status_id)
                    status_name = old_status ? old_status.name : "Silinmiş Durum"
                    history[status_name] ||= 0
                    history[status_name] += duration
                    last_time = journal.created_on
                end
            end
        end
        time_since_last = Time.now - last_time
        current_status_now = issue.status.name
        history[current_status_now] ||= 0
        history[current_status_now] += time_since_last
        return history
    end    
    def format_duration(seconds)
    mm, ss = seconds.divmod(60)
    hh, mm = mm.divmod(60)
    dd, hh = hh.divmod(24)
    
    result = []
    result << "#{dd} gün" if dd > 0
    result << "#{hh} sa" if hh > 0
    result << "#{mm} dk" if mm > 0
    result.empty? ? "1 dk'dan az" : result.join(" ")
    end        
end
