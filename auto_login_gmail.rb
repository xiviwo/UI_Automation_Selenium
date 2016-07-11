require "json"
require "selenium-webdriver"
gem "minitest"
require "minitest/autorun"

class AutoLoginGmail < Minitest::Test 

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "https://accounts.google.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 3
    @verification_errors = []
    #########################################
    #Set up your information here
    @email = "myaccount@gmail.com"
    @passwd = "mypasswd"
    @to_mail = "to_account@gmail.com"
    @subject = "selenium test"
    @msgbody = "selenium test"
    #########################################
  end
  
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end
  
  def test_auto_login_gmail
    @driver.get(@base_url + "/ServiceLogin?service=mail&passive=true&rm=false&continue=https://mail.google.com/mail/&ss=1&scc=1&ltmpl=default&ltmplcache=2&emr=1&osid=1#identifier")
    #For first login
    if element_present?(:id, "Email")
      @driver.find_element(:id, "Email").clear
      @driver.find_element(:id, "Email").send_keys @email
      @driver.find_element(:id, "next").click
      @driver.find_element(:id, "Passwd").clear
      @driver.find_element(:id, "Passwd").send_keys @passwd   
    else
      @driver.find_element(:id, "Passwd").clear
      @driver.find_element(:id, "Passwd").send_keys @passwd
    end

    if element_present?(:id, "signIn")
      @driver.find_element(:id, "signIn").click
    else
      @driver.find_element(:id, "next").click
    end

    @driver.find_element(:link, "Compose Mail").click
    @driver.find_element(:id, "to").clear
    @driver.find_element(:id, "to").send_keys @to_mail
    @driver.find_element(:name, "subject").clear
    @driver.find_element(:name, "subject").send_keys @subject
    @driver.find_element(:name, "body").clear
    @driver.find_element(:name, "body").send_keys @msgbody
    @driver.find_element(:name, "nvp_bu_send").click
    assert_equal "Your message has been sent.", @driver.find_element(:css, "td > b").text

  end
  
  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
