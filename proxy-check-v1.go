package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"sync"
	"time"
)

const (
	magenta = "\033[38;2;128;0;128m"
	yellow  = "\033[38;2;255;255;0m"
	orange  = "\033[38;2;255;165;0m"
	nothing = "\033[0m"
	green   = "\033[38;2;0;255;0m"
	red     = "\033[38;2;255;0;0m"
	pink    = "\033[38;2;255;105;180m"
)

func main() {
	clearTerminal()
	printLogo()

	fmt.Printf("%sHi, Welcome To Grabber And Checking Proxies, Write %s00%s To Exit\n", yellow, pink, yellow)
	fmt.Println("1. Checker Proxies")
	fmt.Println("2. Grabber Proxies")
	fmt.Println("3. Grabber and Checker Proxies")
	fmt.Printf("Please enter your choice (1, 2, or 3): %s", nothing)

	var choice int
	fmt.Scanln(&choice)

	if choice == 0 {
		fmt.Println("Exiting...Thank You For Using Me")
		return
	}

	if choice == 2 || choice == 3 {
		fmt.Printf("%s[!] Grabbing Proxies...\n", orange)
		grabProxies()
	}

	if choice == 1 || choice == 3 {
		fmt.Printf("\n%s[!] Grabbing Proxies Is Done, Now Checking\n", magenta)
		checkProxies()
	}

	fmt.Printf("\n%s[!] Process completed. Thank you for using the script!%s\n", magenta, nothing)
}

func clearTerminal() {
	fmt.Print("\033[H\033[2J")
}

func printLogo() {
	logo := `
..............................................
..............................................
.............                .................
.............                     ............
...........                          .........
..........                            ........
.........                               ......
.......:.          Proxy Scraper!        .....
......::           CoDe By A88            ....
.....:::.          Version 2.0            ....
....::::.          Recommended use vpn     ...
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
`
	fmt.Printf("%s%s%s", magenta, logo, nothing)
}

func grabProxies() {
	sources, err := readLines("sources.txt")
	if err != nil {
		fmt.Printf("Error reading sources: %v\n", err)
		return
	}

	for _, source := range sources {
		if strings.HasPrefix(source, "https://") {
			proxies, err := fetchProxies(source)
			if err != nil {
				fmt.Printf("Error fetching from %s: %v\n", source, err)
				continue
			}
			saveProxies(proxies)
		}
	}
}

func fetchProxies(url string) ([]string, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	re := regexp.MustCompile(`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+`)
	return re.FindAllString(string(body), -1), nil
}

func saveProxies(proxies []string) {
	file, err := os.OpenFile("proxy.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("Error opening proxy.txt: %v\n", err)
		return
	}
	defer file.Close()

	for _, proxy := range proxies {
		if _, err := file.WriteString(proxy + "\n"); err != nil {
			fmt.Printf("Error writing proxy: %v\n", err)
		}
	}
}

func checkProxies() {
	proxies, err := readLines("proxy.txt")
	if err != nil {
		fmt.Printf("Error reading proxies: %v\n", err)
		return
	}

	var wg sync.WaitGroup
	semaphore := make(chan struct{}, 50) // Limit to 50 concurrent goroutines

	for _, proxy := range proxies {
		wg.Add(1)
		semaphore <- struct{}{}
		go func(p string) {
			defer wg.Done()
			defer func() { <-semaphore }()
			checkProxy(p)
		}(proxy)
	}

	wg.Wait()
}

func checkProxy(proxy string) {
	proxyURL, err := url.Parse("http://" + proxy)
	if err != nil {
		fmt.Printf("%sInvalid proxy format: %s%s\n", orange, proxy, nothing)
		return
	}

	client := &http.Client{
		Timeout: 5 * time.Second,
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyURL),
		},
	}

	resp, err := client.Get("http://www.google.com")
	if err != nil {
		fmt.Printf("%s%s not working. %v%s\n", orange, proxy, err, nothing)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode == 200 {
		fmt.Printf("%sWorking on HTTP ----> %s%s\n", green, proxy, nothing)
		saveWorkingProxy(proxy)
	} else {
		fmt.Printf("%s%s not working. HTTP code: %d%s\n", pink, proxy, resp.StatusCode, nothing)
	}
}

func saveWorkingProxy(proxy string) {
	file, err := os.OpenFile("Hits-proxy.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("Error opening Hits-proxy.txt: %v\n", err)
		return
	}
	defer file.Close()

	if _, err := file.WriteString(proxy + "\n"); err != nil {
		fmt.Printf("Error writing working proxy: %v\n", err)
	}
}

func readLines(filename string) ([]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines, scanner.Err()
}
