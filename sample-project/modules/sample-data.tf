# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://ipecho.net/plain"
}