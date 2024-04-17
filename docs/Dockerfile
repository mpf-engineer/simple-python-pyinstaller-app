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
