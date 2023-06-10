require "rqrcode"

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


      # svg = qrcode.as_svg(
      #   color: "000",
      #   shape_rendering: "crispEdges",
      #   module_size: 11,
      #   standalone: true,
      #   use_path: true
      # )
      # return svg
    end
  end
end
