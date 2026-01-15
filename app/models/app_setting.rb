class AppSetting < ApplicationRecord
  # default_access_mode: 新規テーブルの初期設定 / global_access_mode: 全体で上書きする設定
  enum default_access_mode: { pin_required: 0, open_access: 1 }
  enum global_access_mode: { pin_required: 0, open_access: 1 }, _prefix: :global

  validates :default_access_mode, presence: true

  def self.instance
    # 唯一の設定レコードを取得、なければ作成
    first_or_create!(default_access_mode: :pin_required)
  end

  def access_mode_for(table)
    # global_access_mode が設定されていれば優先する
    global_access_mode.presence || table.access_mode
  end

  def open_access_for?(table)
    # 指定されたテーブルがオープンアクセスかどうか
    access_mode_for(table).to_s == "open_access"
  end
end
