User.find_or_create_by!(email_address: "admin@example.com") do |user|
  user.name = "山田太郎"
  user.password = "railsdojo20251126"
  user.password_confirmation = "railsdojo20251126"
end

User.find_or_create_by!(email_address: "test@example.com") do |user|
  user.name = "田中花子"
  user.password = "railsdojo20251126"
  user.password_confirmation = "railsdojo20251126"
end

User.find_or_create_by!(email_address: "sato@example.com") do |user|
  user.name = "佐藤次郎"
  user.password = "railsdojo20251126"
  user.password_confirmation = "railsdojo20251126"
end

User.find_or_create_by!(email_address: "suzuki@example.com") do |user|
  user.name = "鈴木三郎"
  user.password = "railsdojo20251126"
  user.password_confirmation = "railsdojo20251126"
end

# Itemデータを作成
items = [
  { name: "商品A", stock: 10, price: 1000 },
  { name: "商品B", stock: 5, price: 2000 },
  { name: "商品C", stock: 20, price: 1500 },
  { name: "商品D", stock: 15, price: 3000 },
  { name: "商品E", stock: 8, price: 2500 }
]

items.each do |item_data|
  Item.find_or_create_by!(name: item_data[:name]) do |item|
    item.stock = item_data[:stock]
    item.price = item_data[:price]
  end
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
