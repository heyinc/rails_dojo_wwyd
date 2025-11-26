class Reservation < ApplicationRecord
  has_one :order, dependent: :destroy

  enum :status, { pending: "pending", completed: "completed" }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :status, presence: true

  validate :date_must_be_future

  class AlreadyCompletedError < StandardError; end

  def mark_as_completed!
    with_lock do
      raise AlreadyCompletedError if completed?

      completed!
    end
  end

  private

    def date_must_be_future
      return unless date.present?

      if date < Date.current
        errors.add(:date, "は今日以降の日付を選択してください")
      end
    end
end
