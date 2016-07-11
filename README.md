
Auto Login Gmail and Send mail with Selenium
=======
Simple program to demonstrate how to interact with web UI with selenium, take gmail as example here.

##Install selenium-webdriver
```bash
gem install selenium-webdriver
```

##Install Selenium IDE to Record UI Action
Go to [Firefox Addon](https://addons.mozilla.org/en-US/firefox/addon/selenium-ide/), download and install Selenium IDE for firefox.
![Firefox Addon](/images/ags2.png)

##Record Web UI Interaction
Restart Firefox and launch Selenium IDE with ![Grey button](/images/ags3.png) and start to record with ![Red button](/images/ags4.png) , and you are good to record ! For example:
![Record in progress](/images/ags1.png)

##Export Recorded Script 
After record is done, just export the script to whatever language you like, for example as pic below:
![Export as](/images/ags5.png)

##Modify Script to Suit your Situation 
Add your information to login gmail, and your mail body, subject and the desired email address you want to send to.
```ruby
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
```

##Amend  Main Code to Deal with Unexpected
Take into consideration of second login, you may not need to re-input your email account, so add a check here. Besides, for the first login, you use 'next' button to login, but after that you will need to use 'signIn' button

```ruby
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
```

## Verify Mail Sent
Verify mail is successfully sent by assert text, "Your message has been sent." can be found.
```ruby
assert_equal "Your message has been sent.", @driver.find_element(:css, "td > b").text
```

##Round Up

```ruby
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

```

## Rock and Roll

```bash
ruby auto_login_gmail.rb 
Run options: --seed 6221

# Running:


Finished in 9.963172s, 0.1004 runs/s, 0.2007 assertions/s.

1 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

