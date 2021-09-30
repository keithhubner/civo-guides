
# The Civo API key can be found via Civo GUI
variable "civo_token" {
  description = "Civo Token"
  type        = string
  default     = ""
}

# The Twingate API token can be found via the Twingate GUI 
# You will need to have an enterprise account to access this token
variable "twingate_token" {
  description = "Twingate API Token"
  type        = string
  default     = ""
}

# The network name can be found via the Twingate GUI
variable "network" {
  description = "Twingate Network Name"
  type        = string
  default     = ""
}

# The groupID can be found by querying the API using the following cURL command (replacing network and API key with your details):
# curl 'https://network.twingate.com/api/graphql/' \
# -H 'accept: application/json' \
# -H 'content-type: application/json' \
# -H 'x-api-key: YOUR_API_KEY' \
# --data-raw '{"query":"query{groups{edges{node{id,name}}}}","variables":{},"operationName":null}'

variable "groupID" {
  description = "Twingate GroupID"
  type        = string
  default     = ""
}