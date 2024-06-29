require 'httparty'
require 'json'
require 'openssl'
require 'parallel'

# Check and install required gems
gems_to_check = ['httparty', 'openssl', 'json', 'parallel']
gems_to_check.each do |gem|
  begin
    gem_installed = Gem::Specification.find_by_name(gem)
    puts "\e[38;2;0;255;0m[✓]\e[0m The gem #{gem} is installed "
  rescue Gem::LoadError
    puts "\e[31;1m[✗]\e[0m The gem #{gem} is not installed "
    system("gem install #{gem}")
    Gem.clear_paths
  end
end

# Colors
MAGENTA = "\e[38;2;128;0;128m"
YELLOW = "\e[38;2;255;255;0m"
ORANGE = "\e[38;2;255;165;0m"
RESET = "\e[0m"
GREEN = "\e[38;2;0;255;0m"
RED = "\e[38;2;255;0;0m"
PINK = "\e[38;2;255;105;180m"

def running
  print "#{ORANGE}Running"
  3.times do
    sleep(0.5)
    print "."
  end
  puts RESET
  sleep(0.5)
end

running
system("clear")

# Logo
logo = <<LOGO
#{MAGENTA}
..............................................
..............................................
.............                .................
.............                     ............
...........                          .........
..........                            ........
.........                               ......
.......:.          #{RESET}#{YELLOW}Proxy Scraper!#{RESET}#{MAGENTA}        .....
......::           #{RESET}#{YELLOW}CoDe By A88#{RESET}#{MAGENTA}            ....
.....:::.          #{RESET}#{YELLOW}Version 2.0#{RESET}#{MAGENTA}            ....
....::::.          #{RESET}#{YELLOW}Recommended use vpn#{RESET}#{MAGENTA}     ...
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
#{RESET}
LOGO

logo.each_char { |c| print c; sleep(0.0000000001) }

print "#{YELLOW}Hi, Welcome To Grabber And Checking Proxies, Write #{RESET}#{PINK}00#{RESET}#{YELLOW} To Exit\n"
print "1. Checker Proxies\n"
print "2. Grabber Proxies\n"
print "3. Grabber and Checker Proxies\n"
print "Please enter your choice (1, 2, or 3): #{RESET}"
choice = gets.chomp.to_i

if choice == 0
  puts "Exiting...Thank You For Using Me"
  exit
end

$stop_grabbing_proxies = false
Signal.trap("INT") do
  $stop_grabbing_proxies = true
  puts "\n#{MAGENTA}[!]STOPPING...GRABBING...NOW!#{RESET}"
end

def grab_proxies(source_url)
  return if $stop_grabbing_proxies
  return unless source_url.start_with?("https://")

  begin
    response = HTTParty.get(source_url, timeout: 3, verify: false)
    handle_response(response)
  rescue StandardError => e
    puts "Error: #{e.message} - Skipping source URL: #{source_url}"
  end
end

def handle_response(response)
  if response && response.code == 200
    proxies = response.body.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+/)
    if proxies.any?
      proxies.each { |proxy| puts proxy }
      File.open("proxy.txt", "a") do |file|
        proxies.each { |proxy| file.puts proxy }
      end
    else
      puts "No proxies found in the page"
    end
  else
    puts "Failed to get proxies (HTTP Status: #{response&.code || 'Unknown'})"
  end
end

if choice == 2 || choice == 3
  puts "#{ORANGE}[!] Grabbing Proxies...\n"
  file_sources = File.readlines('sources.txt', chomp: true)
  Parallel.each(file_sources, in_threads: 20) do |source_url|
    grab_proxies(source_url)
  end
end

if choice == 1 || choice == 3
  puts "\n#{MAGENTA}[!] Grabbing Proxies Is Done, Now Checking#{RESET}"

  proxies = File.readlines('proxy.txt', chomp: true).uniq
  working_proxies = Parallel.map(proxies, in_threads: 100) do |proxy|
    proxy_host, proxy_port = proxy.split(':')
    begin
      response = HTTParty.get('http://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 5)
      if response.code == 200
        puts "#{GREEN}Working on HTTP ----> #{proxy}#{RESET}"
        proxy
      else
        response_https = HTTParty.get('https://www.google.com', http_proxyaddr: proxy_host, http_proxyport: proxy_port, timeout: 5, verify: false)
        if response_https.code == 200
          puts "#{GREEN}Working on HTTPS ----> #{proxy}#{RESET}"
          proxy
        else
          puts "#{PINK}#{proxy} not working. HTTP code: #{response.code}, HTTPS code: #{response_https.code}#{RESET}"
          nil
        end
      end
    rescue StandardError => e
      puts "#{ORANGE}#{proxy} not working. #{e.message}#{RESET}"
      nil
    end
  end.compact

  File.open('Hits-proxy.txt', 'w') do |file|
    working_proxies.each { |proxy| file.puts proxy }
  end

  File.open('proxy.txt', 'w') do |file|
    working_proxies.each { |proxy| file.puts proxy }
  end

  puts "#{GREEN}Found #{working_proxies.size} working proxies out of #{proxies.size}#{RESET}"
end
