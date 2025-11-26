class Reservation < ApplicationRecord
  has_one :order, dependent: :destroy

  enum :status, { pending: "pending", completed: "completed" }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :status, presence: true

  validate :date_must_be_future

  class AlreadyCompleted < StandardError
  end

  def complete!
    raise AlreadyCompleted if completed?

    update!(status: "completed")
  end

  private

  def date_must_be_future
    return unless date.present?

    if date < Date.current
      errors.add(:date, "は今日以降の日付を選択してください")
    end
  end
end
