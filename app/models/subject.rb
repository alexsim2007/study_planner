class Subject < ApplicationRecord
  belongs_to :user

  has_many :tasks, dependent: :destroy

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :user_id }
end