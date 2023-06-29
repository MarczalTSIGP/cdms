require "rqrcode"
require 'base64'

class CreateQrCode
  def initialize(url, code)
    @url = url
    @code = code
  end

  def generate_and_send_png
    #verificar > fazer verificaçẽos dos parametros
    if !@url.empty?
      qrcode = RQRCode::QRCode.new("#{@url}/#{@code}")    
      
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        file: nil,
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 120
      )
      return png
    end
  end

  def generate_and_send_base64
    if !@url.empty?
      qrcode = RQRCode::QRCode.new("#{@url}/#{@code}")    
      
      png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: "black",
        file: nil,
        fill: "white",
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 120
      )
      #return Base64.encode64(png)
      return Base64.strict_encode64(png.to_s)
    end
  end
end
