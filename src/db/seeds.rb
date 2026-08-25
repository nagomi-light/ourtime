# ユーザー作成
tanaka = User.find_or_create_by!(email: "tanaka@example.com") do |u|
  u.name = "田中"
  u.password = "password"
end
tanaka.update!(admin: true)

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
inside_sales = Team.find_or_create_by!(name: "インサイドセールス") 
field_sales = Team.find_or_create_by!(name: "フィールドセールス") 
customer_success = Team.find_or_create_by!(name: "カスタマーサクセス") 

teams = [inside_sales, field_sales, customer_success]


# チームの所属関係の作成
TeamMember.find_or_create_by!(user: tanaka, team: inside_sales)
TeamMember.find_or_create_by!(user: tanaka, team: field_sales)
TeamMember.find_or_create_by!(user: sato, team: field_sales)
TeamMember.find_or_create_by!(user: sato, team: customer_success)
TeamMember.find_or_create_by!(user: suzuki, team: inside_sales)
TeamMember.find_or_create_by!(user: takahashi, team: field_sales)
TeamMember.find_or_create_by!(user: yamada, team: customer_success)

# サンプルデータ用の日付
base_date = Date.current

# 個人の予定の作成
Event.create!(
  title: "訪問説明",
  user: tanaka,
  start_time: base_date + 1.days + 10.hours,
  end_time: base_date + 1.days + 11.hours
)

Event.create!(
  title: "新商材の資料作成",
  user: sato,
  start_time: base_date + 2.days + 13.hours,
  end_time: base_date + 2.days + 14.hours
)

Event.create!(
  title: "オンライン説明",
  user: suzuki,
  start_time: base_date + 3.days + 15.hours,
  end_time: base_date + 3.days + 16.hours
)

Event.create!(
  title: "1on1",
  user: tanaka,
  start_time: base_date + 4.days + 15.hours,
  end_time: base_date + 4.days + 16.hours
)

Event.create!(
  title: "オンライン説明",
  user: sato,
  start_time: base_date + 5.days + 15.hours,
  end_time: base_date + 5.days + 16.hours
)

Event.create!(
  title: "社内研修",
  user: tanaka,
  start_time: base_date + 7.days,
  end_time: base_date + 8.days,
  all_day: true
)


# チーム予定の作成
Event.create!(
  title: "新商材のインプット会議",
  user: tanaka,
  team: inside_sales,
  start_time: base_date + 4.days + 10.hours,
  end_time: base_date + 4.days + 11.hours
)

Event.create!(
  title: "セミナーイベント開催",
  user: sato,
  team: field_sales,
  start_time: base_date + 2.days + 10.hours,
  end_time: base_date + 2.days + 11.hours
)

Event.create!(
  title: "新施策の会議",
  user: yamada,
  team: customer_success,
  start_time: base_date + 1.days + 10.hours,
  end_time: base_date + 1.days + 11.hours,
)

Event.create!(
  title: "キャンペーン開始",
  user: tanaka,
  team: field_sales,
  start_time: base_date + 6.days,
  end_time: base_date + 7.days,
  all_day: true
)

Event.create!(
  title: "新商材のインプット会議",
  user: sato,
  team: customer_success,
  start_time: base_date + 1.days + 14.hours,
  end_time: base_date + 1.days + 15.hours
)

Event.create!(
  title: "WEB広告",
  user: tanaka,
  team: inside_sales,
  start_time: base_date + 7.days,
  end_time: base_date + 17.days,
  all_day: true
)

# 繰り返し予定の作成
repeat_start = base_date.next_occurring(:monday).to_time.change(hour: 10)
schedule = IceCube::Schedule.new(repeat_start)
schedule.add_recurrence_rule(IceCube::Rule.weekly)

Event.create!(
  title: "インサイドセールス定例",
  user: tanaka,
  team: inside_sales,
  start_time: repeat_start,
  end_time: repeat_start + 1.hour,
  repeat_rule: schedule.to_yaml
)

