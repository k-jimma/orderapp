# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.name = "Admin"
  u.role = :admin
  u.password =
    if Rails.env.production?
      ENV.fetch("INITIAL_ADMIN_PASSWORD")
    else
      ENV.fetch("INITIAL_ADMIN_PASSWORD", "adminpassword")
    end
  u.password_confirmation = u.password
end

User.find_or_create_by!(email: "chief@example.com") do |u|
  u.name = "Chief"
  u.role = :chief
  u.password =
    if Rails.env.production?
      ENV.fetch("INITIAL_CHIEF_PASSWORD")
    else
      ENV.fetch("INITIAL_CHIEF_PASSWORD", "chiefpassword")
    end
  u.password_confirmation = u.password
end

portfolio_numbers = [901, 902, 903]
portfolio_numbers.each do |number|
  table = Table.find_or_initialize_by(number: number)
  table.portfolio = true
  table.access_mode = :open_access
  table.active = true
  table.save! if table.changed?
end
