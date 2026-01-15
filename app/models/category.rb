class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true, inverse_of: :children
  has_many :items, dependent: :destroy, inverse_of: :category
  has_many :children, -> { order(:sort_order, :name) }, class_name: "Category",
            foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  # 同じ階層内では重複名を許可しない
  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :sort_order, presence: true, numericality: { only_integer: true }
  validate :parent_cannot_be_self
  validate :parent_depth_within_limit

  def self.parent_options(except: nil)
    # 階層構造を考慮した親カテゴリの選択肢を生成
    root_categories = Category.where(parent_id: nil).order(:sort_order, :name)
    build_parent_options(root_categories, except: except)
  end

  def self.build_parent_options(categories, except:, depth: 0, options: [])
    # 再帰的にカテゴリの選択肢を構築
    categories.each do |category|
      next if except && category.id == except.id
      next if depth >= 2
      label = "#{"--" * depth} #{category.name}"
      options << [ label.strip, category.id ]
      build_parent_options(category.children.order(:sort_order, :name), except: except, depth: depth + 1, options: options)
    end
    options
  end

  def depth
    # カテゴリの階層を計算
    parent ? parent.depth + 1 : 0
  end

  def root?
    # ルートカテゴリかどうか
    depth == 0
  end

  def middle?
    # 中カテゴリかどうか
    depth == 1
  end

  def small?
    # 小カテゴリかどうか
    depth == 2
  end

  private

  def parent_cannot_be_self
    # 自分自身を親に設定できない
    return unless parent_id && parent_id == id
    errors.add(:parent_id, "は自分自身にできません")
  end

  def parent_depth_within_limit
    # 親カテゴリの階層が制限内であることを確認
    return unless parent
    if parent.depth >= 2
      errors.add(:parent_id, "は小カテゴリの下に設定できません")
    end
  end
end
