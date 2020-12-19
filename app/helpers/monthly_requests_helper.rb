module MonthlyRequestsHelper

  def requests_for_each_user(user_id)
    @all_requests.where(requester_id: user_id)
  end

end
