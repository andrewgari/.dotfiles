{ config, pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      # Get editor completions based on the config schema
      "$schema" = "https://starship.rs/config-schema.json";
      
      # Inserts a blank line between shell prompts
      add_newline = true;
      
      # Custom format
      format = "$env_var$username$hostname$directory$git_branch$git_status$cmd_duration$character";
      
      character = {
        success_symbol = "[⚡](bold green)";
        error_symbol = "[💥](bold red)";
      };
      
      "env_var.OS_ICON" = {
        variable = "STARSHIP_OS";
        default = "";
        format = "[$env_value]($style) ";
        style = "bold blue";
      };
      
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bold yellow";
      };
      
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
        format = "[ $path]($style) ";
        read_only = " 🔒";
        read_only_style = "red";
      };
      
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
      };
      
      git_status = {
        conflicted = "󰞇 ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        untracked = "?\${count} ";
        stashed = "󰏖 ";
        modified = "!\${count} ";
        staged = "+\${count} ";
        renamed = "»\${count} ";
        deleted = "✘\${count} ";
        style = "bold red";
        format = "([$all_status$ahead_behind]($style) )";
      };
      
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };
  
  # Make sure the starship package is installed
  environment.systemPackages = with pkgs; [
    starship
  ];
}
