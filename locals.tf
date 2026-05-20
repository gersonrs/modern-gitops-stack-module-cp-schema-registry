locals {
  domain = format("schema-registry.%s", trimprefix("${var.subdomain}.${var.base_domain}", "."))

  helm_values = [{
    cp-helm-charts = {
      cp-kafka = {
        enabled = false
      }
      cp-zookeeper = {
        enabled = false
      }
      cp-schema-registry = {
        enabled = true
        kafka = {
          bootstrapServers = "PLAINTEXT://${var.kafka_broker_name}-kafka-bootstrap:9092"
        }
      }
      cp-kafka-rest = {
        enabled = false
      }
      cp-kafka-connect = {
        enabled = false
      }
      cp-ksql-server = {
        enabled = false
      }
      cp-control-center = {
        enabled = false
      }
    }
  }]

  helm_values_httproute = [{
    httproute = {
      enabled           = true
      host              = local.domain
      gateway_name      = var.gateway_name
      gateway_namespace = var.gateway_namespace
      backend_service   = var.oidc != null ? "schema-registry-oauth2-proxy" : "schema-registry-cp-schema-registry"
      backend_port      = var.oidc != null ? 4180 : 8081
    }
  }]

  helm_values_oauth2proxy = var.oidc != null ? [{
    oauth2proxy = {
      enabled      = true
      upstreamUrl  = "http://schema-registry-cp-schema-registry:8081"
      redirectUrl  = "https://${local.domain}/oauth2/callback"
      cookieSecret = random_password.oauth2_proxy_cookie_secret.result
      oidc = {
        issuerUrl    = var.oidc.issuer_url
        clientId     = var.oidc.client_id
        clientSecret = var.oidc.client_secret
      }
      extraArgs = concat(
        var.oidc.oauth2_proxy_extra_args,
        [for g in var.allowed_groups : "--allowed-group=${g}"]
      )
    }
  }] : []
}
