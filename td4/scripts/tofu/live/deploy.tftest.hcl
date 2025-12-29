# deploy.tftest.hcl

run "deploy" {
  command = apply
}

run "validate" {
  command = apply

  module {
    # Chemin vers le module créé à l'étape 2
    source = "../modules/test-endpoint"
  }

  variables {
    # Ici, on récupère l'URL de l'infra déployée. 
    # Si tu n'as pas d'infra réelle, cela plantera ici.
    endpoint = run.deploy.api_endpoint
  }

  assert {
    condition     = data.http.test_endpoint.status_code == 200
    error_message = "Unexpected status code"
  }

  assert {
    condition     = data.http.test_endpoint.response_body == "Hello, World!"
    error_message = "Unexpected response body"
  }
}
