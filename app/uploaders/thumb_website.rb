require './config/environment/'
require 'selenium-webdriver'
class ThumbWebsite
require "selenium-webdriver"

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
driver = Selenium::WebDriver.for :chrome, options: options

driver.get "http://3.130.240.169"

width  = driver.execute_script("return Math.max(document.body.scrollWidth,document.body.offsetWidth,document.documentElement.clientWidth,document.documentElement.scrollWidth,document.documentElement.offsetWidth);")
height = driver.execute_script("return Math.max(document.body.scrollHeight,document.body.offsetHeight,document.documentElement.clientHeight,document.documentElement.scrollHeight,document.documentElement.offsetHeight);")

driver.manage.window.resize_to(width+2000, height+2000) # <-- if I do not have +2000, page looks squished
                                                        # the greater the number, the greater the quality
                                                        # but also the more white space is around the page
                                                        # and the picture is heavier
driver.manage.window.maximize

sleep 5             # <--- required waiting for page loading 
driver.save_screenshot "full.png"

# One of the best approaches, but it is not clear to me how to calculate 
# the parameters for resize_to
end
