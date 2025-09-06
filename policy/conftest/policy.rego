package main

deny[msg] {
  input.image.tag == "latest"
  msg := "images must not use latest tag"
}

deny[msg] {
  not input.image.digest
  msg := "image digest must be pinned"
}

deny[msg] {
  input.container.runAsRoot == true
  msg := "containers must not run as root"
}

deny[msg] {
  input.container.securityContext.readOnlyRootFilesystem != true
  msg := "readOnlyRootFilesystem must be true"
}

deny[msg] {
  input.container.securityContext.allowPrivilegeEscalation == true
  msg := "no-new-privileges required"
}
