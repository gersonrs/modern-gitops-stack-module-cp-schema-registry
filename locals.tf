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
    }
  }]
}
