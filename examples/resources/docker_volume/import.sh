#!/bin/bash

docker volume create
524b0457aa2a87dd2b75c74c3e4e53f406974249e63ab3ed9bf21e5644f9dc7d

# Docker volume can be imported using the long ID only
$ terraform import docker_volume.foo 524b0457aa2a87dd2b75c74c3e4e53f406974249e63ab3ed9bf21e5644f9dc7d