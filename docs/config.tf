terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_network" "jenkins_network" {
  name = "RedJenkins"
}

resource "docker_container" "dind" {
  image        = "docker:dind"
  name         = "dind-container"
  network_mode = "bridge"

  ports {
    internal = 2376
    external = 2376
  }
}

resource "docker_image" "jenkins" {
  name = "myjenkins"
  build {
    context    = "."
    dockerfile = "./Dockerfile"  # El Dockerfile está en la misma carpeta que main.tf
  }
}

resource "docker_container" "jenkins" {
  name  = "jenkins-container"
  image = docker_image.jenkins.name

  ports {
    internal = 8080
    external = 8080
  }

  networks_advanced {
    name = docker_network.jenkins_network.name
  }
}
