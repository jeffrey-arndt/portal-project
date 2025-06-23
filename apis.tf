resource "konnect_api" "my_api" {
  provider    = konnect-beta
  name        = "Flights"
  version     = "v1"
  description = "This is a description of a Flights API"
  labels = {
    key = "value"
  }
}

resource "konnect_api_implementation" "my_apiimplementation" {
  provider = konnect-beta
  api_id   = konnect_api.my_api.id
  service = {
    control_plane_id = var.control_plane_id
    id               = konnect_gateway_service.flights_service.id
  }
}

resource "konnect_api_publication" "my_apipublication" {
  provider                   = konnect-beta
  api_id                     = konnect_api.my_api.id
  portal_id                  = "0271a721-adeb-4503-88d7-a666d7ada498"
  auto_approve_registrations = true
  visibility                 = "public"
  auth_strategy_ids = [
    konnect_application_auth_strategy.my_applicationauthstrategy.id
  ]
}

resource "konnect_api_specification" "my_apispecification" {
  provider = konnect-beta
  api_id   = konnect_api.my_api.id
  content  = file("specifications/Flights/openapi.yaml")
  type     = "oas3"
}
