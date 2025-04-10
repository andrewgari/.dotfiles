# Framework laptop specific configuration
{ config, lib, pkgs, ... }:

{
  # Framework-specific hardware support
  # Note: nixos-hardware module is imported through the flake inputs

  # Power management optimizations
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # Use power-profiles-daemon for power management
  services.power-profiles-daemon.enable = true;

  # Framework-specific hardware support
  # AMD sensor support
  hardware.sensor.iio.enable = true;  # For proper sensor support
  
  # Fingerprint reader support (if available on your model)
  services.fprintd.enable = true;
  
  # Better touchpad experience
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      accelProfile = "adaptive";
      disableWhileTyping = true;
    };
  };

  # Enable Bluetooth with better power management
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;  # Don't power bluetooth on boot to save battery
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}