module ApplicationHelper
  
  # Show the local time
  def tz(time_at)
    TzTime.zone.utc_to_local(time_at.utc)
  end
  
end
