require 'capybara/dsl'
require 'capybara-webkit'
require 'dotenv/load'

Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
  config.ignore_ssl_errors
end

include Capybara::DSL

Capybara.javascript_driver = :webkit
Capybara.current_driver = Capybara.javascript_driver

Capybara.app_host = 'https://semaphoreci.com'
visit '/users/sign_in'

username = ENV['SEMAPHORE_USERNAME']
password = ENV['SEMAPHORE_PASSWORD']
require_authentication_code = ENV['SEMAPHORE_REQUIRES_AUTHENTICATION_CODE'] == 'yes' rescue 'no'

fill_in 'Email', with: username
fill_in 'Password', with: password

click_button 'Log In'

if require_authentication_code
  print 'Use authenticator and get an authentication code. Give it here: '
  authentication_code = gets.strip
  fill_in 'Code', with: authentication_code
  click_button 'Proceed'
end

project = 'seedy'
branch_name = 'revert-4922-revert-4911-replace_capybara_webkit_headless_chrome_capybara_setup'
branch_page = "/simplybusiness/#{project}/branches/#{branch_name}"

page = 0
minutes = 0
seconds = 0
number_of_items_taken_into_account = 0
number_of_items = 0
start_build_id = 15
stop_build_id = 10

begin
  page += 1
  visit "#{branch_page}?page=#{page}"
  sleep 2
  build_item_found = false
  all('div.c-branches-list-item').each do |list_item|
    build_item_found = true
    number_of_items += 1
    puts "build_id: *#{list_item['id']}-"
    current_build_id = list_item['id'].split('_').last.to_i
    if stop_build_id <= current_build_id && current_build_id <= start_build_id
      label_text = list_item.find('div.c-branches-list-item_label-holder a').text
      if label_text.strip == 'PASSED'
        list_item.all('a.c-branches-list-item_time_link').each do |time_link|
          text = time_link.text.strip
          if text.length == 5
            number_of_items_taken_into_account += 1
            current_minutes, current_seconds = text.split(':').map {|item| item.to_i}
            minutes += current_minutes
            seconds += current_seconds
          end
        end
      end
    elsif current_build_id < stop_build_id
      build_item_found = false
    end
  end
end while build_item_found

minutes = (minutes + seconds / 60.to_f) / number_of_items_taken_into_account.to_f

puts "Number of all builds: #{number_of_items}"
puts "Number of builds taken into account: #{number_of_items_taken_into_account}"
puts "Average minutes: #{minutes}"
