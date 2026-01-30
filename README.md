# Inception - 42 Istanbul

**Inception** is a System Administration project designed to broaden knowledge of virtualization and infrastructure management using **Docker**. The goal is to set up a secure, multi-container infrastructure using Docker Compose, adhering to strict security and architectural rules.

## 🚀 Overview
The project involves virtualizing several Docker images in a personal virtual machine, creating a dedicated network where each service runs in its own container.

### 🛠 Technical Infrastructure
- **Base OS:** Optimized containers built from Alpine or Debian. 
- **Services:**
    - **NGINX:** Configured with TLSv1.2/v1.3 only for secure entry. 
    - **WordPress & PHP-FPM:** Installed and configured without NGINX in its container.
    - **MariaDB:** Dedicated database container. 
- **Storage:** Persistence managed via **Docker Named Volumes** (storing data in `/home/mikkayma/data`). 
- **Security:** Use of `.env` files and **Docker Secrets** to manage sensitive credentials, with no passwords hardcoded in Dockerfiles. 

## 📋 Design Choices & Comparisons

### Virtual Machines vs. Docker
- **Virtual Machines:** Virtualize hardware to run a full OS, consuming more resources but providing higher isolation.
- **Docker:** Virtualizes the OS kernel to run lightweight containers, sharing the host's resources while maintaining process isolation. 

### Secrets vs. Environment Variables
- **Environment Variables:** Ideal for non-sensitive configuration (e.g., domain names). 
- **Secrets:** Essential for sensitive data (passwords, API keys) as they are encrypted at rest and not exposed in the image layer.

### Docker Network vs. Host Network
- **Docker Network:** Provides a private, isolated bridge for containers to communicate securely.
- **Host Network:** Directly uses the host's network stack, which is forbidden in this project for security and isolation reasons.

### Docker Volumes vs. Bind Mounts
- **Docker Volumes:** Managed by Docker, more portable, and secure for persistent data.
- **Bind Mounts:** Depend on the host's file structure, which can lead to permission issues and less portability; thus, they are prohibited for this project's volumes.

## 🕹 Instructions
### Compilation & Execution
This project is managed by a **Makefile** located at the root directory. 
```bash
make up     # Builds images and starts the infrastructure
make down   # Stops and removes containers
make clean  # Performs a full cleanup of images and volumes
