variable "frontend_port" {
  description = "Puerto externo para el contenedor Frontend (nginx)"
  type        = map(number)
  default = {
    dev = 4001
    qa  = 5001
  }
}

variable "backend_port" {
  description = "Puerto externo para el contenedor Backend (node)"
  type        = map(number)
  default = {
    dev = 4002
    qa  = 5002
  }
}

variable "db_port" {
  description = "Puerto externo para la base de datos (postgresql)"
  type        = map(number)
  default = {
    dev = 4003
    qa  = 5003
  }
}