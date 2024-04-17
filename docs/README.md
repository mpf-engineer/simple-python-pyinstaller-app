# Desplegar Aplicación Python con Jenkins, Docker y Terraform

## Pasos a Seguir

1. Hacemos un fork de la app python a nuestro repositorio.

2. Clonamos nuestro repositorio.

3. Creamos una carpeta docs dentro del repositorio.

4. Creamos un archivo de configuración terraform, con el proveedor terraform, un contenedor para docker dind, y otro para jenkins, pero eso sí, la imagen de jenkins la obtendremos de un archivo Dockerfile:

```
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
    dockerfile = "./Dockerfile" 
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
```

5. Creamos el Dockerfile con la imagen de jenkins, y añadimos instrucciones de personalización para este contenedor, así como instrucciones de instalación de python y los plugins correspondientes. Esta iinstalaciones la llevaremos a cabo en su mayoría activando el modo Root:

```
# Personalizamos la imagen base de Jenkins:
FROM jenkins/jenkins
# Cambiamos al usuario root para instalar dependencias:
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli


# Instalamos las herramientas necesarias para construir y ejecutar la aplicación Python
RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && ln -s /usr/bin/python3 /usr/bin/python

# Cambiamos al usuario jenkins:
USER jenkins

# Instalamos los plugins Blue Ocean y Docker Workflow
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

```

6. Ejecutamos el despliegue de contenedores con terraform con los comandos:
```
terraform init
terraform apply
```
7. Obtenemos la contraseña de administración de jenkins accediendo al contenedor con el comando ```docker exec -it jenkins-container bash``` y ejecutando dentro de este el comando ```cat /var/jenkins_home/secrets/initialAdminPassword```.

8. Entramos al localhost, configuramos jenkins y creamos una nueva tarea seleccionando la opción  "pipeline" y enlazandolo con nuestro repositorio.
 
9. Vamos actualizando en nuestro repositorio los pipelines y ejecutandolos dentro de jenkins.
