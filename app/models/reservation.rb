class Reservation < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :date, presence: true
  validates :time, presence: true

  validate :date_must_be_future

  private

  def date_must_be_future
    return unless date.present?

    if date < Date.current
      errors.add(:date, "は今日以降の日付を選択してください")
    end
  end
end
