commandline_input = ARGV
if commandline_input.length < 3
  abort("3 arguments are required in the commandline, you've given #{commandline_input.length}:
  arg1 = Branch name, arg2 = Start build id, arg3 = Stop build id. (start - stop are in reverse order)
  e.g I want to see average build time of between build 5 to 15 on the branch foo the commandline should read:
  bundle exec ruby main.rb foo 15 5")
end

$LOAD_PATH << File.expand_path('..', __FILE__)

require 'dotenv/load'
require 'configure_capybara'

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

branch_name = ARGV[0]
start_build_id = ARGV[1].to_i
stop_build_id = ARGV[2].to_i
project = 'seedy'
branch_page = "/simplybusiness/#{project}/branches/#{branch_name}"
page = 0
minutes = 0
seconds = 0
number_of_items_taken_into_account = 0
number_of_items = 0

begin
  page += 1

  visit "#{branch_page}?page=#{page}"
  sleep 2

  build_item_found = false
  all('div.c-branches-list-item').each do |list_item|
    build_item_found = true
    number_of_items += 1

    current_build_id = list_item['id'].split('_').last.to_i
    puts "...processing: #{current_build_id}"

    if stop_build_id <= current_build_id && current_build_id <= start_build_id
      label_text = list_item.find('div.c-branches-list-item_label-holder a').text
      if label_text.strip == 'PASSED'
        list_item.all('a.c-branches-list-item_time_link').each do |time_link|
          text = time_link.text.strip
          if text.length == 5 # e.g. text is "05:45", minutes + seconds of build duration
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

seconds = (minutes * 60  + seconds) / number_of_items_taken_into_account

puts "Number of all builds: #{number_of_items}"
puts "Number of PASSED builds: #{number_of_items_taken_into_account}"
puts "Average time of PASSED builds: #{seconds / 60}mins #{seconds % 60}secs"
