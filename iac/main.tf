# Red aislada para cada entorno
resource "docker_network" "app_network" {
  name = "net-${terraform.workspace}"
}


# 1. FRONTEND: Nginx
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = false
}

resource "docker_container" "frontend" {
  name  = "web-${terraform.workspace}"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = var.frontend_port[terraform.workspace]
  }
}


# 2. BACKEND: Node.js (index.js)
resource "docker_image" "node" {
  name         = "node:18-alpine"
  keep_locally = false
}

resource "docker_container" "backend" {
  name  = "api-${terraform.workspace}"
  image = docker_image.node.image_id

  # Servidor HTTP en Node que escucha en el puerto 3000
  command = [
    "node",
    "-e",
    "require('http').createServer((req, res) => { res.writeHead(200, {'Content-Type': 'application/json'}); res.end(JSON.stringify({ status: 'ok', ambiente: '${terraform.workspace}', service: 'api' })); }).listen(3000, () => console.log('API escuchando en puerto 3000'));"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 3000
    external = var.backend_port[terraform.workspace]
  }
}


# 3. BASE DE DATOS: PostgreSQL
resource "docker_image" "postgres" {
  name         = "postgres:13-alpine"
  keep_locally = false
}

resource "docker_container" "database" {
  name  = "bd-${terraform.workspace}"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_DB=app_${terraform.workspace}"
  ]

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 5432
    external = var.db_port[terraform.workspace]
  }
}


# Salidas (Outputs)cd iac
output "frontend_url" {
  value = "http://localhost:${var.frontend_port[terraform.workspace]}"
}

output "backend_url" {
  value = "http://localhost:${var.backend_port[terraform.workspace]}"
}

output "db_port" {
  value = var.db_port[terraform.workspace]
}