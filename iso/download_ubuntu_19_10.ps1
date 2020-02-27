$client = new-object System.Net.WebClient
$client.DownloadFile("http://releases.ubuntu.com/19.10/MD5SUMS", "ubuntu-19.10-md5-checksums.txt")
$client.DownloadFile("http://releases.ubuntu.com/19.10/ubuntu-19.10-live-server-amd64.iso","./ubuntu-19.10-live-server-amd64.iso")
