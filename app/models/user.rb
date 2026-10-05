class User < ApplicationRecord
  has_secure_password

  has_many :subjects, dependent: :destroy
  has_many :tasks, through: :subjects

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def total_tasks_count
    tasks.count
  end

  def completed_tasks_count
    tasks.where(status: "completed").count
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end