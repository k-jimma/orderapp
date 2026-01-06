class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true, inverse_of: :children
  has_many :items, dependent: :destroy, inverse_of: :category
  has_many :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent

  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validate :parent_cannot_be_self

  def self.parent_options(except: nil)
    roots = Category.where(parent_id: nil).order(:name)
    build_parent_options(roots, except: except)
  end

  def self.build_parent_options(categories, except:, depth: 0, options: [])
    categories.each do |category|
      next if except && category.id == except.id
      label = "#{"--" * depth} #{category.name}"
      options << [label.strip, category.id]
      build_parent_options(category.children.order(:name), except: except, depth: depth + 1, options: options)
    end
    options
  end

  private

  def parent_cannot_be_self
    return unless parent_id && parent_id == id
    errors.add(:parent_id, "は自分自身にできません")
  end
end
