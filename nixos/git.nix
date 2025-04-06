{ config, pkgs, ... }:

{
  # Install Git
  programs.git = {
    enable = true;
    
    # Default configuration for all users
    config = {
      init.defaultBranch = "main";
      core = {
        editor = "nvim";  # Change to your preferred editor
        pager = "delta";
        autocrlf = "input";
      };
      
      # Enhanced diffs with delta
      delta = {
        enable = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "Dracula";
      };
      
      # Better merge conflict resolution
      merge = {
        conflictstyle = "diff3";
        tool = "vimdiff";
      };
      
      # Useful aliases
      alias = {
        # Basics
        st = "status -sb";
        ci = "commit";
        co = "checkout";
        br = "branch";
        
        # Log visualization
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        lga = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all";
        
        # Show changes
        df = "diff";
        dfs = "diff --staged";
        
        # Stash operations
        sl = "stash list";
        ss = "stash save";
        sp = "stash pop";
        
        # Branch management
        brd = "branch -d";
        brD = "branch -D";
        
        # Commit amending and fixups
        amend = "commit --amend";
        fix = "commit --fixup";
        
        # Undo operations
        unstage = "reset HEAD --";
        discard = "checkout --";
        uncommit = "reset --soft HEAD~1";
        
        # Show recent activity
        recent = "for-each-ref --sort=-committerdate --count=10 --format='%(refname:short)' refs/heads/";
        
        # Find files and content
        find = "!git ls-files | grep -i";
        grep-all = "!f() { git grep \"$1\" $(git rev-list --all); }; f";
        
        # Show configuration
        aliases = "!git config --get-regexp '^alias\\.' | sed 's/^alias\\.//g' | sort";
        
        # Sync with upstream
        sync = "!git fetch --all -p && git rebase origin/main";
        
        # Clean up local branches
        cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d";
      };
      
      # Color settings
      color = {
        ui = "auto";
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };
        status = {
          added = "green";
          changed = "yellow";
          untracked = "red";
        };
      };
      
      # Push settings
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      
      # Pull settings
      pull = {
        rebase = true;
      };
      
      # URL shortcuts
      url = {
        "git@github.com:" = {
          insteadOf = "gh:";
        };
        "https://github.com/" = {
          insteadOf = "github:";
        };
      };
    };
  };
}

