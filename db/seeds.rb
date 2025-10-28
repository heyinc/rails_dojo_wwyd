User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

User.find_or_create_by!(email_address: "test@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end

sample_reservations = [
  {
    email: "customer1@example.com",
    name: "田中太郎",
    date: Date.current + 1.day,
    time: Time.parse("10:00"),
    preferred_staff: "山田さん",
    purchase_intention: true
  },
  {
    email: "customer2@example.com",
    name: "佐藤花子",
    date: Date.current + 2.days,
    time: Time.parse("14:30"),
    preferred_staff: "",
    purchase_intention: false
  },
  {
    email: "customer3@example.com",
    name: "鈴木一郎",
    date: Date.current + 3.days,
    time: Time.parse("16:00"),
    preferred_staff: "田中さん",
    purchase_intention: true
  }
]

sample_reservations.each do |reservation_data|
  Reservation.find_or_create_by!(
    email: reservation_data[:email],
  ) do |r|
    r.date = reservation_data[:date]
    r.time = reservation_data[:time]
    r.name = reservation_data[:name]
    r.preferred_staff = reservation_data[:preferred_staff]
    r.purchase_intention = reservation_data[:purchase_intention]
  end
end
