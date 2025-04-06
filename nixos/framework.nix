# Framework laptop specific configuration
{ config, lib, pkgs, ... }:

{
  # Import Framework hardware support from nixos-hardware
  # Using Framework 13 AMD (Ryzen 7040 series) module
  imports = [
    <nixos-hardware/framework/13-inch/7040>
  ];

  # Power management optimizations
  services.power-profiles-daemon.enable = true;
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # TLP for better battery life
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  # Framework-specific hardware support
  hardware.framework.amd-chipset.enable = true;
  hardware.sensor.iio.enable = true;  # For proper sensor support
  
  # Fingerprint reader support (if available on your model)
  services.fprintd.enable = true;
  
  # Better touchpad experience
  services.xserver.libinput = {
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