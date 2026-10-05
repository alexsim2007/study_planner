class Task < ApplicationRecord
  STATUSES = %w[pending in_progress completed].freeze
  PRIORITIES = %w[low medium high].freeze

  belongs_to :subject

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
end