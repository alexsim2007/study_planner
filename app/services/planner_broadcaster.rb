# One private stream per user; each page replaces only the frames it contains.
class PlannerBroadcaster
  def self.call(user_id)
    user = User.find_by(id: user_id)
    return unless user

    Turbo::StreamsChannel.broadcast_render_to(
      user, :planner,
      partial: "shared/planner_updates",
      locals: { user: user }
    )
  end
end
