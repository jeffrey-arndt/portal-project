We will be deploying a brand new set of applications for our organization into the Konnect ecosystem

All learners will be divided up into several teams, each in charge of publishing their application to a unified Dev Portal and respective team Gateways

Each team will be responsible for ensuring their OAS spec meets all organization requirements, all conversions are executed, and then Terraform files are built out

Once all of that is complete, each team will apply their configurations declaratively via Terraform

We'll then register for our new Dev portal (https://3029fed9674b.us.kongportals.com/) and create an application to share access between the teams

# Control Plane ID <>

# Dev Portal ID <>
# PAT Token: <>

# PROXY URL: <>

## Prepare your OAS Specification

1) "Create" your application using https://api.dev/
2) Download your OAS specification 
3) Import your OAS spec file in Insomnia (Local)
4) Adjust your OAS spec file to route traffic properly once committed (Local)

```
servers:
- url: <Serverless_Proxy_URL>
  description: <product name> Gateway
```

```
x-kong-service-defaults:
  host: httpbin.konghq.com
  port: 443
  protocol: https
```

5) Perform Linting / Collection Build (Local) / Swap Environment

## Prepare Strigo Lab

```
git clone https://github.com/jeffrey-arndt/portal-project.git
```

6) Change directory to portal-project and copy linted OAS Spec into portal-project folder

7) Perform openapi2deck conversion (Strigo)

```
cat openapi.yaml | deck file openapi2kong > flights_deck.yaml
```

8) Perform kong2tf conversion (strigo)

Example:
```
deck file kong2tf -s ./flights_deck.yaml > flights.tf
```

Delete this section in the resulting file:

```
variable "control_plane_id" {
  type = string
  default = "YOUR_CONTROL_PLANE_ID"
}
```

Note your konnect_gateway_service resource name:

```
resource "konnect_gateway_service" "jeffy_s_pizza_api" {
  name = "jeffy-s-pizza-api"
  host = "541e195c77.serverless.gateways.konggateway.com"
  path = "/v1"
  port = 443
  protocol = "https"

  control_plane_id = var.control_plane_id
}
```


Service resource name:  <>

9) Enter the CP ID and Portal ID provided by the Platform (Instructor) Team in variables.tf (Strigo)

10) Adjust the apis.tf and auth-strategy.tf to be unique to your product (All "adjust' lines should be unique/updated)

apis.tf

resource "konnect_api" "my_api" {
  provider    = konnect-beta
  name        = "Flights"  [adjust]
  version     = "v1"
  description = "This is a description of a Flights API" [adjust]
  labels = {
    key = "value"
  }
}

resource "konnect_api_implementation" "my_apiimplementation" {
  provider = konnect-beta
  api_id   = konnect_api.my_api.id
  service_reference = {
    service = {
      control_plane_id = var.control_plane_id
      id               = konnect_gateway_service.flights_service.id [adjust to noted service name]
    }
  }
}

resource "konnect_api_specification" "my_apispecification" {
  provider = konnect-beta
  api_id   = konnect_api.my_api.id
  content  = file("./openapi.yaml") [adjust]
  type     = "oas3"
}

auth-strategy.tf

resource "konnect_application_auth_strategy" "my_applicationauthstrategy" {
  key_auth = {
    name          = "my-application-auth-strategy" [adjust]
    key_names     = ["apikey"]
    display_name  = "My Test Strategy" [adjust]
    strategy_type = "key_auth"
    configs = {
      key_auth = {
        key_names = ["apikey"]
      }
    }
  }
}

11) Using Terraform, push your configurations to Konnect

```
terraform init
```

```
terraform plan
```

```
terraform apply
```

12) Verify with platform team your API Product has been published (and send them your original OAS Spec)

Using the Developer Portal

1) Register in our new Portal
2) Create an application
3) Generate a credential
5) Using your credential test your access and that the GW is routing to our application properly
6) View the Analytics for your API Product in Konnect Analytics

------------------------------------
