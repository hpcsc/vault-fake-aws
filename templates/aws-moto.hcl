exit_after_auth = true

template_config {
  exit_on_retry_failure = true
}

auto_auth {
  method {
    type      = "approle"

    config = {
      role_id_file_path = "/tmp/role-id"
      secret_id_file_path = "/tmp/secret-id"
      remove_secret_id_file_after_reading = false
    }
  }
}

template {
  error_on_missing_key = true
  contents = <<EOT
{{- with secret "awsmoto/sts/my-aws-role" "ttl=1h" -}}
{
  "accessKey": "{{.Data.access_key}}",
  "secretKey": "{{.Data.secret_key}}",
  "securityToken": "{{.Data.security_token}}"
}
{{- end -}}
EOT
  destination = "tmp/rendered/aws-moto.json"
}
