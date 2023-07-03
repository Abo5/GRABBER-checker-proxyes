# _librarys_
require 'httparty'
require 'json'
require 'openssl'
# clear_in_terminal

clear = `clear`
puts clear
gems_to_check = ['httparty', 'openssl', 'json'] # array_of_gem
gems_to_check.each do |gem|
  gem_installed = Gem::Specification.find_by_name(gem) # check_if_gem_is_install_it?
  if gem_installed
    puts "\e[38;2;0;255;0m[✓]\e[0m The gem #{gem} is installed "
  else
    puts "\e[31;1m[✗]\e[0m The gem #{gem} is not installed "
    system("gem install #{gem}")
    Gem.install(gem)
  end
end

# _colors_
magenta = "\e[38;2;255;0;255m" # "#{magenta}"
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
.....:::.          #{nothing}#{yellow}version 1.0#{nothing}#{magenta}            ....
....::::.                                  ...
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
  sleep(0.0001) # Random sleep delay up to 5 seconds
end

print "#{yellow}Hi, Welcome To Grabber And Checking Proxies, Press \e[0m#{green}Enter\e[0m#{yellow} If You Want To Exit, Write \e[0m#{pink}exit\e[0m#{yellow} or \e[0m#{pink}00\e[0m#{yellow} #{nothing}"
info = gets.chomp
if info == "00" || info.downcase == "exit"
  puts "Exiting...Thank You For Using Me"
  exit
end

def search_and_print_proxies
  file_sources = File.readlines(File.join(__dir__, 'sources.txt'), chomp: true)
  file_sources.each do |source_url|
    next unless source_url.start_with?("https://")
    begin
      response = HTTParty.get(source_url, timeout: 1, verify: false)
      handle_response(response)
    rescue Errno::ECONNRESET => e
      puts "Connection reset by peer - Skipping source URL: #{source_url}"
    end
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
          proxies.each { |proxy| file.puts(proxy) }
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

search_and_print_proxies
puts "\e[38;2;0;255;0mAll Proxyes Save It In proxy.txt\e[0m"
puts "#{orange}[!] Grabbing Proxies Is Done, Now Checking"
proxies = File.readlines(File.join(__dir__, 'proxy.txt'), chomp: true) # Open file and read lines
proxies.each do |proxy|
  proxy_host, proxy_port = proxy.split(':')
  begin
    response = HTTParty.get('http://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 2) # Send request
    if response.code == 200 # Check if the response code is 200
      puts "\e[38;2;144;238;144mWorking on HTTP ----> #{proxy_host}:#{proxy_port}\e[0m"
      hits_file = File.open(File.join(__dir__, 'Hits-proxy.txt'), 'a') do |file|
        file.puts "#{proxy_host}:#{proxy_port}"
      end
    else
      response_https = HTTParty.get('https://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 2, verify: OpenSSL::SSL::VERIFY_NONE) # Send request with ssl
      if response_https.code == 200 # Check if the response code is 200
        puts "\e[38;2;144;238;144mWorking on HTTPS ----> #{proxy_host}:#{proxy_port}\e[0m"
        hits_file = File.open(File.join(__dir__, 'Hits-proxy.txt'), 'a') do |file| # Save the hit proxy in Hits-proxy.txt
          file.puts "#{proxy_host}:#{proxy_port}"
        end
      else
        puts "\e[38;2;255;105;180m#{proxy} not working. HTTP code: #{response.code}, HTTPS code: #{response_https.code}\e[0m"
        # Delete the proxy from the proxy.txt file
        proxy_file = File.join(__dir__, 'proxy.txt')
        proxies.delete(proxy)
        # Rewrite the rest of the content into the file
        File.open(proxy_file, 'w') do |file|
          proxies.each { |p| file.puts(p) }
        end
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
  end
end