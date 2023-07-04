require 'rqrcode'
require 'base64'

class CreateQrCode
  def initialize(url, code)
    @url = url
    @code = code
  end

  def generate_and_send_base64
    return if @url.empty?

    qrcode = generate_qrcode
    encode_qrcode_to_base64(qrcode)
  end

  def generate_and_send_png
    return if @url.empty?

    generate_qrcode
  end

  private

  def generate_qrcode
    RQRCode::QRCode.new("#{@url}/#{@code}").as_png(
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
  # def generate_qrcode
  #   RQRCode::QRCode.new("#{@url}/#{@code}").as_png(bit_depth: 1, border_modules: 4, color_mode:
  #     ChunkyPNG::COLOR_GRAYSCALE, color: 'black', file: nil,
  #     fill: 'white', module_px_size: 6, resize_exactly_to: false,
  #     resize_gte_to: false, size: 120)
  # end

  def encode_qrcode_to_base64(qrcode)
    Base64.strict_encode64(qrcode.to_s)
  end
end
