# Home Manager configuration for andrewgari
{ config, pkgs, unstable, ... }:

{
  # Home Manager settings
  home.username = "andrewgari";
  home.homeDirectory = "/home/andrewgari";
  home.stateVersion = "24.11";
  
  # User packages
  home.packages = with pkgs; [
    github-desktop
    
    steam
    lutris
    retroarch
    
    obs-studio
    
    _1password-cli
    _1password-gui
    
    unstable.windsurf
    unstable.code-cursor
    unstable.claude-code
  ];
  
  # Shell and prompt
  programs.zsh.enable = true;
  programs.starship.enable = true;
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "andrewgari";
    userEmail = "covadax.ag@gmail.com";
    
    # Advanced aliases
    aliases = {
      # Smart commits
      cm = "commit -m";
      cam = "commit -am";
      
      # Worktree management
      wt = "worktree";
      wta = "worktree add";
      wtl = "worktree list";
      wtr = "worktree remove";
      
      # Bisect helpers
      good = "bisect good";
      bad = "bisect bad";
      
      # Advanced log views
      changelog = "log --pretty=format:'* %s (%h)' --reverse";
      standup = "!git log --since yesterday --author=$(git config user.email) --pretty=format:'%Cred%h%Creset - %s %Cgreen(%cr)%Creset'";
      
      # Quick stats
      stat = "!git diff --stat $(git merge-base HEAD origin/main)";
      contributions = "shortlog -sn --no-merges";
      
      # Safely force push
      fpush = "push --force-with-lease";
      
      # Undo last commit but keep changes
      undo = "reset --soft HEAD^";
      
      # Create a new branch with issue number
      issue = "!f() { git checkout -b issue-$1; }; f";
      
      # Interactive rebase with auto-squash
      squash = "!f() { git rebase -i HEAD~$1; }; f";
      
      # Show the history of a file
      flog = "log -p --follow";
      
      # Search commit messages
      search = "!f() { git log --all --grep=$1; }; f";
      
      # Quick save work in progress
      wip = "!git add -A && git commit -m 'WIP: Work in progress'";
      unwip = "!git log -n 1 | grep -q -c 'WIP: Work in progress' && git reset HEAD~1";
      
      # Stash operations
      save = "stash push -m";
      pop = "stash pop";
      snapshot = "!git stash push -m \"snapshot: $(date)\" && git stash apply 'stash@{0}'";
      
      # Show what you've worked on today
      today = "!git log --since=00:00:00 --all --no-merges --oneline --author=$(git config user.email)";
    };
    
    # Git ignore patterns for all repositories
    ignores = [
      # OS specific
      ".DS_Store"
      "Thumbs.db"
      
      # Editor files
      "*.swp"
      ".idea/"
      ".vscode/"
      "*.sublime-*"
      
      # Build artifacts
      "*.o"
      "*.pyc"
      "__pycache__/"
      "*.class"
      
      # Logs and databases
      "*.log"
      "*.sqlite"
      
      # Environment and config
      ".env"
      ".env.local"
      "node_modules/"
      "npm-debug.log"
      
      # Temporary files
      "*~"
      "*.bak"
      "*.tmp"
    ];
    
    # Git attributes for better handling of different file types
    attributes = [
      "*.txt diff=text"
      "*.md diff=markdown"
      "*.pdf diff=pdf"
      "*.json diff=json"
      "*.png diff=image"
      "*.jpg diff=image"
    ];
  };
}