variable "repo" {
  default = "mk4"
}
variable "registry" {
  default = "ghcr.io"
}

group "default" {
  targets = ["tooler"]
}

################################################################################
// MARK: General targets
################################################################################

target "baser" {
  target = "baser"
  tags = ["mk4_ccu:baser"]
  pull = true
  no-cache = false
  cache-from = [
    // "type=registry,ref=${registry}/${repo}:main-tooler.cache",
  ]
  dockerfile = ".docker/Dockerfile"
}

target "cacher" {
  inherits   = ["baser"]
  target = "cacher"
  tags = ["mk4_ccu:cacher"]
}

target "runner" {
  inherits   = ["baser"]
  target = "runner"
  tags = ["mk4_ccu:runner"]
}

target "prepper" {
  inherits   = ["runner"]
  target = "prepper"
  tags = ["mk4_ccu:prepper"]
}

target "validator" {
  inherits   = ["prepper"]
  target = "validator"
  tags = ["mk4_ccu:validator"]
}

target "tooler" {
  inherits   = ["validator"]
  target = "tooler"
  tags = ["mk4_ccu:tooler"]
}

################################################################################
// MARK: Development targets 
################################################################################

variable "DEV_FROM_STAGE" {
  default = "tooler"
}

target "dever" {
  inherits   = ["tooler"]
  target = "dever"
  tags = ["mk4_ccu:dever"]
  args = {
    DEV_FROM_STAGE = "${DEV_FROM_STAGE}",
  }
}

target "seeder" {
  inherits   = ["dever"]
  target = "seeder"
  tags = ["mk4_ccu:seeder"]
  // no-cache-filter = ["builder"]
  args = {
    CLEAR_WS_CACHE = null,
    // CLEAR_WS_CACHE = "${timestamp()}",
    SEED_WS_CACHE = null,
    // SEED_WS_CACHE = "${timestamp()}",
  }
}

target "builder" {
  inherits   = ["seeder"]
  target = "builder"
  tags = ["mk4_ccu:builder"]
  // no-cache-filter = ["builder"]
  args = {
    BUST_BUILD_CACHE = null,
    // BUST_BUILD_CACHE = "${timestamp()}",
  }
}

target "tester" {
  inherits   = ["builder"]
  target = "tester"
  tags = ["mk4_ccu:tester"]
  args = {
    BUST_TEST_CACHE = null,
    // BUST_TEST_CACHE = "${timestamp()}",
  }
}

target "dancer" {
  inherits   = ["builder"]
  target = "dancer"
  tags = ["mk4_ccu:dancer"]
}

target "exporter" {
  inherits   = ["dancer"]
  target = "exporter"
  tags = ["mk4_ccu:exporter"]
}

################################################################################
// MARK: Production targets
################################################################################

target "shipper" {
  inherits   = ["dancer"]
  target = "shipper"
  args = {
  }
}

target "releaser" {
  inherits   = ["shipper"]
  target = "releaser"
  tags = ["mk4_ccu:releaser"]
  args = {
    SHIP_FROM_STAGE = "runner",
  }
  cache-from = [
    // "type=registry,ref=${registry}/${repo}:main-releaser.cache",
  ]
}

target "debugger" {
  inherits   = ["shipper"]
  target = "debugger"
  tags = ["mk4_ccu:debugger"]
  args = {
    SHIP_FROM_STAGE = "tooler",
  }
  cache-from = [
    // "type=registry,ref=${registry}/${repo}:main-debugger.cache",
  ]
}
