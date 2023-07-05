require 'rqrcode'
require 'base64'

class GenerateQrCode
  def initialize(text)
    @text = text
  end

  def perform
    return if @text.empty?

    qrcode_as_png = qrcode
    qrcode_as_base64 = Base64.strict_encode64(qrcode_as_png.to_s)

    robj = Struct.new(:png, :base64)
    robj.new(png: qrcode, base64: qrcode_as_base64)
  end

  private

  def qrcode
    RQRCode::QRCode.new(@text).as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false, resize_gte_to: false, size: 120
    )
  end
end
