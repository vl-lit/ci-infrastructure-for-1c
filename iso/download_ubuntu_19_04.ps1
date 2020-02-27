$client = new-object System.Net.WebClient
$client.DownloadFile("http://releases.ubuntu.com/19.04/MD5SUMS", "ubuntu-19.04-md5-checksums.txt")
$client.DownloadFile("http://releases.ubuntu.com/19.04/ubuntu-19.04-live-server-amd64.iso","./ubuntu-19.04-live-server-amd64.iso")
