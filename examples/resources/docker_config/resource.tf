### Basic
resource "docker_config" "foo_config" {
  name = "foo_config"
  data = "ewogICJzZXJIfQo="
}

### Advanced
#### Dynamically set config with a template
# In this example you can use the `${var.foo_port}` variable to dynamically
# set the `${port}` variable in the `foo.configs.json.tpl` template and create
# the data of the `foo_config` with the help of the `base64encode` interpolation 
# function.

# File `foo.config.json.tpl`
# 
# {
#   "server": {
#     "public_port": ${port}
#   }
# }

# File `main.tf`

# Creates the template in renders the variable
data "template_file" "foo_config_tpl" {
  template = file("foo.config.json.tpl")

  vars {
    port = var.foo_port
  }
}

# Creates the config
resource "docker_config" "foo_config" {
  name = "foo_config"
  data = base64encode(data.template_file.foo_config_tpl.rendered)
}

#### Update config with no downtime
# To update a `config`, Terraform will destroy the existing resource and create a replacement. 
# To effectively use a `docker_config` resource with a `docker_service` resource, it's recommended
#  to specify `create_before_destroy` in a `lifecycle` block. Provide a unique `name` attribute, 
# for example with one of the interpolation functions `uuid` or `timestamp` as shown
# in the example below. The reason is https://github.com/moby/moby/issues/35803.

resource "docker_config" "service_config" {
  name = "${var.service_name}-config-${replace(timestamp(), ":", ".")}"
  data = base64encode(data.template_file.service_config_tpl.rendered)

  lifecycle {
    ignore_changes        = ["name"]
    create_before_destroy = true
  }
}

resource "docker_service" "service" {
  # ...
  configs = [
    {
      config_id   = docker_config.service_config.id
      config_name = docker_config.service_config.name
      file_name   = "/root/configs/configs.json"
    },
  ]
}