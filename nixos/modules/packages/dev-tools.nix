# Development tools packages
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Development environments
    android-studio
    jetbrains-toolbox
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.goland
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    
    # Programming languages and tools
    rustc
    cargo
    go
    typescript
    nodejs
    jdk
    kotlin
    python3Full
    gcc
    cmake
    
    # Version control
    git
    gh
    
    # Crypto/security
    openssl
  ];
}