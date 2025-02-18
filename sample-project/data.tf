# My public IP: data.http.myip.response_body
data "http" "myip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  sample_project_id = "swt14"
}
