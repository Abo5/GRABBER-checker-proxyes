package main

import (
	"bufio"
	"crypto/tls"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"strings"
	"time"
)

// ANSI color codes
const (
	colorReset  = "\033[0m"
	colorRed    = "\033[31m"
	colorGreen  = "\033[32m"
	colorYellow = "\033[33m"
	colorPink   = "\033[38;2;255;105;180m"
	colorOrange = "\033[38;2;255;165;0m"
)

func main() {
	printLogo()

	fmt.Printf("%sHi, Welcome To Grabber And Checking Proxies, Write 00 To Exit\n", colorYellow)
	fmt.Println("1. Checker Proxies")
	fmt.Println("2. Grabber Proxies")
	fmt.Println("3. Grabber and Checker Proxies")
	fmt.Printf("Please enter your choice (1, 2, or 3): %s", colorReset)

	var choice int
	fmt.Scanf("%d", &choice)

	if choice == 0 {
		fmt.Println("Exiting...Thank You For Using Me")
		return
	}

	if choice == 2 || choice == 3 {
		fmt.Printf("%s[!] Grabbing Proxies...\n", colorOrange)
		grabProxies()
	}

	if choice == 1 || choice == 3 {
		fmt.Printf("\n%s[!] Grabbing Proxies Is Done, Now Checking%s\n", colorPink, colorReset)
		checkProxies()
	}
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
	fmt.Println(logo)
}

func grabProxies() {
	sources, err := readLines("sources.txt")
	if err != nil {
		fmt.Printf("Error reading sources: %v\n", err)
		return
	}

	for _, source := range sources {
		if !strings.HasPrefix(source, "https://") {
			continue
		}

		proxies, err := fetchProxies(source)
		if err != nil {
			fmt.Printf("Error fetching proxies from %s: %v\n", source, err)
			continue
		}

		for _, proxy := range proxies {
			fmt.Println(proxy)
			appendToFile("proxy.txt", proxy)
		}
	}
}

func fetchProxies(url string) ([]string, error) {
	client := &http.Client{
		Timeout: 3 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		},
	}

	resp, err := client.Get(url)
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

func checkProxies() {
	proxies, err := readLines("proxy.txt")
	if err != nil {
		fmt.Printf("Error reading proxies: %v\n", err)
		return
	}

	for _, proxy := range proxies {
		if checkProxy(proxy) {
			fmt.Printf("%sWorking ----> %s%s\n", colorGreen, proxy, colorReset)
			appendToFile("Hits-proxy.txt", proxy)
		} else {
			fmt.Printf("%s%s not working%s\n", colorPink, proxy, colorReset)
			removeFromFile("proxy.txt", proxy)
		}
	}
}

func checkProxy(proxy string) bool {
	proxyURL, err := url.Parse("http://" + proxy)
	if err != nil {
		return false
	}

	client := &http.Client{
		Timeout: 500 * time.Millisecond,
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyURL),
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}

	resp, err := client.Get("http://www.google.com")
	if err == nil && resp.StatusCode == 200 {
		resp.Body.Close()
		return true
	}

	resp, err = client.Get("https://www.google.com")
	if err == nil && resp.StatusCode == 200 {
		resp.Body.Close()
		return true
	}

	return false
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

func appendToFile(filename, text string) error {
	f, err := os.OpenFile(filename, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0600)
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = f.WriteString(text + "\n")
	return err
}

func removeFromFile(filename, text string) error {
	lines, err := readLines(filename)
	if err != nil {
		return err
	}

	var newLines []string
	for _, line := range lines {
		if line != text {
			newLines = append(newLines, line)
		}
	}

	return writeLines(filename, newLines)
}

func writeLines(filename string, lines []string) error {
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer f.Close()

	w := bufio.NewWriter(f)
	for _, line := range lines {
		fmt.Fprintln(w, line)
	}
	return w.Flush()
}
