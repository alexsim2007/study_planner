class Task < ApplicationRecord
  STATUSES = %w[pending in_progress completed].freeze
  PRIORITIES = %w[low medium high].freeze

  belongs_to :subject
  after_commit -> { PlannerBroadcaster.call(subject&.user_id) }, on: %i[create update destroy]

  validates :title,
            presence: true,
            length: { maximum: 150 }

  validates :deadline, presence: true

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validates :priority,
            presence: true,
            inclusion: { in: PRIORITIES }

  def completed?
    status == "completed"
  end

  def overdue?
    deadline.present? &&
      deadline < Date.current &&
      !completed?
  end

  def days_left
    return nil unless deadline

    (deadline - Date.current).to_i
  end

  validate :deadline_cannot_be_in_the_past,
           if: -> { new_record? || will_save_change_to_deadline? }

  private

  def deadline_cannot_be_in_the_past
    return if deadline.blank?

    if deadline < Date.current
      errors.add(:deadline, "не может быть в прошлом")
    end
  end
end
