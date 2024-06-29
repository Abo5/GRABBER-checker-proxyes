# _librarys_
require 'httparty'
require 'json'
require 'openssl'
# clear_in_terminal

gems_to_check = ['httparty', 'openssl', 'json'] # array_of_gem
gems_to_check.each do |gem|
  gem_installed = Gem::Specification.find_by_name(gem) # check_if_gem_is_installed?
  if gem_installed
    puts "\e[38;2;0;255;0m[✓]\e[0m The gem #{gem} is installed "
  else
    puts "\e[31;1m[✗]\e[0m The gem #{gem} is not installed "
    system("gem install #{gem}")
    Gem.install(gem)
  end
end

# _colors_
magenta = "\e[38;2;128;0;128m" # "#{magenta}"
yellow = "\e[38;2;255;255;0m" # "#{yellow}"
orange = "\e[38;2;255;165;0m" # "#{orange}"
nothing = "\e[0m"             # "#{nothing}"
green = "\e[38;2;0;255;0m"    # "#{green}"
red = "\e[38;2;255;0;0m"      # "#{red}"
pink = "\e[38;2;255;105;180m" # "#{pink}"

# print Running...
def running
  print "\e[38;2;255;165;0mRunning"
  sleep(0.5)
  print "."
  sleep(0.5)
  print "."
  sleep(0.5)
  puts ".\e[0m"
  sleep(0.5)
end
running

# clear_in_terminal
system("clear")

# printing_logo
logo = <<LOGO
#{magenta}
..............................................
..............................................
.............                .................
.............                     ............
...........                          .........
..........                            ........
.........                               ......
.......:.          #{nothing}#{yellow}Proxy Scraper!#{nothing}#{magenta}        .....
......::           #{nothing}#{yellow}CoDe By A88#{nothing}#{magenta}            ....
.....:::.          #{nothing}#{yellow}Version 2.0#{nothing}#{magenta}            ....
....::::.          #{nothing}#{yellow}Recommended use vpn#{nothing}#{magenta}     ...
...::::::                                  ...
..::::::-.                                 ::.
.::::::::-.                               .:::
.::::::----:                             .::::
::::::-------:.                         .:::::
:::::--------=:                       .:--::::
:::---------==:                   ..:------:::
:--------===-..               .::---==------::
:-----==--::.                 .::-===-------::
:----::...                       .:----------:
:---:                           .  ...--------
::::.                            . .  ...::---
#{nothing}
LOGO

logo.each_char do |c|
  print c
  sleep(0.0000000001) # Random sleep delay up to 5 seconds
end

print "#{yellow}Hi, Welcome To Grabber And Checking Proxies, Write #{nothing}#{pink}00#{nothing}#{yellow} To Exit\n"
print "1. Checker Proxies\n"
print "2. Grabber Proxies\n"
print "3. Grabber and Checker Proxies\n"
print "Please enter your choice (1, 2, or 3): #{nothing}"
choice = gets.chomp.to_i

if choice == 00
  puts "Exiting...Thank You For Using Me"
  exit
end

$stop_grabbing_proxies = false
Signal.trap("INT") do

  $stop_grabbing_proxies = true
  puts "\n\e[0m\e[38;2;128;0;128m[!]STOPPING...GRABBING...NOW!\e[0m"
end

def grab_proxies(source_url)
  return if $stop_grabbing_proxies

  return unless source_url.start_with?("https://")

  begin
    response = HTTParty.get(source_url, timeout: 3, verify: false)
    handle_response(response)
  rescue OpenSSL::SSL::SSLError => e
    puts "SSL Error - Skipping source URL: #{source_url}"
  rescue Errno::ECONNRESET => e
    puts "Connection reset by peer - Skipping source URL: #{source_url}"
  rescue => e
    puts "Error: #{e.message} - Skipping source URL: #{source_url}"
  end
end

def handle_response(response)
  if response
    if response.code == 200
      body = response.body
      proxies = body.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+/) # Searching for the specified format in the page
      if proxies.any?
        proxies.each { |proxy| puts proxy }
        proxy_list = File.open(File.join(__dir__, "proxy.txt"), "a") do |file|
          proxies.each { |proxy| file.puts proxy }
        end
      else
        puts "No proxies found in the page"
      end
    else
      puts "Failed to get proxies (HTTP Status: #{response.code})"
    end
  else
    puts "No response received within the specified timeout."
  end
end

if choice == 2 || choice == 3
  puts "#{orange}[!] Grabbing Proxies...\n"

  file_sources = File.readlines(File.join(__dir__, 'sources.txt'), chomp: true)
  file_sources.each do |source_url|
    grab_proxies(source_url)
  end
end

if choice == 1 || choice == 3
  puts "\n\e[38;2;128;0;128m[!] Grabbing Proxies Is Done, Now Checking"
  Signal.trap("INT") do
    puts "\nExiting...Thank You For Using Me"
    exit
  end

  proxies = File.readlines(File.join(__dir__, 'proxy.txt'), chomp: true) # Open file and read lines
  proxies.each do |proxy|
    proxy_host, proxy_port = proxy.split(':')
    begin
      response = HTTParty.get('http://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 0.5) # Send request
      if response.code == 200 # Check if the response code is 200
        puts "\e[38;2;144;238;144mWorking on HTTP ----> #{proxy_host}:#{proxy_port}\e[0m"
        hits_file = File.open(File.join(__dir__, 'Hits-proxy.txt'), 'a') do |file|
          file.puts "#{proxy_host}:#{proxy_port}"
        end
        sleep(0.000005)
      else
        response_https = HTTParty.get('https://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 0.5, verify: OpenSSL::SSL::VERIFY_NONE) # Send request with ssl
        if response_https.code == 200 # Check if the response code is 200
          puts "\e[38;2;144;238;144mWorking on HTTPS ----> #{proxy_host}:#{proxy_port}\e[0m"
          hits_file = File.open(File.join(__dir__, 'Hits-proxy.txt'), 'a') do |file| # Save the hit proxy in Hits-proxy.txt
            file.puts "#{proxy_host}:#{proxy_port}"
          end
          sleep(0.000005)
        else
          puts "\e[38;2;255;105;180m#{proxy} not working. HTTP code: #{response.code}, HTTPS code: #{response_https.code}\e[0m"
          # Delete the proxy from the proxy.txt file
          proxy_file = File.join(__dir__, 'proxy.txt')
          proxies.delete(proxy)
          # Rewrite the rest of the content into the file
          File.open(proxy_file, 'w') do |file|
            proxies.each { |p| file.puts(p) }
          end
          sleep(0.000005)
        end
      end
    rescue StandardError => e
      puts "\e[38;2;255;165;0m#{proxy} not working. #{e.message}\e[0m"
      # Delete the proxy from the proxy.txt file
      proxy_file = File.join(__dir__, 'proxy.txt')
      proxies.delete(proxy)
      # Rewrite the rest of the content into the file
      File.open(proxy_file, 'w') do |file|
        proxies.each { |p| file.puts(p) }
      end
      sleep(0.000005)
    end
  end
end
