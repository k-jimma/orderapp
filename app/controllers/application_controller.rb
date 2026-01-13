class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_noindex_headers

  add_flash_types :success, :warning

  private

  def set_noindex_headers
    response.set_header("X-Robots-Tag", "noindex, nofollow, noarchive")
  end
end
