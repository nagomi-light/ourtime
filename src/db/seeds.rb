# 開発用サンプルデータ
return unless Rails.env.development?


# ユーザー作成
tanaka = User.find_or_create_by!(email: "tanaka@example.com") do |u|
  u.name = "田中"
  u.password = "password"
end

sato = User.find_or_create_by!(email: "sato@example.com") do |u|
  u.name = "佐藤"
  u.password = "password"
end

suzuki = User.find_or_create_by!(email: "suzuki@example.com") do |u|
  u.name = "鈴木"
  u.password = "password"
end

takahashi = User.find_or_create_by!(email: "takahashi@example.com") do |u|
  u.name = "高橋"
  u.password = "password"
end

yamada = User.find_or_create_by!(email: "yamada@example.com") do |u|
  u.name = "山田"
  u.password = "password"
end

users = [tanaka, sato, suzuki, takahashi, yamada]


# チーム作成
inside_sales = Team.find_or_create_by!(name: "インサイドセールス") do |team|
  team.owner = tanaka
end

field_sales = Team.find_or_create_by!(name: "フィールドセールス") do |team|
  team.owner = sato
end

customer_success = Team.find_or_create_by!(name: "カスタマーサクセス") do |team|
  team.owner = yamada
end

teams = [inside_sales, field_sales, customer_success]


# チームの所属関係の作成
TeamMember.find_or_create_by!(user: tanaka, team: inside_sales)
TeamMember.find_or_create_by!(user: tanaka, team: field_sales)
TeamMember.find_or_create_by!(user: sato, team: field_sales)
TeamMember.find_or_create_by!(user: sato, team: customer_success)
TeamMember.find_or_create_by!(user: suzuki, team: inside_sales)
TeamMember.find_or_create_by!(user: takahashi, team: field_sales)
TeamMember.find_or_create_by!(user: yamada, team: customer_success)


# 個人の予定の作成
Event.create!(
  title: "訪問説明",
  user: tanaka,
  start_time: Time.zone.now + 2.hours,
  end_time: Time.zone.now + 3.hours
)

Event.create!(
  title: "新商材の資料作成",
  user: sato,
  start_time: Time.zone.now + 1.day,
  end_time: Time.zone.now + 1.day + 1.hour
)

Event.create!(
  title: "オンライン説明",
  user: suzuki,
  start_time: Time.zone.now + 3.hours,
  end_time: Time.zone.now + 4.hours
)


# チーム予定の作成
Event.create!(
  title: "新商材のインプット会議",
  user: tanaka,
  team: inside_sales,
  start_time: Time.zone.now + 1.day,
  end_time: Time.zone.now + 1.day + 2.hours
)

Event.create!(
  title: "セミナーイベント開催",
  user: sato,
  team: field_sales,
  start_time: Time.zone.now + 2.days,
  end_time: Time.zone.now + 2.days + 1.hour
)

Event.create!(
  title: "定例会議",
  user: yamada,
  team: customer_success,
  start_time: Time.zone.now + 3.days,
  end_time: Time.zone.now + 3.days + 1.hour
)

