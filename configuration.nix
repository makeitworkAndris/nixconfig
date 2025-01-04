# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Budapest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "hu_HU.UTF-8";
    LC_IDENTIFICATION = "hu_HU.UTF-8";
    LC_MEASUREMENT = "hu_HU.UTF-8";
    LC_MONETARY = "hu_HU.UTF-8";
    LC_NAME = "hu_HU.UTF-8";
    LC_NUMERIC = "hu_HU.UTF-8";
    LC_PAPER = "hu_HU.UTF-8";
    LC_TELEPHONE = "hu_HU.UTF-8";
    LC_TIME = "hu_HU.UTF-8";
  };
  
  #hdd spin down by ID
  services.udev = {
    extraRules = ''
       ACTION=="add", SUBSYSTEM=="block", KERNEL=="sda", ENV{ID_SERIAL_SHORT}=="PK2334PCGZ1ZVB", RUN+="${pkgs.hdparm}/bin/hdparm -B 50 -S 60 /dev/sdb"
    '';
  };  
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "hu";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "hu";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  #Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.snow = {
    isNormalUser = true;
    description = "snow";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kate
      thunderbird
      discord
      prismlauncher #mc
      syncthing
      syncthingtray
      obsidian 
      #anki
      strawberry-qt6 #music
      filezilla #sftp
      #baobab #disk visualization
      genymotion #android emulator
      lutris
      vlc
      steam
      nicotine-plus
      (blender.override {
        cudaSupport = true;
      })
      gimp
      amarok #music player 2 -> gives recommendations
      notepadqq #notepad ++ kinda
      hdparm #config hdd-s
      smartmontools #check hdd status
      peek #screen to gif program
      megasync
     #librewolf
      samba
    ];
  };
  #anki or obsidian
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
  #steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.samba = {
  enable = true;
  securityType = "user";
  openFirewall = true;
  settings = {
    global = {
      "workgroup" = "WORKGROUP";
      "server string" = "smbnix";
      "netbios name" = "smbnix";
      "security" = "user";
      #"use sendfile" = "yes";
      #"max protocol" = "smb2";
      # note: localhost is the ipv6 localhost ::1
      "hosts allow" = "192.168.0.100 192.168.1.109 127.0.0.1 localhost";
      "hosts deny" = "0.0.0.0/0";
      "guest account" = "nobody";
      "map to guest" = "bad user";
    };
    "public" = {
      "path" = "/mnt/4TB/SweetieFox/";
      "browseable" = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "nobody";
     #"force group" = "nobgroup";
    };
  };
};
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.minidlna.enable = true;
  services.minidlna.openFirewall = true;
  services.minidlna.settings = {
    friendly_name = "NixOS_DLNA";
    media_dir = [
      "PV,/mnt/4TB/SweetieFox/"
    ];
   
    inotify = "yes";
    log_level = "error";
    announceInterval = 05;
  };
    users.users.minidlna = {
    extraGroups =
      [ "users" "samba" "wheel" "tolga" ]; # so minidlna can access the files.
    };
    

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "snow";

  # Install firefox.
  programs.firefox.enable = true;
 

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install java
  programs.java = { enable = true; package = pkgs.jdk21_headless; };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    git
    p7zip
    mouse_m908
  ];
  
  services.udev.packages = with pkgs; [ 
    mouse_m908
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080  445  139  8200];
  networking.firewall.allowedUDPPorts = [ 8080  137  138  8200];
  # Or dsable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?
  
  # Enable OpenGL
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
    #PCI settings
    hardware.nvidia.prime = {
	nvidiaBusId = "PCI:1:0:0";
    };
}
