PDFKit.configure do |config|
  config.wkhtmltopdf = ENV['WKHTMLTOPDF_PATH'] || '/usr/bin/wkhtmltopdf'
end
