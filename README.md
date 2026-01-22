<a name="top"></a>

# 🐳 Inception - 42 Project

*This project has been created as part of the 42 curriculum by kabasolo.*

## 📖 Index

- [📦 Description](#-description)
- [🏁 Introduction](#-introduction)
- [📚 Resources](#-resources)
- [🤖 AI Usage](#-ai-usage)

---

## 📦 Description

This project consists of setting up a **Docker-based infrastructure** composed of multiple containers, each running a specific service and configured to work together as a complete **WordPress web server**.

The infrastructure is built using **Docker Compose**, which allows defining, running, and managing multiple containers as a single application. Each service is built from its own **Dockerfile**, using a minimal base image, and follows the rule of **one service per container**. The project includes the configuration and source files required to run:

- **Nginx** as a reverse proxy with SSL (TLS)
- **WordPress** running with **PHP-FPM**
- **MariaDB** as the database server

Docker is used instead of traditional **virtual machines** because containers are lighter, faster to start, and share the host kernel while still providing strong process isolation. Unlike virtual machines, Docker does not require running a full operating system per service, making it more efficient and better suited for microservice architectures.

Sensitive information such as database credentials is handled using **Docker secrets** rather than environment variables. Secrets are not exposed in images or container inspection, making them a safer choice for managing confidential data.

All containers communicate through a **custom Docker network**, ensuring isolated internal communication between services without exposing them directly to the host network. This improves security and control compared to using the host network.

For data persistence, **Docker volumes** are used instead of bind mounts. Volumes are managed by Docker, are portable across systems, and avoid tight coupling with the host filesystem, making the infrastructure more robust and reproducible.

[⬆ Back to 📖 Index](#top)

---

## 🏁 Introduction

### `Automatic setup:`
| Command    | Description |
|------------|-------------|
| make setup | You just gotta change the "replace" in the secrets

### `Individual setup steps:`
| Command      | Description |
|--------------|-------------|
| make host    | Introduces 'kabasolo.42.fr' as a valid host to your machine
| make env     | Create a new srcs/.env
| make secrets | Create secrets/ folder with placeholders to replace

### `Available Makefile commands:`
| Command      | Description |
|--------------|-------------|
| make up      | Build and start containers
| make down    | Stop and remove containers and volumes
| make start   | Start existing (stopped) containers
| make stop    | Stop running containers
| make clean   | Stop and remove containers + volumes
| make fclean  | Like clean + remove images and persistent files
| make nuke    | Like down but also removes orphans
| make re      | fclean + up
| make rebuild | fclean + all (e.g. build SSL then up)

You can also just type `make` / `make all` to see all these options in the root of the project page.

[⬆ Back to 📖 Index](#top)

---

## 📚 Resources

### 🔗 Documentation & References

The following resources were used to understand the concepts and technologies required for this project:

- Docker Documentation  
  https://docs.docker.com/

- Docker Compose Documentation  
  https://docs.docker.com/compose/

- Nginx Official Documentation  
  https://nginx.org/en/docs/

- WordPress Documentation  
  https://wordpress.org/support/

- MariaDB Documentation  
  https://mariadb.org/documentation/

- *Inception Guide — Part I* (Medium)  
  https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671

- *Inception Guide — Part II* (Medium)  
  https://medium.com/@ssterdev/inception-42-project-part-ii-19a06962cf3b

Additionally, several **open-source repositories on GitHub** were consulted for inspiration on structuring the project, service configuration, and best practices when using Docker Compose in a 42-style setup.

These references were used to design the infrastructure, configure services correctly, and follow best practices regarding containerization, networking, and security.

[⬆ Back to 📖 Index](#top)

---

### 🤖 AI Usage

AI tools were used **as a learning and assistance resource**, not as a replacement for implementation.

Specifically, AI was used for:
- Clarifying Docker and Docker Compose concepts
- Understanding differences between virtualization and containerization
- Improving documentation structure and wording
- Reviewing configuration logic and design decisions

All Dockerfiles, configuration files, scripts, and infrastructure choices were written, tested, and validated manually to ensure full understanding of the project requirements.

[⬆ Back to 📖 Index](#top)