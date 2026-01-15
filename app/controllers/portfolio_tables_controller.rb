class PortfolioTablesController < ApplicationController
  def qr
    # ポートフォリオテーブルを取得
    table = Table.portfolio.find(params[:id])
    qr_png = qr_png_for(table)
    send_qr_data(qr_png, "portfolio_table_#{table.number}_qr.png")
  end

  private

  def qr_png_for(table)
    # テーブルのURLからQRコードを生成
    url = table_items_url(token: table.token, host: request.base_url)
    RQRCode::QRCode.new(url).as_png(
      size: 300,
      border_modules: 2,
      color: ChunkyPNG::Color::BLACK,
      fill: ChunkyPNG::Color::WHITE
    ).to_blob
  end

  def send_qr_data(png, filename)
    # QRコード画像を送信
    send_data png,
      type: "image/png",
      disposition: "inline",
      filename: filename
  end
end
