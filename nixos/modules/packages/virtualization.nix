# Virtualization and container tools
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    podman
  ];
  
  # Enable Docker service
  virtualisation.docker.enable = true;
}