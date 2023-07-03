# GRABBER-checker-proxyes
grabber and checker proxy for crackers or hackers or any one want list proxy


# Proxy Scraper

This is a Ruby script that allows you to grab and check proxies from various sources. It automatically installs required gems and performs proxy grabbing and checking tasks.

# Installation

To use this script, make sure you have Ruby installed on your system. Additionally, the script requires the following gems:

`httparty`

`json`

`openssl`

If these gems are not installed, the script will automatically install them for you.
but in case you have install it before run the script, copy the code and paste in terminal:

**Kali linux**
```
sudo gem update && sudo gem install httparty json openssl

```
**Mac**
```
gem update && gem install httparty json openssl
```
**iSH app** 

it’s take a while
```
apk add ruby
gem update && gem install httparty json openssl
```
# Usage

Clone or download the script to your local machine.
Open a terminal and navigate to the directory where the script is located.
Run the script using the following command:
shell
Copy code
```
$ ruby proxy_scraper.rb
```
```
Enter
```
The script will start grabbing proxies from the specified sources and display them on the console.
All proxies will be saved in a file named proxy.txt.
After grabbing proxies, the script will check each proxy's availability by sending HTTP and HTTPS requests to Google. Working proxies will be displayed on the console and saved in a file named Hits-proxy.txt.
Proxies that are not working will be removed from the proxy.txt file.
Note: You don't need to manually download any additional files or libraries because the script handles the installation and execution process for you.

# Advantages

Automatic gem installation: The script checks if the required gems (httparty, json, openssl) are installed and installs them if necessary.
Proxy grabbing: The script retrieves proxies from specified sources and displays them on the console.
Proxy checking: The script checks the availability of each proxy by sending HTTP and HTTPS requests to Google. Working proxies are saved in a separate file.
Error handling: The script handles common errors such as connection resets and timeouts gracefully, ensuring a smooth execution.
Proxy management: Non-working proxies are automatically removed from the proxy.txt file, optimizing the proxy list for future use.
By using this script, you can quickly grab and check proxies without the need for manual intervention or downloading additional dependencies.

# Note: 
**The script focuses on its core functionality and avoids including any unrelated features or distractions for the user.**

**مميزات السكربت**

يثبت لك ويفحص لك اذا المكتبات موجودة ✅

للخروج من السكربت اكتب 00 او exit ✅

يبحث لك في100 موقع ✅

يفحص لك البروكسيات على نوعين من الاتصال على موقع قوقل HTTP , HTTPS✅
 
يفحص لك الشغال ويفرزه في ملف بأسم Hits.txt ✅

يحذف لك الي مو شغال من الملف proxy.txt ✅

-------------------------------------------------
**Features of the script**

the script check if there librarys or will install it ✅

To exit the script, type 00 or exit ✅


Searches for you in 80 sites ✅

Checks proxies on two types of connection on Google's website HTTP, HTTPS ✅

Examines the work proxy for you and sorts it into a file called Hits.txt ✅

if not work proxy It deletes the proxy file in proxy.txt ✅
