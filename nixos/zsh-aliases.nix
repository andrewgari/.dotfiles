{
  # Shell aliases for NixOS configuration
  shellAliases = {
    # Dotfiles aliases
    dotgit = "git --git-dir=$HOME/Repos/dotfiles/.git --work-tree=$HOME/Repos/dotfiles";
    dotfiles = "cd ~/Repos/dotfiles/.scripts/tools";
    scripts = "cd ~/.scripts/tools";
    
    # Dotfiles management
    "dotfiles-sync" = "$HOME/.scripts/tools/run_dotfiles_sync.sh";
    "dotfiles-upload" = "$HOME/.scripts/tools/run_dotfiles_upload.sh";
    "dotfiles-download" = "$HOME/.scripts/tools/run_dotfiles_download.sh";
    "dotfiles-add" = "$HOME/.scripts/tools/run_dotfiles_add.sh";
    "dotfiles-remove" = "$HOME/.scripts/tools/run_dotfiles_remove.sh";
    "dotfiles-status" = "dotgit status";
    "dotfiles-log" = "dotgit log --oneline --graph --decorate -n 10";
    "dotfiles-reset" = "dotgit reset --hard && dotgit clean -fd";
    
    # Bootstrap scripts
    "bootstrap-github" = "$HOME/.scripts/bootstrap/bootstrap_github.sh";
    "bootstrap-packages" = "$HOME/.scripts/bootstrap/bootstrap_packages.sh";
    "bootstrap-dev" = "$HOME/.scripts/bootstrap/bootstrap_dev_environment.sh";
    
    # Git utilities
    "git-https-to-ssh" = "git remote -v | awk \"/https:\\/\\/github.com/ {print \\$1, \\$2}\" | while read remote url; do git remote set-url \"$remote\" \"$(echo \"$url\" | sed -E \"s|https://github.com/|git@github.com:|;s|.git$||\")\".git\"; done";
    
    # Config file quick access
    zshrc = "${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc";
    aliases = "${EDITOR:-nvim} ~/.zsh-aliases && source ~/.zshrc";
    vimrc = "${EDITOR:-nvim} ~/.config/nvim/init.lua";
    configuration = "${EDITOR:-nvim} /etc/nixos/configuration.nix";
    
    # NixOS Package management shortcuts
    update = "sudo nixos-rebuild switch --upgrade";
    install = "nix-env -iA nixos.";
    search = "nix search nixpkgs";
    remove = "nix-env -e";
    clean = "nix-collect-garbage -d";
    nix-gc = "nix-collect-garbage -d";
    nix-update = "sudo nix-channel --update";
    nix-list = "nix-env -q";
    nix-generations = "nix-env --list-generations";
    nix-rollback = "nix-env --rollback";
    
    # System info and monitoring
    free_space = "df -h --total | grep total";
    meminfo = "free -h";
    processes = "ps aux --sort=-%cpu | head -15";
    cpu_temp = "sensors | grep Core";
    io_stats = "iostat -x 1 3";
    net_stats = "ss -tuln";
    sys_info = "inxi -Fxz";
    uptime_info = "uptime -p";
    
    # Power management
    reboot_now = "sudo systemctl reboot";
    shutdown_now = "sudo systemctl poweroff";
    suspend = "systemctl suspend";
    hibernate = "systemctl hibernate";
    
    # File operations
    trash = "mv --force -t ~/.local/share/Trash ";
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";
    mkdir = "mkdir -p";
    md = "mkdir -p";
    print = "echo";
    edit = "${EDITOR:-nvim}";
    
    # SSH connections
    sshpc = "ssh andrewgari@192.168.50.2";
    sshwork = "ssh andrewgari@192.168.50.11";
    ssh_copy_id = "ssh-copy-id -i ~/.ssh/id_rsa.pub";
    
    # Copy/paste in terminal
    c = "xclip -selection clipboard";
    v = "xclip -selection clipboard -o";
    
    # Modern CLI tool aliases
    # Nix handles these through package dependencies
    cat = "bat --style=plain";
    catp = "bat -p";
    df = "duf --only local";
    top = "btop";
    grep = "rg";
    
    # Systemd aliases
    status = "systemctl status";
    start = "systemctl start";
    enable = "systemctl enable";
    disable = "systemctl disable";
    stop = "systemctl stop";
    restart = "systemctl daemon-reload";
    
    # Networking
    myip = "curl ifconfig.me";
    localip = "hostname -I | awk '{print \\$1}'";
    ips = "ip -c a";
    ports = "ss -tulanp";
    listening = "ss -ltn";
    connections = "ss -tn";
    flush_dns = "sudo systemd-resolve --flush-caches && sudo systemctl restart systemd-resolved";
    dns_servers = "grep -i nameserver /etc/resolv.conf";
    ping_google = "ping -c 5 google.com";
    tracert = "traceroute";
    mtr_google = "mtr google.com";
    speedtest = "fast";
    nmap_local = "sudo nmap -sP 192.168.50.0/24";
    nmap_ports = "sudo nmap -p 1-1000";
    nmap_os = "sudo nmap -O";
    restart_network = "sudo systemctl restart NetworkManager";
    wifi_list = "nmcli device wifi list";
    wifi_connect = "nmcli device wifi connect";
    wifi_on = "nmcli radio wifi on";
    wifi_off = "nmcli radio wifi off";
    
    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "~" = "cd ~";
    docs = "cd ~/Documents";
    dl = "cd ~/Downloads";
    repos = "cd ~/Repos";
    starbunk = "cd ~/Repos/starbunk-js";
    unraid = "cd /mnt/unraid";
    "-" = "cd -";
    
    # rsync shortcuts
    rsync = "rsync -avz --progress --one-file-system";
    "giga-rsync" = "rsync -avz --progress";
    "rsync-update" = "rsync -avzu --progress --delete";
    
    # Exa (Better ls)
    ls = "exa --icons";
    ll = "exa -l --icons --group-directories-first";
    la = "exa -la --icons --group-directories-first";
    lt = "exa -lT --icons --git-ignore";
    lg = "exa -l --git --icons";
    lsd = "exa -D --icons";
    lt1 = "exa -lT --icons --level=1";
    lt2 = "exa -lT --icons --level=2";
    
    # Git shortcuts
    g = "git";
    gs = "git status -sb";
    ga = "git add";
    gaa = "git add --all";
    gc = "git commit -m";
    gp = "git push -u origin";
    gl = "git log --oneline --graph --decorate --all";
    gd = "git diff";
    gds = "git diff --staged";
    gco = "git switch";
    gcob = "git switch -c";
    gpull = "git pull origin";
    gf = "git fetch --all";
    grb = "git rebase";
    gm = "git merge";
    gre = "git restore";
    grs = "git restore --staged";
    gpf = "git push --force-with-lease";
    grh = "git reset --hard";
    gb = "git branch";
    gbl = "git branch -l";
    gbr = "git branch -r";
    gbd = "git branch -d";
    gcl = "git clone";
    gst = "git stash";
    gstp = "git stash pop";
    gundo = "git reset --soft HEAD~1";
    
    # Docker/Podman
    docker_restart = "sudo systemctl restart docker";
    docker_cleanup = "docker system prune -a -f && docker volume prune -f";
    docker = "podman";
    dps = "docker ps";
    dpa = "docker ps -a";
    drm = "docker rm";
    drmi = "docker rmi";
    drma = "docker rm $(docker ps -aq)";
    dstop = "docker stop";
    dstopa = "docker stop $(docker ps -q)";
    drestart = "docker restart";
    dlogs = "docker logs";
    dexec = "docker exec -it";
    dimg = "docker images";
    dcup = "docker-compose up -d";
    dcdown = "docker-compose down";
    dcps = "docker-compose ps";
    dclogs = "docker-compose logs -f";
    dcrestart = "docker-compose restart";
    
    # System utilities
    list_services = "systemctl list-units --type=service --state=running";
    reload_systemd = "sudo systemctl daemon-reexec";
    
    # Log viewing
    watch_logs = "journalctl -f";
    logs = "journalctl -xe";
    system_logs = "journalctl -b";
    service_logs = "journalctl -u";
    error_logs = "journalctl -p err..alert -b";
    
    # Process monitoring
    top_cpu = "ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -10";
    top_mem = "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -10";
    psmem = "ps auxf | sort -nr -k 4 | head -10";
    pscpu = "ps auxf | sort -nr -k 3 | head -10";
    pstree = "pstree -pula";
    
    # Common utilities
    weather = "curl wttr.in";
    h = "history | grep";
    paths = "echo $PATH | tr ':' '\\n'";
    path = "echo $PATH | tr ':' '\\n'";
    now = "date +\"%T\"";
    nowtime = "now";
    nowdate = "date +\"%d-%m-%Y\"";
    week = "date +%V";
    
    # Home-manager aliases (NixOS user config management)
    hm = "home-manager";
    hms = "home-manager switch";
    hme = "${EDITOR:-nvim} ~/.config/home-manager/home.nix";
    hmg = "home-manager generations";
    
    # NPM shortcuts
    npmi = "npm install";
    npmg = "npm install -g";
    npmu = "npm update";
    npmr = "npm run";
    npms = "npm start";
    npmt = "npm test";
    npml = "npm list --depth=0";
    npmgl = "npm list -g --depth=0";
    
    # Yarn shortcuts
    yi = "yarn install";
    ya = "yarn add";
    yad = "yarn add --dev";
    yr = "yarn remove";
    ys = "yarn start";
    yt = "yarn test";
    yb = "yarn build";
    
    # Development tools
    python = "python3";
    py = "python3";
    pip = "pip3";
    venv = "python3 -m venv venv";
    activate = "source venv/bin/activate";
    
    # Zoxide
    z = "zoxide query --exclude \"$(pwd)\"";
    zi = "zoxide query --interactive";
    za = "zoxide add";
    zr = "zoxide remove";
    zri = "zoxide remove --interactive";
    
    # Personal scripts
    backup_gnome = "$HOME/.scripts/tools/run_backup_gnome_settings.sh";
    btrfs_backup = "$HOME/.scripts/tools/run_btrfs_backup.sh";
    bulk_rename = "$HOME/.scripts/tools/run_bulk_rename.sh";
    wifi_signal = "$HOME/.scripts/tools/run_check_wifi_signal.sh";
    convert_video = "$HOME/.scripts/tools/run_convert_video.sh";
    diagnostics = "$HOME/.scripts/tools/run_diagnostics.sh";
    find_large_files = "$HOME/.scripts/tools/run_find_large_files.sh";
    kill_high_cpu = "$HOME/.scripts/tools/run_kill_high_cpu.sh";
    mount_usb = "$HOME/.scripts/tools/run_mount_usb.sh";
    benchmark = "$HOME/.scripts/tools/run_performance_benchmark.sh";
    record_terminal = "$HOME/.scripts/tools/run_record_terminal.sh";
    screenshot_ocr = "$HOME/.scripts/tools/run_screenshot_ocr.sh";
    network_diag = "$HOME/.scripts/tools/run_network_diagnostics.sh";
    system_diag = "$HOME/.scripts/tools/run_system_diagnostics.sh";
    system_migrate = "$HOME/.scripts/tools/run_system_migration.sh";
    watch_directory = "$HOME/.scripts/tools/run_watch_directory.sh";
    
    # Chrome with options
    chrome = "google-chrome-stable --ozone-platform=wayland";
  };
}