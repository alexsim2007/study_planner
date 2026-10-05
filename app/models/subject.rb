class Subject < ApplicationRecord
  belongs_to :user

  has_many :tasks, dependent: :destroy

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :user_id }

  def completed_tasks_count
    tasks.where(status: "completed").count
  end

  def progress_percentage
    return 0 if tasks.empty?

    (completed_tasks_count.to_f / tasks.count * 100).round
  end
end