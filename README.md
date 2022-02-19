# vault-fake-aws

2 different ways to simulate AWS when using vault AWS secrets engine. Both examples use vault agent to render a template that retrieves aws temporary credentials from aws secrets engine. The difference is that `templates/aws-kv1.hcl` retrieves credentials using `read`/`GET` while `templates/aws-moto.hcl` uses `write`/`PUT`

## Use KV Secrets Engine V1

Note: only works if aws temporary credentials are requested by using `read`. If `write` is used instead, the values in vault are overwritten with empty values.

Run `./batect render-kv1`. This runs vault agent that renders the template `templates/aws-kv1.hcl`. This template reads credentials from kv1 secrets engine (that pretends to be aws secrets engine) and renders to `tmp/rendered/aws-kv1.json`

## Use AWS Secrets Engine with Moto

Run `./batect render-moto`. This runs vault agent that renders the template `templates/aws-moto.hcl`. This template writes and reads credentials again from aws secrets engine (that talks to moto as fake aws) and renders to `tmp/rendered/aws-moto.json`
