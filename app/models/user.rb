class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable

  enum role: { admin: 0, staff: 1 }

  validates :name, presence: true
  validates :role, presence: true
end
