class PortfolioTablesController < ApplicationController
  def qr
    table = Table.portfolio.find(params[:id])
    png = qr_png_for(table)
    send_qr_data(png, "portfolio_table_#{table.number}_qr.png")
  end

  private

  def qr_png_for(table)
    url = table_items_url(token: table.token, host: request.base_url)
    RQRCode::QRCode.new(url).as_png(
      size: 300,
      border_modules: 2,
      color: ChunkyPNG::Color::BLACK,
      fill: ChunkyPNG::Color::WHITE
    ).to_blob
  end

  def send_qr_data(png, filename)
    send_data png,
      type: "image/png",
      disposition: "inline",
      filename: filename
  end
end
