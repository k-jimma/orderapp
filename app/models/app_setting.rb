class AppSetting < ApplicationRecord
  enum default_access_mode: { pin_required: 0, open_access: 1 }
  enum global_access_mode: { pin_required: 0, open_access: 1 }, _prefix: :global

  validates :default_access_mode, presence: true

  def self.instance
    first_or_create!(default_access_mode: :pin_required)
  end

  def access_mode_for(table)
    global_access_mode.presence || table.access_mode
  end

  def open_access_for?(table)
    access_mode_for(table).to_s == "open_access"
  end
end
