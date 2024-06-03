require './config/environment/'

module S3SeleniumSnap
  def s3_selenium_snapshot(kernal, url)
    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    driver = Selenium::WebDriver.for(:firefox, options: options) 
    driver.manage.window.resize_to(1080, 1080)
    driver.navigate.to params[:url]
    sleep(3) 
    kernal.update_attribute(:url, params[:url])
    driver.save_screenshot("selenium.png")
    driver.quit
    file = File.open("./selenium.png")
    uploader = ImageUploader.new(kernal)
    uploader.store!(file)

    return kernal
  end
end
