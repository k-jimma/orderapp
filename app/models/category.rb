class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true, inverse_of: :children
  has_many :items, dependent: :destroy, inverse_of: :category
  has_many :children, -> { order(:sort_order, :name) }, class_name: "Category",
            foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :sort_order, presence: true, numericality: { only_integer: true }
  validate :parent_cannot_be_self
  validate :parent_depth_within_limit

  def self.parent_options(except: nil)
    roots = Category.where(parent_id: nil).order(:sort_order, :name)
    build_parent_options(roots, except: except)
  end

  def self.build_parent_options(categories, except:, depth: 0, options: [])
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
    parent ? parent.depth + 1 : 0
  end

  def root?
    depth == 0
  end

  def middle?
    depth == 1
  end

  def small?
    depth == 2
  end

  private

  def parent_cannot_be_self
    return unless parent_id && parent_id == id
    errors.add(:parent_id, "は自分自身にできません")
  end

  def parent_depth_within_limit
    return unless parent
    if parent.depth >= 2
      errors.add(:parent_id, "は小カテゴリの下に設定できません")
    end
  end
end
